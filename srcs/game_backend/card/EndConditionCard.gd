extends Card
class_name EndConditionCard

func check(game_state) -> Game.GameState.PROGRESS:
	return Game.GameState.PROGRESS.CONTINUE
