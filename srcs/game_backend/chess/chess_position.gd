extends Resource


## Helper class that handles everything on a chess position, including things like castling and en passant.
## Repetition is not implemented.
class_name ChessPosition

## The chess position, as Dictionary[Piece.SIDE,Dictionary[Piece.TYPE,Array[Vector2i]]]
## typed as Dictionary[Piece.SIDE, Dictionary] because Godot doesn't currently support nested typing
var position :Dictionary[Piece.SIDE, Dictionary]

## Which side makes the next move
var side_to_move :Piece.SIDE = Piece.SIDE.WHITE

## Which side can castle
var castling_right :Dictionary[Piece.SIDE, Dictionary] = {
	Piece.SIDE.WHITE: {
		Piece.BOARD_SIDE.KING_SIDE: true,
		Piece.BOARD_SIDE.QUEEN_SIDE: true,
	},
	Piece.SIDE.BLACK: {
		Piece.BOARD_SIDE.KING_SIDE: true,
		Piece.BOARD_SIDE.QUEEN_SIDE: true,
	}
}

## How many turns it has been since the start of the match. This variable increase every time a player has finished their move.
var turn := 0:
	set(new_turn):
		turn = new_turn
		fullmove = turn / 2

## How many round it has been since the start of the match. This variable increase once when both player has finished their move.
var fullmove := 0

# since only 1 pawn can be en passanted, we can store that as a single int
var _en_passant_possible :int = -1

## Returns whether en passant is possible on a certain rank.
## Will return true on the file where the pawn moved 2 squares, regardless of whether it's capturable or not.
func is_en_passant_possible(file: int) -> bool:
	return _en_passant_possible == file


## Mark en passant as possible, after a pawn from the starting position has haved forward 2 squares.
func mark_en_passant_possible(file: int, possible: bool = true) -> void:
	if file < 0 or file > 7:
		push_error("Out of range!")
	
	if not possible:
		_en_passant_possible = -1
		return
	_en_passant_possible = file

## Mark en passant as impossible.
func mark_en_passant_impossible() -> void:
	_en_passant_possible = -1


## Encode standard algebra notation position to [code]Array[Vector2i][/code]
## [codeblock]
## print(encode_arr_as_vec(["a1", "b1", "e5"])) # [Vector2i(0, 0), Vector2i(1, 0), Vector2i(4, 4)]
## [/codeblock]
static func encode_arr_as_vec(arr: Array[String]) -> Array[Vector2i]:
	var vec_arr :Array[Vector2i] = []
	
	
	for pos in arr:
		vec_arr.append(encode_as_vec(pos))
	
	return vec_arr

## Encode a PGN position string to Vector2i. Returns Vector2i(-1,-1) if invalid input.
## [codeblock]
## print(encode_as_vec("e4")) # Vector2i(4, 3)
## [/codeblock]
static func encode_as_vec(square: String) -> Vector2i:
	if len(square) != 2:
		push_error("Length of square string must be 2!")
		return -Vector2i.ONE
	var x := square[0].unicode_at(0) - "a".unicode_at(0)
	var y := int(square[1]) - 1
	
	if x < 0 or x > 7 or y < 0 or y > 7:
		push_error("Out of range! got (%s, %s)" % [x, y])
		return -Vector2i.ONE

	return Vector2i(x, y)

## Returns every square on a rank as [code]Array[Vector2i][/code]
## Rank is horizontal and starts on 0
static func get_rank(rank: int) -> Array[Vector2i]:
	if rank < 0 or rank > 7:
		push_error("Out of range!")
		return []
	var arr :Array[Vector2i] = []
	
	for i in 8:
		arr.append(Vector2i(i, rank))
	
	return arr

## Returns every square on a file as [code]Array[Vector2i][/code]
## File is vertical and starts on 0
static func get_file(file: int) -> Array[Vector2i]:
	if file < 0 or file > 7:
		push_error("Out of range!")
		return []
	var arr :Array[Vector2i] = []
	
	for i in 8:
		arr.append(Vector2i(file, i))
	
	return arr
