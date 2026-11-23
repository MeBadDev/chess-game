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


## Returns a [code]Dictionary[Vector2i, Piece][/code] that maps position to piece
func build_square_lookup() -> Dictionary[Vector2i, Piece]:
	var lookup: Dictionary[Vector2i, Piece] = {}

	for side: Piece.SIDE in position:
		var by_type: Dictionary = position[side]
		for type: Piece.TYPE in by_type:
			var piece := Piece.create(type, side)
			var squares: Array[Vector2i] = by_type[type]
			for square: Vector2i in squares:
				lookup[square] = piece

	return lookup

## Returns a new ChessPosition with the piece at [param pos] removed.
## If no piece is at [param pos], returns a copy with the same pieces.
func remove_piece(pos: Vector2i) -> ChessPosition:
	if not _is_valid_square(pos):
		push_error("Position out of range: %s" % pos)
		return _clone()

	var next_pos := _clone()
	for side: Piece.SIDE in next_pos.position:
		var by_type: Dictionary = next_pos.position[side]
		for type: Piece.TYPE in by_type:
			var squares: Array[Vector2i] = by_type[type]
			var idx := squares.find(pos)
			if idx != -1:
				squares.remove_at(idx)
				return next_pos

	return next_pos


## Returns a new ChessPosition with a piece of [param piece_type] and [param piece_side]
## placed at [param pos]. If a piece already occupies [param pos], it is replaced.
func create_piece(pos: Vector2i, piece_type: Piece.TYPE, piece_side: Piece.SIDE) -> ChessPosition:
	if not _is_valid_square(pos):
		push_error("Position out of range: %s" % pos)
		return _clone()

	# Remove any existing piece on this square first so two pieces can't share a square
	var next_pos := remove_piece(pos)

	if not next_pos.position.has(piece_side):
		next_pos.position[piece_side] = {}

	var by_type: Dictionary = next_pos.position[piece_side]
	if not by_type.has(piece_type):
		var new_arr: Array[Vector2i] = []
		by_type[piece_type] = new_arr

	var squares: Array[Vector2i] = by_type[piece_type]
	if not squares.has(pos):
		squares.append(pos)

	return next_pos


func _is_valid_square(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x <= 7 and pos.y >= 0 and pos.y <= 7


func _clone() -> ChessPosition:
	var copy := ChessPosition.new()
	copy.side_to_move = side_to_move
	copy._en_passant_possible = _en_passant_possible
	copy.castling_right = castling_right.duplicate(true)

	var cloned_position: Dictionary[Piece.SIDE, Dictionary] = {}
	for side: Piece.SIDE in position:
		var inner_copy: Dictionary = {}
		var by_type: Dictionary = position[side]
		for type: Piece.TYPE in by_type:
			var squares: Array[Vector2i] = by_type[type]
			inner_copy[type] = squares.duplicate()
		cloned_position[side] = inner_copy

	copy.position = cloned_position
	return copy
