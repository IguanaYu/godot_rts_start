extends Node2D

const UnitScript := preload("res://scripts/unit.gd")
const BuildingScript := preload("res://scripts/building.gd")

const GRID_COLS := 20
const GRID_ROWS := 16

enum PlaceMode { NONE, WALL, TOWER, CASTLE, BARRACKS, SOLDIER, ARCHER }

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
@onready var preview_poly: Polygon2D = $PreviewPoly
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D

# UI 引用
var ui_buttons: Dictionary = {}
var place_mode_label: Label

func _ready() -> void:
	result_label.visible = false
	attack_move_indicator.visible = false
	preview_poly.visible = false

	# 创建菱形地面
	_create_ground()

	_create_ui()
	_spawn_initial()
	_create_grid()

	# Y-Sort 深度排序
	player_units_node.y_sort_enabled = true
	enemy_units_node.y_sort_enabled = true
	buildings_node.y_sort_enabled = true

	# 相机居中
	camera.position = grid_to_world(Vector2i(GRID_COLS / 2, GRID_ROWS / 2))

	await get_tree().process_frame


func _create_ground() -> void:
	var ground := Polygon2D.new()
	ground.name = "Ground"
	ground.polygon = Iso.building_diamond(0, 0, GRID_COLS, GRID_ROWS)
	ground.color = Color(0.35, 0.55, 0.25, 1)
	ground.z_index = -1
	add_child(ground)
	move_child(ground, 0)


# --- 坐标转换 ---

func grid_to_world(gpos: Vector2i) -> Vector2:
	return Iso.grid_to_world(gpos.x, gpos.y)

func snap_to_grid(pos: Vector2) -> Vector2i:
	return Iso.snap_to_grid(pos)


# --- 网格工具 ---

func is_grid_free(gpos: Vector2i, size: Vector2i) -> bool:
	for dx in range(size.x):
		for dy in range(size.y):
			var cell := Vector2i(gpos.x + dx, gpos.y + dy)
			if cell in occupied_cells:
				return false
	return true


# --- 网格显示 ---

func _create_grid() -> void:
	var container := Node2D.new()
	container.name = "GridOverlay"
	container.z_index = 1
	container.visible = false
	add_child(container)
	move_child(container, 1)
	var color := Color(1, 1, 1, 0.2)

	# 沿 gx 轴的线（constant gx, varying gy）
	for gx in range(GRID_COLS + 1):
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = color
		line.add_point(Iso.grid_to_world(gx, 0))
		line.add_point(Iso.grid_to_world(gx, GRID_ROWS))
		container.add_child(line)

	# 沿 gy 轴的线（constant gy, varying gx）
	for gy in range(GRID_ROWS + 1):
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = color
		line.add_point(Iso.grid_to_world(0, gy))
		line.add_point(Iso.grid_to_world(GRID_COLS, gy))
		container.add_child(line)

	grid_overlay = container


# --- UI ---

func _create_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.position = Vector2(340, 10)
	panel.size = Vector2(600, 50)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	var buttons_data := [
		{"mode": PlaceMode.WALL, "text": "House[1]", "key": KEY_1},
		{"mode": PlaceMode.TOWER, "text": "Tower[2]", "key": KEY_2},
		{"mode": PlaceMode.SOLDIER, "text": "Soldier[3]", "key": KEY_3},
		{"mode": PlaceMode.ARCHER, "text": "Archer[4]", "key": KEY_4},
		{"mode": PlaceMode.CASTLE, "text": "Castle[5]", "key": KEY_5},
		{"mode": PlaceMode.BARRACKS, "text": "Barracks[6]", "key": KEY_6},
	]

	for data in buttons_data:
		var btn := Button.new()
		btn.text = data.text
		btn.custom_minimum_size = Vector2(120, 36)
		btn.pressed.connect(func(): _enter_place_mode(data.mode))
		hbox.add_child(btn)
		ui_buttons[data.mode] = btn

	canvas.add_child(panel)

	# 放置模式提示
	place_mode_label = Label.new()
	place_mode_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	place_mode_label.position = Vector2(340, 65)
	place_mode_label.add_theme_font_size_override("font_size", 18)
	place_mode_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	place_mode_label.visible = false
	canvas.add_child(place_mode_label)

