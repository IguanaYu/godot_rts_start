class_name BonusObjectiveNoLosses
extends BonusObjective

var _player_units: Array = []
var _has_lost_any := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 记录初始玩家单位
	for unit in get_tree().get_nodes_in_group("player_units"):
		_player_units.append(unit)

	if _player_units.is_empty():
		# 初始无单位，失败
		_has_lost_any = true

func check() -> bool:
	if is_completed or _has_lost_any:
		return is_completed

	# 检查是否有玩家单位死亡
	for unit in _player_units:
		if not is_instance_valid(unit):
			_has_lost_any = true
			break
		if unit.has_method("is_dead") and unit.is_dead():
			_has_lost_any = true
			break

	if not _has_lost_any:
		_grant_reward()
		return true

	return false

func get_objective_text() -> Dictionary:
	return {
		"text": tr(description_key),
		"completed": is_completed
	}
