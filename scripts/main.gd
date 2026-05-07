extends Node2D

const UnitScript := preload("res://scripts/unit.gd")
const BuildingScript := preload("res://scripts/building.gd")
const GRID_SIZE := 64
const NAV_BOUNDS := [Vector2(-500, -500), Vector2(1500, -500), Vector2(1500, 1200), Vector2(-500, 1200)]

enum PlaceMode { NONE, WALL, TOWER, CASTLE, BARRACKS, SOLDIER, ARCHER, MONASTERY, ARCHERY_RANGE, LANCER, MONK_UNIT }

const COSTS := {
	PlaceMode.WALL: 50,
	PlaceMode.TOWER: 150,
	PlaceMode.SOLDIER: 100,
	PlaceMode.ARCHER: 120,
	PlaceMode.CASTLE: 500,
	PlaceMode.BARRACKS: 300,
	PlaceMode.MONASTERY: 350,
	PlaceMode.ARCHERY_RANGE: 250,
	PlaceMode.LANCER: 150,
	PlaceMode.MONK_UNIT: 80,
}

# 框选
var is_selecting: bool = false
var selection_start: Vector2 = Vector2.ZERO
var selected_units: Array = []

# 攻击移动
var attack_move_mode: bool = false

# 放置模式
var place_mode: PlaceMode = PlaceMode.NONE

# 网格显示
var show_grid: bool = false
var grid_overlay = null

# 网格占用
var occupied_cells: Dictionary = {}  # Vector2i -> Building

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

# UI 引用
var ui_buttons: Dictionary = {}
var place_mode_label: Label
var gold: int = 10000
var gold_label: Label

# === 相机控制 ===
var camera_speed: float = 600.0
var edge_margin: float = 30.0
var zoom_step: float = 0.15
var min_zoom: float = 0.4
var max_zoom: float = 2.0
var map_bounds := Rect2(-500, -500, 2000, 1700)

var _mid_dragging: bool = false
var _mid_drag_start_mouse := Vector2.ZERO
var _mid_drag_start_cam := Vector2.ZERO

func _ready() -> void:
	result_label.visible = false
	attack_move_indicator.visible = false
	preview_rect.visible = false
	_create_ui()
	_spawn_initial()
	_create_grid()
	_spawn_environment()

	# 相机平滑设置
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 10.0

	await get_tree().process_frame


func _create_grid() -> void:
	var container := Node2D.new()
	container.name = "GridOverlay"
	container.z_index = 1
	container.visible = false
	add_child(container)
	move_child(container, 1)
	var start_x := -500
	var start_y := -500
	var end_x := 1500
	var end_y := 1200
	var color := Color(1, 1, 1, 0.2)
	var x := start_x
	while x <= end_x:
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = color
		line.add_point(Vector2(x, start_y))
		line.add_point(Vector2(x, end_y))
		container.add_child(line)
		x += GRID_SIZE
	var y := start_y
	while y <= end_y:
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = color
		line.add_point(Vector2(start_x, y))
		line.add_point(Vector2(end_x, y))
		container.add_child(line)
		y += GRID_SIZE
	grid_overlay = container

