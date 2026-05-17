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

# 框选
var is_selecting: bool = false
var selection_start: Vector2 = Vector2.ZERO
var selected_units: Array = []

# 攻击移动
var attack_move_mode: bool = false

# 自定义光标管理器
var cursor_manager: Node = null

# 放置模式
var place_mode: int = D.PlaceMode.NONE

# 网格显示
var show_grid: bool = false
var grid_overlay = null

# 网格占用
var occupied_cells: Dictionary = {}

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
	ui_module.place_mode_requested.connect(_enter_place_mode)
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
	spawner_module.place_building_callback = _place_building

	# 生成
	spawner_module.spawn_from_config(map_config)
	_create_grid()
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

func _create_grid() -> void:
	var container := Node2D.new()
	container.name = "GridOverlay"
	container.z_index = 1
	container.visible = false
	add_child(container)
	move_child(container, 1)
	var bounds: Rect2 = map_bounds
	var color := Color(1, 1, 1, 0.2)
	var x := bounds.position.x
	while x <= bounds.end.x:
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = color
		line.add_point(Vector2(x, bounds.position.y))
		line.add_point(Vector2(x, bounds.end.y))
		container.add_child(line)
		x += D.GRID_SIZE
	var y := bounds.position.y
	while y <= bounds.end.y:
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = color
		line.add_point(Vector2(bounds.position.x, y))
		line.add_point(Vector2(bounds.end.x, y))
		container.add_child(line)
		y += D.GRID_SIZE
	grid_overlay = container

func _enter_place_mode(mode: int) -> void:
	if place_mode == mode:
		place_mode = D.PlaceMode.NONE
	else:
		place_mode = mode
	attack_move_mode = false

# --- 网格工具 ---

func snap_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / D.GRID_SIZE), floori(pos.y / D.GRID_SIZE))

func grid_to_world(gpos: Vector2i) -> Vector2:
	return Vector2(gpos.x * D.GRID_SIZE + D.GRID_SIZE / 2.0, gpos.y * D.GRID_SIZE + D.GRID_SIZE / 2.0)

func is_grid_free(gpos: Vector2i, size: Vector2i) -> bool:
	for dx in range(size.x):
		for dy in range(size.y):
			if Vector2i(gpos.x + dx, gpos.y + dy) in occupied_cells:
				return false
	return true

# --- 建筑 ---

func _place_building(type: int, team: int, gpos: Vector2i) -> Node2D:
	var scene_path: String = D.BUILDING_SCENES.get(type, "res://scenes/building.tscn")
	var building: Node2D = load(scene_path).instantiate()
	building.set("team", team)
	building.set("grid_pos", gpos)
	building.position = grid_to_world(gpos)
	var gsize: Vector2i = D.get_building_grid_size(type)
	if gsize.x > 1 or gsize.y > 1:
		building.position += Vector2((gsize.x - 1) * D.GRID_SIZE / 2.0, (gsize.y - 1) * D.GRID_SIZE / 2.0)
	buildings_node.add_child(building)
	building.add_to_group("buildings")
	building.add_to_group("player_buildings" if team == BuildingScript.Team.PLAYER else "enemy_buildings")
	building.connect("died", _on_building_died)
	for dx in range(gsize.x):
		for dy in range(gsize.y):
			occupied_cells[Vector2i(gpos.x + dx, gpos.y + dy)] = building
	_rebuild_navigation()
	return building

func _on_building_died(building: Node2D) -> void:
	var gpos: Vector2i = building.get("grid_pos")
	var gsize: Vector2i = building.get("grid_size")
	for dx in range(gsize.x):
		for dy in range(gsize.y):
			occupied_cells.erase(Vector2i(gpos.x + dx, gpos.y + dy))
	_rebuild_navigation()

