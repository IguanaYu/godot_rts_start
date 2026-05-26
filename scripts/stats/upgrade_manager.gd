extends RefCounted
## 升级管理器，可选组件——没有此组件的单位不具备成长能力
## 无 class_name，通过 preload 使用

var _stat_set  # StatSet 引用（duck typing）
var _level: int = 0
var _max_level: int = 3
var _cost_per_level: int = 200


func _init(stat_set) -> void:
	_stat_set = stat_set


func setup_from_data(data) -> void:
	if data == null:
		return
	_max_level = data.max_upgrade_level
	_cost_per_level = data.upgrade_cost
	# max_upgrade_level == 0 表示此单位不可升级
	if _max_level <= 0:
		_stat_set = null


func can_upgrade() -> bool:
	return _stat_set != null and _level < _max_level


func get_upgrade_cost() -> int:
	return _cost_per_level


func get_level() -> int:
	return _level


func get_max_level() -> int:
	return _max_level


func apply_upgrade() -> bool:
	if not can_upgrade():
		return false
	_level += 1
	_update_modifiers()
	return true


func _update_modifiers() -> void:
	if _stat_set == null:
		return
	var data = _stat_set.get_base_data()
	var SN = preload("res://scripts/stats/stat_set.gd")
	_stat_set.remove_source("upgrade")
	if _level <= 0:
		return
	_stat_set.add_modifier("upgrade", SN.MAX_HP, float(data.upgrade_hp_per_level * _level))
	_stat_set.add_modifier("upgrade", SN.ATTACK_DAMAGE, float(data.upgrade_damage_per_level * _level))
	_stat_set.add_modifier("upgrade", SN.MOVE_SPEED, float(data.upgrade_speed_per_level * _level))
