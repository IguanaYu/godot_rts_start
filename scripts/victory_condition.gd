class_name VictoryCondition
extends Node

signal game_ended(result: String)  # "victory" or "defeat"

## Check the game state
## Returns: 0 = ongoing, 1 = victory, 2 = defeat
func check() -> int:
	return 0

func _emit_victory() -> void:
	game_ended.emit("victory")

func _emit_defeat() -> void:
	game_ended.emit("defeat")
