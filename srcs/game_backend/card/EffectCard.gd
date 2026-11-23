extends Card
class_name EffectCard


@export var mana_cost := 1

func activate(game_state: Game.GameState) -> Game.GameState:
	return game_state
