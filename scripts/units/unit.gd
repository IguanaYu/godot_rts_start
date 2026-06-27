@tool
extends CharacterBody2D
class_name Unit

enum UnitState { GUARD, HOLD_POSITION, MOVE, ATTACK_MOVE, ATTACK, DEAD, PATROL }
enum UnitType { SOLDIER, ARCHER, LANCER, MONK }
enum Team { PLAYER, ENEMY }
enum CommandSource { NONE, PLAYER, AUTO }

const HealEffectScene := preload("res://scenes/effects/heal_effect.tscn")
const UnitEffectsShader := preload("res://shaders/unit_effects.gdshader")

var _effects_material: ShaderMaterial = null

@export var unit_type: UnitType = UnitType.SOLDIER:
	set(v): unit_type = v; _refresh_editor()
@export var team: Team = Team.PLAYER
## 玩家方=0, 敌方=1, 预留 2/3 用于未来 PvP 地图。由 alliance_id 派生 team。
var alliance_id: int = 0:
	set(v): alliance_id = v; team = Team.PLAYER if v == 0 else Team.ENEMY
## 控制权归属的玩家 ID (1-4)。AI 单位 = -1。
var owner_id: int = -1
## 所属势力槽。同 alliance+slot 的多个玩家共享单位控制权（co-op）。
var slot_id: int = 0
## Faction.Color 枚举值，决定贴图目录。
var faction_color: int = 1
@export var sprite_lift: float = 20.0:
	set(v): sprite_lift = v; _refresh_editor()
@export var shadow_width: int = 28:
	set(v): shadow_width = v; _refresh_editor()
@export var shadow_height: int = 12:
	set(v): shadow_height = v; _refresh_editor()
@export var shadow_alpha: float = 0.4:
	set(v): shadow_alpha = v; _refresh_editor()
@export var shadow_offset_x: float = 0.0:
	set(v): shadow_offset_x = v; _refresh_editor()
@export var shadow_offset_y: float = 0.0:
	set(v): shadow_offset_y = v; _refresh_editor()
@export var sprite_scale_x: float = 0.3:
	set(v): sprite_scale_x = v; _refresh_editor()
@export var sprite_scale_y: float = 0.3:
	set(v): sprite_scale_y = v; _refresh_editor()
@export var sprite_offset_x: float = 0.0:
	set(v): sprite_offset_x = v; _refresh_editor()
@export var sprite_offset_y: float = 0.0:
	set(v): sprite_offset_y = v; _refresh_editor()
@export var arrow_scene: PackedScene = null

var net_id: int = 0

const StatSetClass = preload("res://scripts/stats/stat_set.gd")
const UpgradeMgrClass = preload("res://scripts/stats/upgrade_manager.gd")
@export var stats_data: UnitStats
@export_group("Variant Modifiers")
@export var variant_hp_bonus: int = 0
@export var variant_atk_bonus: int = 0
@export var variant_speed_mult: float = 1.0
@export var variant_scale: float = 1.0
@export var variant_tint: Color = Color.WHITE      # 非白色=启用调色
@export var variant_tint_amount: float = 0.5
var stat_set
var upgrade_mgr
var steer_lock_time: float = 0.5

var state: UnitState = UnitState.GUARD
var attack_target = null
var attack_command_source: CommandSource = CommandSource.NONE
var attack_timer: float = 0.0
var selected: bool = false
var _was_selected: bool = false
var attack_move_target: Vector2 = Vector2.ZERO
var attack_move_scan_range: float = 300.0
var hold_position_mode: bool = false

# Buff 系统
var buffs: Dictionary = {}  # {buff_type: {"value": float, "expire": float}}
var _slow_factor: float = 1.0
var _slow_timer: float = 0.0
var _regen_accumulator: float = 0.0

# 光环系统
var aura_range: float = 0.0
var aura_type: String = ""
var aura_value: float = 0.0
var _aura_scan_timer: float = 0.0

# 技能系统（Phase 2）
var skill_components: Array = []        # SkillComponent 子节点列表
var mana: float = 0.0                   # 当前蓝量
var max_mana: float = 0.0               # 最大蓝量
var mana_regen: float = 0.0             # 每秒回蓝
var mana_type: int = 0                  # 0=NONE, 1=MAGE, 2=ARCHER
# 护盾值（保留在 unit.gd 供 take_damage 使用）
var _shield_hp: int = 0
var _taunt_expire_timer: float = 0.0    # 被嘲讽的剩余时间

# 中毒 DoT（2B Step6）
var _poison_dps: float = 0.0            # 当前中毒每秒伤害
var _poison_timer: float = 0.0          # 中毒剩余时间
var _poison_accumulator: float = 0.0    # DoT 累积器

# 召唤系统（Phase 2 — 仍保留在 unit.gd 供 summon_effect 调用）
var _summoned_minions: Array = []       # 当前存活的召唤物引用
var _summon_lifetime: float = 0.0       # 召唤物存活秒数（0=永久），从 stats 同步

# 命令队列 (Shift)
const CommandQueue = preload("res://scripts/systems/command_queue.gd")
var command_queue = CommandQueue.new()

# 巡逻系统
var patrol_points: Array = []
var patrol_index: int = 0

# 跟随系统
var follow_target = null

# Alt血条
static var show_all_health_bars: bool = false

# 寻路路径线
static var show_path_lines: bool = true

# 阶段 2.1：AI 扫描分帧。每单位每 SCAN_THROTTLE_FRAMES 帧才执行一次邻居扫描，
# 把扫描频率从 60Hz → 10Hz，CPU 直接砍 6 倍。玩家感知差异 ≈ 0（≤100ms 反应延迟）。
const SCAN_THROTTLE_FRAMES: int = 6
var _scan_phase: int = 0
var _cached_scan_enemy = null
var _cached_scan_wounded = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selection_ring: Node2D = $SelectionRing
@onready var hp_bar: ProgressBar = $HPBar
@onready var body_sprite: Sprite2D = $BodySprite
@onready var aggro_line: Line2D = $AggroLine
@onready var path_line: Line2D = $PathLine

# 缓存上次画 aggro_line 时的目标，避免每帧 clear+add 触发完全重画
var _aggro_target = null

# 动画
var _anim_state: String = ""
var _anim_frame: int = 0
var _anim_timer: float = 0.0
var _anim_fps: float = 8.0
var _tex_idle: Texture2D = null
var _tex_run: Texture2D = null
var _tex_attack: Texture2D = null
var _anim_total_frames: int = 6
var _frames_idle: int = 6
var _frames_run: int = 6
var _frames_attack: int = 6
var _is_attacking: bool = false
var _lateral_dir: Vector2 = Vector2.ZERO
var _lateral_timer: float = 0.0
var _blocked_timer: float = 0.0
var _is_blocked: bool = false
var _escaping_building: bool = false
var _escape_target: Vector2 = Vector2.ZERO
var _escape_timer: float = 0.0
const ShadowComp := preload("res://scripts/core/shadow_component.gd")
@onready var _shadow_component: ShadowComp = $ShadowComponent
const HealthComp := preload("res://scripts/core/health_component.gd")
@onready var health: HealthComp = $HealthComponent
var _state_indicator: ColorRect = null

signal died(unit: Unit)

func _ready() -> void:
	_setup_stats()
	_init_outline_materials()
	if Engine.is_editor_hint():
		_setup_editor_visuals()
	else:
		_setup_visuals()
		_update_selection_ring()
		_update_hp_bar()
	# 用 instance_id 把单位均匀分到 6 个 scan_phase，避免同帧扎堆扫描
	_scan_phase = get_instance_id() % SCAN_THROTTLE_FRAMES
	# 复仇者：延迟一帧扫描附近友军，连接死亡信号
	if stats_data and stats_data.vengeance_scan_range > 0:
		call_deferred("_setup_vengeance")


## 是否在本帧执行邻居扫描（每单位每 6 帧扫描一次）
func _should_scan_this_frame() -> bool:
	return Engine.get_physics_frames() % SCAN_THROTTLE_FRAMES == _scan_phase


## 校验缓存的目标是否仍可用（实例存活 + 未死）
func _is_target_alive(target) -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead()

