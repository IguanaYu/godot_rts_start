extends RefCounted
## 据点指挥官策略实现（消耗策略点 SP + 资源 gold 执行高级指令）
## 调用方式：OutpostStrategyEffects.<strategy_id>(cmdr, manager, config)
##
## 策略点设计：
## - attack (1 SP): 圈内单位 attack_move 玩家基地
## - coordinate (2 SP): 与其他 attack 状态指挥官汇合
## - defend (1 SP + gold): 在圈内空闲位置放箭塔/牧场
## - expand (3 SP + gold): 在圈内放兵营（自动屯兵）

const BuildingScript := preload("res://scripts/buildings/building.gd")
const D := preload("res://scripts/systems/game_data.gd")
const FactionClass := preload("res://scripts/faction.gd")


# ============================================================
# 静态分发：用 StringName 调用对应策略（绕过 .call() 不能调 static 的限制）
# ============================================================
static func dispatch(strategy_id: StringName, cmdr: Node, manager: Node, config: Dictionary) -> bool:
	match strategy_id:
		&"attack":
			return attack(cmdr, manager, config)
		&"coordinate":
			return coordinate(cmdr, manager, config)
		&"defend":
			return defend(cmdr, manager, config)
		&"expand":
			return expand(cmdr, manager, config)
		_:
			push_warning("[OutpostStrategyEffects] unknown strategy: %s" % String(strategy_id))
			return false


# ============================================================
# attack — 出击：圈内所有单位 attack_move 到玩家基地
# ============================================================
static func attack(cmdr: Node, _manager: Node, config: Dictionary) -> bool:
	var target_pos: Vector2 = config.get("target_pos", Vector2.ZERO)
	var locked_count: int = 0
	for unit in cmdr.get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(unit) or not (unit is CharacterBody2D):
			continue
		if unit.health == null or unit.health.is_dead():
			continue
		# 仅圈内 + 隶属于本指挥官（重叠区限制见 _try_issue_unit_order）
		if not _belongs_to_cmdr(unit, cmdr):
			continue
		if not _try_issue_unit_order(unit, cmdr, "attack"):
			continue
		if unit.has_method("attack_move_to"):
			unit.attack_move_to(target_pos)
			locked_count += 1
	if locked_count > 0 and cmdr.has_method("_emit_strategy_signal"):
		cmr_set_strategy(cmdr, &"attack")
	print("[OutpostStrategy:attack] %s 派 %d 单位出击" % [_cmdr_uid(cmdr), locked_count])
	return locked_count > 0


# ============================================================
# coordinate — 协同进攻：移动到其他 attack 状态指挥官的领地中心，然后切 attack
# ============================================================
static func coordinate(cmdr: Node, manager: Node, _config: Dictionary) -> bool:
	if manager == null or not manager.has_method("get_commanders"):
		return false
	# 找一个 attack 状态的友邻指挥官
	var rally_cmdr: Node = null
	for other in manager.get_commanders():
		if other == cmdr or not is_instance_valid(other):
			continue
		if other.has_method("get") and other.get("current_strategy") == &"attack":
			rally_cmdr = other
			break
	if rally_cmdr == null:
		return false  # 没有人在 attack，coordinate 失败
	var rally_pos: Vector2 = rally_cmdr.global_position
	var moved: int = 0
	for unit in cmdr.get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(unit) or not (unit is CharacterBody2D):
			continue
		if unit.health == null or unit.health.is_dead():
			continue
		if not _belongs_to_cmdr(unit, cmdr):
			continue
		if not _try_issue_unit_order(unit, cmdr, "coordinate"):
			continue
		if unit.has_method("attack_move_to"):
			unit.attack_move_to(rally_pos)
			moved += 1
	if moved > 0:
		cmr_set_strategy(cmdr, &"attack")  # 协同后切 attack 状态
	print("[OutpostStrategy:coordinate] %s 派 %d 单位汇合到 %s" %
		[_cmdr_uid(cmdr), moved, _cmdr_uid(rally_cmdr)])
	return moved > 0


# ============================================================
# defend — 巩固防御：在圈内空闲位置放箭塔（默认）或牧场
# ============================================================
static func defend(cmdr: Node, _manager: Node, config: Dictionary) -> bool:
	var building_type: int = config.get("building_type", BuildingScript.BuildingType.TOWER)  # 默认箭塔
	var count: int = config.get("count", 1)
	var placed: int = 0
	for i in range(count):
		var gpos: Vector2i = _find_free_grid_near(cmdr, building_type)
		if gpos == Vector2i.MIN:
			break
		var building = _place_building(cmdr, building_type, gpos)
		if building != null:
			placed += 1
	print("[OutpostStrategy:defend] %s 放置 %d 个建筑(type=%d)" %
		[_cmdr_uid(cmdr), placed, building_type])
	return placed > 0


# ============================================================
# expand — 缓慢扩张：在圈内放兵营（自动屯兵）
# ============================================================
static func expand(cmdr: Node, _manager: Node, config: Dictionary) -> bool:
	var count: int = config.get("count", 1)
	var placed: int = 0
	for i in range(count):
		var gpos: Vector2i = _find_free_grid_near(cmdr, BuildingScript.BuildingType.BARRACKS)
		if gpos == Vector2i.MIN:
			break
		var building = _place_building(cmdr, BuildingScript.BuildingType.BARRACKS, gpos)
		if building != null:
			placed += 1
	print("[OutpostStrategy:expand] %s 放置 %d 个兵营" % [_cmdr_uid(cmdr), placed])
	return placed > 0


