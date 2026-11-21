@tool

extends StartingPosition

class_name FourKnightsGame
func _init() -> void:
	name = "Four Knights Game: Italian Variation"
	description = "A classic symmetry variation! Probably the most common opening but I'm too lazy to fact check"
	position = {
		Piece.SIDE.WHITE: {
			Piece.TYPE.PAWN: encode_arr_as_vec(["a2", "b2", "c2", "d2", "e4", "f2", "g2", "h2"]),
			Piece.TYPE.ROOK: encode_arr_as_vec(["a1", "h1"]),
			Piece.TYPE.KNIGHT: encode_arr_as_vec(["c3", "f3"]),
			Piece.TYPE.BISHOP: encode_arr_as_vec(["c1", "c4"]),
			Piece.TYPE.KING: encode_arr_as_vec(["e1"]),
			Piece.TYPE.QUEEN: encode_arr_as_vec(["d1"])
		},
		Piece.SIDE.BLACK: {
			Piece.TYPE.PAWN: encode_arr_as_vec(["a7", "b7", "c7", "d7", "e5", "f7", "g7", "h7"]),
			Piece.TYPE.ROOK: encode_arr_as_vec(["a8", "h8"]),
			Piece.TYPE.KNIGHT: encode_arr_as_vec(["c6", "f6"]),
			Piece.TYPE.BISHOP: encode_arr_as_vec(["c8", "f8"]),
			Piece.TYPE.KING: encode_arr_as_vec(["e8"]),
			Piece.TYPE.QUEEN: encode_arr_as_vec(["d8"])
		}
	}
