extends Node2D

const D := preload("res://scripts/systems/game_data.gd")
const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")
const MapConfigScript := preload("res://scripts/map_config.gd")
const DifficultyClass := preload("res://scripts/difficulty.gd")
const AllyDistressMarkerScript := preload("res://scripts/ui/ally_distress_marker.gd")

# Map configuration
@export var map_config: MapConfigScript = null

# Victory condition node reference
var victory_condition: VictoryCondition = null

# Fallback defaults
var NAV_BOUNDS := [Vector2(-500, -500), Vector2(1500, -500), Vector2(1500, 1200), Vector2(-500, 1200)]

# 自定义光标管理器
var cursor_manager: Node = null

# 节点引用
@onready var camera: Camera2D = $Camera2D
@onready var selection_box: ColorRect = $SelectionBox
@onready var player_units_node: Node2D = $PlayerUnits
@onready var enemy_units_node: Node2D = $EnemyUnits
@onready var buildings_node: Node2D = $Buildings
@onready var result_label: Label = $ResultLabel
@onready var attack_move_indicator: Label = $AttackMoveIndicator
@onready var preview_rect: ColorRect = $PreviewRect
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D

# 模块
var ui_module: Node
var camera_module: Node
var spawner_module: Node
var building_placer: Node
var combat_ctrl: Node
var input_mode: Node  # InputModeManager
var commander_skill_manager: Node
var commander_skill_panel: Node
var upgrade_manager: Node
var upgrade_panel: Node
var unit_upgrade_manager: Node
var t3_upgrade_manager: Node = null
var tech_point_manager: Node = null
var _available_skills: Array = []

# T1 D10: 玩家主基地缓存（用于建造范围判定 is_in_buildable_area）
var player_castle: Node = null

# 全局玩家集结点
var global_rally_point: Vector2 = Vector2.ZERO
var has_global_rally: bool = false
var _rally_indicator: Node2D = null

# 控制组管理器
var ctrl_group_mgr: RefCounted

# 双击检测
var _last_left_click_time: float = 0.0
var _last_left_click_pos: Vector2 = Vector2.ZERO
const DOUBLE_CLICK_TIME := 0.3
const DOUBLE_CLICK_DIST := 10.0

# 编队双击检测
var _group_tap_times: Array = []  # 10个时间戳

# 游戏状态
var gold: int = 10000
var key_to_mode: Dictionary = {}
var map_bounds := Rect2(-500, -500, 2000, 1700)
var show_damage_numbers: bool = true
var _diff_preset: Resource = null  # DifficultyPreset
var show_fps: bool = false
var show_collisions: bool = false
var canvas_modulate: CanvasModulate = null
var _units_lost: int = 0  # 星级评价用：玩家损失单位数
# T3 PR-3 战斗统计
var _enemies_killed: int = 0  # 玩家击杀敌方单位数
var _units_trained: int = 0  # 玩家建造单位数（面板+兵营）
var _buildings_constructed: int = 0  # 玩家建造建筑数
var _gold_earned: int = 0  # 玩家累计获得金币（只算正向收入）
var _game_start_time: float = 0.0  # 本局开始时间（_game_time 起点，一般为 0）
var _initialized: bool = false  # _run_init_steps 跑完前 _process/_input 直接 return
# AI 队友求救感叹号列表（main 实例化，distress_cleared 时清除）
var _distress_markers: Array[Node2D] = []
var _distress_rescue_check_timer: float = 0.0

# 统一游戏时间（吃 Engine.time_scale 加速）；波次/能量/HUD 都从这里取
var _game_time: float = 0.0

# T2 PR-1: 时代升级状态机（player_age=当前时代，1=T1；unlocked_items=已解锁的 PlaceMode 列表）
var player_age: int = 1
var unlocked_items: Array[int] = []
var age_upgrade_timer: float = 0.0
var age_upgrade_target: int = 0  # 0=未在升级中；2=正在升 T2
var _last_upgrade_tick: int = -1  # 上次飘字进度秒数，防重复
const AGE_UPGRADE_COST := {2: 500, 3: 1000}
const AGE_UPGRADE_TIME := {2: 15.0, 3: 30.0}

func get_game_time() -> float:
	return _game_time

func _enter_tree() -> void:
	# map_config 由 PackedScene 实例化时已注入（早于 _enter_tree）。
	# 子节点（包括 PlayerUnits 下的预设单位）的 _ready 会在根节点 _ready 之前触发，
	# 但都在根节点 _enter_tree 之后，因此此处设置 BalanceScheme.current 是安全的。
	if map_config and map_config.balance_scheme > 0:
		BalanceScheme.current = map_config.balance_scheme as BalanceScheme.Scheme

func _ready() -> void:
	result_label.visible = false
	attack_move_indicator.text = tr("UI_ATTACK_MOVE")
	attack_move_indicator.visible = false
	preview_rect.visible = false
	_run_init_steps()