func _init_outline_materials() -> void:
	if UnitEffectsShader == null:
		return
	_effects_material = ShaderMaterial.new()
	_effects_material.shader = UnitEffectsShader
	_effects_material.set_shader_parameter("glow_color", Color(1.0, 0.9, 0.3, 1.0))
	_effects_material.set_shader_parameter("glow_width", 3.0)
	_effects_material.set_shader_parameter("outline_enabled", false)
	_effects_material.set_shader_parameter("slow_enabled", false)
	_effects_material.set_shader_parameter("slow_tint", Color(0.5, 0.8, 1.0, 1.0))
	# 变体调色
	var use_tint := variant_tint != Color.WHITE
	_effects_material.set_shader_parameter("tint_enabled", use_tint)
	if use_tint:
		_effects_material.set_shader_parameter("tint_color", variant_tint)
		_effects_material.set_shader_parameter("tint_amount", variant_tint_amount)
	if body_sprite:
		body_sprite.material = _effects_material

func _setup_stats() -> void:
	if stats_data == null:
		return
	stat_set = StatSetClass.new(stats_data)
	upgrade_mgr = UpgradeMgrClass.new(stat_set)
	upgrade_mgr.setup_from_data(stats_data)
	var max_hp = stat_set.get_int(StatSetClass.MAX_HP)
	if health and not Engine.is_editor_hint():
		health.setup(max_hp, hp_bar, team)
	if stats_data.sprite_scale != 1.0:
		sprite_scale_x *= stats_data.sprite_scale
		sprite_scale_y *= stats_data.sprite_scale
	# 应用指挥官变体 tint（WHITE = 不变）
	if body_sprite and stats_data.tint != Color.WHITE:
		body_sprite.modulate = stats_data.tint
	# 应用变体修饰器（通过 add_modifier 改实际属性）
	if variant_hp_bonus != 0:
		stat_set.add_modifier("variant", StatSetClass.MAX_HP, float(variant_hp_bonus))
	if variant_atk_bonus != 0:
		stat_set.add_modifier("variant", StatSetClass.ATTACK_DAMAGE, float(variant_atk_bonus))
	if variant_speed_mult != 1.0:
		stat_set.add_modifier("variant", StatSetClass.MOVE_SPEED, 0.0, variant_speed_mult)
	if variant_scale != 1.0:
		sprite_scale_x *= variant_scale
		sprite_scale_y *= variant_scale
	# 同步 HP（修饰器可能改了 max_hp）
	if (variant_hp_bonus != 0) and health and not Engine.is_editor_hint():
		health.setup(stat_set.get_int(StatSetClass.MAX_HP), hp_bar, team)
	# 光环字段
	aura_range = stats_data.aura_range
	aura_type = stats_data.aura_type
	aura_value = stats_data.aura_value
	# Phase 2：蓝量初始化
	max_mana = stats_data.max_mana
	mana_regen = stats_data.mana_regen
	mana_type = stats_data.mana_type
	mana = max_mana
	# Phase 2：技能组件初始化
	_setup_skills()

func _setup_editor_visuals() -> void:
	_setup_texture()
	_rebuild_shadow()
	_apply_sprite_position()

func _setup_visuals() -> void:
	_setup_texture()

	# 创建脚底影子
	_rebuild_shadow()

	# 贴图上移
	_apply_sprite_position()

	# HPBar 跟随上移
	hp_bar.offset_top += sprite_lift + sprite_offset_y
	hp_bar.offset_bottom += sprite_lift + sprite_offset_y
	# ManaBar 跟随上移（如果存在）
	if has_node("ManaBar"):
		var mb := $ManaBar as ProgressBar
		mb.offset_top += sprite_lift + sprite_offset_y
		mb.offset_bottom += sprite_lift + sprite_offset_y
		mb.visible = max_mana > 0.0

	# 创建头顶状态指示小圆点
	_state_indicator = ColorRect.new()
	_state_indicator.size = Vector2(8, 8)
	_state_indicator.position = Vector2(-4, hp_bar.offset_top - 12)
	_state_indicator.visible = false
	add_child(_state_indicator)

func _setup_texture() -> void:
	var color_dir := Faction.color_dir(faction_color)
	_load_unit_textures(color_dir)
	# 素材缺失时 fallback 到蓝色（新颜色素材补全前的占位）
	if _tex_idle == null and color_dir != "blue":
		_load_unit_textures("blue")

func _safe_load_tex(path: String):
	if path == "" or not ResourceLoader.exists(path):
		return null
	return load(path)

func _load_unit_textures(color_dir_str: String) -> void:
	match unit_type:
		UnitType.SOLDIER:
			var base := "res://assets/units/%s_warrior" % color_dir_str
			_tex_idle = _safe_load_tex(base + "/Warrior_Idle.png")
			_tex_run = _safe_load_tex(base + "/Warrior_Run.png")
			_tex_attack = _safe_load_tex(base + "/Warrior_Attack1.png")
		UnitType.ARCHER:
			var base := "res://assets/units/%s_archer" % color_dir_str
			_tex_idle = _safe_load_tex(base + "/Archer_Idle.png")
			_tex_run = _safe_load_tex(base + "/Archer_Run.png")
			_tex_attack = _safe_load_tex(base + "/Archer_Shoot.png")
		UnitType.LANCER:
			var base := "res://assets/units/%s_lancer" % color_dir_str
			_tex_idle = _safe_load_tex(base + "/Lancer_Idle.png")
			_tex_run = _safe_load_tex(base + "/Lancer_Run.png")
			_tex_attack = _safe_load_tex(base + "/Lancer_DownRight_Attack.png")
		UnitType.MONK:
			var base := "res://assets/units/%s_monk" % color_dir_str
			_tex_idle = _safe_load_tex(base + "/Idle.png")
			_tex_run = _safe_load_tex(base + "/Run.png")
			_tex_attack = null

	var frame_w := 192
	if unit_type == UnitType.LANCER:
		frame_w = 320
	_frames_idle = _tex_idle.get_width() / frame_w if _tex_idle else 6
	_frames_run = _tex_run.get_width() / frame_w if _tex_run else 6
	_frames_attack = _tex_attack.get_width() / frame_w if _tex_attack else 6

	if not Engine.is_editor_hint():
		_set_anim("idle")
	else:
		if _tex_idle:
			body_sprite.texture = _tex_idle
			body_sprite.hframes = _frames_idle
			body_sprite.frame = 0

func _rebuild_shadow() -> void:
	if _shadow_component:
		_shadow_component.rebuild(shadow_width, shadow_height, shadow_alpha, shadow_offset_x, shadow_offset_y)

func _apply_sprite_position() -> void:
	if _shadow_component:
		_shadow_component.apply_sprite_position(body_sprite, sprite_scale_x, sprite_scale_y, sprite_lift, sprite_offset_x, sprite_offset_y)

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

	# 64x64 参考格子线
	var origin := Vector2(-cell / 2.0, -cell / 2.0)
	draw_rect(Rect2(origin, Vector2(cell, cell)), Color(1, 1, 1, 0.3), false, 1.0)

	# 碰撞圆（红色）
	draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 32, Color(1, 0, 0, 0.6), 1.0)

	# 阴影范围椭圆（黄色）
	var sw := float(shadow_width) / 2.0
	var sh := float(shadow_height) / 2.0
	var points := 32
	for i in range(points):
		var a1 := i * TAU / points
		var a2 := (i + 1) * TAU / points
		var p1 := Vector2(cos(a1) * sw + shadow_offset_x, sin(a1) * sh + shadow_offset_y)
		var p2 := Vector2(cos(a2) * sw + shadow_offset_x, sin(a2) * sh + shadow_offset_y)
		draw_line(p1, p2, Color(1, 1, 0, 0.6), 1.0)

func _set_anim(anim_name: String) -> void:
	if anim_name == _anim_state:
		return
	_anim_state = anim_name
	_anim_frame = 0
	_anim_timer = 0.0
	var tex: Texture2D = null
	match anim_name:
		"idle":
			tex = _tex_idle
			_anim_fps = 8.0
			_anim_total_frames = _frames_idle
		"run":
			tex = _tex_run
			_anim_fps = 10.0
			_anim_total_frames = _frames_run
		"attack":
			tex = _tex_attack
			_anim_fps = 12.0
			_anim_total_frames = _frames_attack
	if tex:
		body_sprite.texture = tex
		body_sprite.hframes = _anim_total_frames
		body_sprite.frame = 0
		body_sprite.visible = true

