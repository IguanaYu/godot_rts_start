class_name SummonLifecycle
extends Node

## 封装召唤兵完整生命周期:人口检查 + 生成 + 计时死亡 + 人口释放。
## 复用 game_spawner.spawn_summon() 生成;玩家方召唤物不加 AI,靠 Unit GUARD 自动战斗。

var spawner  # game_spawner 引用
var pop_manager: PopulationManager

func initialize(spawner_module, pop_mgr: PopulationManager) -> void:
	spawner = spawner_module
	pop_manager = pop_mgr

func summon(stats_id: StringName, pos: Vector2, team: int, lifetime: float) -> Unit:
	# 1. 人口检查
	if not pop_manager.can_summon(1):
		return null
	# 2. 生成单位(复用 game_spawner.spawn_summon L454)
	var unit: Unit = spawner.spawn_summon(0, stats_id, pos, team)
	if unit == null:
		return null
	# 3. 占人口
	pop_manager.add(1)
	# 4. 连死亡信号 → 释放人口
	unit.died.connect(_on_summon_died)
	# 5. 生命周期计时器 → 到时 die()
	if lifetime > 0:
		var t := Timer.new()
		t.wait_time = lifetime
		t.one_shot = true
		t.autostart = true
		var captured_unit := unit
		t.timeout.connect(func():
			if is_instance_valid(captured_unit):
				captured_unit.die()  # unit.gd:1210
		)
		add_child(t)
	return unit

func _on_summon_died(_unit: Unit) -> void:
	pop_manager.remove(1)
