@tool

extends OpeningPosition

class_name SicilianNajdorf
func _init() -> void:
	name = "Sicilian Defense: Najdorf Variation"
	description = "wow najdorf sicilian i feel like a grandmaster just watching this"
	position = {
		Piece.SIDE.WHITE: {
			Piece.TYPE.PAWN: encode_arr_as_vec(["a2", "b2", "c2", "e4", "f2", "g2", "h2"]),
			Piece.TYPE.ROOK: encode_arr_as_vec(["a1", "h1"]),
			Piece.TYPE.KNIGHT: encode_arr_as_vec(["c3", "d4", "f3"]),
			Piece.TYPE.BISHOP: encode_arr_as_vec(["c1", "f1"]),
			Piece.TYPE.KING: encode_arr_as_vec(["e1"]),
			Piece.TYPE.QUEEN: encode_arr_as_vec(["d1"])
		},
		Piece.SIDE.BLACK: {
			Piece.TYPE.PAWN: encode_arr_as_vec(["a6", "b7", "d6", "e7", "f7", "g7", "h7"]),
			Piece.TYPE.ROOK: encode_arr_as_vec(["a8", "h8"]),
			Piece.TYPE.KNIGHT: encode_arr_as_vec(["b8", "f6"]),
			Piece.TYPE.BISHOP: encode_arr_as_vec(["c8", "f8"]),
			Piece.TYPE.KING: encode_arr_as_vec(["e8"]),
			Piece.TYPE.QUEEN: encode_arr_as_vec(["d8"])
		}
	}