func _update_animation() -> void:
	if body_sprite.texture == null:
		return
	_anim_timer += get_physics_process_delta_time()
	var frame_duration := 1.0 / _anim_fps
	if _anim_timer >= frame_duration:
		_anim_timer -= frame_duration
		_anim_frame += 1
		if _anim_frame >= _anim_total_frames:
			if _anim_state == "attack":
				_anim_frame = _anim_total_frames - 1
			else:
				_anim_frame = 0
		body_sprite.frame = _anim_frame

	var target_anim := "idle"
	if state == UnitState.MOVE or state == UnitState.ATTACK_MOVE:
		target_anim = "run" if velocity.length_squared() > 1.0 else "idle"
	elif state == UnitState.ATTACK:
		if velocity.length_squared() > 1.0:
			target_anim = "run"
		elif _is_attacking:
			if _anim_frame >= _anim_total_frames - 1:
				_is_attacking = false
				target_anim = "idle"
			else:
				target_anim = "attack"
		else:
			target_anim = "idle"
	# UnitState.HEAL removed in Phase 2
	_set_anim(target_anim)


## 检查当前是否在某个建筑的碰撞区域内
func _is_inside_any_building() -> bool:
	for b in get_tree().get_nodes_in_group("buildings"):
		if b.is_dead():
			continue
		var rect: Rect2 = b.get_rect().grow(16.0)
		if rect.has_point(global_position):
			return true
	return false

## 计算从建筑内逃生的目标位置
func _find_escape_target() -> Vector2:
	var unit_radius := 16.0
	for b in get_tree().get_nodes_in_group("buildings"):
		if b.is_dead():
			continue
		var rect: Rect2 = b.get_rect().grow(unit_radius)
		if not rect.has_point(global_position):
			continue
		# 找到困住小兵的建筑，计算到四条边的距离
		var pos := global_position
		var dist_left := pos.x - rect.position.x
		var dist_right := rect.end.x - pos.x
		var dist_top := pos.y - rect.position.y
		var dist_bottom := rect.end.y - pos.y
		# 按距离排序四个逃生方向
		var tries := [
			[dist_left, Vector2(rect.position.x - 4.0, pos.y)],
			[dist_right, Vector2(rect.end.x + 4.0, pos.y)],
			[dist_top, Vector2(pos.x, rect.position.y - 4.0)],
			[dist_bottom, Vector2(pos.x, rect.end.y + 4.0)],
		]
		tries.sort_custom(func(a, b): return a[0] < b[0])
		for t in tries:
			var escape_pos: Vector2 = t[1]
			var valid := true
			for b2 in get_tree().get_nodes_in_group("buildings"):
				if b2.is_dead():
					continue
				if b2.get_rect().grow(unit_radius).has_point(escape_pos):
					valid = false
					break
			if valid:
				return escape_pos
	# 兜底：向下移动
	return global_position + Vector2(0, 64)

## 启动建筑内逃生
func _start_escape() -> void:
	_escaping_building = true
	_escape_target = _find_escape_target()
	_escape_timer = 3.0

## 结束逃生
func _stop_escape() -> void:
	_escaping_building = false
	_escape_target = Vector2.ZERO
	_escape_timer = 0.0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if state == UnitState.DEAD:
		return
	if stat_set == null:
		return
	# 过期 buff 清理
	_expire_buffs()
	# 再生
	if stats_data and stats_data.regen_per_sec > 0.0 and health.hp < health.max_hp:
		_regen_accumulator += stats_data.regen_per_sec * delta
		if _regen_accumulator >= 1.0:
			var heal_amt = int(_regen_accumulator)
			health.heal(heal_amt)
			_regen_accumulator -= heal_amt
	# 中毒 DoT
	if _poison_timer > 0.0:
		_poison_timer = max(0.0, _poison_timer - delta)
		_poison_accumulator += _poison_dps * delta
		if _poison_accumulator >= 1.0:
			var dot_dmg = int(_poison_accumulator)
			health.take_damage(dot_dmg)
			_poison_accumulator -= dot_dmg
	# 光环
	_aura_process(delta)
	# Phase 2：技能组件冷却递减 + 自定义 process
	for comp in skill_components:
		comp._skill_process(delta)
	# Phase 3：统一 AI 决策循环（PERIODIC_SCAN 技能按优先级触发）
	_skill_ai_tick(delta)
	# Phase 2：蓝量恢复
	if max_mana > 0.0 and mana < max_mana and mana_regen > 0.0:
		mana = min(max_mana, mana + mana_regen * delta)
	# 被嘲讽状态倒计时
	if _taunt_expire_timer > 0.0:
		_taunt_expire_timer = max(0.0, _taunt_expire_timer - delta)
	# 建筑内逃生逻辑（优先于正常状态机）
	if _escaping_building:
		_escape_timer -= delta
		if not _is_inside_any_building():
			_stop_escape()
		elif _escape_timer <= 0.0:
			global_position = _escape_target
			_stop_escape()
		else:
			var dir := global_position.direction_to(_escape_target)
			velocity = dir * stat_set.get_value(StatSetClass.MOVE_SPEED)
			move_and_slide()
			attack_timer = max(0.0, attack_timer - delta)
			_update_aggro_line()
			_update_animation()
			_update_state_indicator()
			return

	velocity = Vector2.ZERO

	match state:
		UnitState.GUARD:
			_guard_process(delta)
		UnitState.HOLD_POSITION:
			_hold_position_process(delta)
		UnitState.MOVE:
			_move_process()
		UnitState.ATTACK_MOVE:
			_attack_move_process(delta)
		UnitState.ATTACK:
			_attack_process(delta)

	# 减速效果
	if _slow_timer > 0.0:
		_slow_timer -= delta
		velocity *= _slow_factor
		if _effects_material:
			_effects_material.set_shader_parameter("slow_enabled", true)
	else:
		if _effects_material and _effects_material.get_shader_parameter("slow_enabled"):
			_effects_material.set_shader_parameter("slow_enabled", false)
	if velocity.length_squared() > 1.0:
		var prev_pos := global_position
		move_and_slide()
		var actual_move := global_position.distance_to(prev_pos)
		var expected_move = stat_set.get_value(StatSetClass.MOVE_SPEED) * delta
		if actual_move < expected_move * 0.3:
			velocity = Vector2.ZERO
			_blocked_timer = min(_blocked_timer + delta, 2.0)
			var was_blocked := _is_blocked
			_is_blocked = _blocked_timer > 0.1
			if _is_blocked and not was_blocked:
				if _is_inside_any_building():
					_start_escape()
		else:
			if _is_blocked:
				_blocked_timer -= delta * 0.1
				if _blocked_timer <= 0.0:
					_is_blocked = false
					_blocked_timer = 0.0
			else:
				_blocked_timer = 0.0
	else:
		_blocked_timer = max(_blocked_timer - delta, 0.0)
		if _blocked_timer <= 0.0:
			_is_blocked = false

	attack_timer = max(0.0, attack_timer - delta)
	_update_aggro_line()
	_update_path_line()
	_update_animation()
	_update_state_indicator()

func _move_process() -> void:
	if nav_agent.is_navigation_finished():
		state = UnitState.GUARD
		hold_position_mode = false
		return
	var next_pos := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_pos)
	velocity = direction * stat_set.get_value(StatSetClass.MOVE_SPEED)


## Phase 3：统一技能 AI 决策循环
## 按 priority 降序遍历 PERIODIC_SCAN 技能，第一个能激活的就触发
## 跳过 uses_custom_process 的组件（heal/convert 有自己持续逻辑）
## 同帧只触发一个技能，避免低优先级技能抢蓝
func _skill_ai_tick(delta: float) -> void:
	for comp in skill_components:
		if comp.skill_resource == null:
			continue
		if comp.skill_resource.trigger_condition != 1:  # PERIODIC_SCAN
			continue
		if comp.uses_custom_process:
			continue
		# trigger_interval 节流
		comp.trigger_timer += delta
		if comp.trigger_timer < comp.skill_resource.trigger_interval:
			continue
		comp.trigger_timer = 0.0
		# 检查能否激活 + 有无目标
		if not comp.can_activate():
			continue
		var target = comp.find_target()
		if target == null:
			continue
		# 触发！本轮不再检查其他技能
		comp.activate(target)
		break


