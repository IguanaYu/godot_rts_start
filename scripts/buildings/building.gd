@tool
extends Node2D

enum BuildingType { WALL, TOWER, CASTLE, BARRACKS, MONASTERY, ARCHERY, FARM, ALTAR_ARCHER, ACADEMY }
enum Team { PLAYER, ENEMY }

const UnitScript := preload("res://scripts/units/unit.gd")
const D := preload("res://scripts/systems/game_data.gd")

@export var building_type: BuildingType = BuildingType.WALL:
	set(v): building_type = v; _refresh_editor()
@export var team: Team = Team.PLAYER
## 玩家方=0, 敌方=1, 预留 2/3。由 alliance_id 派生 team。
var alliance_id: int = 0:
	set(v): alliance_id = v; team = Team.PLAYER if v == 0 else Team.ENEMY
## 控制权归属的玩家 ID (1-4)。AI 单位 = -1。
var owner_id: int = -1
## 所属势力槽。同 alliance+slot 的多个玩家共享控制权（co-op）。
var slot_id: int = 0
## Faction.Color 枚举值，决定贴图目录。
var faction_color: int = 1
## 所属据点指挥官 uid 列表（多个=重叠区被多指挥官共管；为空=野生建筑）
var commander_ids: Array[StringName] = []
@export var shadow_scale_x: float = 0.85:
	set(v): shadow_scale_x = v; _refresh_editor()
@export var shadow_scale_y: float = 0.45:
	set(v): shadow_scale_y = v; _refresh_editor()
@export var shadow_alpha: float = 0.35:
	set(v): shadow_alpha = v; _refresh_editor()
@export var shadow_offset_x: float = 0.0:
	set(v): shadow_offset_x = v; _refresh_editor()
@export var shadow_offset_y: float = 0.0:
	set(v): shadow_offset_y = v; _refresh_editor()
@export var sprite_scale_x: float = 0.4:
	set(v): sprite_scale_x = v; _refresh_editor()
@export var sprite_scale_y: float = 0.4:
	set(v): sprite_scale_y = v; _refresh_editor()
@export var sprite_lift_ratio: float = 0.15:
	set(v): sprite_lift_ratio = v; _refresh_editor()
@export var sprite_offset_x: float = 0.0:
	set(v): sprite_offset_x = v; _refresh_editor()
@export var sprite_offset_y: float = 0.0:
	set(v): sprite_offset_y = v; _refresh_editor()

var grid_size: Vector2i = Vector2i(1, 1)
var grid_pos: Vector2i = Vector2i.ZERO
var _is_dead: bool = false
var net_id: int = 0
const ShadowComp := preload("res://scripts/core/shadow_component.gd")
@onready var _shadow_component: ShadowComp = $ShadowComponent
const HealthComp := preload("res://scripts/core/health_component.gd")
@onready var health: HealthComp = $HealthComponent
const JellyEffect := preload("res://scripts/effects/jelly_effect.gd")

# 建造系统
var build_time: float = 5.0
var build_progress: float = 0.0
var is_constructed: bool = true
var build_bar: ProgressBar = null

# 箭塔攻击
var attack_target = null
var attack_damage: float = 12.0
var attack_range: float = 150.0
var attack_cooldown: float = 1.5
var attack_timer: float = 0.0

# 生产系统
var production_timer: float = 0.0
var production_cooldown: float = 0.0
var production_unit_type: int = -1  # UnitType 枚举值，-1 = 不生产
@export var disable_production: bool = false

# T1 PR-2: 兵营出兵队列（BARRACKS 专用）
var production_queue: Array[StringName] = []
var queue_max: int = 5  # _apply_commander_building_stats 时从 stats.production_queue_max 覆盖
signal queue_changed(building)

# 指挥官变体：当前建筑对应的 BuildingStats 资源（运行时由 _apply_commander_building_stats 设置）
var building_stats = null
# 产兵轮转索引：变体建筑在多个 stats_id 间轮转生产
var _production_variant_index: int = 0

# 光环系统
var aura_range: float = 0.0
var aura_type: String = ""
var aura_value: float = 0.0
var aura_scan_timer: float = 0.0

# 城墙自修
var _last_damage_time: float = 0.0
var _repair_accumulator: float = 0.0

# 生产圆圈
var _production_circle: Node2D = null

# T2 PR-3: 时代升级进度条（仅玩家城堡使用，独立于产兵圆圈）
var _age_upgrade_bar: ProgressBar = null

# T2 PR-4: 全局升级 mult（building_stats 是共享 Resource 不能改，用实例裸字段）
var gold_production_mult: float = 1.0
var max_hp_mult: float = 1.0
var _base_max_hp: int = 0

signal died(building)
signal damaged(amount, attacker)
signal construction_finished(building)

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var body_sprite: Sprite2D = $BodySprite
@onready var hp_bar: ProgressBar = $HPBar
@onready var aggro_line: Line2D = $AggroLine