func _create_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_top = 10.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	var buttons_data := [
		{"mode": PlaceMode.WALL, "text": "Wall[1] $50", "key": KEY_1},
		{"mode": PlaceMode.TOWER, "text": "Tower[2] $150", "key": KEY_2},
		{"mode": PlaceMode.SOLDIER, "text": "Soldier[3] $100", "key": KEY_3},
		{"mode": PlaceMode.ARCHER, "text": "Archer[4] $120", "key": KEY_4},
		{"mode": PlaceMode.CASTLE, "text": "Castle[5] $500", "key": KEY_5},
		{"mode": PlaceMode.BARRACKS, "text": "Barracks[6] $300", "key": KEY_6},
		{"mode": PlaceMode.MONASTERY, "text": "Monastery[7] $350", "key": KEY_7},
		{"mode": PlaceMode.ARCHERY_RANGE, "text": "Archery[8] $250", "key": KEY_8},
		{"mode": PlaceMode.LANCER, "text": "Lancer[9] $150", "key": KEY_9},
		{"mode": PlaceMode.MONK_UNIT, "text": "Monk[0] $80", "key": KEY_0},
	]

	for data in buttons_data:
		var btn := Button.new()
		btn.text = data.text
		btn.custom_minimum_size = Vector2(135, 36)
		btn.pressed.connect(func(): _enter_place_mode(data.mode))
		hbox.add_child(btn)
		ui_buttons[data.mode] = btn

	canvas.add_child(panel)

	# 放置模式提示
	place_mode_label = Label.new()
	place_mode_label.anchor_left = 0.5
	place_mode_label.anchor_right = 0.5
	place_mode_label.anchor_top = 0.0
	place_mode_label.anchor_bottom = 0.0
	place_mode_label.offset_top = 65.0
	place_mode_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	place_mode_label.add_theme_font_size_override("font_size", 18)
	place_mode_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	place_mode_label.visible = false
	canvas.add_child(place_mode_label)

	# 金币显示
	gold_label = Label.new()
	gold_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	gold_label.offset_left = 10.0
	gold_label.offset_top = 10.0
	gold_label.add_theme_font_size_override("font_size", 22)
	gold_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_update_gold_display()
	canvas.add_child(gold_label)

func _update_gold_display() -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % gold
	_update_button_affordability()

func _update_button_affordability() -> void:
	for mode in ui_buttons:
		var btn: Button = ui_buttons[mode]
		var cost: int = COSTS.get(mode, 0)
		btn.disabled = gold < cost
		btn.modulate.a = 0.5 if gold < cost else 1.0

func _enter_place_mode(mode: PlaceMode) -> void:
	if place_mode == mode:
		place_mode = PlaceMode.NONE
	else:
		place_mode = mode
	attack_move_mode = false

func _spawn_initial() -> void:
	# 玩家单位
	var player_spawns := [
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(200, 200)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(200, 280)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(200, 360)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(150, 240)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(150, 320)},
	]
	for spawn in player_spawns:
		var unit := _create_unit(spawn.type, UnitScript.Team.PLAYER, spawn.pos)
		player_units_node.add_child(unit)
		unit.add_to_group("player_units")

	# 敌方单位
	var enemy_spawns := [
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(900, 200)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(900, 280)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(900, 360)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(950, 240)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(950, 320)},
	]
	for spawn in enemy_spawns:
		var unit := _create_unit(spawn.type, UnitScript.Team.ENEMY, spawn.pos)
		enemy_units_node.add_child(unit)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.set_script(load("res://scripts/enemy_ai.gd"))
		unit.add_child(ai)

	# 玩家初始建筑
	_place_building(BuildingScript.BuildingType.CASTLE, BuildingScript.Team.PLAYER, Vector2i(1, 2))
	_place_building(BuildingScript.BuildingType.BARRACKS, BuildingScript.Team.PLAYER, Vector2i(5, 3))

	# 敌方初始建筑：城堡 + 兵营 + 箭塔 + 围墙
	_place_building(BuildingScript.BuildingType.CASTLE, BuildingScript.Team.ENEMY, Vector2i(12, 2))
	_place_building(BuildingScript.BuildingType.BARRACKS, BuildingScript.Team.ENEMY, Vector2i(10, 3))
	_place_building(BuildingScript.BuildingType.TOWER, BuildingScript.Team.ENEMY, Vector2i(15, 4))
	_place_building(BuildingScript.BuildingType.WALL, BuildingScript.Team.ENEMY, Vector2i(11, 4))
	_place_building(BuildingScript.BuildingType.WALL, BuildingScript.Team.ENEMY, Vector2i(11, 6))

# --- 环境装饰 ---

