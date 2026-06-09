class_name VictoryCondition
extends Node

signal game_ended(result: String)  # "victory" or "defeat"
signal objective_updated            # UI 刷新信号
signal stage_advanced(stage: int, total: int)  # 多阶段用

@export var description_key: String = ""  # 翻译key，用于UI显示
@export var is_hidden: bool = false       # 是否对玩家隐藏（不显示在目标面板）

var game_controller: Node = null  # main.gd 传入 self，用于访问 gold/add_gold 等

## Check the game state
## Returns: 0 = ongoing, 1 = victory, 2 = defeat
func check() -> int:
	return 0

## 返回目标列表供 UI 显示
## 格式: [{"text": String, "progress": String, "state": int}]
## state: 0=进行中, 1=完成, 2=失败
func get_objectives() -> Array[Dictionary]:
	return []

## 进度条用，返回 0.0-1.0
## -1.0 表示无进度条
func get_progress_fraction() -> float:
	return -1.0

## 重置状态（多阶段切换时用）
func reset() -> void:
	pass

func set_game_controller(gc: Node) -> void:
	game_controller = gc

func _emit_victory() -> void:
	game_ended.emit("victory")

func _emit_defeat() -> void:
	game_ended.emit("defeat")