func _ready() -> void:
	# @export team 在 .tscn 中可保存，但 alliance_id 是 var 不会自动同步。
	# 这里反推一次，保证产兵/驻军继承正确的阵营。
	alliance_id = 1 if team == Team.ENEMY else 0
	_setup_stats()
	if Engine.is_editor_hint():
		_snap_position_to_grid()
		_setup_editor_visuals()
	else:
		_setup_visuals()
		_update_hp_bar()
		# 注册到分组（确保 VictoryCondition 在 _ready 时就能找到）
		add_to_group("buildings")
		add_to_group("player_buildings" if team == Team.PLAYER else "enemy_buildings")
		# 预放置建筑（已建造状态）直接创建生产圆圈
		if is_constructed:
			_create_production_circle()
		# 在线模式：产兵 timer 由 TickManager.tick 推进，保证两端同步
		if NetworkManager.is_online:
			TickManager.tick.connect(_on_production_tick)

func _on_production_tick() -> void:
	if disable_production:
		return
	if production_cooldown <= 0.0:
		return
	production_timer += TickManager.TICK_TIME
	if production_timer >= production_cooldown:
		production_timer = 0.0
		# T1: CASTLE 与 FARM 都自动产金（读 stats.gold_production_amount）
		if building_type == BuildingType.CASTLE or building_type == BuildingType.FARM:
			_produce_gold()
		# T1 D2: 移除自动产兵（BARRACKS/MONASTERY/ARCHERY 改由玩家手动下单）
		# 原 else: _spawn_produced_unit() 已移除

func _snap_position_to_grid() -> void:
	var offset := Vector2((grid_size.x - 1) * 32.0, (grid_size.y - 1) * 32.0)
	var tl := position - offset
	var gx := floori((tl.x - 32.0) / 64.0)
	var gy := floori((tl.y - 32.0) / 64.0)
	grid_pos = Vector2i(gx, gy)
	position = Vector2(gx * 64.0 + 32.0 + offset.x, gy * 64.0 + 32.0 + offset.y)

func _setup_stats() -> void:
	var max_hp: int
	match building_type:
		BuildingType.WALL:
			max_hp = 300
			grid_size = Vector2i(1, 1)
		BuildingType.TOWER:
			max_hp = 150
			grid_size = Vector2i(1, 1)
		BuildingType.CASTLE:
			max_hp = 500
			grid_size = Vector2i(3, 3)
			production_cooldown = 10.0
			aura_range = 200.0
			aura_type = "defense"
			aura_value = 0.1
		BuildingType.BARRACKS:
			max_hp = 250
			grid_size = Vector2i(2, 2)
			production_cooldown = 25.0
			production_unit_type = UnitScript.UnitType.SOLDIER
			aura_range = 150.0
			aura_type = "attack_melee"
			aura_value = 0.15
		BuildingType.MONASTERY:
			max_hp = 400
			grid_size = Vector2i(2, 2)
			production_cooldown = 35.0
			production_unit_type = UnitScript.UnitType.MONK
			aura_range = 120.0
			aura_type = "regen"
			aura_value = 2.0
		BuildingType.ARCHERY:
			max_hp = 200
			grid_size = Vector2i(2, 2)
			production_cooldown = 30.0
			production_unit_type = UnitScript.UnitType.ARCHER
			aura_range = 150.0
			aura_type = "range_bonus"
			aura_value = 25.0
		BuildingType.ALTAR_ARCHER:
			# PR-4 据点占领后可造的高级祭坛；建筑 stats 由 BuildingStatsRegistry 提供
			max_hp = 200
			grid_size = Vector2i(2, 2)
	# 指挥官变体覆盖（运行时按 owner_id 查 CommanderProfile.building_variants）
	_apply_commander_building_stats(max_hp)


func _apply_commander_building_stats(fallback_max_hp: int) -> void:
	# 建筑 HP 倍率（SLOW=3.0 / 其他=1.0）。所有 health.setup 路径都应用。
	var bal_hp_mult := BalanceScheme.get_building_hp_mult()
	if Engine.is_editor_hint():
		# 编辑器模式：CommanderContext 未就绪，用 fallback 硬编码值
		if health and fallback_max_hp > 0:
			_setup_health(int(fallback_max_hp * bal_hp_mult))
		return
	var sid: StringName = CommanderContext.get_default_building_stats_id(int(building_type), alliance_id)
	if sid == &"" or not BuildingStatsRegistry.has_id(sid):
		if health and fallback_max_hp > 0:
			_setup_health(int(fallback_max_hp * bal_hp_mult))
		return
	var stats = BuildingStatsRegistry.get_by_id(sid)
	building_stats = stats
	# 应用变体属性覆盖
	var max_hp: int = stats.max_hp
	grid_size = stats.grid_size
	if stats.production_cooldown > 0.0:
		production_cooldown = stats.production_cooldown
	if stats.attack_damage > 0.0:
		attack_damage = stats.attack_damage
	if stats.attack_range > 0.0:
		attack_range = stats.attack_range
	if stats.attack_cooldown > 0.0:
		attack_cooldown = stats.attack_cooldown
	# T1 PR-2: 兵营队列上限从 stats 读
	queue_max = stats.production_queue_max if stats.production_queue_max > 0 else 5
	aura_range = stats.aura_range
	aura_type = stats.aura_type
	aura_value = stats.aura_value
	if health:
		_setup_health(int(max_hp * bal_hp_mult))
	# 应用指挥官变体 tint（WHITE = 不变）
	if body_sprite and stats.tint != Color.WHITE:
		body_sprite.modulate = stats.tint

func _setup_health(base_max_hp: int) -> void:
	_base_max_hp = base_max_hp
	if health:
		health.setup(int(base_max_hp * max_hp_mult), hp_bar, team)

