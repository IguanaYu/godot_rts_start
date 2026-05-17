extends Node2D

const D := preload("res://scripts/game_data.gd")
const UnitScript := preload("res://scripts/unit.gd")
const BuildingScript := preload("res://scripts/building.gd")
const MapConfigScript := preload("res://scripts/map_config.gd")

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

# 游戏状态
var gold: int = 10000
var key_to_mode: Dictionary = {}
var map_bounds := Rect2(-500, -500, 2000, 1700)

func _ready() -> void:
	result_label.visible = false
	attack_move_indicator.visible = false
	preview_rect.visible = false

	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	cursor_manager = CursorManagerScene.instantiate()
	add_child(cursor_manager)

	_load_from_config()

	# UI 模块
	ui_module = Node.new()
	ui_module.set_script(load("res://scripts/game_ui.gd"))
	add_child(ui_module)
	ui_module.initialize(self, map_config, gold)
	ui_module.place_mode_requested.connect(_on_place_mode_requested)
	key_to_mode = ui_module.key_to_mode

	# 相机模块
	camera_module = Node.new()
	camera_module.set_script(load("res://scripts/game_camera.gd"))
	add_child(camera_module)
	camera_module.initialize(camera, map_bounds)

	# 生成模块
	spawner_module = Node.new()
	spawner_module.set_script(load("res://scripts/game_spawner.gd"))
	add_child(spawner_module)
	spawner_module.initialize(self, player_units_node, enemy_units_node, buildings_node)

	# 建筑放置模块
	building_placer = Node.new()
	building_placer.set_script(load("res://scripts/building_placer.gd"))
	add_child(building_placer)
	building_placer.initialize(map_bounds, NAV_BOUNDS, nav_region, buildings_node, preview_rect, ui_module)
	spawner_module.place_building_callback = building_placer.place_building

	# 战斗/选择模块
	combat_ctrl = Node.new()
	combat_ctrl.set_script(load("res://scripts/combat_controller.gd"))
	add_child(combat_ctrl)
	combat_ctrl.initialize(spawner_module)

	# 生成
	spawner_module.spawn_from_config(map_config)
	building_placer.create_grid()
	spawner_module.spawn_environment(map_config, map_bounds)

	_setup_victory_condition()
	_setup_capture_points()
	_setup_wave_manager()

	if map_config != null:
		camera.position = map_config.camera_start

	await get_tree().process_frame

func _load_from_config() -> void:
	if map_config == null:
		return
	NAV_BOUNDS = map_config.nav_bounds
	map_bounds = map_config.map_bounds
	gold = map_config.initial_gold

func _setup_victory_condition() -> void:
	for child in get_children():
		if child is VictoryCondition:
			victory_condition = child
			victory_condition.game_ended.connect(_on_game_ended)
			break

func _on_game_ended(result: String) -> void:
	result_label.text = "Victory!" if result == "victory" else "Defeat!"
	result_label.visible = true

func _setup_capture_points() -> void:
	for child in get_children():
		if child is CapturePoint:
			child.set_game_controller(self)

func _setup_wave_manager() -> void:
	for child in get_children():
		if child is WaveManager:
			child.set_game_controller(self)
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

# --- 单位死亡 ---

func _on_unit_died(unit: CharacterBody2D) -> void:
	combat_ctrl.remove_dead_unit(unit)

# --- 每帧更新 ---

var _wave_clear_notified: bool = false

func _process(delta: float) -> void:
	camera_module.process_camera(delta)
	_check_victory()
	_check_wave_cleared()
	combat_ctrl.update_selection(get_global_mouse_position(), selection_box)
	attack_move_indicator.visible = combat_ctrl.attack_move_mode
	building_placer.update_preview()
	if building_placer.show_grid and building_placer.grid_overlay:
		building_placer.grid_overlay.visible = building_placer.show_grid

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
	if result_label.visible:
		return
	if victory_condition != null:
		var result := victory_condition.check()
		if result == 1:
			result_label.text = "Victory!"
			result_label.visible = true
		elif result == 2:
			result_label.text = "Defeat!"
			result_label.visible = true
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
		result_label.text = "Victory!"
		result_label.visible = true
	elif not player_castle_alive:
		result_label.text = "Defeat!"
		result_label.visible = true

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
	if ec > 0:
		return
	if not _wave_clear_notified:
		_wave_clear_notified = true
		wm.on_wave_cleared()

# --- 输入处理 ---

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if ui_module.pause_menu_open:
			ui_module.close_pause_menu()
			return
		elif building_placer.get_place_mode() != D.PlaceMode.NONE or combat_ctrl.attack_move_mode:
			building_placer.cancel_place_mode()
			combat_ctrl.set_attack_move_mode(false)
			cursor_manager.set_attack(false)
			return
		else:
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
					elif building_placer.get_place_mode() != D.PlaceMode.NONE:
						_do_place(get_global_mouse_position())
					else:
						combat_ctrl.start_selection(get_global_mouse_position())
				else:
					if combat_ctrl.is_selecting:
						combat_ctrl.release_selection(get_global_mouse_position(), selection_box)
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					combat_ctrl.set_attack_move_mode(false)
					building_placer.cancel_place_mode()
					cursor_manager.set_attack(false)
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
		match event.keycode:
			KEY_A:
				if not combat_ctrl.is_empty():
					combat_ctrl.set_attack_move_mode(true)
					building_placer.cancel_place_mode()
					cursor_manager.set_attack(true)
			KEY_S:
				combat_ctrl.stop_selected()
			KEY_H:
				combat_ctrl.hold_position_selected()
			KEY_R:
				get_tree().reload_current_scene()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0:
				if key_to_mode.has(event.keycode):
					_on_place_mode_requested(key_to_mode[event.keycode])
			KEY_G:
				building_placer.show_grid = not building_placer.show_grid
				if building_placer.grid_overlay:
					building_placer.grid_overlay.visible = building_placer.show_grid
			KEY_SPACE:
				if building_placer.get_place_mode() != D.PlaceMode.NONE:
					building_placer.cancel_place_mode()
				_jump_to_base()

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

func spawn_enemy_unit(type: int, pos: Vector2, wave_attack: bool = false, wave_target: Vector2 = Vector2.ZERO) -> void:
	spawner_module.spawn_enemy_unit(type, pos, wave_attack, wave_target)

func add_gold(amount: int) -> void:
	gold += amount
	ui_module.update_gold_display(gold)

func show_floating_text(text: String, color: Color, world_pos: Vector2) -> void:
	spawner_module.show_floating_text(text, color, world_pos)

func spawn_unit_near(type: int, pos: Vector2, team: int) -> void:
	spawner_module.spawn_unit_near(type, pos, team)