func _spawn_environment() -> void:
	var env_node := Node2D.new()
	env_node.name = "Environment"
	env_node.z_index = 1
	add_child(env_node)
	move_child(env_node, 1)

	# 树木
	var tree_scene := load("res://scenes/tree.tscn")
	var tree_textures := [
		"res://assets/environment/trees/Tree1.png",
		"res://assets/environment/trees/Tree2.png",
		"res://assets/environment/trees/Tree3.png",
		"res://assets/environment/trees/Tree4.png",
	]
	for i in range(15):
		var tree: Node2D = tree_scene.instantiate()
		var pos := Vector2(randf_range(-400, 1400), randf_range(-400, 1100))
		tree.position = pos
		tree.get_node("Sprite").texture = load(tree_textures[i % 4])
		tree.get_node("Sprite").frame = randi() % 8
		env_node.add_child(tree)

	# 岩石
	var rock_scene := load("res://scenes/rock.tscn")
	var rock_textures := [
		"res://assets/environment/rocks/Rock1.png",
		"res://assets/environment/rocks/Rock2.png",
		"res://assets/environment/rocks/Rock3.png",
		"res://assets/environment/rocks/Rock4.png",
	]
	for i in range(10):
		var rock: Node2D = rock_scene.instantiate()
		rock.position = Vector2(randf_range(-400, 1400), randf_range(-400, 1100))
		rock.get_node("Sprite").texture = load(rock_textures[i % 4])
		env_node.add_child(rock)

	# 灌木
	var bush_scene := load("res://scenes/bush.tscn")
	var bush_textures := [
		"res://assets/environment/bushes/Bushe1.png",
		"res://assets/environment/bushes/Bushe2.png",
		"res://assets/environment/bushes/Bushe3.png",
		"res://assets/environment/bushes/Bushe4.png",
	]
	for i in range(12):
		var bush: Node2D = bush_scene.instantiate()
		bush.position = Vector2(randf_range(-400, 1400), randf_range(-400, 1100))
		bush.get_node("Sprite").texture = load(bush_textures[i % 4])
		env_node.add_child(bush)

	# 羊
	var sheep_scene := load("res://scenes/sheep.tscn")
	for i in range(5):
		var sheep: Node2D = sheep_scene.instantiate()
		sheep.position = Vector2(randf_range(-200, 1200), randf_range(-200, 1000))
		env_node.add_child(sheep)

# --- 网格工具 ---

func snap_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / GRID_SIZE), floori(pos.y / GRID_SIZE))

func grid_to_world(gpos: Vector2i) -> Vector2:
	return Vector2(gpos.x * GRID_SIZE + GRID_SIZE / 2.0, gpos.y * GRID_SIZE + GRID_SIZE / 2.0)

func is_grid_free(gpos: Vector2i, size: Vector2i) -> bool:
	for dx in range(size.x):
		for dy in range(size.y):
			var cell := Vector2i(gpos.x + dx, gpos.y + dy)
			if cell in occupied_cells:
				return false
	return true

# --- 建筑 ---

func _place_building(type: int, team: int, gpos: Vector2i) -> Node2D:
	var scene_path := "res://scenes/building.tscn"
	match type:
		BuildingScript.BuildingType.WALL: scene_path = "res://scenes/wall.tscn"
		BuildingScript.BuildingType.TOWER: scene_path = "res://scenes/tower.tscn"
		BuildingScript.BuildingType.CASTLE: scene_path = "res://scenes/castle.tscn"
		BuildingScript.BuildingType.BARRACKS: scene_path = "res://scenes/barracks.tscn"
		BuildingScript.BuildingType.MONASTERY: scene_path = "res://scenes/monastery.tscn"
		BuildingScript.BuildingType.ARCHERY: scene_path = "res://scenes/archery_building.tscn"
	var building_scene := load(scene_path)
	var building: Node2D = building_scene.instantiate()
	# building_type 已在场景中设置
	building.set("team", team)
	building.set("grid_pos", gpos)
	building.position = grid_to_world(gpos)

	# 获取建筑网格大小
	var gsize: Vector2i
	match type:
		BuildingScript.BuildingType.WALL:
			gsize = Vector2i(1, 1)
		BuildingScript.BuildingType.TOWER:
			gsize = Vector2i(1, 1)
		BuildingScript.BuildingType.CASTLE:
			gsize = Vector2i(3, 3)
		BuildingScript.BuildingType.BARRACKS:
			gsize = Vector2i(2, 2)
		BuildingScript.BuildingType.MONASTERY:
			gsize = Vector2i(2, 2)
		BuildingScript.BuildingType.ARCHERY:
			gsize = Vector2i(2, 2)

	# 中心需要偏移
	if gsize.x > 1 or gsize.y > 1:
		building.position += Vector2((gsize.x - 1) * GRID_SIZE / 2.0, (gsize.y - 1) * GRID_SIZE / 2.0)

	buildings_node.add_child(building)
	var team_str := "player_buildings" if team == BuildingScript.Team.PLAYER else "enemy_buildings"
	building.add_to_group("buildings")
	building.add_to_group(team_str)
	building.connect("died", _on_building_died)

	# 标记占用
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

	var traversable: Array = []
	traversable.append(PackedVector2Array(NAV_BOUNDS))
	source_geom.traversable_outlines = traversable

	var obstructions: Array = []
	var margin := 0.5
	for building in get_tree().get_nodes_in_group("buildings"):
		if building.is_dead():
			continue
		var rect: Rect2 = building.get_rect()
		obstructions.append(PackedVector2Array([
			rect.position + Vector2(margin, margin),
			Vector2(rect.end.x - margin, rect.position.y + margin),
			rect.end - Vector2(margin, margin),
			Vector2(rect.position.x + margin, rect.end.y - margin)
		]))
	source_geom.obstruction_outlines = obstructions

	var nav_poly := NavigationPolygon.new()
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geom)
	nav_region.navigation_polygon = nav_poly