# T2 PR-4: 全局升级接入（unit_upgrade_manager 调用）
func apply_gold_mult(mult: float) -> void:
	gold_production_mult = mult

func apply_max_hp_mult(mult: float) -> void:
	max_hp_mult = mult
	if health == null or _base_max_hp <= 0:
		return
	var old_max: int = health.max_hp
	var new_max: int = int(_base_max_hp * max_hp_mult)
	health.max_hp = new_max
	if health.hp_bar:
		health.hp_bar.max_value = new_max
	var delta: int = new_max - old_max
	if delta > 0:
		health.hp = mini(health.hp + delta, new_max)

func _setup_editor_visuals() -> void:
	_setup_texture()
	_rebuild_shadow()
	_apply_sprite_position()

func _setup_visuals() -> void:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)

	# 贴图
	_setup_texture()

	# 碰撞
	var shape := RectangleShape2D.new()
	shape.size = pixel_size
	collision_shape.shape = shape

	# 血条位置
	var sprite_height: float = pixel_size.y
	if body_sprite.texture:
		sprite_height = body_sprite.texture.get_height() * body_sprite.scale.y
	hp_bar.offset_left = -pixel_size.x / 2.0
	hp_bar.offset_right = pixel_size.x / 2.0
	hp_bar.offset_top = -sprite_height / 2.0 - 8.0
	hp_bar.offset_bottom = -sprite_height / 2.0

	# 影子
	_rebuild_shadow()

	# 贴图上移
	_apply_sprite_position()

	# HPBar 跟随上移
	var sprite_height_final: float = pixel_size.y
	if body_sprite.texture:
		sprite_height_final = body_sprite.texture.get_height() * body_sprite.scale.y
	var lift: float = sprite_height_final * sprite_lift_ratio
	hp_bar.offset_top += lift + sprite_offset_y
	hp_bar.offset_bottom += lift + sprite_offset_y
	# T1 PR-2: 兵营头顶挂队列 UI（仅玩家兵营）
	# T2 PR-1: 靶场也走队列，加入列表
	if (building_type == BuildingType.BARRACKS or building_type == BuildingType.ARCHERY) and team == Team.PLAYER:
		_create_queue_indicator(pixel_size)

func _setup_texture() -> void:
	var color_dir := Faction.color_dir(faction_color)
	var tex_path := _building_tex_path(color_dir)
	if tex_path != "" and ResourceLoader.exists(tex_path):
		var tex := load(tex_path)
		if tex and body_sprite:
			body_sprite.texture = tex
	elif color_dir != "blue":
		# 素材缺失 fallback 到蓝色
		var fb_path := _building_tex_path("blue")
		if fb_path != "" and ResourceLoader.exists(fb_path):
			var tex := load(fb_path)
			if tex and body_sprite:
				body_sprite.texture = tex

# T1 PR-2: 兵营头顶队列 UI（BarracksQueueIndicator）
const BarracksQueueIndicatorScene := preload("res://scenes/ui/barracks_queue_indicator.tscn")
const INDICATOR_HEAD_OFFSET: float = 30.0
func _create_queue_indicator(pixel_size: Vector2) -> void:
	var indicator = BarracksQueueIndicatorScene.instantiate()
	add_child(indicator)
	# indicator.size 在 _ready 后已设；用绝对 position 把"左上角"放到目标点
	# 目标：x 居中 building 中心（左移 ind_w/2），y 在 building 顶边上方 30+ind_h
	var ind_size: Vector2 = indicator.size
	if ind_size.x <= 0.0:
		ind_size = Vector2(88.0, 16.0)  # 与 indicator._ready 中的 size 一致
	indicator.position = Vector2(-ind_size.x / 2.0, -pixel_size.y / 2.0 - INDICATOR_HEAD_OFFSET - ind_size.y)
	indicator.setup(self)


func _building_tex_path(color_dir_str: String) -> String:
	match building_type:
		BuildingType.WALL:
			return "res://assets/buildings/%s_house/House1.png" % color_dir_str
		BuildingType.TOWER:
			return "res://assets/buildings/%s_tower/Tower.png" % color_dir_str
		BuildingType.CASTLE:
			return "res://assets/buildings/%s_castle/Castle.png" % color_dir_str
		BuildingType.BARRACKS:
			return "res://assets/buildings/%s_barracks/Barracks.png" % color_dir_str
		BuildingType.MONASTERY:
			return "res://assets/buildings/%s_monastery/Monastery.png" % color_dir_str
		BuildingType.ARCHERY:
			return "res://assets/buildings/%s_archery/Archery.png" % color_dir_str
		BuildingType.FARM:
			# T1: 暂复用 house 贴图（无独立美术资源）
			return "res://assets/buildings/%s_house/House1.png" % color_dir_str
	return ""

func _rebuild_shadow() -> void:
	if _shadow_component:
		var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
		var shadow_w := int(pixel_size.x * shadow_scale_x)
		var shadow_h := int(pixel_size.y * shadow_scale_y)
		_shadow_component.rebuild(shadow_w, shadow_h, shadow_alpha, shadow_offset_x, shadow_offset_y)

func _apply_sprite_position() -> void:
	if _shadow_component and body_sprite and body_sprite.texture:
		var sprite_height: float = body_sprite.texture.get_height() * sprite_scale_y
		var lift: float = sprite_height * sprite_lift_ratio
		_shadow_component.apply_sprite_position(body_sprite, sprite_scale_x, sprite_scale_y, lift, sprite_offset_x, sprite_offset_y)

