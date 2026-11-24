extends Node


signal game_started
signal next_turn
signal card_activated
signal chess_piece_moved
signal game_ended(progress: GameState.PROGRESS)

var current_side := Piece.SIDE.WHITE
class GameState extends Resource:
	enum PROGRESS {
		CONTINUE,
		WHITE_WIN_BY_CHECKMATE,
		BLACK_WIN_BY_CHECKMATE,
		WHITE_WIN_ON_TIME,
		BLACK_WIN_ON_TIME,
		STALEMATE,
		DRAW_BY_AGREEMENT,
		ABORTED
	}
	
	var current_progress :PROGRESS = PROGRESS.CONTINUE
	var current_position :ChessPosition
	var end_condition: EndConditionCard
	var chess_move_left_this_turn := 1
	var deck := []
	
	var hand: Dictionary[Piece.SIDE, Array] = {
		Piece.SIDE.WHITE: [],
		Piece.SIDE.BLACK: []
	}
	
	var mana :Dictionary[Piece.SIDE, int] = {
		Piece.SIDE.WHITE: 0,
		Piece.SIDE.BLACK: 0
	}
	
	func draw(side: Piece.SIDE, amount: int):
		for i in amount:
			hand[side].append(deck.pop_back())

var current_game_state :GameState

func start():
	if current_game_state:
		push_error("There's already a game in progress!")
		return
	var game_state = GameState.new()
	game_state.current_position = get_catalogued_openings().pick_random().new()
	var deck :Array[EffectCard]= []
	deck.resize(15)
	deck.fill(EffectCard.new())
	deck.shuffle()
	
	game_state.deck = deck
	
	game_state.draw(Piece.SIDE.WHITE, 3)
	game_state.draw(Piece.SIDE.BLACK, 3)
	
	current_game_state = game_state
	game_started.emit()

func play_card(card: EffectCard):
	if not card in current_game_state.hand[current_side]:
		push_error("You don't have that card in hand!")
		return
	
	if current_game_state.mana[current_side] < card.mana_cost:
		push_error("You don't have enough mana to play that card!")
		return
	

	current_game_state = card.activate(current_game_state)
	current_game_state.mana[current_side] -= card.mana_cost
	current_game_state.hand[current_side].erase(card)
	card_activated.emit()


func validate_move(_piece_pos: Vector2i, _new_pos: Vector2i) -> bool:
	# placeholder
	return true

func play_move(piece_pos: Vector2i, new_pos: Vector2i):
	if not validate_move(piece_pos, new_pos):
		push_error("Illegal Move!")
		return
	
	if not current_game_state.chess_move_left_this_turn > 0:
		push_error("No more chess moves this turn!")
		return
	var piece_pos_dict := current_game_state.current_position.build_square_lookup()
	var piece_at_pos := piece_pos_dict[piece_pos]
	
	current_game_state.current_position.remove_piece(piece_pos).create_piece(new_pos,piece_at_pos.TYPE, piece_at_pos.SIDE)
	chess_piece_moved.emit()
	
	current_game_state.chess_move_left_this_turn -= 1
	
	if current_game_state.chess_move_left_this_turn <= 0:
		end_turn()
	
func stop_game():
	current_game_state = null

func end_turn():

	var next_progress := current_game_state.end_condition.check(current_game_state)
	current_game_state.current_progress = next_progress
	if next_progress != GameState.PROGRESS.CONTINUE:
		game_ended.emit(next_progress)
	
	current_game_state.chess_move_left_this_turn = 1
	current_side = Piece.SIDE.WHITE if current_side == Piece.SIDE.BLACK else Piece.SIDE.BLACK
	
	next_turn.emit()
func get_catalogued_openings() -> Array[GDScript]:
	return [
		OpeningPosition,
		FoolsMate,
		FourKnightsGame,
		SicilianNajdorf
	]