func _attack_process(delta: float) -> void:
	# Monk不攻击，站着不动
	if unit_type == UnitType.MONK:
		return

	if attack_target == null or attack_target.is_dead():
		attack_target = null
		attack_command_source = CommandSource.NONE
		_is_attacking = false
		if hold_position_mode:
			state = UnitState.HOLD_POSITION
		elif attack_move_target != Vector2.ZERO:
			nav_agent.target_position = attack_move_target
			state = UnitState.ATTACK_MOVE
		else:
			state = UnitState.GUARD
			hold_position_mode = false
		return

	var dist := _get_dist_to_target(attack_target)
	if dist > get_effective_attack_range():
		# Phase 3：ON_CHASE 技能触发（闪现）— 统一走 activate()
		for comp in skill_components:
			if comp.skill_resource and comp.skill_resource.trigger_condition == 2:  # ON_CHASE
				if comp.can_activate():
					comp.activate(attack_target)
					dist = _get_dist_to_target(attack_target)
					break
		if hold_position_mode:
			attack_target = null
			attack_command_source = CommandSource.NONE
			_is_attacking = false
			state = UnitState.HOLD_POSITION
			return

		# Attack-Move 清区域：目标跑出扫描范围就放弃，换最近的
		if attack_move_target != Vector2.ZERO and attack_command_source == CommandSource.AUTO:
			var dist_to_target := global_position.distance_to(attack_target.global_position)
			if dist_to_target > attack_move_scan_range:
				attack_target = null
				attack_command_source = CommandSource.NONE
				_is_attacking = false
				nav_agent.target_position = attack_move_target
				state = UnitState.ATTACK_MOVE
				return

		var base_dir: Vector2

		if attack_target.has_method("get_rect"):
			# 建筑：用 NavAgent 导航（需避开建筑障碍区）
			var nav_target := _get_building_nav_target(attack_target)
			nav_agent.target_position = nav_target
			if not nav_agent.is_navigation_finished():
				base_dir = global_position.direction_to(nav_agent.get_next_path_position())
			else:
				base_dir = global_position.direction_to(attack_target.global_position)
		else:
			# 单位：直接追，不用 NavAgent
			base_dir = global_position.direction_to(attack_target.global_position)

		# 只有被堵住时才横向挣脱，否则直走
		if _is_blocked:
			velocity = _get_steered_direction(base_dir, delta) * stat_set.get_value(StatSetClass.MOVE_SPEED)
		else:
			_lateral_dir = Vector2.ZERO
			_lateral_timer = 0.0
			velocity = base_dir * stat_set.get_value(StatSetClass.MOVE_SPEED)
	else:
		if attack_timer <= 0.0:
			_perform_attack()
			attack_timer = stat_set.get_value(StatSetClass.ATTACK_COOLDOWN)

func _attack_move_process(delta: float) -> void:
	# Phase 2：Monk 治疗由技能组件处理，不再特殊分支
	if _should_scan_this_frame():
		_cached_scan_enemy = _find_closest_enemy_in_range(attack_move_scan_range)
	var closest = _cached_scan_enemy if _is_target_alive(_cached_scan_enemy) else null

	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
		nav_agent.target_position = _get_building_nav_target(closest)
		state = UnitState.ATTACK
		return

	# 没有敌人，继续移动
	if nav_agent.is_navigation_finished():
		state = UnitState.GUARD
		hold_position_mode = false
		return
	var next_pos2 := nav_agent.get_next_path_position()
	var base_dir2 := global_position.direction_to(next_pos2)
	if _is_blocked:
		velocity = _get_steered_direction(base_dir2, delta) * stat_set.get_value(StatSetClass.MOVE_SPEED)
	else:
		_lateral_dir = Vector2.ZERO
		_lateral_timer = 0.0
		velocity = base_dir2 * stat_set.get_value(StatSetClass.MOVE_SPEED)

func _find_closest_enemy_in_range(scan_range: float):
	var enemy_building_group := "enemy_buildings" if team == Team.PLAYER else "player_buildings"
	var closest = null
	var closest_dist: float = INF
	for u in UnitGrid.query_neighbors(global_position, scan_range):
		if u.is_dead():
			continue
		if u.team == team:
			continue  # grid 同时含友军和敌军，跳过同队
		# 隐身单位敌方不可见（仅对 Unit 有效）
		if u.has_method("is_stealthed") and u.is_stealthed():
			continue
		var d := global_position.distance_to(u.global_position)
		if d < scan_range and d < closest_dist:
			closest = u
			closest_dist = d
	for b in get_tree().get_nodes_in_group(enemy_building_group):
		if not b.has_method("is_dead") or b.is_dead():
			continue
		var d := global_position.distance_to(b.global_position)
		if d < scan_range and d < closest_dist:
			closest = b
			closest_dist = d
	return closest
func _patrol_process(delta: float) -> void:
	if patrol_points.is_empty():
		state = UnitState.GUARD
		return
	# 巡逻中遇敌自动交战（节流扫描）
	if _should_scan_this_frame():
		_cached_scan_enemy = _find_closest_enemy_in_range(attack_move_scan_range)
	var closest = _cached_scan_enemy if _is_target_alive(_cached_scan_enemy) else null
	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
		nav_agent.target_position = _get_building_nav_target(closest)
		state = UnitState.ATTACK
		return
	# 移动到当前巡逻点
	var target: Vector2 = patrol_points[patrol_index]
	if global_position.distance_to(target) < 20.0:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		target = patrol_points[patrol_index]
	nav_agent.target_position = target
	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * stat_set.get_value(StatSetClass.MOVE_SPEED)

func _guard_process(delta: float) -> void:
	# Phase 2：Monk 治疗由技能组件处理，不再特殊分支
	if _should_scan_this_frame():
		_cached_scan_enemy = _find_closest_enemy_in_range(attack_move_scan_range)
	var closest = _cached_scan_enemy if _is_target_alive(_cached_scan_enemy) else null
	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
		nav_agent.target_position = _get_building_nav_target(closest)
		state = UnitState.ATTACK
		hold_position_mode = false

func _hold_position_process(delta: float) -> void:
	if _should_scan_this_frame():
		_cached_scan_enemy = _find_closest_enemy_in_range(get_effective_attack_range())
	var closest = _cached_scan_enemy if _is_target_alive(_cached_scan_enemy) else null
	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
		state = UnitState.ATTACK
		hold_position_mode = true

func _get_building_nav_target(target, angle_offset: float = 0.0) -> Vector2:
	if not target.has_method("get_rect"):
		return target.global_position
	var brect: Rect2 = target.get_rect()
	var center := brect.get_center()
	var to_unit := global_position - center
	if to_unit.length_squared() < 1.0:
		return center + Vector2.RIGHT * brect.size.x / 2.0
	var angle := to_unit.angle() + angle_offset
	var half := brect.size / 2.0
	var ca := cos(angle)
	var sa := sin(angle)
	var dx: float = half.x / abs(ca) if abs(ca) > 0.001 else 999999.0
	var dy: float = half.y / abs(sa) if abs(sa) > 0.001 else 999999.0
	var d: float = minf(dx, dy)
	return center + Vector2(ca, sa) * (d + 25.0)

func _get_dist_to_target(target) -> float:
	if not target.has_method("get_rect"):
		return global_position.distance_to(target.global_position)
	var brect: Rect2 = target.get_rect()
	var nearest := global_position.clamp(brect.position, brect.end)
	return global_position.distance_to(nearest)

func _show_debug_text(text: String, color: Color) -> void:
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	get_tree().current_scene.add_child(ft)
	ft.setup(text, color, global_position + Vector2(0, -20))