# --- 单位创建 ---

func _create_unit(type: int, team: int, pos: Vector2) -> CharacterBody2D:
	var scene_path := "res://scenes/soldier.tscn"
	match type:
		UnitScript.UnitType.SOLDIER: scene_path = "res://scenes/soldier.tscn"
		UnitScript.UnitType.ARCHER: scene_path = "res://scenes/archer.tscn"
		UnitScript.UnitType.LANCER: scene_path = "res://scenes/lancer.tscn"
		UnitScript.UnitType.MONK: scene_path = "res://scenes/monk.tscn"
	var unit_scene := load(scene_path)
	var unit: CharacterBody2D = unit_scene.instantiate()
	unit.set("team", team)
	unit.position = pos
	unit.connect("died", _on_unit_died)
	return unit

func _on_unit_died(unit: CharacterBody2D) -> void:
	if selected_units.has(unit):
		selected_units.erase(unit)

# --- 每帧更新 ---

func _process(delta: float) -> void:
	_process_camera(delta)
	_check_victory()

	# 框选矩形
	if is_selecting:
		var current_pos := get_global_mouse_position()
		var rect := _get_selection_rect(selection_start, current_pos)
		selection_box.position = rect.position
		selection_box.size = rect.size
		selection_box.visible = true
	else:
		selection_box.visible = false

	attack_move_indicator.visible = attack_move_mode

	# 放置预览
	_update_preview()

func _process_camera(delta: float) -> void:
	var move_dir := Vector2.ZERO
	var viewport_size := get_viewport().get_visible_rect().size

	# --- 边缘滚动 ---
	var mouse_pos := get_viewport().get_mouse_position()
	if mouse_pos.x < edge_margin:
		move_dir.x -= 1.0
	elif mouse_pos.x > viewport_size.x - edge_margin:
		move_dir.x += 1.0
	if mouse_pos.y < edge_margin:
		move_dir.y -= 1.0
	elif mouse_pos.y > viewport_size.y - edge_margin:
		move_dir.y += 1.0

	# --- 方向键滚动 ---
	if Input.is_key_pressed(KEY_UP):
		move_dir.y -= 1.0
	if Input.is_key_pressed(KEY_DOWN):
		move_dir.y += 1.0
	if Input.is_key_pressed(KEY_LEFT):
		move_dir.x -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		move_dir.x += 1.0

	# --- 应用移动 ---
	if move_dir != Vector2.ZERO:
		move_dir = move_dir.normalized()
		var current_zoom := camera.zoom.x
		camera.position += move_dir * camera_speed * delta / current_zoom

	# --- 中键拖拽 ---
	if _mid_dragging:
		var mouse_delta := get_viewport().get_mouse_position() - _mid_drag_start_mouse
		var current_zoom := camera.zoom.x
		camera.position = _mid_drag_start_cam - mouse_delta / current_zoom

	# --- 边界约束 ---
	_clamp_camera()

