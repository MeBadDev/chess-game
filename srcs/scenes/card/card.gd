@tool
extends Control
class_name VisualCard

@export var card :Card

@export var jump_height_when_hovered := 50
@export var max_skew := Vector2.ONE * 0.05
@export var max_tilt_degrees := Vector2.ONE * 10
@export var hover_in_duration := 0.15
@export var hover_out_duration := 0.25
@export var skew_tween_duration := 0.16


@export var flip_duration := 0.5
@export var flip_peak_degrees := 85
var _flip_tween :Tween
var _is_flipping := false


var _hover_tween :Tween
var _skew_tween :Tween

@onready var mat :ShaderMaterial= $Visual/TextureRect.material 
var _active_side := Card.SIDE.BACK:
	set(new_side):
		_active_side = new_side
		_update()

@onready var _side_nodes :Dictionary[Card.SIDE, Panel] = {
	Card.SIDE.BACK: $Visual/SubViewport/BackSide,
	Card.SIDE.FRONT: $Visual/SubViewport/FrontSide
}

var _active_side_node :Panel
@onready var _visual := $Visual

var is_mouse_hovering := false:
	set(new_state):
		if new_state == is_mouse_hovering:
			return
		
		is_mouse_hovering = new_state

		if _hover_tween and _hover_tween.is_valid():
			_hover_tween.kill()
		_hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

		if is_mouse_hovering:
			var target_position := Vector2(0, -jump_height_when_hovered)
			_hover_tween.tween_property(_visual, "offset_transform_position", target_position, hover_in_duration)
		else:
			_hover_tween.tween_property(_visual, "offset_transform_position", Vector2.ZERO, hover_out_duration)
			_reset_skew_and_tilt()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings :PackedStringArray = []
	if not card:
		warnings.append("`card` is not assigned!")
	return warnings
func _ready() -> void:
	card.changed.connect(_update)
	mouse_entered.connect(func(): is_mouse_hovering = true)
	mouse_exited.connect(func(): is_mouse_hovering = false)
	_update()

func _reset_skew_and_tilt() -> void:
	if _flip_tween != null:
		if _flip_tween.is_running():
			return
	if mat == null:
		return

	if _skew_tween and _skew_tween.is_valid():
		_skew_tween.kill()

	_skew_tween = create_tween() \
		.set_parallel(true) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	_skew_tween.tween_method(
		func(val: Vector2) -> void: mat.set_shader_parameter("skew", val),
		mat.get_shader_parameter("skew") as Vector2,
		Vector2.ZERO,
		hover_out_duration
	)
	_skew_tween.tween_method(
		func(val: Vector2) -> void: mat.set_shader_parameter("tilt_degrees", val),
		mat.get_shader_parameter("tilt_degrees") as Vector2,
		Vector2.ZERO,
		hover_out_duration
	)

func _update():
	if not is_node_ready():
		return
	_active_side_node = _side_nodes[_active_side]
	
	$Visual/SubViewport/BackSide/MarginContainer/VBoxContainer/Label.text = card.name
	$Visual/SubViewport/BackSide/MarginContainer/VBoxContainer/Panel/Label2.text = card.description
	var backside_panel := $Visual/SubViewport/BackSide
	var style := backside_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color = card.back_color
	backside_panel.add_theme_stylebox_override("panel", style)
	$Visual/SubViewport/BackSide/MarginContainer/VBoxContainer/TextureRect.texture = card.graphics
	
	$Visual/SubViewport/FrontSide/MarginContainer/TextureRect.texture = card.front_graphics
	
	var viewport :SubViewport= $Visual/SubViewport

	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var shader :ShaderMaterial= $Visual/TextureRect.material
	shader.set_shader_parameter("viewport_tex", viewport.get_texture())
	
func flip() -> void:
	if _is_flipping or mat == null:
		return

	_is_flipping = true

	# Stop hover skew from fighting the flip
	if _skew_tween and _skew_tween.is_valid():
		_skew_tween.kill()

	var current_tilt := mat.get_shader_parameter("tilt_degrees") as Vector2
	if current_tilt == null:
		current_tilt = Vector2.ZERO

	var half_duration := flip_duration * 0.5
	var next_side := Card.SIDE.FRONT if _active_side == Card.SIDE.BACK else Card.SIDE.BACK
	var mid_tilt := Vector2(0.0, flip_peak_degrees)
	var entry_tilt := Vector2(0.0, -flip_peak_degrees)

	if _flip_tween and _flip_tween.is_valid():
		_flip_tween.kill()

	_flip_tween = create_tween()

	# 1. Rotate current side toward edge
	_flip_tween.tween_method(
		func(val: Vector2) -> void: mat.set_shader_parameter("tilt_degrees", val),
		current_tilt,
		mid_tilt,
		half_duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

	# 2. Swap side at the peak turn and start incoming face from the opposite side
	_flip_tween.tween_callback(func() -> void:
		_side_nodes[_active_side].hide()
		_side_nodes[next_side].show()
		_active_side = next_side
		_update()
		mat.set_shader_parameter("tilt_degrees", entry_tilt)
	)

	# 3. Swing new side back to flat
	_flip_tween.tween_method(
		func(val: Vector2) -> void: mat.set_shader_parameter("tilt_degrees", val),
		entry_tilt,
		Vector2.ZERO,
		half_duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	_flip_tween.finished.connect(func() -> void:
		_is_flipping = false
	, CONNECT_ONE_SHOT)
	
	_reset_skew_and_tilt()
func _process(_delta: float) -> void:
	
	if Engine.is_editor_hint():
		return
	if _is_flipping:
		return

	if not is_mouse_hovering or mat == null or size.x <= 0.0 or size.y <= 0.0:
		return
	_handle_skewing()
	if Input.is_action_just_pressed("flip_active_card"):
		flip()


func _handle_skewing():
	var mouse_pos := get_local_mouse_position()
	var norm := (mouse_pos / size) * 2.0 - Vector2.ONE # (-1, -1) to (1, 1)
	var inside := absf(norm.x) <= 1.0 and absf(norm.y) <= 1.0

	var target_skew := Vector2(norm.x * max_skew.x, norm.y * max_skew.y) if inside else Vector2.ZERO
	var target_tilt := Vector2(-norm.y * max_tilt_degrees.x, norm.x * max_tilt_degrees.y) if inside else Vector2.ZERO

	if _skew_tween and _skew_tween.is_valid():
		_skew_tween.kill()

	_skew_tween = create_tween() \
		.set_parallel(true) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	_skew_tween.tween_method(
		func(val: Vector2) -> void: mat.set_shader_parameter("skew", val),
		mat.get_shader_parameter("skew") as Vector2,
		target_skew,
		skew_tween_duration
	)
	_skew_tween.tween_method(
		func(val: Vector2) -> void: mat.set_shader_parameter("tilt_degrees", val),
		mat.get_shader_parameter("tilt_degrees") as Vector2,
		target_tilt,
		skew_tween_duration
	)