func _rebuild_navigation() -> void:
	var source_geom := NavigationMeshSourceGeometryData2D.new()
	source_geom.traversable_outlines = [PackedVector2Array(NAV_BOUNDS)]
	var obstructions: Array = []
	for building in get_tree().get_nodes_in_group("buildings"):
		if building.is_dead():
			continue
		var rect: Rect2 = building.get_rect()
		var m := 20.0
		obstructions.append(PackedVector2Array([
			rect.position - Vector2(m, m), Vector2(rect.end.x + m, rect.position.y - m),
			rect.end + Vector2(m, m), Vector2(rect.position.x - m, rect.end.y + m)
		]))
	source_geom.obstruction_outlines = obstructions
	var nav_poly := NavigationPolygon.new()
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geom)
	nav_region.navigation_polygon = nav_poly

# --- 单位死亡 ---

func _on_unit_died(unit: CharacterBody2D) -> void:
	if selected_units.has(unit):
		selected_units.erase(unit)

# --- 每帧更新 ---

var _wave_clear_notified: bool = false
var _wc_debug_timer: float = 0.0

func _process(delta: float) -> void:
	camera_module.process_camera(delta)
	_check_victory()
	_check_wave_cleared()
	if is_selecting:
		var current_pos := get_global_mouse_position()
		var rect := _get_selection_rect(selection_start, current_pos)
		selection_box.position = rect.position
		selection_box.size = rect.size
		selection_box.visible = true
	else:
		selection_box.visible = false
	attack_move_indicator.visible = attack_move_mode
	_update_preview()

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

func _update_preview() -> void:
	if D.is_unit_mode(place_mode):
		preview_rect.visible = false
		ui_module.set_place_mode_text("Click to place %s" % D.MODE_NAMES.get(place_mode, "Unit"))
		return
	if place_mode == D.PlaceMode.NONE:
		preview_rect.visible = false
		ui_module.hide_place_mode_label()
		return
	var mouse_pos := get_global_mouse_position()
	var gpos := snap_to_grid(mouse_pos)
	var building_type: int = D.PLACE_MODE_TO_BUILDING.get(place_mode, -1)
	var gsize: Vector2i = D.get_building_grid_size(building_type) if building_type >= 0 else Vector2i(1, 1)
	var world_pos := grid_to_world(gpos)
	if gsize.x > 1 or gsize.y > 1:
		world_pos += Vector2((gsize.x - 1) * D.GRID_SIZE / 2.0, (gsize.y - 1) * D.GRID_SIZE / 2.0)
	var can_place := is_grid_free(gpos, gsize)
	preview_rect.visible = true
	preview_rect.position = world_pos - Vector2(gsize.x * D.GRID_SIZE / 2.0, gsize.y * D.GRID_SIZE / 2.0)
	preview_rect.size = Vector2(gsize.x * D.GRID_SIZE, gsize.y * D.GRID_SIZE)
	preview_rect.color = Color(0, 1, 0, 0.3) if can_place else Color(1, 0, 0, 0.3)
	ui_module.set_place_mode_text("Place %s $%d (Esc cancel)" % [D.MODE_NAMES.get(place_mode, "Building"), D.COSTS.get(place_mode, 0)])

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
		_wc_debug_timer += 0.016
		if _wc_debug_timer > 5.0:
			_wc_debug_timer = 0.0
			var ec := 0
			for u in get_tree().get_nodes_in_group("enemy_units"):
				if u is CharacterBody2D and not u.is_dead():
					ec += 1
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
		elif place_mode != D.PlaceMode.NONE or attack_move_mode:
			place_mode = D.PlaceMode.NONE
			attack_move_mode = false
			_set_attack_cursor(false)
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
					if attack_move_mode:
						_do_attack_move(get_global_mouse_position())
						attack_move_mode = false
						_set_attack_cursor(false)
					elif place_mode != D.PlaceMode.NONE:
						_do_place(get_global_mouse_position())
					else:
						is_selecting = true
						selection_start = get_global_mouse_position()
				else:
					if is_selecting:
						is_selecting = false
						_selection_released()
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					attack_move_mode = false
					place_mode = D.PlaceMode.NONE
					_set_attack_cursor(false)
					_right_click()
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
				if not selected_units.is_empty():
					attack_move_mode = true
					place_mode = D.PlaceMode.NONE
					_set_attack_cursor(true)
			KEY_S:
				_stop_selected()
			KEY_H:
				_hold_position_selected()
			KEY_R:
				get_tree().reload_current_scene()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0:
				if key_to_mode.has(event.keycode):
					_enter_place_mode(key_to_mode[event.keycode])
			KEY_G:
				show_grid = not show_grid
				if grid_overlay:
					grid_overlay.visible = show_grid
			KEY_SPACE:
				if place_mode != D.PlaceMode.NONE:
					place_mode = D.PlaceMode.NONE
				_jump_to_base()

