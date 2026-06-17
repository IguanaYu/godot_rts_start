extends Node
## 生成模块：单位/建筑生成、环境装饰、特效

const D := preload("res://scripts/systems/game_data.gd")
const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")
const StatSetClass := preload("res://scripts/stats/stat_set.gd")

var _main_node: Node2D
var _player_units_node: Node2D
var _enemy_units_node: Node2D
var _buildings_node: Node2D
var _diff_preset: Resource = null  # DifficultyPreset
var _upgrade_manager: Node = null  # upgrade_manager, duck typing
var _next_net_id: int = 1

# Callbacks for building placement (grid module functions)
var place_building_callback: Callable
var snap_to_grid_callback: Callable
var is_grid_free_callback: Callable

func initialize(main_node: Node2D, player_units: Node2D, enemy_units: Node2D, buildings: Node2D) -> void:
	_main_node = main_node
	_player_units_node = player_units
	_enemy_units_node = enemy_units
	_buildings_node = buildings

func set_difficulty(preset: Resource) -> void:
	_diff_preset = preset

func set_upgrade_manager(mgr: Node) -> void:
	_upgrade_manager = mgr

# --- 单位创建 ---

func create_unit(type: int, alliance_id: int, pos: Vector2, stats_id: StringName = &"", owner_id: int = -1, color: int = -1, slot_id: int = 0) -> CharacterBody2D:
	# alliance_id 兼容旧 team 参数（PLAYER=0/ENEMY=1），数值一致
	# 默认颜色：玩家方 BLUE，敌方 RED
	if color < 0:
		color = Faction.ColorId.BLUE if alliance_id == 0 else Faction.ColorId.RED
	var scene_path: String = ""
	if stats_id != &"":
		scene_path = D.ENEMY_VARIANT_SCENES.get(stats_id, "")
	if scene_path == "":
		scene_path = D.UNIT_SCENES.get(type, "res://scenes/units/soldier.tscn")
	var unit_scene := load(scene_path)
	var unit: CharacterBody2D = unit_scene.instantiate()
	unit.set("alliance_id", alliance_id)  # setter 会同步 team
	unit.set("owner_id", owner_id)
	unit.set("faction_color", color)
	unit.set("slot_id", slot_id)
	unit.position = pos
	unit.connect("died", Callable(_main_node, "_on_unit_died"))
	return unit

# --- 从配置生成 ---

func spawn_from_config(map_config: Resource) -> void:
	if map_config == null:
		return
	_next_net_id = 1
	if map_config.alliances.is_empty():
		_spawn_legacy_from_config(map_config)
	else:
		_spawn_ai_alliances_from_config(map_config)

# 旧地图 fallback：用 player_units/player2_units/enemy_units 字段生成
# 玩家方一律 alliance=0, owner=-1, color=BLUE；slot 0=player_units, slot 1=player2_units
func _spawn_legacy_from_config(map_config: Resource) -> void:
	for spawn in map_config.player_units:
		var unit := create_unit(spawn.type, 0, spawn.pos, &"", -1, Faction.ColorId.BLUE, 0)
		unit.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(unit)
		_player_units_node.add_child(unit)
		unit.add_to_group("player_units")

	for spawn in map_config.player2_units:
		var unit := create_unit(spawn.type, 0, spawn.pos, &"", -1, Faction.ColorId.BLUE, 1)
		unit.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(unit)
		_player_units_node.add_child(unit)
		unit.add_to_group("player_units")

	for spawn in map_config.enemy_units:
		var stats_id: StringName = spawn.get("stats_id", &"")
		var unit := create_unit(spawn.type, 1, spawn.pos, stats_id, -1, Faction.ColorId.RED, 0)
		unit.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(unit)
		_enemy_units_node.add_child(unit)
		_apply_difficulty_modifiers(unit)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(load("res://scripts/units/enemy_ai.gd"))
		unit.add_child(ai)

	for spawn in map_config.player_buildings:
		var building = place_building_callback.call(spawn.type, BuildingScript.Team.PLAYER, spawn.grid_pos, -1, Faction.ColorId.BLUE, 0)
		building.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(building)

	for spawn in map_config.player2_buildings:
		var building = place_building_callback.call(spawn.type, BuildingScript.Team.PLAYER, spawn.grid_pos, -1, Faction.ColorId.BLUE, 1)
		building.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(building)

	for spawn in map_config.enemy_buildings:
		var building = place_building_callback.call(spawn.type, BuildingScript.Team.ENEMY, spawn.grid_pos, -1, Faction.ColorId.RED, 0)
		building.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(building)

