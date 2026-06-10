extends Node2D

const D := preload("res://scripts/systems/game_data.gd")
const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")
const MapConfigScript := preload("res://scripts/map_config.gd")
const DifficultyClass := preload("res://scripts/difficulty.gd")

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
var canvas_modulate: CanvasModulate = null
var _units_lost: int = 0  # 星级评价用：玩家损失单位数

func _ready() -> void:
	result_label.visible = false
	attack_move_indicator.text = tr("UI_ATTACK_MOVE")
	attack_move_indicator.visible = false
	preview_rect.visible = false

	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	cursor_manager = CursorManagerScene.instantiate()
	add_child(cursor_manager)

	_load_from_config()
	_load_damage_number_setting()
	_load_display_settings()
	_load_brightness()
	_load_audio_settings()

	# 替换 ColorRect 地面为 TileMapLayer 地形
	_replace_ground_with_terrain()

	# UI 模块
	ui_module = Node.new()
	ui_module.set_script(load("res://scripts/systems/game_ui.gd"))
	add_child(ui_module)
	ui_module.initialize(self, map_config, gold)
	ui_module.place_mode_requested.connect(_on_place_mode_requested)
	key_to_mode = ui_module.key_to_mode

	# 相机模块
	camera_module = Node.new()
	camera_module.set_script(load("res://scripts/systems/game_camera.gd"))
	add_child(camera_module)
	camera_module.initialize(camera, map_bounds)
	camera_module.speed_multiplier = _load_gameplay_settings()

	# 注册 UI 面板豁免区域到相机（防止底部面板触发边缘滚动）
	ui_module.update_panel_rect()
	camera_module.ui_exclusion_rects.append(ui_module.get_panel_screen_rect())

	# 生成模块
	spawner_module = Node.new()
	spawner_module.set_script(load("res://scripts/systems/game_spawner.gd"))
	add_child(spawner_module)
	spawner_module.initialize(self, player_units_node, enemy_units_node, buildings_node)
	spawner_module.set_difficulty(_diff_preset)

	# 建筑放置模块
	building_placer = Node.new()
	building_placer.set_script(load("res://scripts/systems/building_placer.gd"))
	add_child(building_placer)
	building_placer.initialize(map_bounds, NAV_BOUNDS, nav_region, buildings_node, preview_rect, ui_module)
	spawner_module.place_building_callback = building_placer.place_building

	# 战斗/选择模块
	combat_ctrl = Node.new()
	combat_ctrl.set_script(load("res://scripts/systems/combat_controller.gd"))
	add_child(combat_ctrl)
	combat_ctrl.initialize(spawner_module)
	combat_ctrl.selection_changed.connect(_on_selection_changed)
	combat_ctrl.building_selected.connect(_on_building_selected)

	# 输入模式管理器 (Q/W)
	input_mode = Node.new()
	input_mode.set_script(load("res://scripts/systems/input_mode_manager.gd"))
	add_child(input_mode)
	input_mode.mode_changed.connect(_on_input_mode_changed)

	# 控制组管理器
	const CtrlGroupMgr := preload("res://scripts/systems/control_group_manager.gd")
	ctrl_group_mgr = CtrlGroupMgr.new()
	for i in range(10):
		_group_tap_times.append(0.0)

	# 指挥官技能系统
	const CSD := preload("res://scripts/commander_skill/commander_skill_data.gd")
	commander_skill_manager = Node.new()
	commander_skill_manager.set_script(load("res://scripts/commander_skill/commander_skill_manager.gd"))
	add_child(commander_skill_manager)
	var available_skills: Array = CSD.ALL_SKILLS
	if map_config != null and not map_config.commander_skills.is_empty():
		available_skills = map_config.commander_skills
	commander_skill_manager.initialize(self, spawner_module, func(): return gold, func(cost: int): _spend_gold(cost))
	commander_skill_manager.set_available_skills(available_skills)

	commander_skill_panel = Node.new()
	commander_skill_panel.set_script(load("res://scripts/commander_skill/commander_skill_panel.gd"))
	add_child(commander_skill_panel)
	commander_skill_panel.initialize(self, commander_skill_manager)
	commander_skill_panel.skill_button_pressed.connect(_on_commander_skill_button_pressed)

	# 升级系统
	upgrade_manager = Node.new()
	upgrade_manager.set_script(load("res://scripts/upgrade/upgrade_manager.gd"))
	add_child(upgrade_manager)
	upgrade_manager.initialize(self)
	upgrade_manager.set_spawner(spawner_module)
	spawner_module.set_upgrade_manager(upgrade_manager)

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

	# 生成
	var has_preplaced := _has_preplaced_entities()
	if has_preplaced:
		building_placer.register_preplaced_buildings(buildings_node)
		_init_preplaced_units()
	else:
		spawner_module.spawn_from_config(map_config)
	building_placer.create_grid()
	spawner_module.spawn_environment(map_config, map_bounds)

	_setup_victory_condition()
	_setup_capture_points()
	_setup_wave_manager()

	if map_config != null:
		camera.position = map_config.camera_start

	await get_tree().process_frame

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
		unit.connect("died", Callable(self, "_on_unit_died"))
		unit.add_to_group("player_units")

	for unit in enemy_units_node.get_children():
		if not unit is Unit:
			continue
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
		water_areas = map_config.water_areas
		border_w = map_config.border_width
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

	# 通知 SaveManager 记录结果
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		var diff_level := DifficultyClass.load_from_config()
		sm.end_game_session(result, diff_level)

	if result == "victory":
		_show_victory_panel(sm)
	else:
		result_label.text = tr("RESULT_DEFEAT")
		result_label.visible = true