func _get_steered_direction(base_dir: Vector2, delta: float) -> Vector2:
	# 通用1秒方向锁：设定了新方向就锁住不改，防止抖动
	if _lateral_dir != Vector2.ZERO and _lateral_timer < steer_lock_time:
		_lateral_timer += delta
		return _lateral_dir

	var scan_range := 50.0

	# Step 1: 收集前方±60°内的单位（友军+敌军），分左右
	var left_units: Array = []
	var right_units: Array = []

	# 一次 grid 查询拿到 50 半径内全部候选，后续两次角度筛选都基于此数组
	var neighbors: Array = UnitGrid.query_neighbors(global_position, scan_range)

	for u in neighbors:
		if u == self or u.is_dead():
			continue
		if u == attack_target:
			continue
		# 同方向移动的单位不算障碍（保持阵型）
		if u.velocity.length_squared() > 1.0:
			var vel_angle: float = abs(base_dir.angle_to(u.velocity))
			if vel_angle < PI / 4.0:
				continue
		var to_u: Vector2 = u.global_position - global_position
		var dist: float = to_u.length()
		if dist < scan_range and dist > 0.1:
			var angle: float = base_dir.angle_to(to_u)
			if abs(angle) < PI / 3.0:  # ±60°
				if angle < 0:
					left_units.append(to_u)
				else:
					right_units.append(to_u)

	var has_left: bool = not left_units.is_empty()
	var has_right: bool = not right_units.is_empty()

	# Step 2: 前方无单位 → 直走，清空锁
	if not has_left and not has_right:
		_lateral_dir = Vector2.ZERO
		_lateral_timer = 0.0
		return base_dir

	# Step 3: 单侧避让 → 锐角切线
	if has_left != has_right:
		var units: Array = left_units if has_left else right_units
		_lateral_dir = _calc_best_tangent(units, base_dir, true, true)
		_lateral_timer = 0.0
		return _lateral_dir

	# Step 4: 双侧都有单位
	var left_acute: Vector2 = _calc_best_tangent(left_units, base_dir, true, true)
	var right_acute: Vector2 = _calc_best_tangent(right_units, base_dir, true, true)

	var left_cross: float = left_acute.cross(base_dir)
	var right_cross: float = right_acute.cross(base_dir)
	var same_side: bool = (left_cross > 0) == (right_cross > 0)

	if same_side:
		# 4a: 同侧堵塞 → 选角度更大的切线
		var la: float = abs(left_acute.angle_to(base_dir))
		var ra: float = abs(right_acute.angle_to(base_dir))
		_lateral_dir = left_acute if la > ra else right_acute
		_lateral_timer = 0.0
		return _lateral_dir

	# 4b: 对侧拥堵 → 扩大扫描到±120°，钝角切线横向躲避（复用 neighbors，省一次 grid 查询）
	for u in neighbors:
		if u == self or u.is_dead() or u == attack_target:
			continue
		var to_u: Vector2 = u.global_position - global_position
		var dist: float = to_u.length()
		if dist < scan_range and dist > 0.1:
			var angle: float = base_dir.angle_to(to_u)
			if abs(angle) >= PI / 3.0 and abs(angle) < 2.0 * PI / 3.0:
				if angle < 0:
					left_units.append(to_u)
				else:
					right_units.append(to_u)

	var left_escape: Vector2 = _calc_best_tangent(left_units, base_dir, false, false)
	var right_escape: Vector2 = _calc_best_tangent(right_units, base_dir, false, false)

	var la2: float = abs(left_escape.angle_to(base_dir))
	var ra2: float = abs(right_escape.angle_to(base_dir))
	_lateral_dir = left_escape if la2 < ra2 else right_escape
	_lateral_timer = 0.0
	return _lateral_dir


# 计算一组单位的最佳切线方向
# acute: true=锐角切线(接近base_dir), false=钝角切线(远离base_dir)
# pick_smallest: true=选角度最小的单位, false=选角度最大的单位
func _calc_best_tangent(units: Array, base_dir: Vector2, acute: bool, pick_smallest: bool) -> Vector2:
	var best: Vector2 = base_dir
	var best_ang: float = INF if pick_smallest else -1.0
	for to_u_v in units:
		var to_u: Vector2 = to_u_v
		var t1: Vector2 = Vector2(-to_u.y, to_u.x).normalized()
		var t2: Vector2 = Vector2(to_u.y, -to_u.x).normalized()
		var tangent: Vector2
		if acute:
			tangent = t1 if t1.dot(base_dir) >= t2.dot(base_dir) else t2
		else:
			tangent = t1 if t1.dot(base_dir) < t2.dot(base_dir) else t2
		var ang: float = abs(tangent.angle_to(base_dir))
		if pick_smallest and ang < best_ang:
			best_ang = ang
			best = tangent
		elif not pick_smallest and ang > best_ang:
			best_ang = ang
			best = tangent
	return best

func _perform_attack() -> void:
	if attack_target and not attack_target.is_dead():
		# 自爆单位不进行普通攻击
		if stats_data and stats_data.explode_damage > 0 and stats_data.attack_damage <= 0:
			return
		# 劝化单位不进行普通攻击
		if stats_data and stats_data.convert_channel_time > 0 and stats_data.attack_damage <= 0:
			return
		if unit_type == UnitType.MONK and (stats_data == null or stats_data.projectile_data == null):
			return
		_is_attacking = true
		_set_anim("")
		_set_anim("attack")
		# 隐身单位攻击时显形
		_reveal_stealth_temporarily()
		var damage = stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
		var pd = stats_data.projectile_data if stats_data else null
		# 锥形攻击：对前方扇形范围内所有敌人造成伤害
		if stats_data and stats_data.cone_range > 0.0:
			_do_cone_attack(damage)
			return
		# 连锁闪电：命中主目标后弹射到附近敌人
		if stats_data and stats_data.chain_count > 0:
			_do_chain_attack(damage)
			return
		if unit_type == UnitType.ARCHER or (pd != null):
			_spawn_arrow(attack_target, damage)
		else:
			attack_target.take_damage(damage, self)
			# 击退：近战命中后将目标推开
			if stats_data and stats_data.knockback_force > 0.0 and attack_target is Unit and is_instance_valid(attack_target):
				var dir = (attack_target.global_position - global_position).normalized()
				attack_target.global_position += dir * stats_data.knockback_force
		# Phase 3：ON_ATTACK 技能触发（召唤、驱散）— 统一走 activate()
		for comp in skill_components:
			if comp.skill_resource and comp.skill_resource.trigger_condition == 0:  # ON_ATTACK
				if comp.can_activate():
					comp.activate(attack_target)
					break

## 连锁闪电：主目标受伤后弹射到附近 N 个敌人
func _do_chain_attack(damage: int) -> void:
	if not attack_target or not is_instance_valid(attack_target):
		return
	# 主目标承受全额伤害
	attack_target.take_damage(damage, self)
	# 连锁弹射
	var chained: Array = [attack_target]
	var chain_points: Array = [global_position, attack_target.global_position]
	var current_target = attack_target
	var current_dmg = damage
	for i in range(stats_data.chain_count):
		current_dmg = int(current_dmg * stats_data.chain_falloff)
		if current_dmg <= 0:
			break
		# 从当前目标位置搜索最近的未连锁敌人
		var best = null
		var best_dist = stats_data.chain_range
		for u in UnitGrid.query_neighbors(current_target.global_position, stats_data.chain_range):
			if not is_instance_valid(u) or u.is_dead():
				continue
			if u.team == team or u in chained:
				continue
			if not (u is Unit):
				continue
			var dist = current_target.global_position.distance_to(u.global_position)
			if dist <= best_dist:
				best_dist = dist
				best = u
		if best == null:
			break
		best.take_damage(current_dmg, self)
		# 只在首次命中时显示文字（后续弹跳不重复显示）
		if i == 0:
			_show_skill_text("连锁闪电")
		chained.append(best)
		chain_points.append(best.global_position)
		current_target = best
	# 闪电视觉特效
	_show_chain_effect(chain_points)

## 锥形 AoE：对前方扇形范围内所有敌人造成伤害
func _do_cone_attack(damage: int) -> void:
	if not attack_target or not is_instance_valid(attack_target):
		return
	var aim_dir = (attack_target.global_position - global_position).normalized()
	var half_angle = deg_to_rad(stats_data.cone_angle * 0.5)
	for u in UnitGrid.query_neighbors(global_position, stats_data.cone_range):
		if not is_instance_valid(u) or u.is_dead():
			continue
		if u.team == team:
			continue
		if not (u is Unit):
			continue
		var to_target = u.global_position - global_position
		var dist = to_target.length()
		if dist > stats_data.cone_range or dist < 1.0:
			continue
		var angle = aim_dir.angle_to(to_target.normalized())
		if abs(angle) <= half_angle:
			u.take_damage(damage, self)
	# 锥形视觉特效
	_show_cone_effect(aim_dir, stats_data.cone_range, stats_data.cone_angle)
	_show_skill_text("锥形攻击")

## 连锁闪电特效：在世界空间画短暂折线
func _show_chain_effect(points: Array) -> void:
	if points.size() < 2:
		return
	var line := Line2D.new()
	line.default_color = Color(0.5, 0.7, 1.0, 0.9)
	line.width = 3.0
	line.joint_mode = Line2D.LINE_JOINT_SHARP
	for p in points:
		line.add_point(p)
	get_tree().current_scene.add_child(line)
	var tw := create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.25)
	tw.tween_callback(line.queue_free)

