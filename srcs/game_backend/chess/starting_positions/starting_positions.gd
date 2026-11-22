@tool

extends ChessPosition
class_name OpeningPosition

@export var name := "Standard Opening Position"
@export var description := "The ancient position that every chess nerd knows and loves!"



func _init() -> void:
	position = {
	Piece.SIDE.WHITE: {
		Piece.TYPE.PAWN: get_rank(1),
		Piece.TYPE.ROOK: encode_arr_as_vec(["a1", "h1"]),
		Piece.TYPE.KNIGHT: encode_arr_as_vec(["b1", "g1"]),
		Piece.TYPE.BISHOP: encode_arr_as_vec(["c1", "f1"]),
		Piece.TYPE.KING: encode_arr_as_vec(["e1"]),
		Piece.TYPE.QUEEN: encode_arr_as_vec(["d1"])
	},
	Piece.SIDE.BLACK: {
		Piece.TYPE.PAWN: get_rank(6),
		Piece.TYPE.ROOK: encode_arr_as_vec(["a8", "h8"]),
		Piece.TYPE.KNIGHT: encode_arr_as_vec(["b8", "g8"]),
		Piece.TYPE.BISHOP: encode_arr_as_vec(["c8", "f8"]),
		Piece.TYPE.KING: encode_arr_as_vec(["e8"]),
		Piece.TYPE.QUEEN: encode_arr_as_vec(["d8"])
	}
}