func _enter_place_mode(mode: PlaceMode) -> void:
	if place_mode == mode:
		place_mode = PlaceMode.NONE
	else:
		place_mode = mode
	attack_move_mode = false


# --- 初始生成 ---

func _spawn_initial() -> void:
	# 玩家单位
	var player_spawns := [
		{"type": UnitScript.UnitType.SOLDIER, "gpos": Vector2i(2, 4)},
		{"type": UnitScript.UnitType.SOLDIER, "gpos": Vector2i(2, 5)},
		{"type": UnitScript.UnitType.SOLDIER, "gpos": Vector2i(3, 4)},
		{"type": UnitScript.UnitType.ARCHER,  "gpos": Vector2i(1, 4)},
		{"type": UnitScript.UnitType.ARCHER,  "gpos": Vector2i(1, 5)},
	]
	for spawn in player_spawns:
		var pos := grid_to_world(spawn.gpos)
		var unit := _create_unit(spawn.type, UnitScript.Team.PLAYER, pos)
		player_units_node.add_child(unit)
		unit.add_to_group("player_units")

	# 敌方单位
	var enemy_spawns := [
		{"type": UnitScript.UnitType.SOLDIER, "gpos": Vector2i(15, 7)},
		{"type": UnitScript.UnitType.SOLDIER, "gpos": Vector2i(15, 8)},
		{"type": UnitScript.UnitType.SOLDIER, "gpos": Vector2i(16, 7)},
		{"type": UnitScript.UnitType.ARCHER,  "gpos": Vector2i(14, 7)},
		{"type": UnitScript.UnitType.ARCHER,  "gpos": Vector2i(14, 8)},
	]
	for spawn in enemy_spawns:
		var pos := grid_to_world(spawn.gpos)
		var unit := _create_unit(spawn.type, UnitScript.Team.ENEMY, pos)
		enemy_units_node.add_child(unit)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.set_script(load("res://scripts/enemy_ai.gd"))
		unit.add_child(ai)

	# 玩家建筑
	_place_building(BuildingScript.BuildingType.CASTLE,   BuildingScript.Team.PLAYER, Vector2i(1, 1))
	_place_building(BuildingScript.BuildingType.BARRACKS, BuildingScript.Team.PLAYER, Vector2i(4, 3))

	# 敌方建筑
	_place_building(BuildingScript.BuildingType.CASTLE,   BuildingScript.Team.ENEMY, Vector2i(14, 9))
	_place_building(BuildingScript.BuildingType.BARRACKS, BuildingScript.Team.ENEMY, Vector2i(12, 7))
	_place_building(BuildingScript.BuildingType.TOWER,    BuildingScript.Team.ENEMY, Vector2i(17, 10))
	_place_building(BuildingScript.BuildingType.WALL,     BuildingScript.Team.ENEMY, Vector2i(13, 9))
	_place_building(BuildingScript.BuildingType.WALL,     BuildingScript.Team.ENEMY, Vector2i(13, 10))


# --- 建筑 ---

func _place_building(type: int, team: int, gpos: Vector2i) -> void:
	var scene_path := "res://scenes/building.tscn"
	match type:
		BuildingScript.BuildingType.WALL: scene_path = "res://scenes/wall.tscn"
		BuildingScript.BuildingType.TOWER: scene_path = "res://scenes/tower.tscn"
		BuildingScript.BuildingType.CASTLE: scene_path = "res://scenes/castle.tscn"
		BuildingScript.BuildingType.BARRACKS: scene_path = "res://scenes/barracks.tscn"
	var building_scene := load(scene_path)
	var building: Node2D = building_scene.instantiate()
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

	# 多格建筑中心偏移（等距）
	building.position += Iso.building_center_offset(gsize.x, gsize.y)

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

func _on_building_died(building: Node2D) -> void:
	var gpos: Vector2i = building.get("grid_pos")
	var gsize: Vector2i = building.get("grid_size")
	for dx in range(gsize.x):
		for dy in range(gsize.y):
			occupied_cells.erase(Vector2i(gpos.x + dx, gpos.y + dy))
	_rebuild_navigation()

