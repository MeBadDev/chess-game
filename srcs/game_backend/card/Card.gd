@tool

extends Resource
class_name Card

@export var front_graphics :Texture2D = preload("res://srcs/textures/card/prototype_front.png"):
	set(new):
		front_graphics = new
		emit_changed()

@export var name := "Card":
	set(new_name):
		name = new_name
		emit_changed()
@export_multiline() var description := "Description":
	set(new_description):
		description = new_description
		emit_changed()
@export var graphics :Texture2D= preload("res://srcs/textures/pieces/White/King White 288px.png"):
	set(new_graphics):
		graphics = new_graphics
		emit_changed()

@export var back_color :Color:
	set(new_color):
		back_color = new_color
		emit_changed()

enum SIDE {
	FRONT,
	BACK,
}