# 新格式：生成所有 is_ai=true 的联盟（玩家方 alliance=0 由 main._spawn_dynamic_players 处理）
func _spawn_ai_alliances_from_config(map_config: Resource) -> void:
	for alliance in map_config.alliances:
		if not alliance.get("is_ai", false):
			continue
		var alliance_id: int = alliance.get("id", 1)
		var alliance_color: int = alliance.get("color", Faction.ColorId.RED)
		var slots: Array = alliance.get("slots", [])
		for slot_idx in slots.size():
			var slot: Dictionary = slots[slot_idx]
			var slot_color: int = slot.get("color", alliance_color)
			for spawn in slot.get("units", []):
				var stats_id: StringName = spawn.get("stats_id", &"")
				var unit := create_unit(spawn.type, alliance_id, spawn.pos, stats_id, -1, slot_color, slot_idx)
				unit.net_id = _next_net_id
				_next_net_id += 1
				LockstepSync.register_unit(unit)
				_enemy_units_node.add_child(unit)
				_apply_difficulty_modifiers(unit)
				unit.add_to_group("enemy_units")
				var ai := Node2D.new()
				ai.name = "EnemyAI"
				ai.set_script(load("res://scripts/units/enemy_ai.gd"))
				unit.add_child(ai)
			for spawn in slot.get("buildings", []):
				var building = place_building_callback.call(spawn.type, BuildingScript.Team.ENEMY, spawn.grid_pos, -1, slot_color, slot_idx)
				building.net_id = _next_net_id
				_next_net_id += 1
				LockstepSync.register_unit(building)

# 联机时按 player_sessions 占用情况动态生成单个玩家 slot 的初始单位/建筑
func spawn_slot_initial(slot: Dictionary, slot_idx: int, owner_id: int, color: int) -> void:
	for spawn in slot.get("units", []):
		var unit := create_unit(spawn.type, 0, spawn.pos, &"", owner_id, color, slot_idx)
		unit.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(unit)
		_player_units_node.add_child(unit)
		unit.add_to_group("player_units")
		if _upgrade_manager:
			_upgrade_manager.apply_all_stat_upgrades_to_unit(unit)
	for spawn in slot.get("buildings", []):
		var building = place_building_callback.call(spawn.type, BuildingScript.Team.PLAYER, spawn.grid_pos, owner_id, color, slot_idx)
		building.net_id = _next_net_id
		_next_net_id += 1
		LockstepSync.register_unit(building)

# 单机模式 AI 队友（owner_id=-2, alliance_id=0, color=YELLOW, slot=2）
func spawn_ally_unit_initial(unit_type: int, pos: Vector2, \
		behavior: String = "follow", defend_pos: Vector2 = Vector2.ZERO, \
		squad_id: String = "general") -> void:
	var unit := create_unit(unit_type, 0, pos, &"", -2, Faction.ColorId.YELLOW, 2)
	unit.net_id = _next_net_id
	_next_net_id += 1
	LockstepSync.register_unit(unit)
	_player_units_node.add_child(unit)
	unit.add_to_group("player_units")
	if _upgrade_manager:
		_upgrade_manager.apply_all_stat_upgrades_to_unit(unit)
	var ai := Node2D.new()
	ai.name = "AllyAI"
	ai.set_script(load("res://scripts/units/ally_ai.gd"))
	unit.add_child(ai)
	ai.squad_id = squad_id
	if behavior != "follow" and ai.has_method("set_initial_behavior"):
		ai.set_initial_behavior(behavior, defend_pos)
	spawn_spawn_effect(pos, UnitScript.Team.PLAYER, unit)