func _refresh_editor() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_node_ready():
		return

	_setup_stats()
	_setup_texture()
	_rebuild_shadow()
	_apply_sprite_position()
	queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var cell := 64
	var pixel_size := Vector2(grid_size.x * cell, grid_size.y * cell)
	var origin := -pixel_size / 2.0

	# 高亮填充建筑占用的格子
	draw_rect(Rect2(origin, pixel_size), Color(0.3, 0.6, 1.0, 0.15))

	# 画格子线
	for x in range(grid_size.x + 1):
		var x_pos := origin.x + x * cell
		draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, origin.y + pixel_size.y), Color(1, 1, 1, 0.5), 1.0)
	for y in range(grid_size.y + 1):
		var y_pos := origin.y + y * cell
		draw_line(Vector2(origin.x, y_pos), Vector2(origin.x + y_pos, y_pos), Color(1, 1, 1, 0.5), 1.0)

	# 碰撞边界（红色）
	draw_rect(Rect2(origin, pixel_size), Color(1, 0, 0, 0.6), false, 2.0)

func is_dead() -> bool:
	return health.is_dead() if health else _is_dead

func get_rect() -> Rect2:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
	return Rect2(global_position - pixel_size / 2.0, pixel_size)

## 检查指定位置是否与任何建筑的碰撞区域重叠
func _is_position_clear(pos: Vector2, unit_radius: float) -> bool:
	for b in get_tree().get_nodes_in_group("buildings"):
		if b == self or b.is_dead():
			continue
		var rect: Rect2 = b.get_rect().grow(unit_radius)
		if rect.has_point(pos):
			return false
	# T1: 也检查其他单位，避免 spawn 重叠被物理引擎弹进建筑
	var min_unit_dist := unit_radius * 2.5
	for u in get_tree().get_nodes_in_group("player_units"):
		if is_instance_valid(u) and u.global_position.distance_to(pos) < min_unit_dist:
			return false
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if is_instance_valid(u) and u.global_position.distance_to(pos) < min_unit_dist:
			return false
	return true

## 找到一个有效的刷新位置，确保不在任何建筑内
func _find_valid_spawn_position(unit_radius: float = 16.0) -> Vector2:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
	var clearance := unit_radius + 4.0
	var half_w := pixel_size.x / 2.0
	var half_h := pixel_size.y / 2.0
	# 候选位置：建筑外围各方向（相对于建筑中心的偏移）
	var candidates := [
		Vector2(0, half_h + clearance),              # 底部中央（正门）
		Vector2(-half_w - clearance, half_h * 0.5),  # 左下
		Vector2(half_w + clearance, half_h * 0.5),   # 右下
		Vector2(-half_w - clearance, 0),              # 左侧中央
		Vector2(half_w + clearance, 0),               # 右侧中央
		Vector2(0, -half_h - clearance),              # 顶部中央
	]
	for offset in candidates:
		var pos: Vector2 = global_position + offset
		if _is_position_clear(pos, unit_radius) and _in_map_bounds(pos):
			return pos
	# 扩大搜索：环形扫描
	for dist in [64.0, 128.0, 192.0, 256.0]:
		for i in range(8):
			var angle: float = i * PI / 4.0
			var pos: Vector2 = global_position + Vector2(cos(angle), sin(angle)) * dist
			if _is_position_clear(pos, unit_radius) and _in_map_bounds(pos):
				return pos
	# 兜底：建筑中心（至少保证在地图内）
	return global_position


## 检查 pos 是否在 main.map_bounds 内（带 margin 边距避免贴边）
## main 没有 map_bounds 字段时不阻拦（兼容编辑器/单测）
func _in_map_bounds(pos: Vector2, margin: float = 16.0) -> bool:
	var main_node := get_parent()
	if main_node == null or "map_bounds" not in main_node:
		return true
	var b: Rect2 = main_node.map_bounds
	return pos.x > b.position.x + margin and pos.x < b.end.x - margin \
		and pos.y > b.position.y + margin and pos.y < b.end.y - margin

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_snap_position_to_grid()
		return
	if health.is_dead():
		return
	# 建造倒计时
	if not is_constructed:
		build_progress += delta
		if build_bar:
			build_bar.value = build_progress
		if build_progress >= build_time:
			_finish_construction()
		return
	# 箭塔攻击
	if building_type == BuildingType.TOWER:
		_tower_process(delta)
	# 生产系统
	_production_process(delta)
	# 光环系统
	_aura_process(delta)
	# 城墙自修
	if building_type == BuildingType.WALL:
		_wall_repair_process(delta)

func _tower_process(delta: float) -> void:
	attack_timer = max(0.0, attack_timer - delta)

	# 验证当前目标
	if attack_target != null:
		if not is_instance_valid(attack_target) or attack_target.is_dead():
			attack_target = null
		elif global_position.distance_to(attack_target.global_position) > attack_range:
			attack_target = null

	# 寻找目标
	if attack_target == null:
		var enemy_group := "player_units" if team == Team.ENEMY else "enemy_units"
		var closest = null
		var closest_dist: float = INF
		for u in get_tree().get_nodes_in_group(enemy_group):
			if u.is_dead():
				continue
			var d: float = global_position.distance_to(u.global_position)
			if d < attack_range and d < closest_dist:
				closest = u
				closest_dist = d
		attack_target = closest

	# 仇恨线
	if attack_target != null:
		aggro_line.visible = true
		aggro_line.clear_points()
		aggro_line.add_point(Vector2.ZERO)
		aggro_line.add_point(attack_target.global_position - global_position)
	else:
		aggro_line.visible = false

	# 射箭
	if attack_target != null and attack_timer <= 0.0:
		_spawn_arrow(attack_target)
		attack_timer = attack_cooldown

