@tool
class_name OutpostCommander
extends Node2D
## 据点敌人指挥官节点（设计师在场景中放置）
## - 编辑器：画领地圆圈（实线红 + 中心标记 + 半径标尺），所见即所得
## - 运行时：visible = false，由 OutpostCommanderManager 周期 tick 触发决策
##
## 失败条件：圈内所有敌方建筑被摧毁 → queue_free（指挥官本身不可选中、不可攻击）

const OutpostCommanderConfigClass := preload("res://scripts/outpost/outpost_commander_config.gd")
const SpellEffectsRef := preload("res://scripts/outpost/outpost_spell_effects.gd")
const StrategyEffectsRef := preload("res://scripts/outpost/outpost_strategy_effects.gd")

# 法术默认参数（可被 config.spell_overrides 覆盖）
const DEFAULT_SPELL_PARAMS := {
	&"heal": {"cost": 30.0, "cooldown": 20.0, "radius": 100.0, "heal_amount": 50},
	&"shield": {"cost": 40.0, "cooldown": 35.0, "duration": 12.0, "max_hp_bonus": 0.5},
	&"inspire": {"cost": 35.0, "cooldown": 25.0, "radius": 120.0, "attack_speed_bonus": 0.5, "move_speed_bonus": 0.3, "duration": 8.0},
	&"call_to_arms": {"cost": 50.0, "cooldown": 40.0, "search_radius": 400.0, "count_per_building": 1},
	&"release_garrison": {"cost": 25.0, "cooldown": 30.0, "search_radius": 400.0},
}

# 策略默认消耗（可被 config.strategy_overrides 覆盖）
const DEFAULT_STRATEGY_COSTS := {
	&"attack": {"sp": 1, "gold": 0},
	&"coordinate": {"sp": 2, "gold": 0},
	&"defend": {"sp": 1, "gold": 100},
	&"expand": {"sp": 3, "gold": 300},
}

@export var config: OutpostCommanderConfig = null:
	set(v):
		config = v
		queue_redraw()

# === 运行时状态（不 @export）===
var mana: float = 0.0
var gold: int = 0
var strategy_points: float = 0.0
var current_strategy: StringName = &"defend"
var spell_cooldowns: Dictionary = {}  # {StringName spell_id: float remaining_sec}
var _tick_accumulator: float = 0.0
var _is_registered: bool = false
var _last_strategy_eval_msec: int = -10000


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	visible = false
	if config != null:
		mana = config.mana_max
		gold = config.gold_max
		strategy_points = float(config.strategy_max)
	_register_to_manager()


func _register_to_manager() -> void:
	var main_node := get_tree().current_scene
	if main_node == null:
		call_deferred("_register_to_manager")
		return
	var manager = main_node.get_node_or_null("OutpostCommanderManager")
	if manager == null:
		call_deferred("_register_to_manager")
		return
	if manager.has_method("register_commander"):
		manager.register_commander(self)
		_is_registered = true


# ============================================================
# 编辑器可视化
# ============================================================
func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var radius: float = 350.0
	if config != null:
		radius = config.territory_radius
	# 实线领地圈
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(1.0, 0.3, 0.3, 0.7), 2.0)
	# 半透明填充
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.3, 0.3, 0.08))
	# 中心标记
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.5, 0.5, 0.9))
	# 半径标尺
	draw_line(Vector2.ZERO, Vector2(radius, 0), Color(1.0, 0.8, 0.3, 0.6), 1.5)


