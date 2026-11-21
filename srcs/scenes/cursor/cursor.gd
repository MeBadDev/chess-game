@tool
extends Control

enum STATE {
	POINTING,
	HAND_OPEN,
	HAND_CLOSED,
	WAITING
}

const cursor_texture :Dictionary[Input.CursorShape, Texture2D] = {
	Input.CursorShape.CURSOR_ARROW: preload("res://srcs/textures/cursor/kenney_cursor-pack/Vector/Outline/cursor_none.svg"),
	Input.CursorShape.CURSOR_DRAG: preload("res://srcs/textures/cursor/kenney_cursor-pack/Vector/Outline/hand_open.svg"),
	Input.CursorShape.CURSOR_CAN_DROP: preload("res://srcs/textures/cursor/kenney_cursor-pack/Vector/Outline/hand_closed.svg"),
	Input.CursorShape.CURSOR_BUSY: preload("res://srcs/textures/cursor/kenney_cursor-pack/Vector/Outline/busy_circle.svg"),
}

func _ready() -> void:
	for cursor_shape in cursor_texture:
		Input.set_custom_mouse_cursor(cursor_texture[cursor_shape], cursor_shape)
