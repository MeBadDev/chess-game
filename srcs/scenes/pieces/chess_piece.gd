@tool

extends TextureRect
class_name VisualChessPiece

@export var piece :Piece
@export var piece_size := 64

const PIECE_TEXTURE := {
	Piece.SIDE.WHITE:
		{
			Piece.TYPE.PAWN: preload("res://srcs/textures/White/Pawn White Outline 288px.png"),
			Piece.TYPE.ROOK: preload("res://srcs/textures/White/Rook White Outline 288px.png"),
			Piece.TYPE.KNIGHT: preload("res://srcs/textures/White/Knight White Outline 288px.png"),
			Piece.TYPE.BISHOP: preload("res://srcs/textures/White/Bishop White Outline 288px.png"),
			Piece.TYPE.QUEEN: preload("res://srcs/textures/White/Queen White Outline 288px.png"),
			Piece.TYPE.KING: preload("res://srcs/textures/White/King White Outline 288px.png"),
		},
	Piece.SIDE.BLACK:
		{
			Piece.TYPE.PAWN: preload("res://srcs/textures/Black/Pawn Black Outline 288px.png"),
			Piece.TYPE.ROOK: preload("res://srcs/textures/Black/Rook Black Outline 288px.png"),
			Piece.TYPE.KNIGHT: preload("res://srcs/textures/Black/Knight Black Outline 288px.png"),
			Piece.TYPE.BISHOP: preload("res://srcs/textures/Black/Bishop Black Outline 288px.png"),
			Piece.TYPE.QUEEN: preload("res://srcs/textures/Black/Queen Black Outline 288px.png"),
			Piece.TYPE.KING: preload("res://srcs/textures/Black/King Black Outline 288px.png"),
		}
}


func _get_configuration_warnings() -> PackedStringArray:
	var warnings :PackedStringArray = []
	if not piece:
		warnings.append("Piece is not assigned!")
	return warnings

func _ready() -> void:
	
	_update()

func _update():
	
	size = Vector2.ONE * piece_size
	if not piece:
		return
	
	if not piece.changed.is_connected(_update):
		piece.changed.connect(_update)

	var piece_texture :Texture2D= PIECE_TEXTURE[piece.piece_side][piece.piece_type]
	texture = piece_texture