func _clamp_camera() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var current_zoom := camera.zoom.x
	var half_w := viewport_size.x / 2.0 / current_zoom
	var half_h := viewport_size.y / 2.0 / current_zoom

	var min_x := map_bounds.position.x + half_w
	var max_x := map_bounds.end.x - half_w
	var min_y := map_bounds.position.y + half_h
	var max_y := map_bounds.end.y - half_h

	if min_x > max_x:
		min_x = (map_bounds.position.x + map_bounds.end.x) / 2.0
		max_x = min_x
	if min_y > max_y:
		min_y = (map_bounds.position.y + map_bounds.end.y) / 2.0
		max_y = min_y

	camera.position.x = clampf(camera.position.x, min_x, max_x)
	camera.position.y = clampf(camera.position.y, min_y, max_y)

func _update_preview() -> void:
	# 单位类型 — 只显示提示文字
	if place_mode == PlaceMode.SOLDIER or place_mode == PlaceMode.ARCHER or place_mode == PlaceMode.LANCER or place_mode == PlaceMode.MONK_UNIT:
		preview_rect.visible = false
		if place_mode_label:
			var unit_name := ""
			match place_mode:
				PlaceMode.SOLDIER: unit_name = "Soldier"
				PlaceMode.ARCHER: unit_name = "Archer"
				PlaceMode.LANCER: unit_name = "Lancer"
				PlaceMode.MONK_UNIT: unit_name = "Monk"
			place_mode_label.text = "Click to place %s" % unit_name
			place_mode_label.visible = true
		return

	if place_mode == PlaceMode.NONE:
		preview_rect.visible = false
		if place_mode_label:
			place_mode_label.visible = false
		return

	# 建筑预览
	var mouse_pos := get_global_mouse_position()
	var gpos := snap_to_grid(mouse_pos)
	var gsize: Vector2i
	match place_mode:
		PlaceMode.WALL:
			gsize = Vector2i(1, 1)
		PlaceMode.TOWER:
			gsize = Vector2i(1, 1)
		PlaceMode.CASTLE:
			gsize = Vector2i(3, 3)
		PlaceMode.BARRACKS:
			gsize = Vector2i(2, 2)
		PlaceMode.MONASTERY:
			gsize = Vector2i(2, 2)
		PlaceMode.ARCHERY_RANGE:
			gsize = Vector2i(2, 2)
		_:
			gsize = Vector2i(1, 1)

	var world_pos := grid_to_world(gpos)
	if gsize.x > 1 or gsize.y > 1:
		world_pos += Vector2((gsize.x - 1) * GRID_SIZE / 2.0, (gsize.y - 1) * GRID_SIZE / 2.0)

	var can_place := is_grid_free(gpos, gsize)
	preview_rect.visible = true
	preview_rect.position = world_pos - Vector2(gsize.x * GRID_SIZE / 2.0, gsize.y * GRID_SIZE / 2.0)
	preview_rect.size = Vector2(gsize.x * GRID_SIZE, gsize.y * GRID_SIZE)
	preview_rect.color = Color(0, 1, 0, 0.3) if can_place else Color(1, 0, 0, 0.3)

	var type_name := ""
	match place_mode:
		PlaceMode.WALL: type_name = "Wall"
		PlaceMode.TOWER: type_name = "Tower"
		PlaceMode.CASTLE: type_name = "Castle"
		PlaceMode.BARRACKS: type_name = "Barracks"
		PlaceMode.MONASTERY: type_name = "Monastery"
		PlaceMode.ARCHERY_RANGE: type_name = "Archery"
		_: type_name = "Building"
	var cost_preview: int = COSTS.get(place_mode, 0)
	place_mode_label.text = "Place %s $%d (Esc cancel)" % [type_name, cost_preview]
	place_mode_label.visible = true

