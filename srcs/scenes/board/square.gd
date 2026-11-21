@tool

extends ColorRect
class_name ChessboardSquare
var square_color: Color = Color.RED
var fade_in_time := 0.05
var fade_out_time := 0.1
var is_mouse_hovering := false:
	set(new_state):
		if new_state == is_mouse_hovering:
			return

		var tween := get_tree().create_tween()
		if new_state == true:
			tween.tween_property(self, "color", square_color.lightened(0.3), fade_in_time)
		else:
			tween.tween_property(self, "color", square_color, fade_out_time)
		
		is_mouse_hovering = new_state

func setup(new_size:float, new_color:Color):
	custom_minimum_size = Vector2.ONE * new_size
	color = new_color
	square_color = color

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(func(): is_mouse_hovering = true)
	mouse_exited.connect(func(): is_mouse_hovering = false)
