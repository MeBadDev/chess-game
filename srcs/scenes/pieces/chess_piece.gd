@tool

extends Control
class_name VisualChessPiece

@export var piece :Piece:
	set(new_piece):
		piece = new_piece
		_update()
@export var piece_size := 64

@onready var texture_rect :TextureRect = $TextureRect
var fade_in_time := 0.08
var fade_out_time := 0.15
var is_mouse_hovering := false:
	set(new_state):
		if new_state == is_mouse_hovering:
			return

		var tween := get_tree().create_tween()
		if new_state == true:
			tween.parallel().tween_property(texture_rect, "scale", Vector2.ONE * 1.4, fade_in_time)
			tween.parallel().tween_property(texture_rect, "rotation_degrees", randf_range(-40, 40), fade_in_time)
		else:
			tween.parallel().tween_property(texture_rect, "scale", Vector2.ONE, fade_out_time)
			tween.parallel().tween_property(texture_rect, "rotation_degrees", 0, fade_in_time)
		
		is_mouse_hovering = new_state

const PIECE_TEXTURE := {
	Piece.SIDE.WHITE:
		{
			Piece.TYPE.PAWN: preload("res://srcs/textures/pieces/White/Pawn White Outline 288px.png"),
			Piece.TYPE.ROOK: preload("res://srcs/textures/pieces/White/Rook White Outline 288px.png"),
			Piece.TYPE.KNIGHT: preload("res://srcs/textures/pieces/White/Knight White Outline 288px.png"),
			Piece.TYPE.BISHOP: preload("res://srcs/textures/pieces/White/Bishop White Outline 288px.png"),
			Piece.TYPE.QUEEN: preload("res://srcs/textures/pieces/White/Queen White Outline 288px.png"),
			Piece.TYPE.KING: preload("res://srcs/textures/pieces/White/King White Outline 288px.png"),
		},
	Piece.SIDE.BLACK:
		{
			Piece.TYPE.PAWN: preload("res://srcs/textures/pieces/Black/Pawn Black Outline 288px.png"),
			Piece.TYPE.ROOK: preload("res://srcs/textures/pieces/Black/Rook Black Outline 288px.png"),
			Piece.TYPE.KNIGHT: preload("res://srcs/textures/pieces/Black/Knight Black Outline 288px.png"),
			Piece.TYPE.BISHOP: preload("res://srcs/textures/pieces/Black/Bishop Black Outline 288px.png"),
			Piece.TYPE.QUEEN: preload("res://srcs/textures/pieces/Black/Queen Black Outline 288px.png"),
			Piece.TYPE.KING: preload("res://srcs/textures/pieces/Black/King Black Outline 288px.png"),
		}
}


func _get_configuration_warnings() -> PackedStringArray:
	var warnings :PackedStringArray = []
	if not piece:
		warnings.append("Piece is not assigned!")
	return warnings

func _ready() -> void:
	_update()
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(func(): is_mouse_hovering = true)
	mouse_exited.connect(func(): is_mouse_hovering = false)

func _update():
	
	if not texture_rect:
		return
	size = Vector2.ONE * piece_size
	pivot_offset = size / 2
	
	texture_rect.custom_maximum_size = Vector2.ONE * piece_size
	texture_rect.pivot_offset = size / 2
	if not piece:
		return
	
	if not piece.changed.is_connected(_update):
		piece.changed.connect(_update)

	var piece_texture :Texture2D= PIECE_TEXTURE[piece.piece_side][piece.piece_type]
	texture_rect.texture = piece_texture