func _check_victory() -> void:
	if result_label.visible:
		return

	# 检查玩家城堡是否存活
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				player_castle_alive = true
				break

	# 检查敌方城堡是否存活
	var enemy_castle_alive := false
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				enemy_castle_alive = true
				break

	if not enemy_castle_alive:
		result_label.text = "Victory!"
		result_label.visible = true
	elif not player_castle_alive:
		result_label.text = "Defeat!"
		result_label.visible = true

# --- 输入处理 ---

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if attack_move_mode:
					_do_attack_move(get_global_mouse_position())
					attack_move_mode = false
				elif place_mode != PlaceMode.NONE:
					_do_place(get_global_mouse_position())
				else:
					is_selecting = true
					selection_start = get_global_mouse_position()
			else:
				if is_selecting:
					is_selecting = false
					_selection_released()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			attack_move_mode = false
			place_mode = PlaceMode.NONE
			_right_click()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_mid_dragging = true
				_mid_drag_start_mouse = get_viewport().get_mouse_position()
				_mid_drag_start_cam = camera.position
			else:
				_mid_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			var new_zoom := clampf(camera.zoom.x + zoom_step, min_zoom, max_zoom)
			camera.zoom = Vector2(new_zoom, new_zoom)
			_clamp_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			var new_zoom := clampf(camera.zoom.x - zoom_step, min_zoom, max_zoom)
			camera.zoom = Vector2(new_zoom, new_zoom)
			_clamp_camera()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_A:
				if not selected_units.is_empty():
					attack_move_mode = true
					place_mode = PlaceMode.NONE
			KEY_S:
				_stop_selected()
			KEY_R:
				get_tree().reload_current_scene()
			KEY_1:
				_enter_place_mode(PlaceMode.WALL)
			KEY_2:
				_enter_place_mode(PlaceMode.TOWER)
			KEY_3:
				_enter_place_mode(PlaceMode.SOLDIER)
			KEY_4:
				_enter_place_mode(PlaceMode.ARCHER)
			KEY_5:
				_enter_place_mode(PlaceMode.CASTLE)
			KEY_6:
				_enter_place_mode(PlaceMode.BARRACKS)
			KEY_7:
				_enter_place_mode(PlaceMode.MONASTERY)
			KEY_8:
				_enter_place_mode(PlaceMode.ARCHERY_RANGE)
			KEY_9:
				_enter_place_mode(PlaceMode.LANCER)
			KEY_0:
				_enter_place_mode(PlaceMode.MONK_UNIT)
			KEY_G:
				show_grid = not show_grid
				if grid_overlay:
					grid_overlay.visible = show_grid
			KEY_ESCAPE:
				place_mode = PlaceMode.NONE
				attack_move_mode = false

# --- 放置 ---

func _do_place(click_pos: Vector2) -> void:
	var cost: int = COSTS.get(place_mode, 0)
	if gold < cost:
		return

	var placed := false
	match place_mode:
		PlaceMode.WALL:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(1, 1)):
				var b = _place_building(BuildingScript.BuildingType.WALL, BuildingScript.Team.PLAYER, gpos)
				b.start_construction()
				placed = true
		PlaceMode.TOWER:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(1, 1)):
				var b = _place_building(BuildingScript.BuildingType.TOWER, BuildingScript.Team.PLAYER, gpos)
				b.start_construction()
				placed = true
		PlaceMode.SOLDIER:
			var unit := _create_unit(UnitScript.UnitType.SOLDIER, UnitScript.Team.PLAYER, click_pos)
			player_units_node.add_child(unit)
			unit.add_to_group("player_units")
			placed = true
		PlaceMode.ARCHER:
			var unit := _create_unit(UnitScript.UnitType.ARCHER, UnitScript.Team.PLAYER, click_pos)
			player_units_node.add_child(unit)
			unit.add_to_group("player_units")
			placed = true
		PlaceMode.CASTLE:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(3, 3)):
				var b = _place_building(BuildingScript.BuildingType.CASTLE, BuildingScript.Team.PLAYER, gpos)
				b.start_construction()
				placed = true
		PlaceMode.BARRACKS:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(2, 2)):
				var b = _place_building(BuildingScript.BuildingType.BARRACKS, BuildingScript.Team.PLAYER, gpos)
				b.start_construction()
				placed = true
		PlaceMode.MONASTERY:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(2, 2)):
				var b = _place_building(BuildingScript.BuildingType.MONASTERY, BuildingScript.Team.PLAYER, gpos)
				b.start_construction()
				placed = true
		PlaceMode.ARCHERY_RANGE:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(2, 2)):
				var b = _place_building(BuildingScript.BuildingType.ARCHERY, BuildingScript.Team.PLAYER, gpos)
				b.start_construction()
				placed = true
		PlaceMode.LANCER:
			var unit := _create_unit(UnitScript.UnitType.LANCER, UnitScript.Team.PLAYER, click_pos)
			player_units_node.add_child(unit)
			unit.add_to_group("player_units")
			placed = true
		PlaceMode.MONK_UNIT:
			var unit := _create_unit(UnitScript.UnitType.MONK, UnitScript.Team.PLAYER, click_pos)
			player_units_node.add_child(unit)
			unit.add_to_group("player_units")
			placed = true

	if placed:
		gold -= cost
		_update_gold_display()