func _spawn_arrow(target) -> void:
	JellyEffect.play(body_sprite, Vector2(sprite_scale_x, sprite_scale_y))
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		var data: Resource = null
		if building_type == BuildingType.TOWER:
			data = _get_tower_projectile_data()
		spawner.spawn_projectile(data, global_position, target.global_position, target, self, int(attack_damage))


const ProjectileDataScript := preload("res://scripts/resources/projectile_data.gd")
const SlowEffectScript := preload("res://scripts/resources/slow_effect.gd")

func _get_tower_projectile_data() -> Resource:
	var data := ProjectileDataScript.new()
	var slow := SlowEffectScript.new()
	slow.slow_rate = 0.25
	slow.duration = 2.0
	data.effects.append(slow)
	return data

# ============================================================
# 生产系统
# ============================================================
func _production_process(delta: float) -> void:
	if disable_production:
		return
	if production_cooldown <= 0.0:
		return
	# 在线模式：timer 由 TickManager.tick 同步推进（_on_production_tick），这里只更新视觉
	if NetworkManager.is_online:
		if _production_circle:
			_production_circle.update_progress(production_timer / production_cooldown)
		return
	# T1 PR-2: BARRACKS 走队列 —— 队列空时归零 timer，不推进
	# T2 PR-1: 扩展到 ARCHERY/MONASTERY（之前埋的 bug——只 BARRACKS 走队列，靶场入队后无人处理）
	if building_type == BuildingType.BARRACKS or building_type == BuildingType.ARCHERY or building_type == BuildingType.MONASTERY:
		if production_queue.is_empty():
			production_timer = 0.0
			if _production_circle:
				_production_circle.update_progress(0.0)
			return
		production_timer += delta
		if _production_circle:
			_production_circle.update_progress(production_timer / production_cooldown)
		if production_timer >= production_cooldown:
			production_timer = 0.0
			_spawn_next_unit()
		return
	production_timer += delta
	# 更新圆圈进度
	if _production_circle:
		_production_circle.update_progress(production_timer / production_cooldown)
	if production_timer >= production_cooldown:
		production_timer = 0.0
		# T1: CASTLE 与 FARM 都自动产金（读 stats.gold_production_amount）
		if building_type == BuildingType.CASTLE or building_type == BuildingType.FARM:
			_produce_gold()
		# T1 D2: 移除自动产兵（BARRACKS/MONASTERY/ARCHERY 改由玩家手动下单）
		# 原 else: _spawn_produced_unit() 已移除


# ============================================================
# T1 PR-2: 兵营出兵队列 API
# ============================================================

func queue_has_space() -> bool:
	return production_queue.size() < queue_max


## 入队一个单位 stats_id。成功返回 true；队列满返回 false。
func queue_unit(stats_id: StringName) -> bool:
	if not queue_has_space():
		return false
	production_queue.append(stats_id)
	queue_changed.emit(self)
	return true


## 当前队列首位完成 → spawn 并 pop。被 _production_process 调用。
func _spawn_next_unit() -> void:
	if production_queue.is_empty():
		return
	var stats_id: StringName = production_queue.pop_front()
	queue_changed.emit(self)
	_spawn_unit_by_stats_id(stats_id)


## 队列状态快照（供 UI 查询）
func get_queue_state() -> Dictionary:
	var cur: StringName = production_queue[0] if not production_queue.is_empty() else &""
	return {
		"queue": production_queue.duplicate(),
		"remaining": max(0.0, production_cooldown - production_timer),
		"total": production_cooldown,
		"current": cur,
	}

func _spawn_produced_unit() -> void:
	# 取当前轮转变体的 stats_id（按 alliance_id 查 CommanderContext）
	var stats_id: StringName = &""
	var variant_ids: Array = CommanderContext.get_unit_variant_ids_for_building(int(building_type), alliance_id)
	if variant_ids.size() > 0:
		stats_id = variant_ids[_production_variant_index % variant_ids.size()]
		_production_variant_index = (_production_variant_index + 1) % variant_ids.size()
	# T1 PR-2: 变体 id 为空时 fallback 到 building_stats.completion_refund_unit（BARRACKS=&"soldier"）
	if stats_id == &"" and building_stats and building_stats.completion_refund_unit != &"":
		stats_id = building_stats.completion_refund_unit
	_spawn_unit_by_stats_id(stats_id)