# 分帧初始化：每个段落之间 await process_frame 让 LoadRouter 进度条有机会刷新
func _run_init_steps() -> void:
	# Step -1: 技能视觉控制器（PR-6，技能脚本经 static instance 调用）
	var skill_visual := SkillVisualController.new()
	skill_visual.name = "SkillVisualController"
	add_child(skill_visual)

	# Step 0: 光标管理器
	LoadRouter.report_init_progress(0.05)
	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	cursor_manager = CursorManagerScene.instantiate()
	add_child(cursor_manager)
	await get_tree().process_frame

	# Step 1: 多人模式地图配置
	LoadRouter.report_init_progress(0.10)
	if RelayManager.is_online and map_config == null:
		var map_path := "res://resources/" + RelayManager._map_name.replace("_", "") + "_config.tres"
		map_config = load(map_path)
	await get_tree().process_frame

	# Step 2: 配置/设置/地形
	LoadRouter.report_init_progress(0.20)
	_load_from_config()
	_apply_loadout_filter()  # 玩家战前编制 ∩ 关卡允许 = 实际可用
	_init_unlocked_items()  # T2 PR-1: 初始化时代锁定列表（剔除 ARCHERY_RANGE + ARCHER）
	_load_damage_number_setting()
	_load_display_settings()
	_load_brightness()
	_load_audio_settings()
	_replace_ground_with_terrain()
	await get_tree().process_frame

	# Step 3: UI 模块
	LoadRouter.report_init_progress(0.30)
	ui_module = Node.new()
	ui_module.set_script(load("res://scripts/systems/game_ui.gd"))
	ui_module.name = "GameUI"
	add_child(ui_module)
	ui_module.initialize(self, map_config, gold)
	ui_module.place_mode_requested.connect(_on_place_mode_requested)
	key_to_mode = ui_module.key_to_mode
	await get_tree().process_frame

	# Step 4: 相机模块（camera_module 在此创建，豁免矩形必须在此之后注入）
	LoadRouter.report_init_progress(0.40)
	camera_module = Node.new()
	camera_module.set_script(load("res://scripts/systems/game_camera.gd"))
	add_child(camera_module)
	camera_module.initialize(camera, map_bounds)
	camera_module.speed_multiplier = _load_gameplay_settings()
	# 底部 UI 条遮屏区：鼠标在此矩形内不触发边缘滚动。高度用 D.BOTTOM_UI_PX 统一管理。
	var _vp_size := get_viewport().get_visible_rect().size
	camera_module.ui_exclusion_rects.append(
		Rect2(0, _vp_size.y - D.BOTTOM_UI_PX, _vp_size.x, D.BOTTOM_UI_PX))
	await get_tree().process_frame

	# Step 5: 生成模块 + 建筑放置（依赖 ui_module）
	LoadRouter.report_init_progress(0.50)
	spawner_module = Node.new()
	spawner_module.set_script(load("res://scripts/systems/game_spawner.gd"))
	add_child(spawner_module)
	spawner_module.initialize(self, player_units_node, enemy_units_node, buildings_node)
	spawner_module.set_floating_text_layer(ui_module.get_floating_text_layer())
	spawner_module.set_difficulty(_diff_preset)
	building_placer = Node.new()
	building_placer.set_script(load("res://scripts/systems/building_placer.gd"))
	add_child(building_placer)
	building_placer.initialize(map_bounds, NAV_BOUNDS, nav_region, buildings_node, preview_rect, ui_module)
	# T1 D5: 同步"显示建造范围"设置（building_placer 是 main 子节点，Step 2 时还未创建）
	var _cfg := ConfigFile.new()
	if _cfg.load("user://settings.cfg") == OK:
		building_placer.show_build_range = _cfg.get_value("game", "show_build_range", false)
	spawner_module.place_building_callback = building_placer.place_building
	spawner_module.snap_to_grid_callback = building_placer.snap_to_grid
	spawner_module.is_grid_free_callback = building_placer.is_grid_free
	await get_tree().process_frame

	# Step 5.5: 据点指挥官调度器（依赖 spawner；早于 spawn_from_config 实例化，便于 spawn 时即时 tag）
	var outpost_commander_manager = Node.new()
	outpost_commander_manager.name = "OutpostCommanderManager"
	outpost_commander_manager.set_script(load("res://scripts/outpost/outpost_commander_manager.gd"))
	add_child(outpost_commander_manager)

	# Step 6: 战斗/选择 + 输入模式 + 控制组
	LoadRouter.report_init_progress(0.60)
	combat_ctrl = Node.new()
	combat_ctrl.set_script(load("res://scripts/systems/combat_controller.gd"))
	add_child(combat_ctrl)
	combat_ctrl.initialize(spawner_module)
	combat_ctrl.selection_changed.connect(_on_selection_changed)
	input_mode = Node.new()
	input_mode.set_script(load("res://scripts/systems/input_mode_manager.gd"))
	add_child(input_mode)
	input_mode.mode_changed.connect(_on_input_mode_changed)
	const CtrlGroupMgr := preload("res://scripts/systems/control_group_manager.gd")
	ctrl_group_mgr = CtrlGroupMgr.new()
	for i in range(10):
		_group_tap_times.append(0.0)
	await get_tree().process_frame

	# Step 7: 指挥官技能系统（依赖 spawner）
	LoadRouter.report_init_progress(0.70)
	const CSD := preload("res://scripts/commander_skill/commander_skill_data.gd")
	# 注入玩家指挥官 profile（决定可用单位/建筑变体 + 面板技能 + 起始金币）
	var selected_id: StringName = CommanderChoice.player_selected_id
	# T1: temp_flag 强制指挥官（test_all：全单位/建筑变体可见，无 economy_boost）
	if SaveManager.has_temp_flag("force_commander"):
		selected_id = SaveManager.get_temp_flag("force_commander")
	elif selected_id == &"" or not CommanderRegistry.has_profile(selected_id):
		selected_id = &"balanced"
	var commander_profile = CommanderRegistry.get_profile(selected_id)
	CommanderContext.set_player_profile(commander_profile)
	PassiveSkillManager.set_profile(commander_profile)
	if commander_profile != null and commander_profile.starting_gold_bonus > 0:
		gold += commander_profile.starting_gold_bonus
		ui_module.update_gold(gold) if ui_module.has_method("update_gold") else null
	commander_skill_manager = Node.new()
	commander_skill_manager.set_script(load("res://scripts/commander_skill/commander_skill_manager.gd"))
	add_child(commander_skill_manager)
	var available_skills: Array = _resolve_available_skills()
	_available_skills = available_skills
	commander_skill_manager.initialize(self, spawner_module, func(): return gold, func(cost: int): _spend_gold(cost))
	commander_skill_manager.set_available_skills(available_skills)
	commander_skill_panel = Node.new()
	commander_skill_panel.set_script(load("res://scripts/commander_skill/commander_skill_panel.gd"))
	add_child(commander_skill_panel)
	commander_skill_panel.initialize(self, commander_skill_manager)
	commander_skill_panel.skill_button_pressed.connect(_on_commander_skill_button_pressed)
	await get_tree().process_frame

	# Step 7.5: 科技点系统
	LoadRouter.report_init_progress(0.75)
	tech_point_manager = Node.new()
	tech_point_manager.set_script(load("res://scripts/tech/tech_point_manager.gd"))
	add_child(tech_point_manager)
	tech_point_manager.level_unlocked.connect(_on_tech_level_unlocked)
	tech_point_manager.points_changed.connect(_on_tech_points_changed)
	var tech_timer := Timer.new()
	tech_timer.name = "TechPointTimer"
	tech_timer.wait_time = 60.0
	tech_timer.autostart = true
	tech_timer.timeout.connect(_on_tech_passive_timer)
	add_child(tech_timer)
	await get_tree().process_frame

	# Step 8: 升级系统（双向依赖 spawner）
	LoadRouter.report_init_progress(0.80)
	upgrade_manager = Node.new()
	upgrade_manager.set_script(load("res://scripts/upgrade/upgrade_manager.gd"))
	add_child(upgrade_manager)
	upgrade_manager.initialize(self)
	upgrade_manager.set_spawner(spawner_module)
	spawner_module.set_upgrade_manager(upgrade_manager)
	# T2 PR-4: 兵种全局升级（金币购买）
	unit_upgrade_manager = Node.new()
	unit_upgrade_manager.set_script(load("res://scripts/upgrade/unit_upgrade_manager.gd"))
	add_child(unit_upgrade_manager)
	unit_upgrade_manager.initialize(self)
	spawner_module.set_unit_upgrade_manager(unit_upgrade_manager)
	# T3 PR-2: T3 升级管理器
	t3_upgrade_manager = Node.new()
	t3_upgrade_manager.set_script(load("res://scripts/upgrade/t3_upgrade_manager.gd"))
	t3_upgrade_manager.name = "T3UpgradeManager"
	add_child(t3_upgrade_manager)
	spawner_module.set_t3_upgrade_manager(t3_upgrade_manager)
	# T3 PR-2: N 选 1 弹窗
	var t3_dialog := CanvasLayer.new()
	t3_dialog.set_script(load("res://scripts/ui/t3_choice_dialog.gd"))
	t3_dialog.name = "T3ChoiceDialog"
	add_child(t3_dialog)
	t3_dialog.choice_confirmed.connect(_on_t3_choice_confirmed)
	# T3 PR-2: 场景替换执行器
	var t3_replacer := Node.new()
	t3_replacer.set_script(load("res://scripts/systems/t3_unit_replacer.gd"))
	t3_replacer.name = "T3UnitReplacer"
	add_child(t3_replacer)
	t3_replacer.initialize(self, t3_upgrade_manager, unit_upgrade_manager)
	upgrade_panel = Node.new()
	upgrade_panel.set_script(load("res://scripts/upgrade/upgrade_panel.gd"))
	add_child(upgrade_panel)
	upgrade_panel.initialize(self, upgrade_manager)
	ui_module.upgrade_button_pressed.connect(_on_upgrade_button_pressed)
	upgrade_manager.token_count_changed.connect(ui_module.update_upgrade_tokens)
	# TODO: 测试用初始升级币，测试完毕后删除
	upgrade_manager.add_token(0)  # 1 白银
	upgrade_manager.add_token(1)  # 1 黄金
	upgrade_manager.add_token(2)  # 1 钻石
	await get_tree().process_frame

	# Step 9: 实体生成 + 多人 + 网格 + 环境 + setup + camera_start
	LoadRouter.report_init_progress(0.90)
	var has_preplaced := _has_preplaced_entities()
	if has_preplaced:
		building_placer.register_preplaced_buildings(buildings_node)
		_init_preplaced_units()
		# 给预放置敌方建筑/单位补打 commander_ids（与 spawn_from_config 路径对齐）
		spawner_module.tag_all_existing_for_commanders()
	else:
		spawner_module.spawn_from_config(map_config)
		# 兜底：spawn 完成后给所有现存敌方建筑/单位补打 commander_ids
		spawner_module.tag_all_existing_for_commanders()
		# 新格式地图：玩家方按 player_sessions 占用情况动态生成 slot
		_spawn_dynamic_players()
	# AI 队友（单机模式；预放置和配置生成两种情况都支持）
	_spawn_ai_allies()
	if RelayManager.is_online:
		LockstepSync.set_game(self)
		if RelayManager._game_seed != 0:
			LockstepSync._start_game(RelayManager._game_seed)
	building_placer.create_grid()
	# 装饰物刷新范围用【可玩区】（扣除底部装饰水带 BOTTOM_SKIRT_H），避免在水带上刷树/石。
	# 仅当 map_config 存在时扣除（与 _load_from_config 里扩 map_bounds 的条件一致）。
	var _spawn_bounds := map_bounds
	if map_config != null:
		_spawn_bounds.size.y -= D.BOTTOM_SKIRT_H
	spawner_module.spawn_environment(map_config, _spawn_bounds)
	_setup_victory_condition()
	_setup_capture_points()
	_setup_ambush_triggers()
	_setup_adaptive_reinforcement()
	_setup_boss_ai()
	_setup_grand_tactic_releasers()
	_setup_wave_manager()
	_setup_outpost_capture_signals()
	if map_config != null:
		camera.position = map_config.camera_start
	# 连接 AI 队友求救信号
	if not AllyDistressSignal.distress_reported.is_connected(_on_ally_distress_reported):
		AllyDistressSignal.distress_reported.connect(_on_ally_distress_reported)
	if not AllyDistressSignal.distress_cleared.is_connected(_on_ally_distress_cleared):
		AllyDistressSignal.distress_cleared.connect(_on_ally_distress_cleared)
	# 应用战前被动（玩家选的 3 个 UpgradeId，在所有单位生成之后应用）
	_apply_pre_battle_passives()
	# T1 D10: 缓存玩家主基地（建造范围判定的圆心）
	_cache_player_castle()
	# T1: 清理 temp_flag（本局已消费，避免影响下一局）
	SaveManager.clear_temp_flags()
	await get_tree().process_frame

	# Step 10: 完成
	_initialized = true
	LoadRouter.report_init_progress(1.0)
	LoadRouter.finish_init()
	ui_module.update_gold_display(gold)
	# T3 PR-3: 记录开始时间 + 显示开局一次性提示
	_game_start_time = _game_time
	var intro_hint := CanvasLayer.new()
	intro_hint.set_script(load("res://scripts/ui/intro_hint_dialog.gd"))
	intro_hint.name = "IntroHintDialog"
	add_child(intro_hint)

func _has_preplaced_entities() -> bool:
	for child in player_units_node.get_children():
		if child is Unit:
			return true
	for child in enemy_units_node.get_children():
		if child is Unit:
			return true
	for child in buildings_node.get_children():
		if child.has_method("is_dead"):
			return true
	return false

func _init_preplaced_units() -> void:
	for unit in player_units_node.get_children():
		if not unit is Unit:
			continue
		# 预放置单位走 .tscn 设的 team；faction_color 默认 BLUE，按 team 显式补全防御性
		unit.faction_color = Faction.ColorId.BLUE
		unit.connect("died", Callable(self, "_on_unit_died"))
		unit.add_to_group("player_units")

	for unit in enemy_units_node.get_children():
		if not unit is Unit:
			continue
		# .tscn 里敌方只设了 team=ENEMY，没设 faction_color（默认 BLUE）；这里按 team 推导为 RED 并重载贴图
		unit.faction_color = Faction.ColorId.RED
		if unit.has_method("_setup_texture"):
			unit._setup_texture()
		unit.connect("died", Callable(self, "_on_unit_died"))
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(load("res://scripts/units/enemy_ai.gd"))
		unit.add_child(ai)

func _load_from_config() -> void:
	if map_config == null:
		return
	NAV_BOUNDS = map_config.nav_bounds
	map_bounds = map_config.map_bounds
	# 底部装饰水带：仅扩 map_bounds（地形+相机+小地图），nav_bounds 不变 → 单位仍锁原可玩区
	map_bounds.size.y += D.BOTTOM_SKIRT_H
	gold = map_config.initial_gold
	# 加载难度预设并应用金币乘数
	var diff_level := DifficultyClass.load_from_config()
	_diff_preset = DifficultyClass.get_preset(map_config, diff_level)
	gold = int(gold * _diff_preset.gold_mult)

func _replace_ground_with_terrain() -> void:
	var ground_node = get_node_or_null("Ground")
	if ground_node and ground_node is ColorRect:
		ground_node.queue_free()

	var terrain_layer := TileMapLayer.new()
	terrain_layer.name = "Ground"
	terrain_layer.z_index = -10
	terrain_layer.set_script(load("res://scripts/terrain_layer.gd"))
	add_child(terrain_layer)
	move_child(terrain_layer, 0)

	var theme := 0
	var water_areas: Array[Rect2] = []
	var border_w := 1
	if map_config != null:
		theme = map_config.terrain_theme
		water_areas = map_config.water_areas.duplicate()  # duplicate 避免 append 污染 .tres 资源数组
		border_w = map_config.border_width
		# 底部装饰水带（map_bounds 已在 _load_from_config 扩过 BOTTOM_SKIRT_H，仅地形+相机+小地图可见）
		water_areas.append(Rect2(map_bounds.position.x,
			map_bounds.end.y - D.BOTTOM_SKIRT_H,
			map_bounds.size.x, D.BOTTOM_SKIRT_H))
	terrain_layer.setup(map_bounds, theme, water_areas, border_w)

func _setup_victory_condition() -> void:
	for child in get_children():
		if child is VictoryCondition:
			victory_condition = child
			victory_condition.game_ended.connect(_on_game_ended)
			victory_condition.set_game_controller(self)
			break

var _game_result_saved := false

func _on_game_ended(result: String) -> void:
	if _game_result_saved:
		return
	_game_result_saved = true
	# T2 PR-1: 游戏结束时清理时代升级悬空状态
	age_upgrade_target = 0
	age_upgrade_timer = 0.0
	# T2 PR-3: 隐藏城堡头顶进度条
	if player_castle != null and is_instance_valid(player_castle):
		player_castle.set_age_upgrade_progress(0.0)
	if RelayManager.is_online:
		_show_mp_result(result)
		return

	# 通知 SaveManager 记录结果
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		var diff_level := DifficultyClass.load_from_config()
		sm.end_game_session(result, diff_level)
		# 首次胜利解锁 test_all 指挥官
		if result == "victory" and not sm.is_commander_unlocked("test_all"):
			sm.unlock_commander("test_all")

	if result == "victory":
		_show_victory_panel(sm)
	else:
		_show_defeat_panel(sm)