# --- 攻击移动 ---

func _do_attack_move(click_pos: Vector2) -> void:
	if selected_units.is_empty():
		return

	# 检测是否点到了敌方单位或建筑 → 集火
	var target = _find_enemy_at(click_pos)
	if target != null:
		for u in selected_units:
			u.call("command_attack", target)
		if target.has_method("get_children"):
			for ai in target.get_children():
				if ai.has_method("on_attacked") and selected_units.size() > 0:
					ai.on_attacked(selected_units[0])
		return

	# 没点到敌人 → 普通攻击移动
	var count := selected_units.size()
	for i in range(count):
		var offset := _formation_offset(i, count)
		selected_units[i].call("attack_move_to", click_pos + offset)

func _find_enemy_at(pos: Vector2):
	# 先查敌方单位
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			var sprite_pos: Vector2 = u.global_position
			if u.has_node("BodySprite"):
				sprite_pos = u.get_node("BodySprite").global_position
			if sprite_pos.distance_to(pos) < 25.0:
				return u
	# 再查敌方建筑
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.get_rect().has_point(pos):
				return b
	return null

func _stop_selected() -> void:
	for unit in selected_units:
		unit.call("stop")

# --- 选择 ---

func _selection_released() -> void:
	var end_pos := get_global_mouse_position()
	var rect := _get_selection_rect(selection_start, end_pos)

	if rect.size.length() < 5.0:
		rect = Rect2(end_pos - Vector2(10, 10), Vector2(20, 20))

	_deselect_all()

	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			var sel_pos: Vector2 = u.global_position
			if u.has_node("BodySprite"):
					sel_pos = u.get_node("BodySprite").global_position
			if rect.has_point(sel_pos):
				u.call("set_selected", true)
				selected_units.append(u)

# --- 右键命令 ---

func _right_click() -> void:
	if selected_units.is_empty():
		return

	var click_pos := get_global_mouse_position()

	# 检测敌方目标
	var target = _find_enemy_at(click_pos)
	if target != null:
		for unit in selected_units:
			unit.call("command_attack", target)
		if target.has_method("get_children"):
			for ai in target.get_children():
				if ai.has_method("on_attacked"):
					ai.on_attacked(selected_units[0])
		return

	# 移动
	var count := selected_units.size()
	for i in range(count):
		var offset := _formation_offset(i, count)
		selected_units[i].call("move_to", click_pos + offset)

# --- 工具 ---

func _formation_offset(index: int, total: int) -> Vector2:
	if total == 1:
		return Vector2.ZERO
	var angle := (float(index) / float(total)) * PI - PI / 2.0
	var radius := 30.0 + total * 5.0
	return Vector2(cos(angle), sin(angle)) * radius

func _deselect_all() -> void:
	for unit in selected_units:
		unit.call("set_selected", false)
	selected_units.clear()

func _get_selection_rect(start: Vector2, end: Vector2) -> Rect2:
	var pos := Vector2(min(start.x, end.x), min(start.y, end.y))
	var size := Vector2(abs(end.x - start.x), abs(end.y - start.y))
	return Rect2(pos, size)