# T1 PR-2: 实际 spawn 主体（被 _spawn_produced_unit / _spawn_next_unit 共用）
func _spawn_unit_by_stats_id(stats_id: StringName) -> void:
	# 取 unit_type（按建筑类型派生，BARRACKS→SOLDIER, MONASTERY→MONK, ARCHERY→ARCHER）
	var unit_type: int = production_unit_type
	if unit_type < 0:
		return
	# T3 PR-2: 玩家方且该兵种已选 T3 升级时，直接用变体场景，跳过 stats_id 路由
	var t3_scene: PackedScene = null
	if team == Team.PLAYER:
		var main := get_tree().current_scene
		if main and main.get("t3_upgrade_manager"):
			var mgr = main.t3_upgrade_manager
			var choice_id: StringName = mgr.get_selected_choice(unit_type)
			if choice_id != &"":
				var data = mgr.get_upgrade_data(unit_type)
				for c in data.choices:
					if c.choice_id == choice_id:
						t3_scene = c.variant_scene
						break
	# 场景路由：T3 变体 > 指挥官变体 stats_id > 基础 UNIT_SCENES
	var scene_path: String = ""
	if t3_scene == null:
		if stats_id != &"":
			scene_path = D.ENEMY_VARIANT_SCENES.get(stats_id, "")
		if scene_path == "":
			scene_path = D.UNIT_SCENES.get(unit_type, "")
		if scene_path == "":
			return
	var unit_scene: PackedScene = t3_scene if t3_scene != null else load(scene_path)
	if unit_scene == null:
		return
	var unit: CharacterBody2D = unit_scene.instantiate()
	# 按 stats_id 替换 stats_data（指挥官变体复用基础兵种场景，靠 stats_data 区分属性）
	# T3 变体场景：stats_data 已经在 .tscn 里指定，不要覆盖
	if t3_scene == null and stats_id != &"" and UnitStatsRegistry.has_id(stats_id):
		unit.set("stats_data", UnitStatsRegistry.get_by_id(stats_id))
	# 继承建筑的所有势力字段（alliance_id setter 同步 team）
	unit.set("alliance_id", alliance_id)
	unit.set("owner_id", owner_id)
	unit.set("faction_color", faction_color)
	unit.set("slot_id", slot_id)
	# 在建筑旁找到有效出生位置
	unit.position = _find_valid_spawn_position(16.0)
	# 找到正确的父节点
	var main_node := get_tree().current_scene
	var parent_name := "PlayerUnits" if team == Team.PLAYER else "EnemyUnits"
	var parent_node := main_node.get_node_or_null(parent_name)
	if parent_node == null:
		unit.queue_free()
		return
	parent_node.add_child(unit)
	# 分配 net_id 并注册，否则 lockstep 命令通过 net_id 查不到这个单位
	# （建筑造的兵两端各自跑 _process 生成，_next_net_id 可能略有不同步；
	#  这是当前 lockstep 协议的局限，对单机模式无影响）
	var main_node2 := get_tree().current_scene
	if main_node2 and "spawner_module" in main_node2 and main_node2.spawner_module:
		unit.net_id = main_node2.spawner_module._next_net_id
		main_node2.spawner_module._next_net_id += 1
		LockstepSync.register_unit(unit)
	# 刷新后检查：如果小兵仍在建筑内，触发逃生
	if unit.has_method("_start_escape") and unit.has_method("_is_inside_any_building"):
		if unit._is_inside_any_building():
			unit._start_escape()
	# 召唤特效
	var dust := D.DustEffectScene.instantiate()
	get_tree().current_scene.add_child(dust)
	dust.global_position = unit.global_position
	# 添加到对应的组
	var group_name := "player_units" if team == Team.PLAYER else "enemy_units"
	unit.add_to_group(group_name)
	# T3 PR-3: 战斗统计（兵营造兵，仅玩家方）
	if team == Team.PLAYER and main_node != null:
		main_node._units_trained += 1
	# 连接死亡信号
	if main_node.has_method("_on_unit_died"):
		unit.connect("died", Callable(main_node, "_on_unit_died"))
	# 全局集结点：新单位自动前往（移动并攻击）
	var main_scene := get_tree().current_scene
	if main_scene and main_scene.get("has_global_rally"):
		unit.attack_move_to(main_scene.global_rally_point)
	# 敌方单位添加AI
	if team == Team.ENEMY:
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(load("res://scripts/units/enemy_ai.gd"))
		unit.add_child(ai)
	# 通知科技点系统：生产单位（双方造兵都给）
	if main_scene and main_scene.get("tech_point_manager"):
		var TPD := preload("res://scripts/tech/tech_point_data.gd")
		main_scene.tech_point_manager.add_points(TPD.BASE_POINTS.get("produce_unit", 5), TPD.CATEGORY_PRODUCE_UNIT)

func _produce_gold() -> void:
	# T1: 产金量读 building_stats.gold_production_amount（>0 时），否则兜底 30
	var amount: int = 30
	if building_stats and building_stats.gold_production_amount > 0:
		amount = building_stats.gold_production_amount
	# T2 PR-4: 农场科技加成
	amount = int(amount * gold_production_mult)
	var main_node := get_tree().current_scene
	if main_node and main_node.has_method("add_gold"):
		main_node.add_gold(amount)
		# 金币漂浮数字
		var ft := Node2D.new()
		ft.set_script(load("res://scripts/effects/floating_text.gd"))
		get_tree().current_scene.add_child(ft)
		ft.setup("+" + str(amount), Color(1.0, 0.85, 0.0), global_position + Vector2(0, -40))