func _show_mp_result(result: String):
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(overlay)

	var label := Label.new()
	label.text = tr("RESULT_VICTORY") if result == "victory" else tr("RESULT_DEFEAT")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.0) if result == "victory" else Color(1, 0.3, 0.3))
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.offset_left = -200
	label.offset_right = 200
	label.offset_top = -60
	label.offset_bottom = 60
	canvas.add_child(label)

	var btn := Button.new()
	btn.text = "Back to Menu"
	btn.custom_minimum_size = Vector2(160, 44)
	btn.add_theme_font_size_override("font_size", 16)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	btn.offset_left = -80
	btn.offset_right = 80
	btn.offset_top = 40
	btn.offset_bottom = 84
	btn.pressed.connect(func():
		RelayManager.disconnect_from_server()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	canvas.add_child(btn)

func _show_victory_panel(sm: Node) -> void:
	result_label.visible = false

	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 520)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	canvas.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "胜  利"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(title)

	# SaveManager 历史数据（最佳用时 + 总分，沿用现有 UX）
	if sm:
		var elapsed: float = sm.get_last_session_time()
		var save_data: Dictionary = sm.get_current_data()
		var total: int = sm.calc_total_score(save_data)
		var sm_box := VBoxContainer.new()
		sm_box.add_theme_constant_override("separation", 4)
		var best_label := Label.new()
		best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		best_label.add_theme_font_size_override("font_size", 18)
		best_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.5))
		best_label.text = tr("SAVE_BEST_TIME") % sm.format_time(elapsed)
		sm_box.add_child(best_label)
		var score_label := Label.new()
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_label.add_theme_font_size_override("font_size", 18)
		score_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		score_label.text = tr("SAVE_TOTAL_SCORE") % [total, 100]
		sm_box.add_child(score_label)
		vbox.add_child(sm_box)

	# T3 PR-3: 本局统计区
	_add_stats_section(vbox, true)

	var btn := Button.new()
	btn.text = tr("SAVE_CONTINUE")
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.custom_minimum_size = Vector2(160, 44)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/level_select.tscn"))
	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim_button(btn)
	vbox.add_child(btn)


# T3 PR-3: 失败面板（与胜利对称，红色调）
func _show_defeat_panel(_sm: Node) -> void:
	result_label.visible = false

	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.2, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 520)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	canvas.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "失  败"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(title)

	# T3 PR-3: 本局统计区
	_add_stats_section(vbox, false)

	var btn := Button.new()
	btn.text = tr("SAVE_CONTINUE")
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.custom_minimum_size = Vector2(160, 44)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/level_select.tscn"))
	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim_button(btn)
	vbox.add_child(btn)


# T3 PR-3: 统计区构建（胜利/失败共用）
func _add_stats_section(parent: Container, _is_victory: bool) -> void:
	var stats_data := _collect_game_stats()
	for item in stats_data:
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 8)
		var label := Label.new()
		label.text = item.label + ":"
		label.add_theme_font_size_override("font_size", 14)
		row.add_child(label)
		var value := Label.new()
		value.text = str(item.value)
		value.add_theme_font_size_override("font_size", 14)
		value.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		row.add_child(value)
		parent.add_child(row)


# T3 PR-3: 收集本局统计（7 项）
func _collect_game_stats() -> Array:
	var time_used := _game_time - _game_start_time
	var minutes := int(time_used) / 60
	var seconds := int(time_used) % 60
	var time_str := "%d:%02d" % [minutes, seconds]
	return [
		{"label": "用时", "value": time_str},
		{"label": "剩余金币", "value": gold},
		{"label": "获得金币总数", "value": _gold_earned},
		{"label": "击杀敌方单位", "value": _enemies_killed},
		{"label": "损失单位", "value": _units_lost},
		{"label": "建造单位数", "value": _units_trained},
		{"label": "建造建筑数", "value": _buildings_constructed},
	]

func _setup_capture_points() -> void:
	for child in get_children():
		if child is CapturePoint:
			child.set_game_controller(self)
			if not child.captured.is_connected(_on_capture_point_captured):
				child.captured.connect(_on_capture_point_captured.bind(child))


# 占领 capture_point 后的回调：检查是否配置了 AI 队友延迟增援
func _on_capture_point_captured(_team: int, point: CapturePoint) -> void:
	# 集结点被占领 → 指定小队转为进攻（关卡4阶段切换）
	if point.name == "RallyCP":
		var rally_target: Vector2 = point.get_meta("rally_attack_target", Vector2.ZERO)
		if rally_target != Vector2.ZERO:
			AllyCommander.issue_squad_attack_order("south", rally_target)
	var delay: float = point.ally_reinforcement_delay
	if delay <= 0.0 or point.ally_reinforcement_groups.is_empty():
		return
	if RelayManager.is_online:
		return  # 多人模式不支持 AI 队友
	var spawn_pos: Vector2 = point.global_position
	var target: Vector2 = _find_nearest_enemy_pos(spawn_pos)
	# 屏幕提示
	spawner_module.show_floating_text(tr("ALLY_REINFORCEMENT_INCOMING"), Color(1.0, 0.85, 0.0), spawn_pos)
	# 延迟生成
	var timer := get_tree().create_timer(delay)
	timer.timeout.connect(_on_ally_reinforcement_timeout.bind(point.ally_reinforcement_groups, spawn_pos, target))
	# === 连续增援波次 ===
	var repeat: int = point.ally_reinforcement_repeat
	if repeat > 0:
		var interval: float = point.ally_reinforcement_interval
		for i in range(repeat):
			var wave_delay: float = delay + (i + 1) * interval
			var rtimer := get_tree().create_timer(wave_delay)
			rtimer.timeout.connect(_on_ally_reinforcement_timeout.bind(point.ally_reinforcement_groups, spawn_pos, target))


func _on_ally_reinforcement_timeout(groups: Array, spawn_pos: Vector2, target: Vector2) -> void:
	if not is_instance_valid(self):
		return
	spawner_module.spawn_ally_wave(groups, spawn_pos, target)