# AI 队友延迟增援波次：占领 capture_point 后调用，生成的单位自动 attack_move 到 target
func spawn_ally_wave(groups: Array, spawn_center: Vector2, target: Vector2, formation: String = "column", spacing: float = 50.0) -> void:
	var expanded: Array = _expand_groups(groups)
	var positions: Array = _calc_formation_positions(spawn_center, expanded.size(), formation, spacing)
	for i in expanded.size():
		_spawn_ally_wave_unit(expanded[i].type, positions[i], target)


func _spawn_ally_wave_unit(unit_type: int, pos: Vector2, target: Vector2) -> void:
	var unit := create_unit(unit_type, 0, pos, &"", -2, Faction.ColorId.YELLOW, 2)
	unit.net_id = _next_net_id
	_next_net_id += 1
	LockstepSync.register_unit(unit)
	_player_units_node.add_child(unit)
	unit.add_to_group("player_units")
	if _upgrade_manager:
		_upgrade_manager.apply_all_stat_upgrades_to_unit(unit)
	var ai := Node2D.new()
	ai.name = "AllyAI"
	ai.set_script(load("res://scripts/units/ally_ai.gd"))
	unit.add_child(ai)
	spawn_spawn_effect(pos, UnitScript.Team.PLAYER, unit)
	ai.call_deferred("start_wave_attack", target)

# --- 环境装饰 ---

func spawn_environment(map_config: Resource, map_bounds: Rect2) -> void:
	var env_node := Node2D.new()
	env_node.name = "Environment"
	env_node.z_index = 1
	_main_node.add_child(env_node)
	_main_node.move_child(env_node, 1)

	# 收集地形障碍区域，用于避开
	var obstacle_rects: Array[Rect2] = []
	var obstacles_node = _main_node.get_node_or_null("Obstacles")
	if obstacles_node:
		for obstacle in obstacles_node.get_children():
			if obstacle.has_method("get_obstacle_rect"):
				obstacle_rects.append(obstacle.get_obstacle_rect())

	var spawn_min_x: float = map_bounds.position.x + 100
	var spawn_max_x: float = map_bounds.end.x - 100
	var spawn_min_y: float = map_bounds.position.y + 100
	var spawn_max_y: float = map_bounds.end.y - 100

	var tree_count := D.DEFAULT_TREES
	var rock_count := D.DEFAULT_ROCKS
	var bush_count := D.DEFAULT_BUSHES
	var sheep_count := D.DEFAULT_SHEEP

	if map_config != null:
		var env: Dictionary = map_config.environment
		tree_count = env.get("trees", D.DEFAULT_TREES)
		rock_count = env.get("rocks", D.DEFAULT_ROCKS)
		bush_count = env.get("bushes", D.DEFAULT_BUSHES)
		sheep_count = env.get("sheep", D.DEFAULT_SHEEP)

	var tree_scene := load("res://scenes/environment/tree.tscn")
	for i in range(tree_count):
		var pos := _find_safe_spawn_pos(spawn_min_x, spawn_max_x, spawn_min_y, spawn_max_y, obstacle_rects)
		var tree: Node2D = tree_scene.instantiate()
		tree.position = pos
		tree.get_node("Sprite").texture = load(D.TREE_TEXTURES[i % 4])
		tree.get_node("Sprite").frame = randi() % 8
		env_node.add_child(tree)

	var rock_scene := load("res://scenes/environment/rock.tscn")
	for i in range(rock_count):
		var pos := _find_safe_spawn_pos(spawn_min_x, spawn_max_x, spawn_min_y, spawn_max_y, obstacle_rects)
		var rock: Node2D = rock_scene.instantiate()
		rock.position = pos
		rock.get_node("Sprite").texture = load(D.ROCK_TEXTURES[i % 4])
		env_node.add_child(rock)

	var bush_scene := load("res://scenes/environment/bush.tscn")
	for i in range(bush_count):
		var pos := _find_safe_spawn_pos(spawn_min_x, spawn_max_x, spawn_min_y, spawn_max_y, obstacle_rects)
		var bush: Node2D = bush_scene.instantiate()
		bush.position = pos
		bush.get_node("Sprite").texture = load(D.BUSH_TEXTURES[i % 4])
		env_node.add_child(bush)

	var sheep_scene := load("res://scenes/environment/sheep.tscn")
	for i in range(sheep_count):
		var pos := _find_safe_spawn_pos(spawn_min_x, spawn_max_x, spawn_min_y, spawn_max_y, obstacle_rects)
		var sheep: Node2D = sheep_scene.instantiate()
		sheep.position = pos
		env_node.add_child(sheep)