# ============================================================
# 光环系统
# ============================================================
func _aura_process(delta: float) -> void:
	if aura_range <= 0.0:
		return
	aura_scan_timer += delta
	if aura_scan_timer < 0.5:
		return
	aura_scan_timer = 0.0
	var ally_group := "player_units" if team == Team.PLAYER else "enemy_units"
	for u in get_tree().get_nodes_in_group(ally_group):
		if not is_instance_valid(u) or u.is_dead():
			continue
		var dist := global_position.distance_to(u.global_position)
		if dist > aura_range:
			continue
		match aura_type:
			"regen":
				if u.health.hp < u.health.max_hp:
					u.health.heal(int(aura_value * 0.5))
			"attack_melee":
				if u.unit_type in [UnitScript.UnitType.SOLDIER, UnitScript.UnitType.LANCER]:
					u.apply_buff("attack_melee", aura_value)
			"range_bonus":
				u.apply_buff("range_bonus", aura_value)
			"defense":
				u.apply_buff("defense", aura_value)

# ============================================================
# 城墙系统
# ============================================================
func _wall_repair_process(delta: float) -> void:
	if health.hp >= health.max_hp:
		return
	# 被攻击后3秒才开始修复
	if _last_damage_time > 0.0:
		_last_damage_time -= delta
		return
	_repair_accumulator += delta
	if _repair_accumulator >= 1.0:
		_repair_accumulator -= 1.0
		health.heal(1)

func _check_wall_connections() -> void:
	if building_type != BuildingType.WALL:
		return
	var bonus := 0
	for b in get_tree().get_nodes_in_group("buildings"):
		if b == self or b.building_type != BuildingType.WALL:
			continue
		if b.is_dead() or not b.is_constructed:
			continue
		var diff: Vector2i = b.grid_pos - grid_pos
		if absi(diff.x) + absi(diff.y) == 1:
			bonus += 80
	var new_max := 300 + bonus
	if health.max_hp != new_max:
		health.max_hp = new_max
		if health.hp > new_max:
			health.hp = new_max
		health._update_hp_bar()

func _update_neighbor_walls() -> void:
	for b in get_tree().get_nodes_in_group("buildings"):
		if b == self or b.building_type != BuildingType.WALL:
			continue
		if b.is_dead() or not b.is_constructed:
			continue
		var diff: Vector2i = b.grid_pos - grid_pos
		if absi(diff.x) + absi(diff.y) == 1:
			b._check_wall_connections()

# ============================================================
# 生产圆圈
# ============================================================
func _create_production_circle() -> void:
	if production_cooldown <= 0.0:
		return
	# T1 PR-2: BARRACKS 重新启用生产圆圈（队列首单位进度，与 CASTLE/FARM 同款）
	# T2 PR-1: ARCHERY 现在也走队列，加入显示列表；MONASTERY 仍不显示（未提供玩家入队接口）
	match building_type:
		BuildingType.MONASTERY:
			return
	# 确定颜色
	var fill_color := Color.WHITE
	match building_type:
		BuildingType.CASTLE:
			fill_color = Color(1.0, 0.85, 0.0)    # 金色
		BuildingType.BARRACKS:
			fill_color = Color(0.9, 0.3, 0.2)     # 红色
		BuildingType.MONASTERY:
			fill_color = Color(0.9, 0.9, 1.0)     # 白色
		BuildingType.ARCHERY:
			fill_color = Color(0.3, 0.8, 0.3)     # 绿色
	# 计算 Y 偏移：放在 HP 条上方
	var y_offset := hp_bar.offset_top - 12.0
	_production_circle = Node2D.new()
	_production_circle.set_script(load("res://scripts/effects/production_circle.gd"))
	add_child(_production_circle)
	_production_circle.setup(fill_color, y_offset)
	# T2 PR-3: 玩家城堡额外创建时代升级进度条（默认隐藏，升级时由 main.gd 调用 set_age_upgrade_progress）
	if building_type == BuildingType.CASTLE and team == Team.PLAYER:
		_create_age_upgrade_bar()


# T2 PR-3: 创建时代升级进度条（HP 条上方 28px，避开产兵圆圈 y=-12，金色填充）
func _create_age_upgrade_bar() -> void:
	_age_upgrade_bar = ProgressBar.new()
	_age_upgrade_bar.max_value = 1.0
	_age_upgrade_bar.value = 0.0
	_age_upgrade_bar.show_percentage = false
	_age_upgrade_bar.visible = false
	_age_upgrade_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 宽度比 HP 条窄 20%，居中
	var bar_width := (hp_bar.offset_right - hp_bar.offset_left) * 0.8
	_age_upgrade_bar.offset_left = -bar_width / 2.0
	_age_upgrade_bar.offset_right = bar_width / 2.0
	# 位置：HP 条上方 28px（避开产兵圆圈 y=-12，给飘字留空间）
	_age_upgrade_bar.offset_top = hp_bar.offset_top - 28.0
	_age_upgrade_bar.offset_bottom = hp_bar.offset_top - 22.0
	# 暗底 + 金色填充 + 金色细边
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
	bg_style.set_corner_radius_all(2)
	bg_style.set_border_width_all(1)
	bg_style.border_color = Color(1.0, 0.85, 0.0, 0.6)
	_age_upgrade_bar.add_theme_stylebox_override("background", bg_style)
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(1.0, 0.85, 0.0)
	fill_style.set_corner_radius_all(2)
	_age_upgrade_bar.add_theme_stylebox_override("fill", fill_style)
	add_child(_age_upgrade_bar)