# ============================================================
# Manager 周期调用
# ============================================================
func tick(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if config == null:
		return
	_regen_resources(delta)
	_tick_accumulator += delta
	if _tick_accumulator < 1.0:
		return
	_tick_accumulator = 0.0
	_on_decision_tick()


func _regen_resources(delta: float) -> void:
	mana = minf(mana + (config.mana_max / 60.0) * delta, config.mana_max)
	gold = mini(int(gold + config.gold_regen * delta), config.gold_max)
	strategy_points = minf(strategy_points + config.strategy_regen * delta, float(config.strategy_max))
	# 法术冷却递减
	var expired: Array = []
	for spell_id in spell_cooldowns.keys():
		spell_cooldowns[spell_id] = float(spell_cooldowns[spell_id]) - delta
		if float(spell_cooldowns[spell_id]) <= 0.0:
			expired.append(spell_id)
	for spell_id in expired:
		spell_cooldowns.erase(spell_id)


# 完整决策树：失败检测 → forced 策略 → 法术优先级 → 策略决策（5s 节流）
func _on_decision_tick() -> void:
	var buildings := _get_managed_buildings()
	var units := _get_managed_units()

	# 失败检测：圈内无敌方建筑 → 据点消灭
	if buildings.is_empty():
		print("[OutpostCommander:%s] 圈内无敌方建筑, 据点消灭" % _uid_str())
		_despawn()
		return

	# 强制策略：跳过决策树，直接执行（不消耗资源，仅下达命令）
	if config.forced_strategy != &"":
		_try_execute_strategy(config.forced_strategy, true)
		return

	# 局势评估
	var threat: int = _assess_threat()
	var attacked_buildings: int = _count_attacked_buildings(buildings)
	var buildings_alive: int = buildings.size()
	var mana_full: bool = mana >= config.mana_max * 0.8

	# 法术优先级（瞬时反应，优先于策略）
	var spell_cast: StringName = _pick_and_cast_spell(threat, attacked_buildings, buildings, units, mana_full)

	# 策略决策（5s 节流，避免抖动）
	var now_msec: int = Time.get_ticks_msec()
	if now_msec - _last_strategy_eval_msec >= 5000:
		_last_strategy_eval_msec = now_msec
		var strat := _pick_strategy(threat, buildings_alive, mana_full)
		if strat != &"":
			_try_execute_strategy(strat, false)

	# 周期日志（带星号标记本次 tick 是否触发了法术）
	var marker: String = "*" if spell_cast != &"" else " "
	print("[OutpostCommander:%s]%s tick: mana=%.0f gold=%d sp=%.1f threat=%d attack_bld=%d strat=%s 圈内 %d 建筑 %d 单位" %
		[_uid_str(), marker, mana, gold, strategy_points, threat, attacked_buildings, String(current_strategy), buildings_alive, units.size()])


# ============================================================
# 局势评估
# ============================================================
## 圈内 + 即将进圈的玩家单位数（粗略威胁值）
func _assess_threat() -> int:
	if config == null:
		return 0
	var center: Vector2 = global_position
	var count: int = 0
	for u in get_tree().get_nodes_in_group("player_units"):
		if not is_instance_valid(u) or not (u is CharacterBody2D):
			continue
		if u.global_position.distance_to(center) <= config.territory_radius + 80.0:
			count += 1
	return count


## 圈内 hp < 70% 的敌方建筑数（粗略"正在被攻击"判定）
func _count_attacked_buildings(buildings: Array) -> int:
	var count: int = 0
	for b in buildings:
		if not is_instance_valid(b):
			continue
		if not b.has_node("HealthComponent"):
			continue
		var h = b.get_node("HealthComponent")
		if h.hp < h.max_hp * 0.7:
			count += 1
	return count


func _has_wounded_units(units: Array, ratio: float) -> bool:
	for u in units:
		if not is_instance_valid(u) or not (u is CharacterBody2D):
			continue
		if u.health == null or u.health.is_dead():
			continue
		if float(u.health.hp) < float(u.health.max_hp) * ratio:
			return true
	return false


## 找血量低于 ratio 的单位的最密集点（简化：取其平均位置）
func _densest_wounded_center(units: Array, ratio: float) -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	var count: int = 0
	for u in units:
		if not is_instance_valid(u) or not (u is CharacterBody2D):
			continue
		if u.health == null or u.health.is_dead():
			continue
		if float(u.health.hp) < float(u.health.max_hp) * ratio:
			sum += u.global_position
			count += 1
	if count == 0:
		return global_position
	return sum / float(count)


## 圈内是否有"满驻军"的兵营（用于 release_garrison 触发）
func _has_full_garrison() -> bool:
	for b in _get_managed_buildings():
		if not is_instance_valid(b):
			continue
		var garrison = b.get_node_or_null("Garrison")
		if garrison == null or not garrison.has_method("get_garrison_count"):
			continue
		if garrison.get_garrison_count() >= 5:  # 简化阈值
			return true
	return false


# ============================================================
# 法术决策 + 执行
# ============================================================
## 按优先级检查法术，第一个能放的就放。返回触发的 spell_id（无则为 &""）
func _pick_and_cast_spell(threat: int, attacked: int, buildings: Array, units: Array, mana_full: bool) -> StringName:
	if not (&"shield" in config.enabled_spells) and attacked > 0:
		pass
	# 优先级：shield > call_to_arms > heal > inspire > release_garrison
	if attacked > 0 and &"shield" in config.enabled_spells:
		var target := _weakest_attacked_building(buildings)
		if target != null and _try_cast_spell(&"shield", {"target_building": target}):
			return &"shield"
	if threat >= 8 and &"call_to_arms" in config.enabled_spells:
		var center := _weakest_attacked_building(buildings)
		var pos: Vector2 = center.global_position if center != null else global_position
		if _try_cast_spell(&"call_to_arms", {"center": pos}):
			return &"call_to_arms"
	if _has_wounded_units(units, 0.5) and &"heal" in config.enabled_spells:
		var pos := _densest_wounded_center(units, 0.5)
		if _try_cast_spell(&"heal", {"_target_pos": pos}):
			return &"heal"
	if current_strategy == &"attack" and mana_full and &"inspire" in config.enabled_spells:
		var pos := global_position  # 简化：以指挥官为中心（圈内的友军聚集点）
		if _try_cast_spell(&"inspire", {"_target_pos": pos}):
			return &"inspire"
	if _has_full_garrison() and &"release_garrison" in config.enabled_spells:
		if _try_cast_spell(&"release_garrison", {"center": global_position}):
			return &"release_garrison"
	return &""


func _weakest_attacked_building(buildings: Array):
	var weakest = null
	var weakest_ratio: float = 1.1
	for b in buildings:
		if not is_instance_valid(b) or not b.has_node("HealthComponent"):
			continue
		var h = b.get_node("HealthComponent")
		var ratio: float = float(h.hp) / float(h.max_hp) if h.max_hp > 0 else 1.0
		if ratio < 0.7 and ratio < weakest_ratio:
			weakest = b
			weakest_ratio = ratio
	return weakest


## 检查 mana + cd，满足则扣 mana、设 cd、调对应 SpellEffects
func _try_cast_spell(spell_id: StringName, extra_config: Dictionary) -> bool:
	var params: Dictionary = _resolve_spell_params(spell_id)
	var cost: float = float(params.get("cost", 0.0))
	if mana < cost:
		return false
	if spell_cooldowns.has(spell_id):
		return false  # 还在冷却
	mana -= cost
	spell_cooldowns[spell_id] = float(params.get("cooldown", 20.0))
	# 合并参数 + 调用法术
	var cfg: Dictionary = params.duplicate()
	cfg.merge(extra_config, true)
	var target_pos: Vector2 = cfg.get("_target_pos", global_position)
	cfg.erase("_target_pos")
	var main_node := get_tree().current_scene
	var spawner = main_node.get("spawner_module") if "spawner_module" in main_node else null
	SpellEffectsRef.call(spell_id, main_node, spawner, target_pos, cfg)
	print("[OutpostCommander:%s] cast spell %s (cost=%.0f)" % [_uid_str(), String(spell_id), cost])
	return true


func _resolve_spell_params(spell_id: StringName) -> Dictionary:
	var base: Dictionary = DEFAULT_SPELL_PARAMS.get(spell_id, {}).duplicate()
	if config.spell_overrides.has(spell_id):
		base.merge(config.spell_overrides[spell_id], true)
	return base


# ============================================================
# 策略决策 + 执行
# ============================================================
func _pick_strategy(threat: int, buildings_alive: int, mana_full: bool) -> StringName:
	# 1. 高威胁且建筑少 → defend
	if threat >= 10 and buildings_alive <= 3 and &"defend" in config.enabled_strategies:
		return &"defend"
	# 2. 法力满 + 进攻倾向 + 有玩家目标
	if mana_full and config.aggression > 0.6 and _has_player_target():
		if &"coordinate" in config.enabled_strategies and _other_commander_attacking():
			return &"coordinate"
		if &"attack" in config.enabled_strategies:
			return &"attack"
	# 3. 低威胁 + 资源充足 + 扩张倾向
	if threat < 3 and gold > 200 and config.expansionist > 0.5 and buildings_alive < 6 and &"expand" in config.enabled_strategies:
		return &"expand"
	# 4. 默认 defend
	if &"defend" in config.enabled_strategies:
		return &"defend"
	return &""


func _has_player_target() -> bool:
	# 圈外有玩家建筑即视为可攻击目标
	return not get_tree().get_nodes_in_group("player_buildings").is_empty()


func _other_commander_attacking() -> bool:
	var main_node := get_tree().current_scene
	if main_node == null:
		return false
	var manager = main_node.get_node_or_null("OutpostCommanderManager")
	if manager == null or not manager.has_method("get_commanders"):
		return false
	for other in manager.get_commanders():
		if other == self or not is_instance_valid(other):
			continue
		if other.get("current_strategy") == &"attack":
			return true
	return false


func _try_execute_strategy(strategy_id: StringName, force: bool) -> bool:
	if strategy_id == &"":
		return false
	if strategy_id == &"defend" or strategy_id == &"attack" or strategy_id == &"coordinate" or strategy_id == &"expand":
		pass
	else:
		return false  # 未知策略
	var costs: Dictionary = DEFAULT_STRATEGY_COSTS.get(strategy_id, {}).duplicate()
	if config.strategy_overrides.has(strategy_id):
		costs.merge(config.strategy_overrides[strategy_id], true)
	var sp_cost: int = int(costs.get("sp", 0))
	var gold_cost: int = int(costs.get("gold", 0))
	if not force:
		if strategy_points < float(sp_cost):
			return false
		if gold < gold_cost:
			return false
		strategy_points -= float(sp_cost)
		gold -= gold_cost
	# 攻击目标：玩家方最近的 building（兜底用世界原点）
	var attack_target: Vector2 = _find_player_attack_target()
	var strat_config: Dictionary = {
		"target_pos": attack_target,
		"building_type": 1,  # TOWER（defend 用）
		"count": 1,
	}
	var main_node := get_tree().current_scene
	var manager = main_node.get_node_or_null("OutpostCommanderManager")
	var ok: bool = StrategyEffectsRef.call(strategy_id, self, manager, strat_config)
	if ok:
		current_strategy = strategy_id
		print("[OutpostCommander:%s] execute strategy %s (sp=%d gold=%d)" %
			[_uid_str(), String(strategy_id), sp_cost, gold_cost])
	return ok


func _find_player_attack_target() -> Vector2:
	var center: Vector2 = global_position
	var best = null
	var best_dist: float = 1e12
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if not is_instance_valid(b):
			continue
		var d: float = b.global_position.distance_to(center)
		if d < best_dist:
			best = b
			best_dist = d
	if best != null:
		return best.global_position
	return Vector2.ZERO


func _despawn() -> void:
	var main_node := get_tree().current_scene
	if main_node != null:
		var manager = main_node.get_node_or_null("OutpostCommanderManager")
		if manager != null and manager.has_method("unregister_commander"):
			manager.unregister_commander(self)
	queue_free()


# ============================================================
# 圈内查询
# ============================================================
func _get_managed_buildings() -> Array:
	var result: Array = []
	if config == null:
		return result
	var center: Vector2 = global_position
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if not is_instance_valid(b):
			continue
		if b.global_position.distance_to(center) <= config.territory_radius:
			result.append(b)
	return result


func _get_managed_units() -> Array:
	var result: Array = []
	if config == null:
		return result
	var center: Vector2 = global_position
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(u):
			continue
		if u.global_position.distance_to(center) <= config.territory_radius:
			result.append(u)
	return result


# ============================================================
# 外部接口
# ============================================================
func contains_entity(entity) -> bool:
	if config == null or not is_instance_valid(entity):
		return false
	return entity.global_position.distance_to(global_position) <= config.territory_radius


func get_uid() -> StringName:
	return config.commander_uid if config != null else &""


func _uid_str() -> String:
	if config == null:
		return "<no_config>"
	return String(config.commander_uid)
