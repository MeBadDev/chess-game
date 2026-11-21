@tool

extends StartingPosition

class_name FoolsMate
func _init() -> void:
	name = "Fool's Mate"
	description = "how not to play chess"
	position = {
		Piece.SIDE.WHITE: {
			Piece.TYPE.PAWN: encode_arr_as_vec(["a2", "b2", "c2", "d2", "e2", "f3", "g4", "h2"]),
			Piece.TYPE.ROOK: encode_arr_as_vec(["a1", "h1"]),
			Piece.TYPE.KNIGHT: encode_arr_as_vec(["b1", "g1"]),
			Piece.TYPE.BISHOP: encode_arr_as_vec(["c1", "f1"]),
			Piece.TYPE.KING: encode_arr_as_vec(["e1"]),
			Piece.TYPE.QUEEN: encode_arr_as_vec(["d1"])
		},
		Piece.SIDE.BLACK: {
			Piece.TYPE.PAWN: encode_arr_as_vec(["a7", "b7", "c7", "d7", "e5", "f7", "g7", "h7"]),
			Piece.TYPE.ROOK: encode_arr_as_vec(["a8", "h8"]),
			Piece.TYPE.KNIGHT: encode_arr_as_vec(["b8", "g8"]),
			Piece.TYPE.BISHOP: encode_arr_as_vec(["c8", "f8"]),
			Piece.TYPE.KING: encode_arr_as_vec(["e8"]),
			Piece.TYPE.QUEEN: encode_arr_as_vec(["d8"])
		}
	}
