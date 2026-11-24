extends Card
class_name EndConditionCard

func check(_game_state) -> Game.GameState.PROGRESS:
	return Game.GameState.PROGRESS.CONTINUE
