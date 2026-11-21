@tool
extends Control
@export var square_size := 32:
	set(new_value):
		square_size = new_value
		_update_ui()

@export var dark_square_color :Color
@export var light_square_color :Color

@onready var background_grid :GridContainer = $Background

var square_scene := preload("res://srcs/scenes/board/square.tscn")
func _ready() -> void:
	_update_ui()

func _free_all_child(node: Node):
	for childs in node.get_children():
		childs.queue_free()

func _update_ui():
	if not background_grid:
		return
	_free_all_child(background_grid)
	custom_minimum_size = Vector2.ONE * square_size * 8
	for x in 8:
		for y in 8:
			var new_square :ChessboardSquare = square_scene.instantiate()
			background_grid.add_child(new_square)
			var square_color := dark_square_color
			var is_light_square := ((x + y) % 2 == 0)

			if is_light_square:
				square_color = light_square_color

			new_square.setup(square_size, square_color)