func _rebuild_navigation() -> void:
	var source_geom := NavigationMeshSourceGeometryData2D.new()

	# 可行走区域：整个地图菱形
	var traversable: Array = []
	traversable.append(Iso.building_diamond(0, 0, GRID_COLS, GRID_ROWS))
	source_geom.traversable_outlines = traversable

	# 建筑障碍：每个建筑用菱形轮廓
	var obstructions: Array = []
	for building in get_tree().get_nodes_in_group("buildings"):
		if building.is_dead():
			continue
		var b_gpos: Vector2i = building.get("grid_pos")
		var b_gsize: Vector2i = building.get("grid_size")
		obstructions.append(Iso.building_diamond(b_gpos.x, b_gpos.y, b_gsize.x, b_gsize.y))
	source_geom.obstruction_outlines = obstructions

	var nav_poly := NavigationPolygon.new()
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geom)
	nav_region.navigation_polygon = nav_poly


# --- 单位创建 ---

func _create_unit(type: int, team: int, pos: Vector2) -> CharacterBody2D:
	var scene_path := "res://scenes/soldier.tscn" if type == 0 else "res://scenes/archer.tscn"
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

func _process(_delta: float) -> void:
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

func _update_preview() -> void:
	if place_mode == PlaceMode.NONE or place_mode == PlaceMode.SOLDIER or place_mode == PlaceMode.ARCHER:
		preview_poly.visible = false
		if place_mode_label:
			if place_mode == PlaceMode.SOLDIER:
				place_mode_label.text = "Click to place Soldier"
				place_mode_label.visible = true
			elif place_mode == PlaceMode.ARCHER:
				place_mode_label.text = "Click to place Archer"
				place_mode_label.visible = true
			else:
				place_mode_label.visible = false
		return

	# 建筑预览（菱形）
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
		_:
			gsize = Vector2i(1, 1)

	var can_place := is_grid_free(gpos, gsize)
	preview_poly.visible = true
	preview_poly.polygon = Iso.building_diamond(gpos.x, gpos.y, gsize.x, gsize.y)
	preview_poly.color = Color(0, 1, 0, 0.3) if can_place else Color(1, 0, 0, 0.3)

	var type_name := ""
	match place_mode:
		PlaceMode.WALL: type_name = "Wall"
		PlaceMode.TOWER: type_name = "Tower"
		PlaceMode.CASTLE: type_name = "Castle"
		PlaceMode.BARRACKS: type_name = "Barracks"
		_: type_name = "Building"
	place_mode_label.text = "Place " + type_name + " (Esc cancel)"
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
			KEY_G:
				show_grid = not show_grid
				if grid_overlay:
					grid_overlay.visible = show_grid
			KEY_ESCAPE:
				place_mode = PlaceMode.NONE
				attack_move_mode = false


# --- 放置 ---

func _do_place(click_pos: Vector2) -> void:
	match place_mode:
		PlaceMode.WALL:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(1, 1)):
				_place_building(BuildingScript.BuildingType.WALL, BuildingScript.Team.PLAYER, gpos)
		PlaceMode.TOWER:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(1, 1)):
				_place_building(BuildingScript.BuildingType.TOWER, BuildingScript.Team.PLAYER, gpos)
		PlaceMode.SOLDIER:
			var unit := _create_unit(UnitScript.UnitType.SOLDIER, UnitScript.Team.PLAYER, click_pos)
			player_units_node.add_child(unit)
			unit.add_to_group("player_units")
		PlaceMode.ARCHER:
			var unit := _create_unit(UnitScript.UnitType.ARCHER, UnitScript.Team.PLAYER, click_pos)
			player_units_node.add_child(unit)
			unit.add_to_group("player_units")
		PlaceMode.CASTLE:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(3, 3)):
				_place_building(BuildingScript.BuildingType.CASTLE, BuildingScript.Team.PLAYER, gpos)
		PlaceMode.BARRACKS:
			var gpos := snap_to_grid(click_pos)
			if is_grid_free(gpos, Vector2i(2, 2)):
				_place_building(BuildingScript.BuildingType.BARRACKS, BuildingScript.Team.PLAYER, gpos)


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
	# 再查敌方建筑（使用菱形点击检测）
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.has_method("has_point") and b.has_point(pos):
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