func _find_safe_spawn_pos(min_x: float, max_x: float, min_y: float, max_y: float, avoid_rects: Array[Rect2]) -> Vector2:
	for _attempt in range(20):
		var pos := Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
		var blocked := false
		for r in avoid_rects:
			if r.has_point(pos):
				blocked = true
				break
		if not blocked:
			return pos
	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))

# --- 放置时生成玩家单位 ---

func place_player_unit(unit_type: int, click_pos: Vector2, stats_id: StringName = &"") -> void:
	var unit := create_unit(unit_type, UnitScript.Team.PLAYER, click_pos, stats_id)
	unit.net_id = _next_net_id
	_next_net_id += 1
	LockstepSync.register_unit(unit)
	_player_units_node.add_child(unit)
	unit.add_to_group("player_units")
	if _upgrade_manager:
		_upgrade_manager.apply_all_stat_upgrades_to_unit(unit)
	spawn_spawn_effect(click_pos, UnitScript.Team.PLAYER, unit)
	# 全局集结点：新单位自动前往（移动并攻击）
	var main_scene := get_tree().current_scene
	if main_scene and main_scene.get("has_global_rally"):
		unit.attack_move_to(main_scene.global_rally_point)

# --- 阵型计算 ---

## 将 groups 展开为有序的 type+data 列表
static func _expand_groups(groups: Array) -> Array:
	var result: Array = []
	for g in groups:
		var type: int = g.get("type", 0)
		var count: int = g.get("count", 1)
		for _i in count:
			var entry: Dictionary = {"type": type}
			for key in ["variant_hp", "variant_atk", "variant_speed_mult", "variant_scale", "stats_id"]:
				if g.has(key):
					entry[key] = g[key]
			result.append(entry)
	return result

## 根据阵型计算每个单位的出生坐标
static func _calc_formation_positions(center: Vector2, count: int, formation: String, spacing: float) -> Array:
	var positions: Array = []
	match formation:
		"line":
			for i in count:
				var x: float = center.x + (i - (count - 1) / 2.0) * spacing
				positions.append(Vector2(x, center.y))
		"grid":
			var cols: int = max(1, ceili(sqrt(count)))
			var rows: int = ceili(count / float(cols))
			var idx := 0
			for r in rows:
				for c in cols:
					if idx >= count:
						break
					var x: float = center.x + (c - (cols - 1) / 2.0) * spacing
					var y: float = center.y + (r - (rows - 1) / 2.0) * spacing
					positions.append(Vector2(x, y))
					idx += 1
		_:  # "column" 默认：纵列左右交错
			for i in count:
				var row := i / 2
				var side := 1 if i % 2 == 0 else -1
				var x: float = center.x + side * spacing * 0.5
				var y: float = center.y + row * spacing
				positions.append(Vector2(x, y))
	return positions

# --- 帧延迟生成队列 ---

var _spawn_queue: Array = []

