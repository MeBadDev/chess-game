@tool
extends Control
@export var square_size := 32:
	set(new_value):
		square_size = new_value
		_update_ui()

@export var dark_square_color :Color:
	set(new_color):
		dark_square_color = new_color
		_update_ui()
@export var light_square_color :Color:
	set(new_color):
		light_square_color = new_color
		_update_ui()

@export var opening_position:= OpeningPosition.new():
	set(new_opening_pos):
		opening_position = new_opening_pos
		_update_ui()

@onready var background_grid :GridContainer = $Background

var square_scene := preload("res://srcs/scenes/board/square.tscn")
var piece_node_scene := preload("res://srcs/scenes/pieces/ChessPiece.tscn")
func _ready() -> void:
	_update_ui()
	


func _free_all_child(node: Node):
	if not node:
		return
	for childs in node.get_children():
		childs.queue_free()

func _update_background_squares():
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

func _setup_starting_position():
	if not opening_position:
		return
	if get_node_or_null("Pieces") == null:
		return
	_free_all_child($Pieces)
	
	var starting_pos := opening_position.position
	
	for side: Piece.SIDE in starting_pos:
		for types: Piece.TYPE in starting_pos[side]:
			for pos: Vector2i in starting_pos[side][types]:
				create_piece(types, side, pos)

func create_piece(piece_type: Piece.TYPE, piece_side: Piece.SIDE, piece_pos: Vector2i):
	if get_node_or_null("Pieces") == null:
		return
	var piece := Piece.create(piece_type, piece_side)
	var piece_node :VisualChessPiece= piece_node_scene.instantiate()
	piece_node.piece_size = square_size
	piece_node.piece = piece
	
	piece_node.position = Vector2(piece_pos.x * square_size, (7 - piece_pos.y) * square_size)
	$Pieces.add_child(piece_node)

func _update_ui():
	_update_background_squares()
	_setup_starting_position()