func _show_victory_panel(sm: Node) -> void:
	result_label.visible = false

	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(overlay)

	var panel := Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -180
	panel.offset_right = 180
	panel.offset_top = -140
	panel.offset_bottom = 140
	canvas.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 24
	vbox.offset_right = -24
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title := Label.new()
	title.text = tr("RESULT_VICTORY")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(title)

	if sm:
		var elapsed: float = sm.get_last_session_time()
		var time_label := Label.new()
		time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		time_label.add_theme_font_size_override("font_size", 18)
		time_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		time_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
		time_label.add_theme_constant_override("shadow_offset_x", 1)
		time_label.add_theme_constant_override("shadow_offset_y", 1)
		time_label.text = tr("SAVE_BEST_TIME") % sm.format_time(elapsed)
		vbox.add_child(time_label)

		var save_data: Dictionary = sm.get_current_data()
		var total: int = sm.calc_total_score(save_data)
		var score_label := Label.new()
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_label.add_theme_font_size_override("font_size", 18)
		score_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
		score_label.add_theme_constant_override("shadow_offset_x", 1)
		score_label.add_theme_constant_override("shadow_offset_y", 1)
		score_label.text = tr("SAVE_TOTAL_SCORE") % [total, 100]
		vbox.add_child(score_label)

	var btn := Button.new()
	btn.text = tr("SAVE_CONTINUE")
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.custom_minimum_size = Vector2(160, 44)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/level_select.tscn"))
	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim_button(btn)
	vbox.add_child(btn)

func _setup_capture_points() -> void:
	for child in get_children():
		if child is CapturePoint:
			child.set_game_controller(self)

func _setup_wave_manager() -> void:
	for child in get_children():
		if child is WaveManager:
			child.set_game_controller(self)
			child.set_difficulty(_diff_preset)
			child.wave_started.connect(_on_wave_started)
			child.countdown_updated.connect(_on_countdown_updated)
			child.all_waves_completed.connect(_on_all_waves_completed)
			child.start_waves()
			break

func _on_wave_started(_wave_number: int) -> void:
	_wave_clear_notified = false

func _on_countdown_updated(wave_number: int, remaining: float, total: int) -> void:
	ui_module.update_wave_countdown(wave_number, remaining, total)

func _on_all_waves_completed() -> void:
	ui_module.hide_wave_countdown()

func _on_place_mode_requested(mode: int) -> void:
	building_placer.enter_place_mode(mode)
	combat_ctrl.set_attack_move_mode(false)


func _on_selection_changed(units: Array) -> void:
	ui_module.update_selection_info(units)


func _on_building_selected(building) -> void:
	ui_module.update_selection_info([], building)


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
	# Ctrl+数字键：分配编队
	if event.ctrl_pressed:
		var gi := _keycode_to_group_index(key)
		if gi >= 0:
			ctrl_group_mgr.assign_group(gi, combat_ctrl.selected_units)
		return

	# Q/W模式下：放置单位/建筑
	if input_mode.is_unit_production():
		var mode: int = D.UNIT_PRODUCTION_HOTKEYS.get(key, -1)
		if mode >= 0:
			ui_module.switch_tab_for_mode(mode)
			_on_place_mode_requested(mode)
		return

	if input_mode.is_building_placement():
		var mode: int = D.BUILDING_PLACEMENT_HOTKEYS.get(key, -1)
		if mode >= 0:
			ui_module.switch_tab_for_mode(mode)
			_on_place_mode_requested(mode)
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

# --- 单位死亡 ---