# ============================================================
# 辅助：单位归属 + 指令锁定（解决重叠区双指挥冲突）
# ============================================================
## 单位是否隶属于本指挥官（commander_ids 包含本指挥官 uid）
static func _belongs_to_cmdr(unit, cmdr) -> bool:
	if not ("commander_ids" in unit):
		return false
	var uid: StringName = cmdr.get_uid() if cmdr.has_method("get_uid") else &""
	return uid in unit.commander_ids


## 尝试给单位下指令，检查 3 秒锁定窗口（避免 A/B 指挥官抖动）
## 返回 true 表示可以下指令
static func _try_issue_unit_order(unit, cmdr, _order_type: String) -> bool:
	if not ("active_order_timestamp" in unit):
		return true  # 字段未加，跳过锁定（兼容旧代码）
	var now_msec: int = Time.get_ticks_msec()
	var source_uid: StringName = unit.get("order_source_uid") if "order_source_uid" in unit else &""
	var cmdr_uid: StringName = cmdr.get_uid() if cmdr.has_method("get_uid") else &""
	# 3 秒锁定窗口：其他指挥官刚下过指令就跳过
	if source_uid != &"" and source_uid != cmdr_uid:
		var last_ts: int = unit.active_order_timestamp
		if now_msec - last_ts < 3000:
			return false
	# 锁定本指挥官的指令
	unit.active_order_timestamp = now_msec
	if "order_source_uid" in unit:
		unit.order_source_uid = cmdr_uid
	return true


# ============================================================
# 辅助：找圈内空闲 grid + 调 place_building_callback
# ============================================================
const _SEARCH_STEPS: int = 16  # 圈内尝试 16 个候选位置（以指挥官为中心螺旋）

static func _find_free_grid_near(cmdr: Node, building_type: int) -> Vector2i:
	var main_node := cmdr.get_tree().current_scene
	if main_node == null:
		return Vector2i.MIN
	var spawner = main_node.get_node_or_null("SpawnerModule")
	if spawner == null:
		spawner = main_node.get("spawner_module") if "spawner_module" in main_node else null
	if spawner == null:
		return Vector2i.MIN
	var snap_cb: Callable = spawner.snap_to_grid_callback
	var free_cb: Callable = spawner.is_grid_free_callback
	if snap_cb.is_null() or free_cb.is_null():
		return Vector2i.MIN
	var center: Vector2 = cmdr.global_position
	var radius: float = cmdr.config.territory_radius if cmdr.config != null else 350.0
	var gsize: Vector2i = D.get_building_grid_size(building_type)
	# 螺旋搜索：以圆心为起点，逐步扩大半径绕一圈
	var step: float = D.GRID_SIZE
	for ring in range(1, _SEARCH_STEPS):
		var r: float = ring * step
		if r > radius:
			break
		for angle_deg in [0, 90, 180, 270, 45, 135, 225, 315]:
			var angle: float = deg_to_rad(angle_deg)
			var candidate: Vector2 = center + Vector2(cos(angle), sin(angle)) * r
			var gpos: Vector2i = snap_cb.call(candidate)
			if free_cb.call(gpos, gsize):
				return gpos
	return Vector2i.MIN


static func _place_building(cmdr: Node, building_type: int, gpos: Vector2i) -> Node2D:
	var main_node := cmdr.get_tree().current_scene
	if main_node == null:
		return null
	var spawner = main_node.get("spawner_module") if "spawner_module" in main_node else null
	if spawner == null:
		return null
	var cb: Callable = spawner.place_building_callback
	if cb.is_null():
		return null
	# team=ENEMY=1, owner=-1, color=RED, slot=0
	var building = cb.call(building_type, BuildingScript.Team.ENEMY, gpos, -1, FactionClass.ColorId.RED, 0)
	if building != null and is_instance_valid(building):
		building.net_id = spawner._next_net_id
		spawner._next_net_id += 1
		# 打 tag：让新建筑归属本指挥官
		var uid: StringName = cmdr.get_uid() if cmdr.has_method("get_uid") else &""
		if uid != &"" and "commander_ids" in building:
			building.commander_ids.append(uid)
		# 同步注册到 LockstepSync（如果存在 autoload）
		var ls = main_node.get_node_or_null("/root/LockstepSync")
		if ls != null and ls.has_method("register_unit"):
			ls.register_unit(building)
	return building


# ============================================================
# 杂项
# ============================================================
static func _cmdr_uid(cmdr: Node) -> String:
	if cmdr == null or not is_instance_valid(cmdr):
		return "<invalid>"
	if cmdr.has_method("_uid_str"):
		return cmdr._uid_str()
	return "<unknown>"


## 设置指挥官当前策略（供 attack/coordinate 调用后更新状态）
static func cmr_set_strategy(cmdr: Node, strategy_id: StringName) -> void:
	if cmdr != null and is_instance_valid(cmdr) and "current_strategy" in cmdr:
		cmdr.current_strategy = strategy_id