## 锥形特效：画短暂半透明扇形
func _show_cone_effect(aim_dir: Vector2, range_val: float, angle_deg: float) -> void:
	var poly := Polygon2D.new()
	poly.color = Color(1.0, 0.5, 0.1, 0.25)
	var center := global_position
	var pts := PackedVector2Array()
	pts.append(center)
	var half := deg_to_rad(angle_deg * 0.5)
	var base_a := aim_dir.angle()
	var segs := 8
	for i in range(segs + 1):
		var a := base_a - half + (half * 2.0 * i / segs)
		pts.append(center + Vector2(cos(a), sin(a)) * range_val)
	poly.polygon = pts
	get_tree().current_scene.add_child(poly)
	var tw := create_tween()
	tw.tween_property(poly, "color:a", 0.0, 0.3)
	tw.tween_callback(poly.queue_free)

func _spawn_arrow(target, damage: int = -1) -> void:
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		var pd = stats_data.projectile_data if stats_data else null
		spawner.spawn_projectile(pd, global_position, target.global_position, target, self, damage, arrow_scene)

func take_damage(amount: int, attacker = null) -> void:
	if Engine.is_editor_hint():
		return
	if health.is_dead():
		return
	# 闪避
	if stats_data and stats_data.dodge_chance > 0.0 and randf() < stats_data.dodge_chance:
		return
	var final_amount := amount
	# 反特化：attacker 对 self.unit_type 有额外伤害倍率
	var atk_stats = attacker.stats_data if attacker is Unit else null
	if atk_stats:
		if atk_stats.bonus_vs_multiplier > 1.0 and unit_type in atk_stats.bonus_vs_unit_types:
			final_amount = int(final_amount * atk_stats.bonus_vs_multiplier)
		# 减伤计算（穿甲单位无视减伤）
		if not atk_stats.ignores_damage_reduction:
			var reduction = stat_set.get_value(StatSetClass.DAMAGE_REDUCTION)
			if reduction > 0.0:
				final_amount = int(final_amount * (1.0 - reduction))
	else:
		var reduction = stat_set.get_value(StatSetClass.DAMAGE_REDUCTION)
		if reduction > 0.0:
			final_amount = int(final_amount * (1.0 - reduction))
	# 护盾抵扣：先扣护盾，剩余伤害才进血量
	if _shield_hp > 0 and final_amount > 0:
		if _shield_hp >= final_amount:
			_shield_hp -= final_amount
			final_amount = 0
		else:
			final_amount -= _shield_hp
			_shield_hp = 0
	health.take_damage(final_amount)
	# 受击时显形
	_reveal_stealth_temporarily()
	# 吸血：attacker 根据造成伤害回血
	if final_amount > 0 and attacker is Unit:
		attacker._heal_from_lifesteal(final_amount)
	# 伤害飘字
	if final_amount > 0:
		var main_node := get_tree().current_scene
		if main_node and main_node.has_method("show_damage_number"):
			main_node.show_damage_number(final_amount, global_position)
	if attacker:
		if team == Team.ENEMY:
			_alert_enemy_response(attacker)
		elif team == Team.PLAYER:
			_player_retaliate(attacker)
	# AI 队友受击：上报求救（由 AllyDistressSignal 区域 CD 去重）
	if owner_id == -2 and attacker != null:
		AllyDistressSignal.report(global_position, self)
	if health.hp <= 0:
		die()

func _player_retaliate(attacker) -> void:
	# 已经在攻击有效目标时不切换
	if state == UnitState.ATTACK and attack_target != null and not attack_target.is_dead():
		return
	# 玩家手动指定的攻击目标不被自动索敌打断
	if attack_command_source == CommandSource.PLAYER:
		return
	# 玩家移动指令不被自动反击打断
	if state == UnitState.MOVE:
		return
	# 验证攻击者仍存活
	if attacker == null or not is_instance_valid(attacker) or attacker.is_dead():
		return

	attack_target = attacker
	attack_command_source = CommandSource.AUTO
	nav_agent.target_position = _get_building_nav_target(attacker)

	if state == UnitState.HOLD_POSITION:
		state = UnitState.ATTACK
		hold_position_mode = true
	else:
		state = UnitState.ATTACK
		hold_position_mode = false

	# 通知附近友军
	_alert_nearby_allies(attacker)

func _alert_nearby_allies(attacker) -> void:
	var alert_range := 400.0
	for u in UnitGrid.query_neighbors(global_position, alert_range):
		if u == self or u.is_dead():
			continue
		if u.team != team:
			continue
		if global_position.distance_to(u.global_position) <= alert_range:
			u._player_retaliate(attacker)

func _alert_enemy_response(attacker) -> void:
	# 通知自身AI
	var ai = get_node_or_null("EnemyAI")
	if ai and ai.has_method("on_attacked"):
		ai.on_attacked(attacker)
	# 广播给附近友军
	var alert_range := 400.0
	for u in UnitGrid.query_neighbors(global_position, alert_range):
		if u == self or u.is_dead():
			continue
		if u.team != Team.ENEMY:
			continue
		if global_position.distance_to(u.global_position) <= alert_range:
			var ally_ai = u.get_node_or_null("EnemyAI")
			if ally_ai and ally_ai.has_method("on_attacked"):
				ally_ai.on_attacked(attacker)

func die() -> void:
	state = UnitState.DEAD
	died.emit(self)
	# 自爆：死亡时对周围敌人造成范围伤害
	if stats_data and stats_data.explode_damage > 0 and stats_data.explode_radius > 0:
		for u in UnitGrid.query_neighbors(global_position, stats_data.explode_radius):
			if is_instance_valid(u) and not u.is_dead() and u.team != team:
				var dist = global_position.distance_to(u.global_position)
				if dist <= stats_data.explode_radius:
					var ratio = 1.0 - dist / stats_data.explode_radius
					var dmg = max(1, int(stats_data.explode_damage * ratio))
					u.take_damage(dmg, self)
	health._is_dead = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _reset_movement_state() -> void:
	_is_blocked = false
	_blocked_timer = 0.0
	_lateral_dir = Vector2.ZERO
	_lateral_timer = 0.0
	follow_target = null

func command_patrol(points: Array) -> void:
	_reset_movement_state()
	patrol_points = points
	patrol_index = 0
	attack_target = null
	attack_command_source = CommandSource.NONE
	hold_position_mode = false
	if not patrol_points.is_empty():
		nav_agent.target_position = patrol_points[0]
		state = UnitState.PATROL

func command_follow(target) -> void:
	_reset_movement_state()
	follow_target = target
	attack_target = null
	attack_command_source = CommandSource.NONE
	hold_position_mode = false
	state = UnitState.MOVE

func queue_move(target_pos: Vector2) -> void:
	var cmd := CommandQueue.QueuedCommand.new()
	cmd.type = CommandQueue.CommandType.MOVE
	cmd.target_pos = target_pos
	command_queue.enqueue(cmd)

func queue_attack_move(target_pos: Vector2) -> void:
	var cmd := CommandQueue.QueuedCommand.new()
	cmd.type = CommandQueue.CommandType.ATTACK_MOVE
	cmd.target_pos = target_pos
	command_queue.enqueue(cmd)

func queue_attack_target(target) -> void:
	var cmd := CommandQueue.QueuedCommand.new()
	cmd.type = CommandQueue.CommandType.ATTACK_TARGET
	cmd.target_pos = target.global_position if target else Vector2.ZERO
	cmd.target_unit = weakref(target) if target else null
	command_queue.enqueue(cmd)

func _try_dequeue_next_command() -> void:
	if command_queue.is_empty():
		return
	var cmd := command_queue.dequeue()
	match cmd.type:
		CommandQueue.CommandType.MOVE:
			move_to(cmd.target_pos)
		CommandQueue.CommandType.ATTACK_MOVE:
			attack_move_to(cmd.target_pos)
		CommandQueue.CommandType.ATTACK_TARGET:
			var target: Variant = cmd.target_unit.get_ref() if cmd.target_unit else null
			if is_instance_valid(target) and target.has_method("is_dead") and not target.is_dead():
				command_attack(target)
			else:
				_try_dequeue_next_command()

func move_to(target_pos: Vector2) -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = Vector2.ZERO
	hold_position_mode = false
	nav_agent.target_position = target_pos
	state = UnitState.MOVE

