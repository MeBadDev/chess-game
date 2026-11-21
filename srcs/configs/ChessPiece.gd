@tool 
extends Resource
class_name Piece


enum SIDE {
	WHITE,
	BLACK,
}

enum TYPE {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	KING,
	QUEEN
}

const VALUE :Dictionary[TYPE, int] = {
	TYPE.PAWN: 1,
	TYPE.ROOK: 5,
	TYPE.KNIGHT: 3,
	TYPE.BISHOP: 3,
	TYPE.QUEEN: 9
}


@export var piece_type: TYPE:
	set(new_type):
		piece_type = new_type
		changed.emit()
@export var piece_side: SIDE:
	set(new_side):
		piece_side = new_side
		changed.emit()


static func create(type: TYPE, side: SIDE):
	var new_piece := Piece.new()
	new_piece.piece_type = type
	new_piece.side = side
	
	return new_piece