# T2 PR-3: 设置时代升级进度（ratio 0~1，<=0 隐藏，>0 显示并更新；由 main.gd 升级流程调用）
func set_age_upgrade_progress(ratio: float) -> void:
	if _age_upgrade_bar == null or not is_instance_valid(_age_upgrade_bar):
		return
	var r := clampf(ratio, 0.0, 1.0)
	if r <= 0.0:
		_age_upgrade_bar.visible = false
		return
	_age_upgrade_bar.visible = true
	_age_upgrade_bar.value = r

func take_damage(amount: int, attacker = null) -> void:
	if Engine.is_editor_hint():
		return
	if health.is_dead():
		return
	# 反特化：attacker 对建筑有额外伤害倍率
	var final_amount := amount
	var atk_stats = attacker.stats_data if (is_instance_valid(attacker) and attacker is Unit) else null
	if atk_stats and atk_stats.bonus_vs_building_multiplier > 1.0:
		final_amount = int(final_amount * atk_stats.bonus_vs_building_multiplier)
	health.take_damage(final_amount)
	damaged.emit(final_amount, attacker)
	# 伤害飘字
	if final_amount > 0:
		var main_node := get_tree().current_scene
		if main_node and main_node.has_method("show_damage_number"):
			main_node.show_damage_number(final_amount, global_position)
	_last_damage_time = 3.0  # 城墙被攻击后3秒才开始修复
	if attacker and team == Team.ENEMY:
		_alert_nearby_enemies(attacker)
	if health.hp <= 0:
		die()

func _alert_nearby_enemies(attacker) -> void:
	var alert_range := 500.0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u.is_dead():
			continue
		if global_position.distance_to(u.global_position) <= alert_range:
			var ai = u.get_node_or_null("EnemyAI")
			if ai and ai.has_method("on_attacked"):
				ai.on_attacked(attacker)

func die() -> void:
	health._is_dead = true
	died.emit(self)
	# 更新相邻城墙的连结加成
	if building_type == BuildingType.WALL:
		_update_neighbor_walls()
	# 生成爆炸特效
	var explosion_scene := load("res://scenes/effects/explosion.tscn")
	var explosion: Node2D = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	var max_dim := maxf(float(grid_size.x), float(grid_size.y))
	explosion.scale = Vector2(max_dim, max_dim)
	# 缩小+删除动画
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _update_hp_bar() -> void:
	if health:
		health._update_hp_bar()

func start_construction(duration: float = 5.0) -> void:
	build_time = duration
	build_progress = 0.0
	is_constructed = false
	body_sprite.modulate.a = 0.5
	_create_build_bar()

func _create_build_bar() -> void:
	build_bar = ProgressBar.new()
	build_bar.max_value = build_time
	build_bar.value = 0.0
	build_bar.show_percentage = false

	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
	build_bar.offset_left = -pixel_size.x / 2.0
	build_bar.offset_right = pixel_size.x / 2.0
	build_bar.offset_top = hp_bar.offset_top - 10.0
	build_bar.offset_bottom = hp_bar.offset_top - 2.0

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.set_corner_radius_all(2)
	build_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(1.0, 0.85, 0.0)
	fill_style.set_corner_radius_all(2)
	build_bar.add_theme_stylebox_override("fill", fill_style)

	add_child(build_bar)

func _finish_construction() -> void:
	is_constructed = true
	body_sprite.modulate.a = 1.0
	# 城墙连结检测
	_check_wall_connections()
	# 创建生产圆圈
	_create_production_circle()
	if build_bar:
		build_bar.queue_free()
		build_bar = null
	# T1 D14: 建造完成反还单位（如 BARRACKS 反 2 个 soldier）
	_spawn_completion_refund_units()
	# T2 PR-1: 建造完成反还金币（如 FARM 反 100 金）
	_refund_gold_on_completion()
	construction_finished.emit(self)


# T1 D14: 建造完成时反还单位（building.gd 自调 spawn，职责清晰）
func _spawn_completion_refund_units() -> void:
	if building_stats == null:
		return
	if building_stats.completion_refund_unit == &"":
		return
	if building_stats.completion_refund_unit_count <= 0:
		return
	var main_node := get_tree().current_scene
	if main_node == null or not main_node.get("spawner_module"):
		return
	# T2 PR-1: 用 STATS_ID_TO_UNIT_TYPE 映射替代硬编码
	var stats_id: StringName = building_stats.completion_refund_unit
	var unit_type: int = D.STATS_ID_TO_UNIT_TYPE.get(stats_id, UnitScript.UnitType.SOLDIER)
	for i in range(building_stats.completion_refund_unit_count):
		# D15: 用 _find_valid_spawn_position 找空位，避免重叠/卡建筑/弹地图外
		var spawn_pos := _find_valid_spawn_position(16.0)
		main_node.spawner_module.place_player_unit(unit_type, spawn_pos, stats_id)


# T2 PR-1: 建造完成时反还金币（如 FARM 反 100 金）
func _refund_gold_on_completion() -> void:
	if building_stats == null or building_stats.completion_refund <= 0:
		return
	var main_node := get_tree().current_scene
	if main_node == null or not main_node.has_method("add_gold"):
		return
	var amount: int = building_stats.completion_refund
	main_node.add_gold(amount)
	# 金币飘字（复用 _produce_gold 的飘字模式）
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	main_node.add_child(ft)
	ft.setup("+" + str(amount), Color(1.0, 0.85, 0.0), global_position + Vector2(0, -40))