func attack_move_to(target_pos: Vector2) -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = target_pos
	hold_position_mode = false
	nav_agent.target_position = target_pos
	state = UnitState.ATTACK_MOVE

func stop() -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = Vector2.ZERO
	_is_attacking = false
	hold_position_mode = false
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	state = UnitState.GUARD

func hold_position() -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = Vector2.ZERO
	_is_attacking = false
	hold_position_mode = true
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	state = UnitState.HOLD_POSITION

func command_attack(target) -> void:
	_reset_movement_state()
	attack_target = target
	attack_command_source = CommandSource.PLAYER
	hold_position_mode = false
	nav_agent.target_position = _get_building_nav_target(target)
	state = UnitState.ATTACK

func set_selected(value: bool) -> void:
	selected = value
	_update_selection_ring()

func _update_selection_ring() -> void:
	if selection_ring:
		selection_ring.visible = selected
		if selected:
			selection_ring.team_color = Color(0.3, 0.6, 1.0, 0.6) if team == Team.PLAYER else Color(1.0, 0.3, 0.3, 0.6)
			if not _was_selected:
				selection_ring.flash()
	# 发光 shader uniform 切换
	if _effects_material:
		_effects_material.set_shader_parameter("outline_enabled", selected)
	_was_selected = selected
	_update_state_indicator()

func _update_hp_bar() -> void:
	if health:
		health._update_hp_bar()

func _update_state_indicator() -> void:
	if _state_indicator == null:
		return
	_state_indicator.visible = selected and team == Team.PLAYER
	if not _state_indicator.visible:
		return
	match state:
		UnitState.GUARD:
			_state_indicator.color = Color("#4CAF50")
		UnitState.HOLD_POSITION:
			_state_indicator.color = Color("#FFC107")
		UnitState.ATTACK:
			_state_indicator.color = Color("#F44336")
		UnitState.MOVE, UnitState.ATTACK_MOVE:
			_state_indicator.color = Color("#2196F3")

func _update_aggro_line() -> void:
	if state == UnitState.DEAD or aggro_line == null:
		return
	if attack_target != null and not attack_target.is_dead():
		if _aggro_target != attack_target:
			_aggro_target = attack_target
			aggro_line.visible = true
			aggro_line.clear_points()
			aggro_line.add_point(Vector2.ZERO)
			aggro_line.add_point(attack_target.global_position - global_position)
		else:
			var pts2 := PackedVector2Array([Vector2.ZERO, attack_target.global_position - global_position])
			aggro_line.points = pts2
	else:
		if _aggro_target != null:
			aggro_line.visible = false
			_aggro_target = null

func _update_path_line() -> void:
	if path_line == null:
		return
	if not show_path_lines or not selected or state == UnitState.DEAD:
		path_line.visible = false
		return
	if nav_agent.is_navigation_finished():
		path_line.visible = false
		return
	var path := nav_agent.get_current_navigation_path()
	var idx := nav_agent.get_current_navigation_path_index()
	if idx >= path.size():
		path_line.visible = false
		return
	path_line.visible = true
	path_line.clear_points()
	path_line.add_point(Vector2.ZERO)
	for i in range(idx, path.size()):
		path_line.add_point(path[i] - global_position)

func is_dead() -> bool:
	return health.is_dead() if health else state == UnitState.DEAD

func heal(amount: int) -> void:
	if health.is_dead():
		return
	health.heal(amount)
	var effect: Node2D = HealEffectScene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position

# ============================================================
# Buff 系统
# ============================================================
func apply_buff(buff_type: String, value: float) -> void:
	var now_msec := Time.get_ticks_msec()
	buffs[buff_type] = {"value": value, "expire": now_msec + 1500}
	# 同步修饰器到 StatSet
	match buff_type:
		"defense":
			stat_set.add_modifier("buff:defense", StatSetClass.DAMAGE_REDUCTION, 0.0, 1.0 - value)
		"attack":
			stat_set.add_modifier("buff:attack", StatSetClass.ATTACK_DAMAGE, 0.0, 1.0 + value)
		"attack_melee":
			stat_set.add_modifier("buff:attack_melee", StatSetClass.ATTACK_DAMAGE, 0.0, 1.0 + value)
		"range_bonus":
			stat_set.add_modifier("buff:range_bonus", StatSetClass.ATTACK_RANGE, value, 1.0)

## 带自定义持续时间的 buff（duration_msec 毫秒）
func apply_buff_duration(buff_type: String, value: float, duration_msec: int) -> void:
	var now_msec := Time.get_ticks_msec()
	buffs[buff_type] = {"value": value, "expire": now_msec + duration_msec}
	match buff_type:
		"defense":
			stat_set.add_modifier("buff:defense", StatSetClass.DAMAGE_REDUCTION, 0.0, 1.0 - value)
		"attack":
			stat_set.add_modifier("buff:attack", StatSetClass.ATTACK_DAMAGE, 0.0, 1.0 + value)
		"attack_melee":
			stat_set.add_modifier("buff:attack_melee", StatSetClass.ATTACK_DAMAGE, 0.0, 1.0 + value)
		"range_bonus":
			stat_set.add_modifier("buff:range_bonus", StatSetClass.ATTACK_RANGE, value, 1.0)

func _expire_buffs() -> void:
	var now_msec := Time.get_ticks_msec()
	var expired := []
	for buff_type in buffs:
		if now_msec > buffs[buff_type]["expire"]:
			expired.append(buff_type)
	for bt in expired:
		buffs.erase(bt)
		stat_set.remove_source("buff:" + bt)

func has_buff(buff_type: String) -> bool:
	if buff_type not in buffs:
		return false
	if Time.get_ticks_msec() > buffs[buff_type]["expire"]:
		buffs.erase(buff_type)
		stat_set.remove_source("buff:" + buff_type)
		return false
	return true

func get_buff_value(buff_type: String) -> float:
	if not has_buff(buff_type):
		return 0.0
	return buffs[buff_type]["value"]

func apply_slow(factor: float, duration: float) -> void:
	_slow_factor = 1.0 - factor
	_slow_timer = duration


## 施加中毒 DoT（Venomblade 的 PoisonEffect 调用）
func apply_poison(dps: float, duration: float) -> void:
	_poison_dps = dps
	_poison_timer = duration
	_poison_accumulator = 0.0


## 清除自身所有 debuff（中毒/减速）
func cleanse_debuffs() -> void:
	_poison_dps = 0.0
	_poison_timer = 0.0
	_poison_accumulator = 0.0
	_slow_timer = 0.0
	_slow_factor = 1.0
	if _effects_material:
		_effects_material.set_shader_parameter("slow_enabled", false)


## 驱散：命中目标时清除其所有增益 buff（Inquisitor）
func dispel_target(target_node) -> void:
	if not stats_data or not stats_data.dispel_on_hit:
		return
	if target_node == null or not is_instance_valid(target_node):
		return
	if target_node.has_method("clear_buffs"):
		target_node.clear_buffs()
	_show_skill_text("驱散")


## 清除自身所有增益 buff（被驱散时调用）
func clear_buffs() -> void:
	var keys = buffs.keys()
	for bt in keys:
		stat_set.remove_source("buff:" + bt)
		buffs.erase(bt)


# ============== 召唤系统（2B Step7） ==============

## 攻击命中后尝试召唤一个 minion（Necromancer）
func _try_summon_minion() -> void:
	if stats_data == null or stats_data.summon_max <= 0:
		return
	if randf() > stats_data.summon_chance:
		return
	_prune_dead_minions()
	if _summoned_minions.size() >= stats_data.summon_max:
		return

	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner == null:
		return

	# 确定弹道目标位置：当前攻击目标的位置
	var target_pos: Vector2
	if attack_target and is_instance_valid(attack_target):
		target_pos = attack_target.global_position
	else:
		target_pos = global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60))

	const SummonProjectileScene := preload("res://scenes/effects/summon_projectile.tscn")
	var callback := func():
		if not is_instance_valid(self):
			return
		var final_pos := target_pos
		if attack_target and is_instance_valid(attack_target) and not attack_target.is_dead():
			final_pos = attack_target.global_position
		var minion = spawner.spawn_summon(
			stats_data.summon_type,
			stats_data.summon_stats_id,
			final_pos,
			team
		)
		if minion == null:
			return
		minion.connect("died", Callable(self, "_on_minion_died"))
		_summoned_minions.append(minion)
		if stats_data.summon_lifetime > 0.0:
			var tw := create_tween()
			tw.tween_interval(stats_data.summon_lifetime)
			tw.tween_callback(func():
				if is_instance_valid(minion) and not minion.is_dead():
					minion.die()
			)
		_show_skill_text("召唤")

	spawner.spawn_projectile(null, global_position, target_pos, null, self, 0, SummonProjectileScene, callback)


