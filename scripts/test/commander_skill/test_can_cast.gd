extends RefCounted
## 指挥官技能 can_cast 逻辑测试（Layer 1：纯逻辑，不需要场景树）

const SD := preload("res://scripts/commander_skill/commander_skill_data.gd")


func run(a: RefCounted, _runner: Node) -> void:
	_test_unavailable_skill_returns_false(a)
	_test_on_cooldown_returns_false(a)
	_test_insufficient_energy_returns_false(a)
	_test_insufficient_gold_returns_false(a)
	_test_sufficient_energy_returns_true(a)
	_test_sufficient_gold_returns_true(a)
	_test_zero_cost_always_castable(a)


func _create_manager(test_gold: int = 1000) -> Node:
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/commander_skill/commander_skill_manager.gd"))
	mgr.initialize(null, null, func(): return test_gold, func(c): test_gold -= c)
	return mgr


func _test_unavailable_skill_returns_false(a: RefCounted) -> void:
	var mgr := _create_manager()
	mgr.set_available_skills([SD.SkillId.ORBITAL_STRIKE])
	# HEAL_FIELD 不在可用列表里
	var result: bool = mgr.can_cast(SD.SkillId.HEAL_FIELD)
	a.assert_false(result, "不可用技能返回 false")
	mgr.queue_free()


func _test_on_cooldown_returns_false(a: RefCounted) -> void:
	var mgr := _create_manager()
	mgr.set_available_skills([SD.SkillId.ORBITAL_STRIKE])
	mgr.cooldowns[SD.SkillId.ORBITAL_STRIKE] = 5.0
	var result: bool = mgr.can_cast(SD.SkillId.ORBITAL_STRIKE)
	a.assert_false(result, "冷却中返回 false")
	mgr.queue_free()


func _test_insufficient_energy_returns_false(a: RefCounted) -> void:
	var mgr := _create_manager()
	mgr.set_available_skills([SD.SkillId.ORBITAL_STRIKE])
	mgr.energy = 10.0  # ORBITAL_STRIKE cost=40
	var result: bool = mgr.can_cast(SD.SkillId.ORBITAL_STRIKE)
	a.assert_false(result, "能量不足返回 false")
	mgr.queue_free()


func _test_insufficient_gold_returns_false(a: RefCounted) -> void:
	var test_gold := 100  # UNIT_DROP cost=300
	var mgr := _create_manager(test_gold)
	mgr.set_available_skills([SD.SkillId.UNIT_DROP])
	var result: bool = mgr.can_cast(SD.SkillId.UNIT_DROP)
	a.assert_false(result, "金币不足返回 false")
	mgr.queue_free()


func _test_sufficient_energy_returns_true(a: RefCounted) -> void:
	var mgr := _create_manager()
	mgr.set_available_skills([SD.SkillId.ORBITAL_STRIKE])
	mgr.energy = 50.0  # cost=40
	var result: bool = mgr.can_cast(SD.SkillId.ORBITAL_STRIKE)
	a.assert_true(result, "能量充足返回 true")
	mgr.queue_free()


func _test_sufficient_gold_returns_true(a: RefCounted) -> void:
	var test_gold := 500  # UNIT_DROP cost=300
	var mgr := _create_manager(test_gold)
	mgr.set_available_skills([SD.SkillId.UNIT_DROP])
	var result: bool = mgr.can_cast(SD.SkillId.UNIT_DROP)
	a.assert_true(result, "金币充足返回 true")
	mgr.queue_free()


func _test_zero_cost_always_castable(a: RefCounted) -> void:
	var mgr := _create_manager()
	mgr.set_available_skills([SD.SkillId.SUPPLY_DROP])
	mgr.energy = 0.0  # SUPPLY_DROP cost=0
	var result: bool = mgr.can_cast(SD.SkillId.SUPPLY_DROP)
	a.assert_true(result, "零耗能技能在 0 能量时可放")
	mgr.queue_free()