# --- 放置 ---

func _do_place(click_pos: Vector2) -> void:
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
		var gp := snap_to_grid(click_pos)
		if is_grid_free(gp, gs):
			_place_building(bt, BuildingScript.Team.PLAYER, gp).start_construction()
			placed = true
	if placed:
		gold -= cost
		ui_module.update_gold_display(gold)

# --- 攻击移动 ---

func _do_attack_move(click_pos: Vector2) -> void:
	if selected_units.is_empty():
		return
	var target = _find_enemy_at(click_pos)
	if target != null:
		for u in selected_units:
			u.call("command_attack", target)
		if target.has_method("get_children"):
			for ai in target.get_children():
				if ai.has_method("on_attacked") and selected_units.size() > 0:
					ai.on_attacked(selected_units[0])
		spawner_module.spawn_click_effect(D.AttackClickEffectScene, click_pos)
		return
	for i in range(selected_units.size()):
		selected_units[i].call("attack_move_to", click_pos + _formation_offset(i, selected_units.size()))
	spawner_module.spawn_click_effect(D.AttackClickEffectScene, click_pos)

func _find_enemy_at(pos: Vector2):
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if sp.distance_to(pos) < 25.0:
				return u
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.has_method("is_dead") and not b.is_dead() and b.get_rect().has_point(pos):
			return b
	return null

func _stop_selected() -> void:
	for unit in selected_units:
		unit.call("stop")

func _hold_position_selected() -> void:
	for unit in selected_units:
		unit.call("hold_position")

func _set_attack_cursor(is_attack: bool) -> void:
	cursor_manager.set_attack(is_attack)

# --- 选择 ---

func _selection_released() -> void:
	var end_pos := get_global_mouse_position()
	var rect := _get_selection_rect(selection_start, end_pos)
	if rect.size.length() < 5.0:
		rect = Rect2(end_pos - Vector2(10, 10), Vector2(20, 20))
	_deselect_all()
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if rect.has_point(sp):
				u.call("set_selected", true)
				selected_units.append(u)

func _right_click() -> void:
	if selected_units.is_empty():
		return
	var click_pos := get_global_mouse_position()
	var target = _find_enemy_at(click_pos)
	if target != null:
		for unit in selected_units:
			unit.call("command_attack", target)
		if target.has_method("get_children"):
			for ai in target.get_children():
				if ai.has_method("on_attacked"):
					ai.on_attacked(selected_units[0])
		spawner_module.spawn_click_effect(D.AttackClickEffectScene, click_pos)
		return
	for i in range(selected_units.size()):
		selected_units[i].call("move_to", click_pos + _formation_offset(i, selected_units.size()))
	spawner_module.spawn_click_effect(D.MoveClickEffectScene, click_pos)

func _formation_offset(index: int, total: int) -> Vector2:
	if total == 1:
		return Vector2.ZERO
	var angle := (float(index) / float(total)) * PI - PI / 2.0
	return Vector2(cos(angle), sin(angle)) * (30.0 + total * 5.0)

func _deselect_all() -> void:
	for unit in selected_units:
		unit.call("set_selected", false)
	selected_units.clear()

func _get_selection_rect(start: Vector2, end: Vector2) -> Rect2:
	return Rect2(Vector2(min(start.x, end.x), min(start.y, end.y)), Vector2(abs(end.x - start.x), abs(end.y - start.y)))

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