## 清理已死亡/失效的 minion 引用
func _prune_dead_minions() -> void:
	var alive: Array = []
	for m in _summoned_minions:
		if is_instance_valid(m) and not m.is_dead():
			alive.append(m)
	_summoned_minions = alive


## minion 死亡时从列表移除
func _on_minion_died(_minion: Unit) -> void:
	_prune_dead_minions()




## 吸血回血：根据造成的伤害和自身吸血属性回血
func _heal_from_lifesteal(damage_dealt: int) -> void:
	if not stats_data or damage_dealt <= 0:
		return
	var heal_amt := 0
	if stats_data.lifesteal_ratio > 0.0:
		heal_amt += int(damage_dealt * stats_data.lifesteal_ratio)
	if stats_data.lifesteal_flat > 0:
		heal_amt += stats_data.lifesteal_flat
	if heal_amt > 0 and health.hp < health.max_hp:
		health.heal(heal_amt)



## 复仇者：扫描附近友军并连接死亡信号
func _setup_vengeance() -> void:
	var range_val := stats_data.vengeance_scan_range
	if range_val <= 0.0:
		return
	for u in UnitGrid.query_neighbors(global_position, range_val):
		if is_instance_valid(u) and not u.is_dead() and u.team == team:
			if not u.died.is_connected(_on_ally_died):
				u.died.connect(_on_ally_died)


## 复仇者：友军死亡时获得攻击加成
func _on_ally_died(_ally: Unit) -> void:
	if not stats_data or stats_data.vengeance_buff_duration <= 0.0:
		return
	var dur_msec := int(stats_data.vengeance_buff_duration)
	apply_buff_duration("attack", stats_data.vengeance_buff_value, dur_msec)


# ============== 隐身 / 闪现（2B Step4） ==============

## 当前是否处于隐身状态（委托给 StealthSkill 组件）
func is_stealthed() -> bool:
	if stats_data == null or not stats_data.stealth_on_idle:
		return false
	for comp in skill_components:
		if comp.has_method("is_stealthed"):
			return comp.is_stealthed()
	return false


## 受击/攻击后短暂显形（委托给 StealthSkill 组件）
func _reveal_stealth_temporarily() -> void:
	if stats_data != null and stats_data.stealth_on_idle:
		for comp in skill_components:
			if comp.has_method("reveal_temporarily"):
				comp.reveal_temporarily()
				return


## 当前护盾值（供 UI / 调试用）
func get_shield_hp() -> int:
	return _shield_hp


## 设置护盾值（供 ShieldSkill 调用）
func set_shield_hp(amount: int) -> void:
	_shield_hp = max(_shield_hp, amount)


## 嘲讽者：周期性扫描范围内敌方单位，强制其攻击自己
func force_attack_target(target_node, duration_sec: float) -> void:
	if target_node == null or not is_instance_valid(target_node):
		return
	if target_node.is_dead():
		return
	attack_target = target_node
	attack_command_source = CommandSource.AUTO
	_taunt_expire_timer = max(_taunt_expire_timer, duration_sec)
	if state != UnitState.ATTACK:
		state = UnitState.ATTACK


## 是否处于被嘲讽状态（供 AI 决策参考）
func is_taunted() -> bool:
	return _taunt_expire_timer > 0.0


# ============== 劝化（2B Step8） ==============

## 劝化引导：锁定射程内一个敌方单位，持续引导 convert_channel_time 秒后转化
func _convert_unit(target: Unit) -> void:
	if target == null or not is_instance_valid(target) or target.is_dead():
		return
	var old_group := "enemy_units" if target.team == Team.ENEMY else "player_units"
	var new_group := "player_units" if target.team == Team.ENEMY else "enemy_units"
	var new_alliance := 0 if target.team == Team.ENEMY else 1
	# 切换分组
	if target.is_in_group(old_group):
		target.remove_from_group(old_group)
	# 切换阵营（setter 自动同步 team）
	target.alliance_id = new_alliance
	target.add_to_group(new_group)
	# 移动到对方节点树下
	var new_parent_name := "PlayerUnits" if new_alliance == 0 else "EnemyUnits"
	var new_parent := get_tree().current_scene.get_node_or_null(new_parent_name)
	if new_parent:
		var old_pos := target.global_position
		target.reparent(new_parent)
		target.global_position = old_pos
	# 若原为敌方单位，移除其 EnemyAI 子节点
	var ai := target.get_node_or_null("EnemyAI")
	if ai:
		ai.queue_free()
	# 清除目标的攻击目标（避免转化后立刻攻击新队友）
	target.attack_target = null
	target.attack_command_source = CommandSource.NONE
	if target.state == UnitState.ATTACK:
		target.state = UnitState.GUARD
	_show_skill_text("劝化")




## Phase 2：根据 stats_data.skills 创建 SkillComponent 子节点
func _setup_skills() -> void:
	if stats_data == null or stats_data.skills.is_empty():
		return
	for skill_res in stats_data.skills:
		if skill_res == null:
			continue
		var comp: Node = _create_skill_component(skill_res)
		if comp == null:
			continue
		comp.skill_resource = skill_res
		comp.name = "Skill_" + skill_res.skill_name
		add_child(comp)
		skill_components.append(comp)
		comp.skill_activated.connect(_on_unit_skill_activated)
	# Phase 3：按 priority 降序排列（高优先级先获得蓝量分配）
	skill_components.sort_custom(func(a: Node, b: Node):
		return a.skill_resource.priority > b.skill_resource.priority
	)


## Phase 3：技能激活信号回调 — 跨切面扩展点
## 未来在此添加扣钱、扣血、日志、事件推送等逻辑
func _on_unit_skill_activated(target) -> void:
	pass


## 根据技能名创建对应的 SkillComponent（preload + duck typing）
func _create_skill_component(skill_res) -> Node:
	match skill_res.skill_name:
		"嘲讽":
			return load("res://scripts/skills/skill_effects/taunt_effect.gd").new()
		"闪现":
			return load("res://scripts/skills/skill_effects/blink_effect.gd").new()
		"隐身":
			return load("res://scripts/skills/skill_effects/stealth_effect.gd").new()
		"劝化":
			return load("res://scripts/skills/skill_effects/convert_effect.gd").new()
		"护盾":
			return load("res://scripts/skills/skill_effects/shield_effect.gd").new()
		"召唤":
			return load("res://scripts/skills/skill_effects/summon_effect.gd").new()
		"治疗":
			return load("res://scripts/skills/skill_effects/heal_effect.gd").new()
		"驱散":
			return load("res://scripts/skills/skill_effects/dispel_effect.gd").new()
	return null


## 在单位头顶显示技能名浮动文字（绿色）
func _show_skill_text(skill_name: String) -> void:
	if not is_instance_valid(self):
		return
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	get_tree().current_scene.add_child(ft)
	ft.setup(skill_name, Color(0.3, 1.0, 0.3), global_position + Vector2(0, -40))

## 光环扫描：每 0.5s 对范围内友军施加光环效果
func _aura_process(delta: float) -> void:
	if aura_range <= 0.0:
		return
	_aura_scan_timer += delta
	if _aura_scan_timer < 0.5:
		return
	_aura_scan_timer = 0.0
	var neighbors = UnitGrid.query_neighbors(global_position, aura_range)
	for u in neighbors:
		if not is_instance_valid(u) or u.is_dead() or u.team != team:
			continue
		if global_position.distance_to(u.global_position) > aura_range:
			continue
		match aura_type:
			"regen":
				if u.health.hp < u.health.max_hp:
					u.health.heal(int(aura_value * 0.5))
			"attack":
				u.apply_buff("attack", aura_value)
			"defense":
				u.apply_buff("defense", aura_value)
			"range_bonus":
				u.apply_buff("range_bonus", aura_value)
			"shield":
				# 护盾叠加（不超过 aura_value 上限）
				if u._shield_hp < int(aura_value):
					u._shield_hp = int(aura_value)

func get_effective_attack_range() -> float:
	return stat_set.get_value(StatSetClass.ATTACK_RANGE)