# 找最近的敌方建筑/单位位置作为增援目标
func _find_nearest_enemy_pos(from: Vector2) -> Vector2:
	var nearest: Vector2 = from + Vector2(800, 0)
	var nearest_dist: float = INF
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if not is_instance_valid(b) or b.is_dead():
			continue
		var d: float = from.distance_to(b.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = b.global_position
	if nearest_dist == INF:
		for u in get_tree().get_nodes_in_group("enemy_units"):
			if not (u is CharacterBody2D) or u.is_dead():
				continue
			var d2: float = from.distance_to(u.global_position)
			if d2 < nearest_dist:
				nearest_dist = d2
				nearest = u.global_position
	return nearest

func _setup_ambush_triggers() -> void:
	for child in get_children():
		if child is AmbushTrigger:
			child.set_game_controller(self)

func _setup_adaptive_reinforcement() -> void:
	for child in get_children():
		if child is AdaptiveReinforcement:
			child.set_game_controller(self)

func _setup_boss_ai() -> void:
	var boss_ais := get_tree().get_nodes_in_group("boss_ai")
	for boss in boss_ais:
		if boss.has_method("set_game_controller"):
			boss.set_game_controller(self)

func _setup_grand_tactic_releasers() -> void:
	var releasers := get_tree().get_nodes_in_group("grand_tactic_releaser")
	for r in releasers:
		if r.has_method("set_game_controller"):
			r.set_game_controller(self)

func _setup_wave_manager() -> void:
	for child in get_children():
		if child is WaveManager:
			child.set_game_controller(self)
			child.set_difficulty(_diff_preset)
			# PR-3：从 map_config 注入 waves（数据驱动；为空则保留场景级 @export）
			if map_config != null and map_config.waves.size() > 0:
				child.waves = map_config.waves
			child.wave_started.connect(_on_wave_started)
			child.countdown_updated.connect(_on_countdown_updated)
			child.all_waves_completed.connect(_on_all_waves_completed)
			child.wave_warning_triggered.connect(_on_wave_warning_triggered)
			child.start_waves()
			break

# PR-4：连接所有 OutpostCommander 的占领信号
func _setup_outpost_capture_signals() -> void:
	for cmdr in find_children("*", "OutpostCommander", true, false):
		if cmdr.has_signal("outpost_captured") and not cmdr.outpost_captured.is_connected(_on_outpost_captured):
			cmdr.outpost_captured.connect(_on_outpost_captured.bind(cmdr))

# PR-4：据点被玩家占领 → 实例化绿色光圈 + 通知 building_placer 加 captured ring + 通知 ui_module 显示据点分类
func _on_outpost_captured(team: int, cmdr: Node) -> void:
	if team != 0:
		return  # 仅玩家方占领触发
	var ring_scene := preload("res://scenes/effects/outpost_capture_ring.tscn")
	var ring: Node2D = ring_scene.instantiate()
	add_child(ring)
	ring.global_position = cmdr.global_position
	var radius: float = 200.0
	if cmdr.config != null:
		radius = cmdr.config.territory_radius
	ring.setup(radius)
	# 通知 building_placer 加 captured ring（仅 ALTAR_ARCHER 可造）
	if building_placer and building_placer.has_method("add_captured_outpost_ring"):
		building_placer.add_captured_outpost_ring(cmdr.global_position, radius)
	# 通知 UI 显示据点建筑分类
	if ui_module and ui_module.has_method("show_outpost_category"):
		ui_module.show_outpost_category()

func _on_wave_started(_wave_number: int) -> void:
	_wave_clear_notified = false

func _on_wave_warning_triggered(wave_number: int, spawn_pos: Vector2) -> void:
	# PR-3：在 spawn_pos 实例化红色脉冲 warning_marker，30s 后自毁
	var marker_scene := preload("res://scenes/effects/warning_marker.tscn")
	var marker := marker_scene.instantiate()
	add_child(marker)
	marker.global_position = spawn_pos
	var lifetime: float = 30.0  # warning_time → spawn_time 固定 30s
	marker.setup(wave_number, lifetime)
	# PR-3 修复：小地图右下角红点脉冲（复用 minimap.flash_at）
	if ui_module and ui_module.has_method("get_minimap"):
		var minimap = ui_module.get_minimap()
		if minimap != null and minimap.has_method("flash_at"):
			minimap.flash_at(spawn_pos, Color(1.0, 0.2, 0.2), lifetime)

func _on_countdown_updated(wave_number: int, remaining: float, total: int) -> void:
	ui_module.update_wave_countdown(wave_number, remaining, total)

func _on_all_waves_completed() -> void:
	ui_module.hide_wave_countdown()

func _on_place_mode_requested(mode: int) -> void:
	# T2 PR-1: 时代锁定拦截（按钮未 disable 时点击会触发此处）
	if int(mode) not in unlocked_items:
		_show_era_locked_hint(mode)
		return
	# 金币/农场上限等前置拦截：进入放置模式前就提示，避免 ghost 拖到落地才报错
	var reason: int = building_placer.check_build_block(mode)
	if reason != BuildingPlacer.BuildBlockReason.OK:
		var key := BuildingPlacer.reason_to_translation_key(reason)
		if key != &"":
			show_floating_text(tr(key), Color(1, 0.3, 0.3), get_global_mouse_position())
		return
	building_placer.enter_place_mode(mode)
	combat_ctrl.set_attack_move_mode(false)


# T2 PR-1: 时代锁定提示（在城堡头顶飘字"需要升级到 T2 时代"）
func _show_era_locked_hint(mode: int) -> void:
	var msg := tr("ERA_LOCKED_HINT")
	if msg == "" or msg == "ERA_LOCKED_HINT":
		msg = "需要升级到 T2 时代"
	var pos := get_global_mouse_position()
	show_floating_text(msg, Color(1.0, 0.6, 0.6), pos)


# T2 PR-1: 城堡头顶位置（飘字用），兜底屏幕中心
func _castle_head_pos() -> Vector2:
	if player_castle != null and is_instance_valid(player_castle):
		return player_castle.global_position + Vector2(0, -60)
	return Vector2(960, 540)


func _on_selection_changed(units: Array, buildings: Array = [], peek_building = null) -> void:
	ui_module.update_selection_info(units, buildings, peek_building)


func _on_input_mode_changed(new_mode: int) -> void:
	# 切换模式时取消当前放置状态
	if new_mode == 0:  # DEFAULT
		building_placer.cancel_place_mode()
		ui_module.hide_place_mode_label()
		ui_module.set_build_panel_highlight(false)

	elif new_mode == 1:  # UNIT_PRODUCTION
		building_placer.cancel_place_mode()
		ui_module.switch_tab(0)
		ui_module.set_place_mode_text(tr("MODE_UNIT_PRODUCTION"))
		ui_module.set_build_panel_highlight(true)

	elif new_mode == 2:  # BUILDING_PLACEMENT
		building_placer.cancel_place_mode()
		ui_module.switch_tab(1)
		ui_module.set_place_mode_text(tr("MODE_BUILDING_PLACEMENT"))
		ui_module.set_build_panel_highlight(true)



func _keycode_to_group_index(keycode: int) -> int:
	if keycode == KEY_0:
		return 9
	var idx := keycode - KEY_1
	if idx >= 0 and idx <= 8:
		return idx
	return -1


func _handle_number_key(key: int, event: InputEventKey) -> void:
	# QW 改造：数字键 1-9 永远只用于编队，不再造兵（造兵改用 QWER ASDF）
	# Ctrl+数字键：分配编队
	if event.ctrl_pressed:
		var gi := _keycode_to_group_index(key)
		if gi >= 0:
			ctrl_group_mgr.assign_group(gi, combat_ctrl.selected_units)
		return

	# 默认模式：编队操作
	var gi := _keycode_to_group_index(key)
	if gi < 0:
		return

	# Shift+数字键：添加编队到选择
	if event.shift_pressed:
		ctrl_group_mgr.add_group_to_selection(gi, combat_ctrl)
		return

	# 单击数字键：选中编队（双击=居中镜头）
	var now := Time.get_ticks_msec() / 1000.0
	if now - _group_tap_times[gi] < DOUBLE_CLICK_TIME:
		ctrl_group_mgr.center_camera_on_group(gi, camera_module)
	else:
		ctrl_group_mgr.select_group(gi, combat_ctrl)
	_group_tap_times[gi] = now


# QW 改造：处理 QWER ASDF 网格键（仅 QW 模式激活时）
func _handle_grid_key(key: int) -> void:
	if not ui_module.key_to_mode.has(key):
		return
	var mode: int = ui_module.key_to_mode[key]
	if input_mode.is_unit_production():
		_quick_produce_unit(mode)
	elif input_mode.is_building_placement():
		ui_module.switch_tab_for_mode(mode)
		_on_place_mode_requested(mode)


# QW 改造：Tab 键永远切菜单（单位 → 建筑 → 据点 → 单位），同时自动进入对应 QW 模式
# cycle_subgroup 子组切换功能取消快捷键
func _handle_tab_key(shift_pressed: bool) -> void:
	ui_module.cycle_tab()


# --- 多人建造/生产 (由 LockstepSync 回调) ---

## 新格式地图：按 player_sessions 占用情况动态生成玩家方 slot。
## 玩家方 alliance=0 的所有 slot 在配置里声明，运行时只生成被占用的。
## 没人占据的 slot 保持空地。两人选同槽 = 共享控制（owner_id=-1）。
## 旧格式地图走 fallback，玩家方已在 spawn_from_config 内生成，此函数自动跳过。
func _spawn_dynamic_players() -> void:
	if map_config == null or map_config.alliances.is_empty():
		return
	if NetworkManager.player_sessions.is_empty():
		# 单机：确保有一个默认 session（已在 NetworkManager._ready 中创建）
		pass
	# 找玩家方联盟（is_ai=false 的第一个）
	var player_alliance: Dictionary = {}
	for a in map_config.alliances:
		if not a.get("is_ai", false):
			player_alliance = a
			break
	if player_alliance.is_empty():
		return
	var slots: Array = player_alliance.get("slots", [])
	# 统计每个 slot 被哪些玩家占用
	var slot_occupied: Dictionary = {}  # slot_idx -> Array[player_id]
	for pid in NetworkManager.player_sessions:
		var s: Dictionary = NetworkManager.player_sessions[pid]
		if s.get("alliance_id", 0) != 0:
			continue
		var slot_idx: int = s.get("slot_id", 0)
		if not slot_occupied.has(slot_idx):
			slot_occupied[slot_idx] = []
		slot_occupied[slot_idx].append(pid)
	# 为每个被占用的 slot 生成（用占用人颜色；多人同槽共享控制）
	for slot_idx in slot_occupied.keys():
		if slot_idx >= slots.size():
			continue
		var owners: Array = slot_occupied[slot_idx]
		var primary_pid: int = owners[0]
		var s: Dictionary = NetworkManager.player_sessions[primary_pid]
		var color: int = s.get("color", Faction.ColorId.BLUE)
		spawner_module.spawn_slot_initial(slots[slot_idx], slot_idx, -1, color)
	# 初始化占用的玩家金币（各自独立池）
	for slot_idx in slot_occupied.keys():
		var owners: Array = slot_occupied[slot_idx]
		var slot_cfg: Dictionary = slots[slot_idx] if slot_idx < slots.size() else {}
		var slot_gold: int = slot_cfg.get("initial_gold", map_config.initial_gold)
		for pid in owners:
			NetworkManager.player_sessions[pid]["gold"] = slot_gold
	# 自己的金币复制到 main.gold 便于旧代码读取
	var my_sess: Dictionary = NetworkManager.player_sessions.get(NetworkManager.my_id, {})
	if my_sess.get("gold", -1) >= 0:
		gold = my_sess["gold"]


# 单机模式 AI 队友：从 map_config.ai_allies 生成黄色盟军（owner_id=-2）
# 多人模式下强制跳过，避免 lockstep 同步复杂度
func _spawn_ai_allies() -> void:
	if RelayManager.is_online:
		return
	if map_config == null or map_config.ai_allies.is_empty():
		return
	for spawn in map_config.ai_allies:
		var behavior: String = spawn.get("behavior", "follow")
		var defend_pos: Vector2 = spawn.get("defend_pos", Vector2.ZERO)
		var squad: String = spawn.get("squad_id", "general")
		spawner_module.spawn_ally_unit_initial(spawn.type, spawn.pos, behavior, defend_pos, squad)


# === AI 队友求救系统回调 ===

func _on_ally_distress_reported(world_pos: Vector2, _victim: Node) -> void:
	# 1. 屏幕文字（世界位置漂浮）
	spawner_module.show_floating_text(tr("ALLY_DISTRESS_TEXT"), Color(1.0, 0.85, 0.0), world_pos)
	# 2. 地图感叹号
	var marker: Node2D = AllyDistressMarkerScript.new()
	add_child(marker)
	marker.setup(world_pos)
	_distress_markers.append(marker)


func _on_ally_distress_cleared(world_pos: Vector2) -> void:
	# 清除距离 world_pos 最近的感叹号
	var best_idx: int = -1
	var best_dist: float = INF
	for i in _distress_markers.size():
		var m: Node2D = _distress_markers[i]
		if not is_instance_valid(m):
			continue
		var d: float = m.global_position.distance_to(world_pos)
		if d < best_dist:
			best_dist = d
			best_idx = i
	if best_idx >= 0 and best_dist < AllyDistressSignal.AREA_RADIUS:
		var m2: Node2D = _distress_markers[best_idx]
		_distress_markers.remove_at(best_idx)
		if is_instance_valid(m2):
			m2.queue_free()


# 玩家走到求救点附近自动清除信号（每 0.5s 检查一次）
func _check_distress_rescue() -> void:
	if _distress_markers.is_empty():
		return
	var rescue_radius: float = AllyDistressSignal.RESCUE_RADIUS
	var positions: Array = []
	for m in _distress_markers:
		if is_instance_valid(m):
			positions.append(m.global_position)
	if positions.is_empty():
		return
	for unit in get_tree().get_nodes_in_group("player_units"):
		if not (unit is CharacterBody2D) or unit.is_dead():
			continue
		if unit.owner_id == -2:
			continue  # AI 队友自身不算救援者
		for pos in positions:
			if unit.global_position.distance_to(pos) < rescue_radius:
				AllyDistressSignal.clear_at(pos)
				break


# 玩家 ping 攻击指挥（Alt+左键）：所有 AI 队友 attack_move 到此点
func _do_ally_ping_attack(world_pos: Vector2) -> void:
	if RelayManager.is_online:
		return  # 多人模式不支持 AI 队友
	var has_ally: bool = false
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead() and u.owner_id == -2:
			has_ally = true
			break
	if not has_ally:
		return  # 没有 AI 队友，ping 无意义
	AllyCommander.issue_attack_order(world_pos)
	spawner_module.show_floating_text(tr("ALLY_PING_ATTACK"), Color(1.0, 0.4, 0.3), world_pos)
	_spawn_ally_ping_marker(world_pos, Color(1.0, 0.4, 0.3))


# 玩家 ping 防御指挥（Alt+右键）：所有 AI 队友 move 到此点后驻防
func _do_ally_ping_defend(world_pos: Vector2) -> void:
	if RelayManager.is_online:
		return
	var has_ally: bool = false
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead() and u.owner_id == -2:
			has_ally = true
			break
	if not has_ally:
		return
	AllyCommander.issue_defend_order(world_pos)
	spawner_module.show_floating_text(tr("ALLY_PING_DEFEND"), Color(0.4, 0.8, 1.0), world_pos)
	_spawn_ally_ping_marker(world_pos, Color(0.4, 0.8, 1.0))


# ping 位置的扩散十字 + 圆圈视觉反馈（1.2s 自动消失）
func _spawn_ally_ping_marker(world_pos: Vector2, color: Color) -> void:
	var marker := Node2D.new()
	marker.name = "AllyPingMarker"
	add_child(marker)
	marker.global_position = world_pos
	marker.z_index = 60
	var cross_h := Line2D.new()
	cross_h.width = 3.0
	cross_h.default_color = color
	cross_h.add_point(Vector2(-40, 0))
	cross_h.add_point(Vector2(40, 0))
	marker.add_child(cross_h)
	var cross_v := Line2D.new()
	cross_v.width = 3.0
	cross_v.default_color = color
	cross_v.add_point(Vector2(0, -40))
	cross_v.add_point(Vector2(0, 40))
	marker.add_child(cross_v)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(marker, "scale", Vector2(1.8, 1.8), 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(marker, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(marker.queue_free)


func mp_place_building(player: int, building_type: int, pos: Vector2):
	# 用 player_sessions 推断 alliance/color/slot，不再用 player == my_id 推断 team
	# 修复：原 bug 是 host 端执行 client 命令时把 client 单位当成 ENEMY（红色）
	var sess: Dictionary = NetworkManager.player_sessions.get(player, {})
	var alliance_id: int = sess.get("alliance_id", 0)
	var color: int = sess.get("color", Faction.ColorId.BLUE)
	var slot: int = sess.get("slot_id", 0)
	var team = BuildingScript.Team.PLAYER if alliance_id == 0 else BuildingScript.Team.ENEMY
	# 在 place_building 内部 add_child 前设置字段，避免 _ready 跑 _setup_texture 时还是默认蓝色
	var building = building_placer.place_building(building_type, team, building_placer.snap_to_grid(pos), player, color, slot)
	building.start_construction()
	building.net_id = spawner_module._next_net_id
	spawner_module._next_net_id += 1
	LockstepSync.register_unit(building)

func mp_spawn_unit(player: int, unit_type: int, pos: Vector2):
	var sess: Dictionary = NetworkManager.player_sessions.get(player, {})
	var alliance_id: int = sess.get("alliance_id", 0)
	var color: int = sess.get("color", Faction.ColorId.BLUE)
	var slot: int = sess.get("slot_id", 0)
	var unit = spawner_module.create_unit(unit_type, alliance_id, pos, &"", player, color, slot)
	unit.net_id = spawner_module._next_net_id
	spawner_module._next_net_id += 1
	LockstepSync.register_unit(unit)
	if alliance_id == 0:
		spawner_module._player_units_node.add_child(unit)
		unit.add_to_group("player_units")
		if spawner_module._upgrade_manager:
			spawner_module._upgrade_manager.apply_all_stat_upgrades_to_unit(unit)
	else:
		spawner_module._enemy_units_node.add_child(unit)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(load("res://scripts/units/enemy_ai.gd"))
		unit.add_child(ai)
	spawner_module.spawn_spawn_effect(pos, alliance_id, unit)

# --- 单位死亡 ---

func _on_unit_died(unit: CharacterBody2D) -> void:
	LockstepSync.unregister_unit(unit)
	# 星级评价：玩家单位死亡计数
	if unit.is_in_group("player_units"):
		_units_lost += 1
	combat_ctrl.remove_dead_unit(unit)
	_check_elite_drop(unit)
	# 通知类型C的CapturePoint
	for child in get_children():
		if child is CapturePoint:
			child.notify_kill()
	# 被动技能触发：单位死亡
	var died_alliance: int = unit.get("alliance_id") if "alliance_id" in unit else -1
	# 科技点：消灭敌方单位 / 己方单位死亡
	if tech_point_manager:
		var TPD := preload("res://scripts/tech/tech_point_data.gd")
		if unit.is_in_group("enemy_units"):
			_enemies_killed += 1  # T3 PR-3 战斗统计
			tech_point_manager.add_points(TPD.BASE_POINTS.get("kill_unit", 1), TPD.CATEGORY_KILL_ENEMY_UNIT)
		elif unit.is_in_group("player_units"):
			tech_point_manager.add_points(TPD.BASE_POINTS.get("own_unit_died", 2), TPD.CATEGORY_OWN_UNIT_DIED)
	PassiveSkillManager.emit_trigger(
		preload("res://scripts/commander/passive_triggers.gd").UNIT_DIED,
		{"unit": unit, "alliance_id": died_alliance}
	)

# --- 每帧更新 ---

func _check_elite_drop(unit: CharacterBody2D) -> void:
	if not unit is Unit:
		return
	if unit.team != Unit.Team.ENEMY:
		return
	var stats = unit.get("stats_data")
	if stats == null:
		return
	var category: String = stats.category
	var roll := randf()
	var tier := -1
	match category:
		"hero":
			if roll < 0.60:
				tier = 0  # SILVER
			elif roll < 0.90:
				tier = 1  # GOLD
		"boss":
			if roll < 0.70:
				tier = 1  # GOLD
			else:
				tier = 2  # DIAMOND
	if tier < 0:
		return
	_spawn_upgrade_token(unit.global_position, tier)

const UpgradeTokenScene := preload("res://scenes/upgrade/upgrade_token.tscn")

func _spawn_upgrade_token(pos: Vector2, tier: int) -> void:
	var token := UpgradeTokenScene.instantiate()
	add_child(token)
	token.global_position = pos + Vector2(randf_range(-8, 8), randf_range(-8, 8))
	token.tier = tier

var _wave_clear_notified: bool = false
var _wave_debug_timer: float = 0.0
var _perf_log_timer: float = 0.0

func _process(delta: float) -> void:
	if not _initialized:
		return
	# 统一游戏时间累积（吃加速）
	_game_time += delta * Engine.time_scale
	camera_module.process_camera(delta / Engine.time_scale)
	_check_victory()
	_check_wave_cleared()
	# AI 队友求救救援检测：每 0.5s 一次
	_distress_rescue_check_timer += delta
	if _distress_rescue_check_timer >= 0.5:
		_distress_rescue_check_timer = 0.0
		_check_distress_rescue()
	combat_ctrl.update_selection(get_global_mouse_position(), selection_box)
	if combat_ctrl.patrol_mode:
		if combat_ctrl._patrol_first_point == null:
			attack_move_indicator.text = "Patrol: click first point"
		else:
			attack_move_indicator.text = "Patrol: click second point"
	elif combat_ctrl.attack_move_mode:
		attack_move_indicator.text = tr("UI_ATTACK_MOVE")
	attack_move_indicator.visible = combat_ctrl.attack_move_mode or combat_ctrl.patrol_mode
	building_placer.update_preview()
	if building_placer.show_grid and building_placer.grid_overlay:
		building_placer.grid_overlay.visible = building_placer.show_grid
	# 更新指挥官技能目标预览
	if input_mode.is_commander_skill_cast() and commander_skill_manager.is_casting():
		commander_skill_panel.update_target_preview(get_global_mouse_position())
	# 性能监控：每 2 秒打印一次关键指标
	_perf_log_timer += delta
	if _perf_log_timer >= 2.0:
		_perf_log_timer = 0.0
		var fps := Engine.get_frames_per_second()
		var proc_ms := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		var phys_ms := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
		var resources := int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
		var draw_calls := int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var p_units := get_tree().get_nodes_in_group("player_units").size()
		var e_units := get_tree().get_nodes_in_group("enemy_units").size()
		print("[PERF] fps=%d proc=%.1fms phys=%.1fms nodes=%d res=%d draw_calls=%d units=P%d/E%d" %
			[fps, proc_ms, phys_ms, nodes, resources, draw_calls, p_units, e_units])
	# T2 PR-1: 时代升级倒计时
	if age_upgrade_target > 0:
		age_upgrade_timer -= delta
		var cur_tick: int = int(age_upgrade_timer)
		if cur_tick != _last_upgrade_tick and cur_tick > 0 and cur_tick % 3 == 0:
			show_floating_text("T%d 升级中: %ds" % [age_upgrade_target, cur_tick], Color(1.0, 0.85, 0.0), _castle_head_pos())
			_last_upgrade_tick = cur_tick
		# T2 PR-3: 实时更新城堡头顶进度条
		var total_t: float = AGE_UPGRADE_TIME[age_upgrade_target]
		var ratio: float = 1.0 - clampf(age_upgrade_timer / total_t, 0.0, 1.0)
		if player_castle != null and is_instance_valid(player_castle):
			player_castle.set_age_upgrade_progress(ratio)
		if age_upgrade_timer <= 0:
			_on_age_upgrade_complete()

func _get_base_position() -> Vector2:
	var buildings := get_tree().get_nodes_in_group("player_buildings")
	if buildings.is_empty():
		return map_bounds.position + map_bounds.size / 2.0
	for preferred_type in [BuildingScript.BuildingType.CASTLE, BuildingScript.BuildingType.BARRACKS, BuildingScript.BuildingType.TOWER]:
		for building in buildings:
			if building.building_type == preferred_type:
				return building.position
	return buildings[0].position

func _jump_to_base() -> void:
	camera_module.jump_to_base(_get_base_position())


func toggle_outpost_status_panels() -> void:
	# F4：切换敌方指挥官状态 panel（mana/sp/gold/cooldowns）显隐
	# 开启后 panel 显示在领地圈中心，仅当相机看得到该领地时才渲染（viewport culling）
	var mgr = get_node_or_null("OutpostCommanderManager")
	if mgr != null and mgr.has_method("toggle_status_panels"):
		mgr.toggle_status_panels()

# T2 PR-1: 开始时代升级（金币不足/已在升级中则 return）
func _start_age_upgrade() -> void:
	if age_upgrade_target > 0:
		return  # 已在升级中，由 _input 走取消分支
	var target: int = player_age + 1
	if target not in AGE_UPGRADE_COST:
		return
	var cost: int = AGE_UPGRADE_COST[target]
	if gold < cost:
		show_floating_text("金币不足（需要 %d）" % cost, Color(1.0, 0.4, 0.4), _castle_head_pos())
		return
	gold -= cost
	ui_module.update_gold_display(gold)
	age_upgrade_target = target
	age_upgrade_timer = AGE_UPGRADE_TIME[target]
	_last_upgrade_tick = -1
	# T2 PR-3: 显示城堡头顶进度条（0% 起步）
	if player_castle != null and is_instance_valid(player_castle):
		player_castle.set_age_upgrade_progress(0.001)
	show_floating_text("开始升级到 T%d（%ds）" % [target, int(age_upgrade_timer)], Color(0.4, 1.0, 0.4), _castle_head_pos())


# T2 PR-1: 取消时代升级（全额退款）
func _cancel_age_upgrade() -> void:
	if age_upgrade_target == 0:
		return
	var cost: int = AGE_UPGRADE_COST[age_upgrade_target]
	gold += cost
	ui_module.update_gold_display(gold)
	age_upgrade_target = 0
	age_upgrade_timer = 0.0
	# T2 PR-3: 隐藏城堡头顶进度条
	if player_castle != null and is_instance_valid(player_castle):
		player_castle.set_age_upgrade_progress(0.0)
	show_floating_text("升级已取消，退回 %d 金" % cost, Color(1.0, 0.85, 0.0), _castle_head_pos())


# T2 PR-1: 时代升级完成（解锁 T2 内容 + 刷新建造栏）
func _on_age_upgrade_complete() -> void:
	var completed: int = age_upgrade_target
	player_age = completed
	age_upgrade_target = 0
	age_upgrade_timer = 0.0
	# T2 PR-3: 隐藏城堡头顶进度条
	if player_castle != null and is_instance_valid(player_castle):
		player_castle.set_age_upgrade_progress(0.0)
		# PR-4: 升级完成大反馈（转动环收尾 + 双环扩散 + 脉冲）
		player_castle.notify_age_upgrade_completed()
	_unlock_age_items(completed)
	show_floating_text("升级到 T%d 完成！" % completed, Color(0.4, 1.0, 0.4), _castle_head_pos())


# T2 PR-1: 解锁对应时代的 PlaceMode（追加到 unlocked_items）+ 触发建造栏灰显刷新
# T2 只解锁生产建筑；单位（ARCHER/MONK_UNIT）由 building_placer 的 construction_finished 事件解锁
# T3 PR-1: T3 加 LANCER（沿用 BARRACKS 生产线）
func _unlock_age_items(age: int) -> void:
	var to_unlock: Array[int] = []
	if age >= 2:
		# T2 解锁：靶场 + 修道院（建筑）。弓兵/僧侣等对应建筑造好后再解锁
		to_unlock = [
			D.PlaceMode.ARCHERY_RANGE,
			D.PlaceMode.MONASTERY,
		]
	if age >= 3:
		# T3 解锁：长矛兵（沿用 BARRACKS 生产线）+ 学院
		to_unlock.append(D.PlaceMode.LANCER)
		to_unlock.append(D.PlaceMode.ACADEMY)
	for mode in to_unlock:
		var m: int = int(mode)
		if m not in unlocked_items:
			unlocked_items.append(m)
	# 触发 _update_button_affordability 重新计算（按钮从紫灰变白）
	ui_module.update_gold_display(gold)


func _check_victory() -> void:
	if _game_result_saved:
		return
	if victory_condition != null:
		var result := victory_condition.check()
		if result == 1:
			_on_game_ended("victory")
		elif result == 2:
			_on_game_ended("defeat")
	else:
		_fallback_check_victory()

func _fallback_check_victory() -> void:
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead() and b.building_type == BuildingScript.BuildingType.CASTLE:
			player_castle_alive = true
			break
	var enemy_castle_alive := false
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.has_method("is_dead") and not b.is_dead() and b.building_type == BuildingScript.BuildingType.CASTLE:
			enemy_castle_alive = true
			break
	# 两边都没 castle = 场景未初始化（main.tscn 启动瞬间 / test 场景），不算胜负
	if not player_castle_alive and not enemy_castle_alive:
		return
	if not enemy_castle_alive:
		_on_game_ended("victory")
	elif not player_castle_alive:
		_on_game_ended("defeat")

func _check_wave_cleared() -> void:
	var wm: Node = null
	for child in get_children():
		if child is WaveManager:
			wm = child
			break
	if wm == null:
		return
	if not wm.wave_active:
		return
	var ec := 0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			ec += 1
	# Debug log once per second
	_wave_debug_timer += get_process_delta_time()
	if _wave_debug_timer >= 1.0:
		_wave_debug_timer = 0.0
		print("[WAVE DEBUG] enemy_count=", ec, " wave_active=", wm.wave_active, " notified=", _wave_clear_notified)
	if ec > 0:
		return
	print("[WAVE] All enemies dead, notified=", _wave_clear_notified, " wave_active=", wm.wave_active)
	if not _wave_clear_notified:
		_wave_clear_notified = true
		wm.on_wave_cleared()

# --- 输入处理 ---

func _input(event: InputEvent) -> void:
	if not _initialized:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if upgrade_panel and upgrade_panel.is_panel_visible():
			upgrade_panel.close()
			return
		if ui_module.pause_menu_open:
			ui_module.handle_pause_esc()
			return
		# 逐层取消：攻击移动 → 放置 → Q/W模式 → 暂停菜单
		if combat_ctrl.attack_move_mode:
			combat_ctrl.set_attack_move_mode(false)
			cursor_manager.set_attack(false)
			return
		if building_placer.get_place_mode() != D.PlaceMode.NONE:
			building_placer.cancel_place_mode()
			return
		if not input_mode.is_default():
			commander_skill_manager.cancel_cast()
			input_mode.cancel_mode()
			return
		ui_module.open_pause_menu()
		return
	if get_tree().paused:
		return
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					if event.alt_pressed:
						_do_ally_ping_attack(get_global_mouse_position())
						return
					if combat_ctrl.attack_move_mode:
						combat_ctrl.do_attack_move(get_global_mouse_position())
						combat_ctrl.set_attack_move_mode(false)
						cursor_manager.set_attack(false)
					elif combat_ctrl.patrol_mode:
						var shift_held := Input.is_key_pressed(KEY_SHIFT)
						var done: bool = combat_ctrl.do_patrol(get_global_mouse_position(), shift_held)
						if done:
							combat_ctrl.set_patrol_mode(false)
							cursor_manager.set_attack(false)
					elif input_mode.is_commander_skill_cast() and commander_skill_manager.is_casting():
						commander_skill_manager.confirm_cast(get_global_mouse_position())
						input_mode.cancel_mode()
					elif input_mode.is_rally_placement():
						_set_global_rally(get_global_mouse_position())
						input_mode.cancel_mode()
						cursor_manager.set_attack(false)
					elif building_placer.get_place_mode() != D.PlaceMode.NONE:
						_do_place(get_global_mouse_position())
					else:
						# 点击落在 UI 控件上 → 跳过地图选中（修复点面板按钮跳回默认视图）
						if get_viewport().gui_get_hovered_control() != null:
							return
						# 双击检测
						var now := Time.get_ticks_msec() / 1000.0
						var click_pos := get_global_mouse_position()
						var is_double_click := (now - _last_left_click_time) < DOUBLE_CLICK_TIME \
							and click_pos.distance_to(_last_left_click_pos) < DOUBLE_CLICK_DIST
						_last_left_click_time = now
						_last_left_click_pos = click_pos
						combat_ctrl.start_selection(click_pos, is_double_click)
				else:
					if combat_ctrl.is_selecting:
						var shift_held := Input.is_key_pressed(KEY_SHIFT)
						var ctrl_held := Input.is_key_pressed(KEY_CTRL)
						combat_ctrl.release_selection(get_global_mouse_position(), selection_box, shift_held, ctrl_held)
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					if event.alt_pressed:
						_do_ally_ping_defend(get_global_mouse_position())
						return
					combat_ctrl.set_attack_move_mode(false)
					cursor_manager.set_attack(false)
					# Q/W模式下右键退出模式
					if not input_mode.is_default():
						commander_skill_manager.cancel_cast()
						input_mode.cancel_mode()
						return
					building_placer.cancel_place_mode()
					# 建筑选中时：右键设置全局集结点
					var sb = combat_ctrl.selected_building
					if sb != null and is_instance_valid(sb) and combat_ctrl.is_empty():
						_set_global_rally(get_global_mouse_position())
						return
					combat_ctrl.right_click(get_global_mouse_position())
			MOUSE_BUTTON_MIDDLE:
				if event.pressed:
					camera_module.start_mid_drag(get_viewport().get_mouse_position(), camera.position)
				else:
					camera_module.stop_mid_drag()
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					camera_module.zoom_in()
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					camera_module.zoom_out()
	elif event is InputEventKey and event.pressed:
		var key: int = event.keycode
		match key:
			KEY_MINUS, KEY_KP_SUBTRACT:
				ui_module.decrease_game_speed()
			KEY_EQUAL, KEY_KP_ADD:
				ui_module.increase_game_speed()
			KEY_Q, KEY_W, KEY_E, KEY_R, KEY_A, KEY_S, KEY_D, KEY_F:
				# QW 改造：QWER ASDF 是 QW 栏槽位键，仅在 QW 模式激活时造兵
				# 默认模式下：A/S 仍下达部队命令（attack-move / stop），Q/W/E/R/D/F 默认无操作
				# 切菜单的唯一入口是 Tab 键，Q/W 不再切菜单
				if input_mode.is_unit_production() or input_mode.is_building_placement():
					if not event.ctrl_pressed:
						_handle_grid_key(key)
				elif key == KEY_A and not combat_ctrl.is_empty():
					combat_ctrl.set_attack_move_mode(true)
					building_placer.cancel_place_mode()
					cursor_manager.set_attack(true)
				elif key == KEY_S:
					combat_ctrl.stop_selected()
				# Q/W/E/R/D/F 默认模式下不响应
				# E/R/D/F 在默认模式下暂无绑定（保留）
			KEY_Y:
				input_mode.enter_rally_placement()
				building_placer.cancel_place_mode()
				combat_ctrl.set_attack_move_mode(false)
				cursor_manager.set_attack(input_mode.is_rally_placement())
			KEY_U:
				# T2 PR-1: 时代升级触发/取消（升级中按 U = 取消，全额退款）
				if age_upgrade_target > 0:
					_cancel_age_upgrade()
				else:
					_start_age_upgrade()
			KEY_H:
				combat_ctrl.hold_position_selected()
			KEY_P:
				if not combat_ctrl.is_empty():
					combat_ctrl.set_patrol_mode(true)
					combat_ctrl.set_attack_move_mode(false)
					cursor_manager.set_attack(true)
			KEY_Z, KEY_X, KEY_C, KEY_V:
				const SLOT_KEYS := [KEY_Z, KEY_X, KEY_C, KEY_V]
				var slot_index: int = SLOT_KEYS.find(key)
				if slot_index >= 0 and slot_index < _available_skills.size():
					_start_commander_skill(_available_skills[slot_index])
			KEY_G:
				building_placer.show_grid = not building_placer.show_grid
				if building_placer.grid_overlay:
					building_placer.grid_overlay.visible = building_placer.show_grid
			KEY_SPACE:
				if building_placer.get_place_mode() != D.PlaceMode.NONE:
					building_placer.cancel_place_mode()
				_jump_to_base()
			KEY_F2:
				combat_ctrl.select_all_army()
				ui_module.show_army_selected_feedback(combat_ctrl.selected_units.size())
			KEY_F3:
				add_gold(1000)
				show_floating_text("Debug +1000G", Color(1.0, 0.85, 0.0), get_global_mouse_position())
			KEY_F4:
				toggle_outpost_status_panels()
			KEY_TAB:
				# QW 改造：Tab 双语义 —— QW 模式激活时循环切菜单，默认时 cycle_subgroup
				_handle_tab_key(event.shift_pressed)
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0:
				_handle_number_key(key, event)

# --- 放置 ---

# B1: 快捷键直接造兵（不进入放置模式）
# 复用 check_build_block + _find_best_barracks + queue_unit，错误提示显示在鼠标位置
func _quick_produce_unit(mode: int) -> bool:
	var click_pos: Vector2 = get_global_mouse_position()
	var reason: int = building_placer.check_build_block(mode, click_pos)
	if reason != BuildingPlacer.BuildBlockReason.OK:
		var key := BuildingPlacer.reason_to_translation_key(reason)
		if key != &"":
			show_floating_text(tr(key), Color(1, 0.3, 0.3), click_pos)
		return false
	var stats_id: StringName = D.PLACE_MODE_TO_STATS_ID.get(mode, &"")
	var producer_type: int = D.UNIT_TO_PRODUCER_TYPE.get(mode, BuildingScript.BuildingType.BARRACKS)
	var barracks := _find_best_barracks(click_pos, producer_type)
	if barracks == null:
		show_floating_text(tr("NO_BARRACKS"), Color(1, 0.3, 0.3), click_pos)
		return false
	if not barracks.queue_has_space():
		show_floating_text(tr("QUEUE_FULL"), Color(1, 0.3, 0.3), barracks.global_position)
		return false
	if not barracks.queue_unit(stats_id):
		show_floating_text(tr("QUEUE_FULL"), Color(1, 0.3, 0.3), barracks.global_position)
		return false
	var cost: int = building_placer.get_current_cost(mode)
	gold -= cost
	ui_module.update_gold_display(gold)
	return true


func _do_place(click_pos: Vector2) -> void:
	var place_mode: int = building_placer.get_place_mode()
	var cost: int = building_placer.get_current_cost(place_mode)  # T1: 动态造价（农场递增）
	# T1 PR-2: 统一阻挡检查（金币/上限/前置/范围），按 reason 显示 floating_text
	var reason: int = building_placer.check_build_block(place_mode, click_pos)
	if reason != BuildingPlacer.BuildBlockReason.OK:
		var key := BuildingPlacer.reason_to_translation_key(reason)
		if key != &"":
			show_floating_text(tr(key), Color(1, 0.3, 0.3), click_pos)
		return

	if RelayManager.is_online:
		if D.is_unit_mode(place_mode):
			CommandBuffer.add_spawn_command(D.PLACE_MODE_TO_UNIT[place_mode], click_pos)
		elif D.is_building_mode(place_mode):
			CommandBuffer.add_build_command(D.PLACE_MODE_TO_BUILDING[place_mode], click_pos)
		gold -= cost
		ui_module.update_gold_display(gold)
		return

	var placed := false
	if D.is_unit_mode(place_mode):
		# T1 PR-2: 单位入兵营队列，由 _production_process 在 cooldown 后 spawn
		var stats_id: StringName = D.PLACE_MODE_TO_STATS_ID.get(place_mode, &"")
		var producer_type: int = D.UNIT_TO_PRODUCER_TYPE.get(place_mode, BuildingScript.BuildingType.BARRACKS)
		var barracks := _find_best_barracks(click_pos, producer_type)  # B2: 智能选择（队列优先 + 800码虚拟+3）
		if barracks == null:
			show_floating_text(tr("NO_BARRACKS"), Color(1, 0.3, 0.3), click_pos)
			return
		if not barracks.queue_has_space():
			show_floating_text(tr("QUEUE_FULL"), Color(1, 0.3, 0.3), barracks.global_position)
			return
		if not barracks.queue_unit(stats_id):
			show_floating_text(tr("QUEUE_FULL"), Color(1, 0.3, 0.3), barracks.global_position)
			return
		placed = true
	elif D.is_building_mode(place_mode):
		var bt: int = D.PLACE_MODE_TO_BUILDING[place_mode]
		var gs: Vector2i = D.get_building_grid_size(bt)
		var gp: Vector2i = building_placer.snap_to_grid(click_pos)
		if building_placer.is_grid_free(gp, gs):
			building_placer.place_building(bt, BuildingScript.Team.PLAYER, gp).start_construction()
			placed = true
	if placed:
		gold -= cost
		ui_module.update_gold_display(gold)

# === Public API (for WaveManager, CapturePoint, etc.) ===

func spawn_enemy_wave(units: Array, wave_attack: bool = false, wave_target: Vector2 = Vector2.ZERO) -> void:
	spawner_module.spawn_enemy_wave(units, wave_attack, wave_target)

func spawn_enemy_wave_v2(groups: Array, spawn_center: Vector2, wave_attack: bool, wave_target: Vector2, formation: String = "column", spacing: float = 50.0, radius: float = 80.0) -> void:
	spawner_module.spawn_enemy_wave_v2(groups, spawn_center, wave_attack, wave_target, formation, spacing, radius)

func spawn_enemy_unit(type: int, pos: Vector2, wave_attack: bool = false, wave_target: Vector2 = Vector2.ZERO) -> void:
	spawner_module.spawn_enemy_unit(type, wave_attack, wave_target)

func add_gold(amount: int) -> void:
	gold += amount
	if amount > 0:
		_gold_earned += amount  # T3 PR-3: 累计正向收入
	ui_module.update_gold_display(gold)


func _spend_gold(amount: int) -> void:
	gold -= amount
	ui_module.update_gold_display(gold)


func _on_commander_skill_button_pressed(skill_id: int) -> void:
	_start_commander_skill(skill_id)

func _on_upgrade_button_pressed() -> void:
	if upgrade_manager and upgrade_manager.can_open_selection():
		var tier: int = upgrade_manager.get_highest_tier_token()
		upgrade_panel.show_selection(tier)

# T3 PR-2: 玩家在弹窗确认 T3 升级选择
func _on_t3_choice_confirmed(unit_type: int, choice_id: StringName) -> void:
	var data = t3_upgrade_manager.get_upgrade_data(unit_type)
	gold -= data.cost
	ui_module.update_gold_display(gold)
	t3_upgrade_manager.confirm_choice(unit_type, choice_id)


func _start_commander_skill(skill_id: int) -> void:
	if commander_skill_manager.start_cast(skill_id):
		if commander_skill_manager.is_casting():
			input_mode.enter_commander_skill_cast()


# ============================================================
# 玩家选择的指挥官技能（4 个槽位，全局共享，存 settings.cfg）
# ============================================================

const SKILL_SLOTS_COUNT := 4
const DEFAULT_PLAYER_SKILLS := [0, 1, 2, 3]  # ORBITAL_STRIKE / HEAL_FIELD / SHIELD_WALL / UNIT_DROP


# 计算本局实际可用的技能列表（最多 4 个）。
# 优先级：玩家选的 4 个 ∩ 关卡允许；不足时按关卡允许的顺序补足；都空则用默认 4 个。
func _resolve_available_skills() -> Array:
	var player_picked: Array = load_player_selected_skills()
	var allowed_by_map: Array = []
	if map_config != null and not map_config.commander_skills.is_empty():
		allowed_by_map = map_config.commander_skills

	var result: Array = []
	# 1) 玩家选的，关卡允许的
	for sid in player_picked:
		if allowed_by_map.is_empty() or allowed_by_map.has(sid):
			result.append(sid)
	# 2) 不足 4 个时，从关卡允许列表里补
	while result.size() < SKILL_SLOTS_COUNT and not allowed_by_map.is_empty():
		var added := false
		for sid in allowed_by_map:
			if not result.has(sid):
				result.append(sid)
				added = true
				if result.size() >= SKILL_SLOTS_COUNT:
					break
		if not added:
			break
	# 3) 兜底：玩家选的或默认
	if result.is_empty():
		if not player_picked.is_empty():
			result = player_picked.duplicate()
		else:
			result = DEFAULT_PLAYER_SKILLS.duplicate()
	# 4) 限制最多 4 个
	if result.size() > SKILL_SLOTS_COUNT:
		result = result.slice(0, SKILL_SLOTS_COUNT)
	return result


# 读取玩家选择的 4 个技能 ID（全局共享）。无配置时返回默认 4 个。
static func load_player_selected_skills() -> Array:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return DEFAULT_PLAYER_SKILLS.duplicate()
	var skills = config.get_value("commander_skills", "selected", DEFAULT_PLAYER_SKILLS)
	if not skills is Array or skills.size() != SKILL_SLOTS_COUNT:
		return DEFAULT_PLAYER_SKILLS.duplicate()
	# 校验所有 ID 在合法范围内（SkillId 枚举）
	var validated: Array = []
	for sid in skills:
		if sid is int and sid >= 0 and sid < 12:
			validated.append(sid)
	if validated.size() != SKILL_SLOTS_COUNT:
		return DEFAULT_PLAYER_SKILLS.duplicate()
	return validated


# 保存玩家选择的 4 个技能 ID 到 settings.cfg。
static func save_player_selected_skills(skill_ids: Array) -> bool:
	if skill_ids.size() != SKILL_SLOTS_COUNT:
		return false
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("commander_skills", "selected", skill_ids)
	var err := config.save("user://settings.cfg")
	return err == OK


# ============================================================
# 玩家战前编制（最多 10 个 PlaceMode，全局共享）
# ============================================================

const LOADOUT_SLOTS_COUNT := 15
const DEFAULT_PLAYER_LOADOUT := [
	D.PlaceMode.SOLDIER, D.PlaceMode.ARCHER, D.PlaceMode.LANCER, D.PlaceMode.MONK_UNIT,
	D.PlaceMode.SHIELDBEARER, D.PlaceMode.BERSERKER, D.PlaceMode.CROSSBOWMAN,
	D.PlaceMode.PYROMANCER, D.PlaceMode.CRYOMANCER,
	D.PlaceMode.WALL, D.PlaceMode.TOWER, D.PlaceMode.BARRACKS,
	D.PlaceMode.ARCHERY_RANGE, D.PlaceMode.MONASTERY, D.PlaceMode.CASTLE,
	D.PlaceMode.FARM, D.PlaceMode.ACADEMY,
]


# 读取玩家选择的部队编制。无配置或非法返回默认 10 个。
static func load_player_loadout() -> Array:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return DEFAULT_PLAYER_LOADOUT.duplicate()
	var raw = config.get_value("loadout", "selected", DEFAULT_PLAYER_LOADOUT)
	if not raw is Array:
		return DEFAULT_PLAYER_LOADOUT.duplicate()
	var validated: Array = []
	for mode in raw:
		if mode is int and mode in D.ALL_ITEMS:
			validated.append(mode)
	return validated


static func save_player_loadout(modes: Array) -> bool:
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("loadout", "selected", modes)
	var err := config.save("user://settings.cfg")
	return err == OK


# 计算本局实际可用的物品 PlaceMode 列表（最多 10 个）。
# 完全以玩家战前选择为准，关卡 available_items 不再做交集限制。
# 玩家未选或选不满时，用默认编制补足。
func _resolve_loadout() -> Array:
	# T1: temp_flag 强制编制（绕过玩家 save 的 loadout，避免 FARM 被 DEFAULT_PLAYER_LOADOUT 覆盖）
	if SaveManager.has_temp_flag("skip_loadout_screen"):
		return [
			D.PlaceMode.FARM, D.PlaceMode.TOWER, D.PlaceMode.BARRACKS,
			D.PlaceMode.SOLDIER, D.PlaceMode.ARCHER,
			# T2 PR-1: 加入靶场，让玩家在 T1 就能看到锁定按钮（紫灰），升级后亮起
			D.PlaceMode.ARCHERY_RANGE,
			# T3 PR-2: 加入 T2/T3 解锁内容，让按钮在 QW 菜单可见（灰显→升级后亮起）
			D.PlaceMode.MONASTERY, D.PlaceMode.MONK_UNIT,
			D.PlaceMode.LANCER, D.PlaceMode.ACADEMY,
		]
	var player_picked: Array = load_player_loadout()
	var result: Array = []
	for mode in player_picked:
		if mode in D.ALL_ITEMS and not result.has(mode):
			result.append(mode)
	# 玩家没选任何东西，用默认
	if result.is_empty():
		result = DEFAULT_PLAYER_LOADOUT.duplicate()
	# 限制最多 10
	if result.size() > LOADOUT_SLOTS_COUNT:
		result = result.slice(0, LOADOUT_SLOTS_COUNT)
	return result


# 把战前编制覆盖回 map_config.available_items，给 game_ui 使用
func _apply_loadout_filter() -> void:
	if map_config == null:
		return
	var resolved: Array = _resolve_loadout()
	# 空配置场景下不动；非空则覆盖
	if not resolved.is_empty():
		# map_config.available_items 是 Array[int] 强类型数组，必须转换
		var typed: Array[int] = []
		for mode in resolved:
			typed.append(int(mode))
		map_config.available_items = typed


# T3 PR-1: 初始化 unlocked_items（T1 阶段过滤掉所有非 T1 内容）
# - ARCHERY_RANGE / ARCHER ：T2 解锁
# - MONASTERY / MONK_UNIT  ：T2 解锁（T3 PR-1 调整）
# - LANCER                  ：T3 解锁（T3 PR-1 调整）
# 注意：时代升级时 _unlock_age_items() 会往里追加 T2/T3 内容
func _init_unlocked_items() -> void:
	unlocked_items.clear()
	var source: Array = D.ALL_ITEMS
	if map_config != null and not map_config.available_items.is_empty():
		source = map_config.available_items
	var t1_filtered := {
		D.PlaceMode.ARCHERY_RANGE: true,
		D.PlaceMode.ARCHER: true,
		D.PlaceMode.MONASTERY: true,
		D.PlaceMode.MONK_UNIT: true,
		D.PlaceMode.LANCER: true,
		D.PlaceMode.ACADEMY: true,
	}
	for mode in source:
		var m: int = int(mode)
		if not t1_filtered.has(m):
			unlocked_items.append(m)


# T1 D10: 缓存玩家主基地（建造范围圆心；找不到则置 null，is_in_buildable_area 会返回 true 不阻拦）
func _cache_player_castle() -> void:
	player_castle = null
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.get("building_type") == BuildingScript.BuildingType.CASTLE:
			player_castle = b
			return


# T1 D2: 找最近的已建成玩家兵营（单位面板点击的 spawn 锚点）
func _find_nearest_barracks(pos: Vector2) -> Node:
	var nearest = null
	var nearest_dist := INF
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.get("building_type") != BuildingScript.BuildingType.BARRACKS:
			continue
		if b.has_method("is_dead") and b.is_dead():
			continue
		if b.get("is_constructed") == false:
			continue
		var d := pos.distance_to(b.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = b
	return nearest


# B2: 智能选择兵营（队列短优先 + 800码外虚拟+3）
# 标杆位置 = rally point 优先，fallback 玩家城堡
func _find_best_barracks(click_pos: Vector2, building_type: int = BuildingScript.BuildingType.BARRACKS) -> Node:
	var candidates: Array = []
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.get("building_type") != building_type:
			continue
		if b.has_method("is_dead") and b.is_dead():
			continue
		if b.get("is_constructed") == false:
			continue
		if not b.queue_has_space():
			continue
		candidates.append(b)
	if candidates.is_empty():
		return null
	# 标杆位置：rally point 优先，fallback 玩家城堡，再 fallback click_pos
	var benchmark: Vector2
	if has_global_rally:
		benchmark = global_rally_point
	elif player_castle != null:
		benchmark = player_castle.global_position
	else:
		benchmark = click_pos
	# 计算每个兵营的有效队列长度 + 距离鼠标
	var scored: Array = []
	for b in candidates:
		var actual_queue: int = b.production_queue.size()
		var dist_to_benchmark: float = b.global_position.distance_to(benchmark)
		var effective_queue: int = actual_queue + (3 if dist_to_benchmark > 800.0 else 0)
		var dist_to_click: float = b.global_position.distance_to(click_pos)
		scored.append({"b": b, "eq": effective_queue, "dc": dist_to_click})
	# 排序：effective_queue 升序 -> distance_to_click 升序
	scored.sort_custom(func(a, b):
		if a.eq != b.eq:
			return a.eq < b.eq
		return a.dc < b.dc)
	return scored[0]["b"]


# ============================================================
# 玩家战前被动（最多 3 个 UpgradeId，全局共享）
# ============================================================

const PASSIVE_SLOTS_COUNT := 3
const DEFAULT_PLAYER_PASSIVES := []  # 默认无被动，由玩家选


static func load_player_passives() -> Array:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return DEFAULT_PLAYER_PASSIVES.duplicate()
	var raw = config.get_value("passives", "selected", DEFAULT_PLAYER_PASSIVES)
	if not raw is Array:
		return DEFAULT_PLAYER_PASSIVES.duplicate()
	const UD := preload("res://scripts/upgrade/upgrade_data.gd")
	var validated: Array = []
	for uid in raw:
		if uid is int and UD.CONFIGS.has(uid):
			validated.append(uid)
	return validated


static func save_player_passives(upgrade_ids: Array) -> bool:
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("passives", "selected", upgrade_ids)
	var err := config.save("user://settings.cfg")
	return err == OK


# 计算本局实际生效的战前被动 UpgradeId 列表
func _resolve_passives() -> Array:
	return load_player_passives()


# 在所有玩家单位生成后调用，应用战前被动
func _apply_pre_battle_passives() -> void:
	if upgrade_manager == null:
		return
	var ids: Array = _resolve_passives()
	if ids.is_empty():
		return
	upgrade_manager.apply_pre_battle_passives(ids)

func show_floating_text(text: String, color: Color, world_pos: Vector2) -> void:
	spawner_module.show_floating_text(text, color, world_pos)

func show_damage_number(amount: int, world_pos: Vector2) -> void:
	if not show_damage_numbers:
		return
	var dn := Node2D.new()
	dn.set_script(load("res://scripts/effects/damage_number.gd"))
	add_child(dn)
	dn.setup(amount, world_pos)

func _load_damage_number_setting() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		show_damage_numbers = config.get_value("game", "show_damage_numbers", true)
		Unit.show_path_lines = config.get_value("game", "show_path_lines", true)
		show_collisions = config.get_value("game", "show_collisions", false)
	refresh_collision_debug()


# 即时切换碰撞区域显示：设置 hint 后手动触发已有节点重绘
func refresh_collision_debug() -> void:
	get_tree().debug_collisions_hint = show_collisions
	_redraw_collision_shapes(get_tree().root)


func _redraw_collision_shapes(node: Node) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.queue_redraw()
	for child in node.get_children():
		_redraw_collision_shapes(child)


func _load_display_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return
	# 兼容旧的 fullscreen 字段，迁移到 display_mode
	if config.has_section_key("display", "fullscreen"):
		var fullscreen: bool = config.get_value("display", "fullscreen", false)
		if fullscreen:
			config.set_value("display", "display_mode", 0)
		else:
			config.set_value("display", "display_mode", 2)
		config.erase_section_key("display", "fullscreen")
		config.save("user://settings.cfg")
	var display_mode: int = config.get_value("display", "display_mode", 2)
	match display_mode:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var w: int = config.get_value("display", "resolution_width", 1280)
			var h: int = config.get_value("display", "resolution_height", 720)
			DisplayServer.window_set_size(Vector2i(w, h))
	show_fps = config.get_value("display", "show_fps", false)


func _load_brightness() -> void:
	canvas_modulate = CanvasModulate.new()
	canvas_modulate.color = Color(1, 1, 1, 1)
	add_child(canvas_modulate)
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var brightness: float = config.get_value("display", "brightness", 1.0)
		canvas_modulate.color = Color(brightness, brightness, brightness, 1.0)


func _load_audio_settings() -> void:
	# 确保至少有 Master, Music, SFX 三个总线
	while AudioServer.bus_count < 3:
		AudioServer.add_bus()
	if AudioServer.get_bus_count() >= 2:
		AudioServer.set_bus_name(1, "Music")
	if AudioServer.get_bus_count() >= 3:
		AudioServer.set_bus_name(2, "SFX")
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var master: float = config.get_value("audio", "master_volume", 1.0)
		var music: float = config.get_value("audio", "music_volume", 1.0)
		var sfx: float = config.get_value("audio", "sfx_volume", 1.0)
		AudioServer.set_bus_volume_db(0, linear_to_db(master))
		AudioServer.set_bus_mute(0, master <= 0.0)
		AudioServer.set_bus_volume_db(1, linear_to_db(music))
		AudioServer.set_bus_mute(1, music <= 0.0)
		AudioServer.set_bus_volume_db(2, linear_to_db(sfx))
		AudioServer.set_bus_mute(2, sfx <= 0.0)


func _load_gameplay_settings() -> float:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		return config.get_value("gameplay", "camera_sensitivity", 1.0)
	return 1.0

func _set_global_rally(pos: Vector2) -> void:
	global_rally_point = pos
	has_global_rally = true
	if _rally_indicator == null:
		_rally_indicator = Node2D.new()
		_rally_indicator.set_script(load("res://scripts/effects/rally_point_indicator.gd"))
		_rally_indicator.z_index = 5
		add_child(_rally_indicator)
	_rally_indicator.setup_global(pos)
	# 弹入动画
	_rally_indicator.scale = Vector2(0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(_rally_indicator, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# 视野内所有玩家单位立刻 attack_move
	_rally_units_in_view(pos)


func _rally_units_in_view(pos: Vector2) -> void:
	var view_rect: Rect2 = camera_module.get_camera_view_rect()
	for u in get_tree().get_nodes_in_group("player_units"):
		if is_instance_valid(u) and not u.is_dead() and view_rect.has_point(u.global_position):
			u.attack_move_to(pos)


# === 科技点系统回调 ===

func _on_tech_level_unlocked(level: int) -> void:
	print("[Tech] 科技等级解锁: Tier ", level)
	if ui_module and ui_module.has_method("update_tech_level"):
		ui_module.update_tech_level(level)


func _on_tech_passive_timer() -> void:
	if tech_point_manager:
		var TPD := preload("res://scripts/tech/tech_point_data.gd")
		tech_point_manager.add_points(TPD.BASE_POINTS.get("passive_60s", 10), TPD.CATEGORY_PASSIVE)


func _on_tech_points_changed(points: int) -> void:
	print("[DEBUG] _on_tech_points_changed points=", points, " ui=", ui_module)
	if ui_module and ui_module.has_method("update_tech_points"):
		ui_module.update_tech_points(points)

func spawn_unit_near(type: int, pos: Vector2, team: int) -> CharacterBody2D:
	var unit = spawner_module.spawn_unit_near(type, pos, team)
	# 玩家单位自动前往全局集结点（覆盖 adaptive_reinforcement / capture_point 等通过 game_controller 的调用）
	if team == UnitScript.Team.PLAYER and has_global_rally and is_instance_valid(unit):
		unit.attack_move_to(global_rally_point)
	return unit
