extends Node
## 建筑放置系统：网格管理、建筑放置/移除、导航重建、放置预览

signal building_placed(building)
signal building_died(building)

const D := preload("res://scripts/systems/game_data.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

var place_mode: int = D.PlaceMode.NONE
var show_grid: bool = false
var grid_overlay = null
var occupied_cells: Dictionary = {}

var _map_bounds: Rect2
var _nav_bounds: Array
var _nav_region: NavigationRegion2D
var _buildings_node: Node2D
var _preview_rect: ColorRect
var _ui_module: Node


func initialize(map_bounds: Rect2, nav_bounds: Array, nav_region: NavigationRegion2D,
		buildings_node: Node2D, preview_rect: ColorRect, ui_module: Node) -> void:
	_map_bounds = map_bounds
	_nav_bounds = nav_bounds
	_nav_region = nav_region
	_buildings_node = buildings_node
	_preview_rect = preview_rect
	_ui_module = ui_module


func create_grid() -> void:
	var container := Node2D.new()
	container.name = "GridOverlay"
	container.z_index = 1
	container.visible = false
	get_parent().add_child(container)
	get_parent().move_child(container, 1)
	var bounds: Rect2 = _map_bounds
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


func enter_place_mode(mode: int) -> void:
	if place_mode == mode:
		place_mode = D.PlaceMode.NONE
	else:
		place_mode = mode


func get_place_mode() -> int:
	return place_mode


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


func place_building(type: int, team: int, gpos: Vector2i) -> Node2D:
	var scene_path: String = D.BUILDING_SCENES.get(type, "res://scenes/buildings/building.tscn")
	var building: Node2D = load(scene_path).instantiate()
	building.set("team", team)
	building.set("grid_pos", gpos)
	building.position = grid_to_world(gpos)
	var gsize: Vector2i = D.get_building_grid_size(type)
	if gsize.x > 1 or gsize.y > 1:
		building.position += Vector2((gsize.x - 1) * D.GRID_SIZE / 2.0, (gsize.y - 1) * D.GRID_SIZE / 2.0)
	_buildings_node.add_child(building)
	building.add_to_group("buildings")
	building.add_to_group("player_buildings" if team == BuildingScript.Team.PLAYER else "enemy_buildings")
	building.connect("died", _on_building_died)
	for dx in range(gsize.x):
		for dy in range(gsize.y):
			occupied_cells[Vector2i(gpos.x + dx, gpos.y + dy)] = building
	_rebuild_navigation()
	building_placed.emit(building)
	return building


func update_preview() -> void:
	if D.is_unit_mode(place_mode):
		_preview_rect.visible = false
		_ui_module.set_place_mode_text(tr("PLACE_UNIT") % tr(D.MODE_NAMES.get(place_mode, "ENTITY_UNIT")))
		return
	if place_mode == D.PlaceMode.NONE:
		_preview_rect.visible = false
		_ui_module.hide_place_mode_label()
		return
	var mouse_pos: Vector2 = get_parent().get_global_mouse_position()
	var gpos := snap_to_grid(mouse_pos)
	var building_type: int = D.PLACE_MODE_TO_BUILDING.get(place_mode, -1)
	var gsize: Vector2i = D.get_building_grid_size(building_type) if building_type >= 0 else Vector2i(1, 1)
	var world_pos: Vector2 = grid_to_world(gpos)
	if gsize.x > 1 or gsize.y > 1:
		world_pos += Vector2((gsize.x - 1) * D.GRID_SIZE / 2.0, (gsize.y - 1) * D.GRID_SIZE / 2.0)
	var can_place: bool = is_grid_free(gpos, gsize)
	_preview_rect.visible = true
	_preview_rect.position = world_pos - Vector2(gsize.x * D.GRID_SIZE / 2.0, gsize.y * D.GRID_SIZE / 2.0)
	_preview_rect.size = Vector2(gsize.x * D.GRID_SIZE, gsize.y * D.GRID_SIZE)
	_preview_rect.color = Color(0, 1, 0, 0.3) if can_place else Color(1, 0, 0, 0.3)
	_ui_module.set_place_mode_text(tr("PLACE_BUILDING") % [tr(D.MODE_NAMES.get(place_mode, "ENTITY_BUILDING")), D.COSTS.get(place_mode, 0)])


func cancel_place_mode() -> void:
	place_mode = D.PlaceMode.NONE


func register_preplaced_buildings(buildings_node: Node2D) -> void:
	for building in buildings_node.get_children():
		if not building.has_method("is_dead"):
			continue
		var gpos: Vector2i = building.grid_pos
		var gsize: Vector2i = building.grid_size
		var team: int = building.team
		building.add_to_group("buildings")
		building.add_to_group("player_buildings" if team == BuildingScript.Team.PLAYER else "enemy_buildings")
		building.connect("died", _on_building_died)
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
	building_died.emit(building)


func _rebuild_navigation() -> void:
	var source_geom := NavigationMeshSourceGeometryData2D.new()
	source_geom.traversable_outlines = [PackedVector2Array(_nav_bounds)]
	var obstructions: Array = []
	# 建筑遮挡
	for building in get_tree().get_nodes_in_group("buildings"):
		if building.is_dead():
			continue
		var rect: Rect2 = building.get_rect()
		obstructions.append(_rect_to_outline(rect, 20.0))
	# 地形障碍遮挡
	var obstacles_node = get_tree().current_scene.get_node_or_null("Obstacles")
	if obstacles_node:
		for obstacle in obstacles_node.get_children():
			if obstacle.has_method("get_obstacle_rect"):
				var rect: Rect2 = obstacle.get_obstacle_rect()
				obstructions.append(_rect_to_outline(rect, 4.0))
	source_geom.obstruction_outlines = obstructions
	var nav_poly := NavigationPolygon.new()
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geom)
	_nav_region.navigation_polygon = nav_poly
	print("[Nav] rebuilt: %d obstructions, %d vertices" % [obstructions.size(), nav_poly.vertices.size()])


func _rect_to_outline(rect: Rect2, margin: float = 0.0) -> PackedVector2Array:
	# 逆时针 (CCW)：obstruction_outlines 要求逆时针环绕
	return PackedVector2Array([
		rect.position - Vector2(margin, margin),
		Vector2(rect.position.x - margin, rect.end.y + margin),
		rect.end + Vector2(margin, margin),
		Vector2(rect.end.x + margin, rect.position.y - margin)
	])
