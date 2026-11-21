@tool

extends Resource
class_name StartingPosition

@export var name := "Standard Opening Position"
@export var description := "The ancient position that every chess nerd knows and loves!"

var position : Dictionary[Piece.SIDE, Dictionary] = {
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

func _init() -> void:
	print(encode_as_vec("e5"))
func encode_arr_as_vec(arr: Array[String]) -> Array[Vector2i]:
	var vec_arr :Array[Vector2i] = []
	
	for pos in arr:
		vec_arr.append(encode_as_vec(pos))
	
	return vec_arr

func encode_as_vec(square: String) -> Vector2i:
	var x := (square[0] as String).unicode_at(0) - "a".unicode_at(0)
	var y := int(square[1]) - 1
	
	if x < 0 or x > 7 or y < 0 or y > 7:
		push_error("Out of range! got (%s, %s)" % [x, y])
		return Vector2i.ZERO

	return Vector2i(x, y)

## Rank is horizontal and starts on 0
func get_rank(rank: int) -> Array[Vector2i]:
	if rank < 0 or rank > 7:
		push_error("Out of range!")
		return []
	var arr :Array[Vector2i] = []
	
	for i in 8:
		arr.append(Vector2i(i, rank))
	
	return arr

## File is vertical and starts on 0
func get_file(file: int) -> Array[Vector2i]:
	if file < 0 or file > 7:
		push_error("Out of range!")
		return []
	var arr :Array[Vector2i] = []
	
	for i in 8:
		arr.append(Vector2i(file, i))
	
	return arr