func _process(_delta: float) -> void:
	if _spawn_queue.is_empty():
		return
	var batch := 2
	while batch > 0 and not _spawn_queue.is_empty():
		var job: Dictionary = _spawn_queue.pop_front()
		_spawn_enemy_unit_immediate(job.type, job.pos, job.wave_attack, job.wave_target, job.data)
		batch -= 1

# --- Public API (for WaveManager, CapturePoint) ---

## 旧接口兼容：直接指定 pos 的 units 数组
func spawn_enemy_wave(units: Array, wave_attack: bool = false, wave_target: Vector2 = Vector2.ZERO) -> void:
	for unit_data in units:
		var type: int = unit_data.get("type", 0)
		var pos: Vector2 = unit_data.get("pos", Vector2.ZERO)
		_spawn_queue.append({
			"type": type, "pos": pos,
			"wave_attack": wave_attack, "wave_target": wave_target,
			"data": unit_data
		})

## 新接口：groups 编组 + spawn_center，自动计算阵型位置
func spawn_enemy_wave_v2(groups: Array, spawn_center: Vector2, wave_attack: bool, wave_target: Vector2, formation: String = "column", spacing: float = 50.0) -> void:
	var scaled_groups := _scale_group_counts(groups)
	var expanded: Array = _expand_groups(scaled_groups)
	var positions: Array = _calc_formation_positions(spawn_center, expanded.size(), formation, spacing)
	for i in expanded.size():
		_spawn_queue.append({
			"type": expanded[i].type, "pos": positions[i],
			"wave_attack": wave_attack, "wave_target": wave_target,
			"data": expanded[i]
		})

func _spawn_enemy_unit_immediate(type: int, pos: Vector2, wave_attack: bool, wave_target: Vector2, data: Dictionary) -> void:
	var stats_id: StringName = data.get("stats_id", &"")
	var unit := create_unit(type, UnitScript.Team.ENEMY, pos, stats_id)
	unit.net_id = _next_net_id
	_next_net_id += 1
	LockstepSync.register_unit(unit)
	# 先加入场景树触发 _ready()，确保 stat_set 已初始化
	_enemy_units_node.add_child(unit)
	# 应用变种修饰器
	if data.has("variant_hp"):
		unit.stat_set.add_modifier("variant", StatSetClass.MAX_HP, float(data.variant_hp))
	if data.has("variant_atk"):
		unit.stat_set.add_modifier("variant", StatSetClass.ATTACK_DAMAGE, float(data.variant_atk))
	if data.has("variant_speed_mult"):
		unit.stat_set.add_modifier("variant", StatSetClass.MOVE_SPEED, 0.0, float(data.variant_speed_mult))
	if data.has("variant_scale"):
		var s = float(data.variant_scale)
		unit.sprite_scale_x *= s
		unit.sprite_scale_y *= s
		# 重新应用到 BodySprite（_ready 已跑过一次）
		if unit.body_sprite:
			unit.body_sprite.scale = Vector2(unit.sprite_scale_x, unit.sprite_scale_y)
	if data.has("variant_hp") or data.has("variant_scale"):
		unit.health.setup(unit.stat_set.get_int(StatSetClass.MAX_HP), unit.hp_bar, unit.team)
		_apply_difficulty_modifiers(unit)
	spawn_spawn_effect(pos, UnitScript.Team.ENEMY, unit)
	unit.add_to_group("enemy_units")
	var ai := Node2D.new()
	ai.name = "EnemyAI"
	ai.set_script(load("res://scripts/units/enemy_ai.gd"))
	unit.add_child(ai)
	if wave_attack and wave_target != Vector2.ZERO:
		ai.call_deferred("start_wave_attack", wave_target)