func _on_unit_died(unit: CharacterBody2D) -> void:
	# 星级评价：玩家单位死亡计数
	if unit.is_in_group("player_units"):
		_units_lost += 1
	combat_ctrl.remove_dead_unit(unit)
	_check_elite_drop(unit)
	# 通知类型C的CapturePoint
	for child in get_children():
		if child is CapturePoint:
			child.notify_kill()

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

func _process(delta: float) -> void:
	camera_module.process_camera(delta / Engine.time_scale)
	_check_victory()
	_check_wave_cleared()
	combat_ctrl.update_selection(get_global_mouse_position(), selection_box)
	attack_move_indicator.visible = combat_ctrl.attack_move_mode
	building_placer.update_preview()
	if building_placer.show_grid and building_placer.grid_overlay:
		building_placer.grid_overlay.visible = building_placer.show_grid
	# 更新指挥官技能目标预览
	if input_mode.is_commander_skill_cast() and commander_skill_manager.is_casting():
		commander_skill_panel.update_target_preview(get_global_mouse_position())

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
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if upgrade_panel and upgrade_panel.is_panel_visible():
			upgrade_panel.close()
			return
		if ui_module.pause_menu_open:
			ui_module.close_pause_menu()
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
					if combat_ctrl.attack_move_mode:
						combat_ctrl.do_attack_move(get_global_mouse_position())
						combat_ctrl.set_attack_move_mode(false)
						cursor_manager.set_attack(false)
					elif input_mode.is_commander_skill_cast() and commander_skill_manager.is_casting():
						commander_skill_manager.confirm_cast(get_global_mouse_position())
						input_mode.cancel_mode()
					elif building_placer.get_place_mode() != D.PlaceMode.NONE:
						_do_place(get_global_mouse_position())
					else:
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
					combat_ctrl.set_attack_move_mode(false)
					cursor_manager.set_attack(false)
					# Q/W模式下右键退出模式
					if not input_mode.is_default():
						commander_skill_manager.cancel_cast()
						input_mode.cancel_mode()
						return
					building_placer.cancel_place_mode()
					# 建筑选中时：右键设置集结点
					var sb = combat_ctrl.selected_building
					if sb != null and is_instance_valid(sb) and combat_ctrl.is_empty():
						sb.set_rally_point(get_global_mouse_position())
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
			KEY_Q:
				if not event.ctrl_pressed:
					input_mode.enter_unit_production()
			KEY_W:
				if not event.ctrl_pressed:
					input_mode.enter_building_placement()
			KEY_A:
				if not combat_ctrl.is_empty():
					combat_ctrl.set_attack_move_mode(true)
					building_placer.cancel_place_mode()
					cursor_manager.set_attack(true)
			KEY_S:
				combat_ctrl.stop_selected()
			KEY_H:
				combat_ctrl.hold_position_selected()
			KEY_Z, KEY_X, KEY_C, KEY_V:
				var CSD2 := preload("res://scripts/commander_skill/commander_skill_data.gd")
				var skill_id: int = CSD2.HOTKEY_TO_SKILL.get(key, -1)
				if skill_id >= 0:
					_start_commander_skill(skill_id)
			KEY_R:
				get_tree().reload_current_scene()
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
			KEY_TAB:
				combat_ctrl.cycle_subgroup(not event.shift_pressed)
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0:
				_handle_number_key(key, event)

# --- 放置 ---

func _do_place(click_pos: Vector2) -> void:
	var place_mode: int = building_placer.get_place_mode()
	var cost: int = D.COSTS.get(place_mode, 0)
	if gold < cost:
		return
	var placed := false
	if D.is_unit_mode(place_mode):
		spawner_module.place_player_unit(D.PLACE_MODE_TO_UNIT[place_mode], click_pos)
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

func spawn_enemy_wave_v2(groups: Array, spawn_center: Vector2, wave_attack: bool, wave_target: Vector2, formation: String = "column", spacing: float = 50.0) -> void:
	spawner_module.spawn_enemy_wave_v2(groups, spawn_center, wave_attack, wave_target, formation, spacing)

func spawn_enemy_unit(type: int, pos: Vector2, wave_attack: bool = false, wave_target: Vector2 = Vector2.ZERO) -> void:
	spawner_module.spawn_enemy_unit(type, wave_attack, wave_target)

func add_gold(amount: int) -> void:
	gold += amount
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


func _start_commander_skill(skill_id: int) -> void:
	if commander_skill_manager.start_cast(skill_id):
		if commander_skill_manager.is_casting():
			input_mode.enter_commander_skill_cast()

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

func spawn_unit_near(type: int, pos: Vector2, team: int) -> void:
	spawner_module.spawn_unit_near(type, pos, team)
