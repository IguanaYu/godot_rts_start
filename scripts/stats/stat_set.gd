extends RefCounted
## 运行时属性计算引擎，无 class_name，通过 preload 使用
## 公式：final_value = (base + sum(flat)) * product(multipliers)

# 属性名常量
const MAX_HP := "max_hp"
const ATTACK_DAMAGE := "attack_damage"
const ATTACK_RANGE := "attack_range"
const ATTACK_COOLDOWN := "attack_cooldown"
const MOVE_SPEED := "move_speed"
const DAMAGE_REDUCTION := "damage_reduction"
const HEAL_RANGE := "heal_range"
const HEAL_AMOUNT := "heal_amount"
const HEAL_COOLDOWN := "heal_cooldown"
const HEAL_SCAN_RANGE := "heal_scan_range"

const ALL := [MAX_HP, ATTACK_DAMAGE, ATTACK_RANGE, ATTACK_COOLDOWN, MOVE_SPEED,
	DAMAGE_REDUCTION, HEAL_RANGE, HEAL_AMOUNT, HEAL_COOLDOWN, HEAL_SCAN_RANGE]

var _base_data  # UnitStats Resource（duck typing）
var _modifiers: Array = []
var _cached: Dictionary = {}
var _dirty: bool = true


func _init(base_data) -> void:
	_base_data = base_data
	recalculate()


func _get_base(stat_name: String) -> float:
	var d = _base_data
	match stat_name:
		MAX_HP: return float(d.max_hp)
		ATTACK_DAMAGE: return float(d.attack_damage)
		ATTACK_RANGE: return d.attack_range
		ATTACK_COOLDOWN: return d.attack_cooldown
		MOVE_SPEED: return d.move_speed
		DAMAGE_REDUCTION: return d.damage_reduction
		HEAL_RANGE: return d.heal_range
		HEAL_AMOUNT: return float(d.heal_amount)
		HEAL_COOLDOWN: return d.heal_cooldown
		HEAL_SCAN_RANGE: return d.heal_scan_range
	return 0.0


func add_modifier(source_id: String, stat_name: String, flat: float = 0.0, mult: float = 1.0) -> void:
	for i in range(_modifiers.size() - 1, -1, -1):
		if _modifiers[i]["source_id"] == source_id and _modifiers[i]["stat_name"] == stat_name:
			_modifiers[i] = {"source_id": source_id, "stat_name": stat_name, "flat": flat, "multiplier": mult}
			_dirty = true
			return
	_modifiers.append({"source_id": source_id, "stat_name": stat_name, "flat": flat, "multiplier": mult})
	_dirty = true


func remove_source(source_id: String) -> void:
	for i in range(_modifiers.size() - 1, -1, -1):
		if _modifiers[i]["source_id"] == source_id:
			_modifiers.remove_at(i)
			_dirty = true


func recalculate() -> void:
	_cached.clear()
	for sn in ALL:
		var base_val = _get_base(sn)
		var total_flat = 0.0
		var total_mult = 1.0
		for m in _modifiers:
			if m["stat_name"] == sn:
				total_flat += m["flat"]
				total_mult *= m["multiplier"]
		_cached[sn] = (base_val + total_flat) * total_mult
	_dirty = false


func get_value(stat_name: String) -> float:
	if _dirty:
		recalculate()
	return _cached.get(stat_name, 0.0)


func get_int(stat_name: String) -> int:
	return int(get_value(stat_name))


func get_base_data():
	return _base_data
