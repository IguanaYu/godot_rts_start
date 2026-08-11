extends Node
## T3 升级管理器：处理 N 选 1 互斥 + 场景替换

# 已选定的升级：unit_type -> choice_id
var _selected: Dictionary = {}

# 升级数据：unit_type -> T3UpgradeData
var _upgrade_data: Dictionary = {}

signal t3_upgrade_confirmed(unit_type: int, choice_id: StringName)
signal t3_upgrade_visual_started(unit_type: int)

func _ready() -> void:
	_upgrade_data[0] = preload("res://resources/upgrades/t3_infantry.tres")  # SOLDIER
	_upgrade_data[1] = preload("res://resources/upgrades/t3_archer.tres")    # ARCHER
	_upgrade_data[2] = preload("res://resources/upgrades/t3_lancer.tres")    # LANCER
	_upgrade_data[3] = preload("res://resources/upgrades/t3_monk.tres")      # MONK

func get_upgrade_data(unit_type: int) -> Resource:
	return _upgrade_data.get(unit_type)

func is_completed(unit_type: int) -> bool:
	return _selected.has(unit_type)

func get_selected_choice(unit_type: int) -> StringName:
	return _selected.get(unit_type, &"")

## 玩家在弹窗里确认选择
func confirm_choice(unit_type: int, choice_id: StringName) -> void:
	if _selected.has(unit_type):
		push_warning("T3 升级已选定，不可更改: unit_type=%d" % unit_type)
		return
	_selected[unit_type] = choice_id
	t3_upgrade_confirmed.emit(unit_type, choice_id)
	# 0.5s 延时后触发场景替换
	await get_tree().create_timer(0.5).timeout
	t3_upgrade_visual_started.emit(unit_type)