func spawn_unit_near(type: int, pos: Vector2, team: int) -> CharacterBody2D:
	var offset := Vector2(randf_range(-50, 50), randf_range(-50, 50))
	var unit := create_unit(type, team, pos + offset)
	unit.net_id = _next_net_id
	_next_net_id += 1
	LockstepSync.register_unit(unit)
	if team == UnitScript.Team.PLAYER:
		_player_units_node.add_child(unit)
		unit.add_to_group("player_units")
		if _upgrade_manager:
			_upgrade_manager.apply_all_stat_upgrades_to_unit(unit)
		spawn_spawn_effect(pos + offset, team, unit)
	else:
		_enemy_units_node.add_child(unit)
		spawn_spawn_effect(pos + offset, team, unit)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(load("res://scripts/units/enemy_ai.gd"))
		unit.add_child(ai)
	return unit

# --- 难度乘数 ---

func _apply_difficulty_modifiers(unit: CharacterBody2D) -> void:
	if _diff_preset == null:
		return
	var hp_mult: float = _diff_preset.hp_mult
	var atk_mult: float = _diff_preset.atk_mult
	var speed_mult: float = _diff_preset.speed_mult
	if hp_mult != 1.0:
		unit.stat_set.add_modifier("difficulty", StatSetClass.MAX_HP, 0.0, hp_mult)
	if atk_mult != 1.0:
		unit.stat_set.add_modifier("difficulty", StatSetClass.ATTACK_DAMAGE, 0.0, atk_mult)
	if speed_mult != 1.0:
		unit.stat_set.add_modifier("difficulty", StatSetClass.MOVE_SPEED, 0.0, speed_mult)
	if hp_mult != 1.0:
		unit.health.setup(unit.stat_set.get_int(StatSetClass.MAX_HP), unit.hp_bar, unit.team)

func _scale_group_counts(groups: Array) -> Array:
	if _diff_preset == null or _diff_preset.count_mult == 1.0:
		return groups
	var count_mult: float = _diff_preset.count_mult
	var scaled: Array = []
	for g in groups:
		var new_g: Dictionary = g.duplicate()
		var base_count: int = g.get("count", 1)
		new_g["count"] = maxi(1, int(base_count * count_mult + 0.5))
		scaled.append(new_g)
	return scaled

# --- 特效 ---

# --- 弹道 ---

const ArrowScene := preload("res://scenes/effects/arrow.tscn")

func spawn_projectile(data: Resource, from: Vector2, to: Vector2, target, shooter, damage: int, custom_arrow: PackedScene = null) -> void:
	var count := 1
	var spread := 0.0
	if data:
		count = data.shot_count
		spread = deg_to_rad(data.spread_angle)
	for i in count:
		var offset_angle: float = 0.0
		if count > 1:
			offset_angle = -spread + (2.0 * spread * float(i) / float(count - 1))
		var dir := from.direction_to(to).rotated(offset_angle)
		var dist := from.distance_to(to)
		var actual_to := from + dir * dist

		var scene: PackedScene = custom_arrow if custom_arrow else ArrowScene
		var arrow: Node2D = scene.instantiate()
		_main_node.get_tree().current_scene.add_child(arrow)
		arrow.setup(from, actual_to)
		arrow.hit_target = target
		arrow.hit_damage = damage
		arrow.shooter = shooter
		arrow.data = data

# --- 特效 ---

func spawn_click_effect(scene: PackedScene, pos: Vector2) -> void:
	var effect: Node2D = scene.instantiate()
	_main_node.get_tree().current_scene.add_child(effect)
	effect.global_position = pos


func spawn_spawn_effect(pos: Vector2, team: int, reveal_target: Node2D = null) -> void:
	var effect: Node2D = D.SpawnEffectScene.instantiate()
	effect.global_position = pos
	effect.team_color = 0 if team == UnitScript.Team.PLAYER else 1
	effect.reveal_target = reveal_target
	_main_node.get_tree().current_scene.add_child(effect)

func spawn_dust_effect(pos: Vector2) -> void:
	var effect: Node2D = D.DustEffectScene.instantiate()
	_main_node.get_tree().current_scene.add_child(effect)
	effect.global_position = pos

func show_floating_text(text: String, color: Color, world_pos: Vector2) -> void:
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	_main_node.add_child(ft)
	ft.setup(text, color, world_pos)

# --- 情绪系统节点 ---



