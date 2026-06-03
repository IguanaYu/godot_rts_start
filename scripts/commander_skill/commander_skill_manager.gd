extends Node
## 指挥官技能管理器：能量系统、冷却管理、释放流程

const SD := preload("res://scripts/commander_skill/commander_skill_data.gd")
const UnitScript := preload("res://scripts/units/unit.gd")

signal energy_changed(current: float, max_energy: float)
signal skill_cooldown_updated(skill_id: int, remaining: float, total: float)
signal skill_cast_started(skill_id: int, cast_type: int, radius: float)
signal skill_cast_cancelled
signal skill_cast_completed(skill_id: int)

var energy: float = SD.MAX_ENERGY
var cooldowns: Dictionary = {}  # skill_id -> remaining seconds
var active_skill: int = -1  # 当前选择中的技能
var available_skills: Array = []  # 可用技能列表

var _main_node: Node2D
var _spawner_module: Node
var _gold_getter: Callable  # 获取当前金币的回调
var _gold_spend: Callable   # 扣除金币的回调


func initialize(main_node: Node2D, spawner_module: Node, gold_getter: Callable, gold_spend: Callable) -> void:
	_main_node = main_node
	_spawner_module = spawner_module
	_gold_getter = gold_getter
	_gold_spend = gold_spend


func set_available_skills(skills: Array) -> void:
	available_skills = skills
	for skill_id in skills:
		cooldowns[skill_id] = 0.0


func get_skill_config(skill_id: int) -> Dictionary:
	return SD.SKILL_CONFIGS.get(skill_id, {})


func can_cast(skill_id: int) -> bool:
	if not available_skills.has(skill_id):
		return false
	if cooldowns.get(skill_id, 0.0) > 0.0:
		return false
	var config: Dictionary = SD.SKILL_CONFIGS[skill_id]
	var cost_type: int = config.get("cost_type", SD.CostType.ENERGY)
	var cost: int = config.get("cost", 0)
	if cost_type == SD.CostType.ENERGY:
		return energy >= cost
	else:
		return _gold_getter.call() >= cost


func start_cast(skill_id: int) -> bool:
	if not can_cast(skill_id):
		return false
	active_skill = skill_id
	var config: Dictionary = SD.SKILL_CONFIGS[skill_id]
	var cast_type: int = config.get("cast_type", SD.CastType.INSTANT)
	var radius: float = config.get("radius", 0.0)

	if cast_type == SD.CastType.INSTANT:
		confirm_cast(Vector2.ZERO)
		return true

	skill_cast_started.emit(skill_id, cast_type, radius)
	return true


func confirm_cast(target_pos: Vector2) -> void:
	if active_skill < 0:
		return
	var skill_id: int = active_skill
	var config: Dictionary = SD.SKILL_CONFIGS[skill_id]
	var cost_type: int = config.get("cost_type", SD.CostType.ENERGY)
	var cost: int = config.get("cost", 0)

	# 再次检查（可能状态已变）
	if cost_type == SD.CostType.ENERGY:
		if energy < cost:
			cancel_cast()
			return
		energy -= cost
		energy_changed.emit(energy, SD.MAX_ENERGY)
	else:
		if _gold_getter.call() < cost:
			cancel_cast()
			return
		_gold_spend.call(cost)

	# 开始冷却
	cooldowns[skill_id] = config.get("cooldown", 0.0)

	# 执行效果
	_execute_skill(skill_id, target_pos)

	active_skill = -1
	skill_cast_completed.emit(skill_id)


func cancel_cast() -> void:
	if active_skill < 0:
		return
	active_skill = -1
	skill_cast_cancelled.emit()


func is_casting() -> bool:
	return active_skill >= 0


func get_active_skill() -> int:
	return active_skill


func _process(delta: float) -> void:
	# 能量回复
	if energy < SD.MAX_ENERGY:
		energy = minf(energy + SD.ENERGY_REGEN_RATE * delta, SD.MAX_ENERGY)
		energy_changed.emit(energy, SD.MAX_ENERGY)

	# 冷却递减
	for skill_id in cooldowns:
		if cooldowns[skill_id] > 0.0:
			cooldowns[skill_id] = maxf(0.0, cooldowns[skill_id] - delta)
			skill_cooldown_updated.emit(skill_id, cooldowns[skill_id], SD.SKILL_CONFIGS[skill_id].get("cooldown", 0.0))


func _execute_skill(skill_id: int, target_pos: Vector2) -> void:
	const SkillEffects := preload("res://scripts/commander_skill/skill_effects.gd")
	match skill_id:
		SD.SkillId.ORBITAL_STRIKE:
			SkillEffects.orbital_strike(_main_node, _spawner_module, target_pos, SD.SKILL_CONFIGS[skill_id])
		SD.SkillId.HEAL_FIELD:
			SkillEffects.heal_field(_main_node, _spawner_module, target_pos, SD.SKILL_CONFIGS[skill_id])
		SD.SkillId.SHIELD_WALL:
			SkillEffects.shield_wall(_main_node, _spawner_module, target_pos, SD.SKILL_CONFIGS[skill_id])
		SD.SkillId.UNIT_DROP:
			SkillEffects.unit_drop(_main_node, _spawner_module, target_pos, SD.SKILL_CONFIGS[skill_id])
