class_name BuildingPlacer
extends Node
## 建筑放置系统：网格管理、建筑放置/移除、导航重建、放置预览

signal building_placed(building)
signal building_died(building)

const D := preload("res://scripts/systems/game_data.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

# T1 PR-2: 建造阻挡原因（按 reason 决定 UI 灰显策略与 floating_text 文案）
enum BuildBlockReason { OK, NO_GOLD, FARM_LIMIT, NEED_FARM, OUT_OF_RANGE, QUEUE_FULL, ERA_LOCKED }

var place_mode: int = D.PlaceMode.NONE
var show_grid: bool = false
var grid_overlay = null
var occupied_cells: Dictionary = {}

# T1 D5/D3: 建造范围显示开关（main_menu settings 控制）+ 圆形可建区半径
var show_build_range: bool = false
const BUILD_RADIUS := 6 * 64  # 384 px = 6 格
var _build_range_overlay: Line2D = null

var _map_bounds: Rect2
var _nav_bounds: Array
var _nav_region: NavigationRegion2D
var _buildings_node: Node2D
var _preview_rect: ColorRect
var _ui_module: Node

# PR-4：据点光圈多源可建区
# _captured_outpost_rings：占领后但未造特殊建筑的光圈（仅 ALTAR_ARCHER 可造）
# _activated_outpost_rings：已造特殊建筑的光圈（拓展区，可造任意建筑）
var _captured_outpost_rings: Array = []  # [{position: Vector2, radius: float}]
var _activated_outpost_rings: Array = []


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


## T1: 动态造价 —— 农场每多造一个加价 cost_increment
func get_current_cost(mode: int) -> int:
	var base: int = D.COSTS.get(mode, 0)
	var bt: int = D.PLACE_MODE_TO_BUILDING.get(mode, -1)
	if bt < 0:
		return base
	var stats = BuildingStatsRegistry.get_by_type(bt)
	if stats == null or stats.cost_increment <= 0:
		return base
	var count := 0
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.get("building_type") == bt:
			count += 1
	return base + count * stats.cost_increment


## T1 D3 + PR-4: 多源可建区判定
## 源 1：主基地圆（PR-1）
## 源 2：已激活据点光圈（造了特殊建筑 → 拓展区，可造任意建筑）
## 源 3：占领中据点光圈（仅 ALTAR_ARCHER 可造）
func is_in_buildable_area(world_pos: Vector2, place_mode: int = -1) -> bool:
	# 源 1：主基地圆
	var main_node := get_parent()  # main.gd
	if main_node == null or main_node.get("player_castle") == null:
		return true  # 没主基地时不阻拦（避免卡死）
	if world_pos.distance_to(main_node.player_castle.global_position) <= BUILD_RADIUS:
		return true
	# 源 2：已激活据点光圈（拓展区）
	for ring in _activated_outpost_rings:
		if world_pos.distance_to(ring.position) <= ring.radius:
			return true
	# 源 3：占领中据点光圈（仅 ALTAR_ARCHER 可造）
	if place_mode == D.PlaceMode.ALTAR_ARCHER:
		for ring in _captured_outpost_rings:
			if world_pos.distance_to(ring.position) <= ring.radius:
				return true
	return false


## PR-4：占领后由 main.gd 调用，添加 captured ring
func add_captured_outpost_ring(position: Vector2, radius: float) -> void:
	_captured_outpost_rings.append({"position": position, "radius": radius})


## PR-4：祭坛建造完成时由 main.gd 调用，把 captured ring 升级为 activated（拓展区）
func promote_captured_to_activated(position: Vector2) -> void:
	for i in range(_captured_outpost_rings.size()):
		var ring = _captured_outpost_rings[i]
		if position.distance_to(ring.position) <= ring.radius:
			_captured_outpost_rings.remove_at(i)
			_activated_outpost_rings.append(ring)
			return


# ============================================================
# T1 PR-2: 建造阻挡检查（统一接口，供 UI 灰显 + floating_text 双反馈使用）
# ============================================================

## 检查当前是否可建造/生产。click_pos=ZERO 表示无位置概念（建造栏按钮态）。
func check_build_block(mode: int, click_pos: Vector2 = Vector2.ZERO) -> BuildBlockReason:
	var main_node := get_parent()
	# T2 PR-1: 时代锁定检查（最高优先级，未解锁时直接拦截）
	if main_node and main_node.get("unlocked_items") != null:
		var unlocked: Array = main_node.get("unlocked_items")
		if int(mode) not in unlocked:
			return BuildBlockReason.ERA_LOCKED
	var gold: int = int(main_node.get("gold")) if main_node and main_node.get("gold") != null else 0
	var cost := get_current_cost(mode)
	if gold < cost:
		return BuildBlockReason.NO_GOLD
	var bt: int = D.PLACE_MODE_TO_BUILDING.get(mode, -1)
	if bt == BuildingScript.BuildingType.FARM and _count_built(BuildingScript.BuildingType.FARM) >= _max_farms():
		return BuildBlockReason.FARM_LIMIT
	if bt == BuildingScript.BuildingType.BARRACKS and not _has_farm():
		return BuildBlockReason.NEED_FARM
	# 建造范围检查：仅建筑模式（单位从兵营 spawn，不受建造范围限制）
	if click_pos != Vector2.ZERO and not D.is_unit_mode(mode) and not is_in_buildable_area(click_pos, mode):
		return BuildBlockReason.OUT_OF_RANGE
	return BuildBlockReason.OK


## reason → 翻译 key（floating_text 显示用）。OK 返回空字符串。
static func reason_to_translation_key(r: int) -> StringName:
	match r:
		BuildBlockReason.NO_GOLD:      return &"NO_GOLD"
		BuildBlockReason.FARM_LIMIT:   return &"FARM_LIMIT"
		BuildBlockReason.NEED_FARM:    return &"NEED_FARM"
		BuildBlockReason.OUT_OF_RANGE: return &"OUT_OF_RANGE"
		BuildBlockReason.QUEUE_FULL:   return &"QUEUE_FULL"
		BuildBlockReason.ERA_LOCKED:   return &"ERA_LOCKED"
	return &""


## 已建造的某类型建筑数量（建造中 + 已完成，玩家建筑）
## 注意：建造中的也算入，避免快速连点绕过农场上限
func _count_built(type: int) -> int:
	var n := 0
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.get("building_type") != type:
			continue
		if b.has_method("is_dead") and b.is_dead():
			continue
		n += 1
	return n


func _max_farms() -> int:
	var s = BuildingStatsRegistry.get_by_type(BuildingScript.BuildingType.FARM)
	return s.max_farms if s != null else 5


func _has_farm() -> bool:
	return _count_built(BuildingScript.BuildingType.FARM) > 0


## T1 D5: 懒加载建造范围圆环（Line2D 64 点近似圆）
func _ensure_build_range_overlay() -> void:
	if _build_range_overlay != null:
		return
	var overlay := Line2D.new()
	overlay.name = "BuildRangeOverlay"
	overlay.width = 2.0
	overlay.default_color = Color(0, 1, 0, 0.6)
	overlay.z_index = 1
	overlay.visible = false
	var pts := PackedVector2Array()
	var steps := 64
	for i in range(steps + 1):
		var angle := TAU * float(i) / float(steps)
		pts.append(Vector2(cos(angle), sin(angle)) * BUILD_RADIUS)
	overlay.points = pts
	get_parent().add_child(overlay)
	_build_range_overlay = overlay


func place_building(type: int, team: int, gpos: Vector2i, owner_id: int = -1, faction_color: int = -1, slot_id: int = 0) -> Node2D:
	var scene_path: String = D.BUILDING_SCENES.get(type, "res://scenes/buildings/building.tscn")
	var building: Node2D = load(scene_path).instantiate()
	# 在 add_child 前设置 faction_color 等字段，避免 _ready 跑 _setup_texture 时还是默认值
	# team 数值上等于 alliance_id（PLAYER=0/ENEMY=1），用 alliance_id setter 同步 team 字段
	building.set("alliance_id", team)
	building.set("owner_id", owner_id)
	if faction_color >= 0:
		building.set("faction_color", faction_color)
	else:
		building.set("faction_color", Faction.ColorId.BLUE if team == 0 else Faction.ColorId.RED)
	building.set("slot_id", slot_id)
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
	# 连接建造完成信号（用于科技点系统）
	if building.has_signal("construction_finished"):
		if not building.construction_finished.is_connected(_on_building_construction_finished):
			building.construction_finished.connect(_on_building_construction_finished)
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
	var can_place: bool = is_grid_free(gpos, gsize) and is_in_buildable_area(world_pos, place_mode)
	_preview_rect.visible = true
	_preview_rect.position = world_pos - Vector2(gsize.x * D.GRID_SIZE / 2.0, gsize.y * D.GRID_SIZE / 2.0)
	_preview_rect.size = Vector2(gsize.x * D.GRID_SIZE, gsize.y * D.GRID_SIZE)
	_preview_rect.color = Color(0, 1, 0, 0.3) if can_place else Color(1, 0, 0, 0.3)
	_ui_module.set_place_mode_text(tr("PLACE_BUILDING") % [tr(D.MODE_NAMES.get(place_mode, "ENTITY_BUILDING")), get_current_cost(place_mode)])
	# T1 D5: 显示建造范围圆环
	_update_build_range_overlay()


func _update_build_range_overlay() -> void:
	if not show_build_range:
		if _build_range_overlay != null:
			_build_range_overlay.visible = false
		return
	if D.is_unit_mode(place_mode) or place_mode == D.PlaceMode.NONE:
		if _build_range_overlay != null:
			_build_range_overlay.visible = false
		return
	_ensure_build_range_overlay()
	var main_node := get_parent()
	if main_node and main_node.get("player_castle") != null:
		_build_range_overlay.position = main_node.player_castle.global_position
		_build_range_overlay.visible = true
	else:
		_build_range_overlay.visible = false


func cancel_place_mode() -> void:
	place_mode = D.PlaceMode.NONE
	if _build_range_overlay != null:
		_build_range_overlay.visible = false


func register_preplaced_buildings(buildings_node: Node2D) -> void:
	for building in buildings_node.get_children():
		if not building.has_method("is_dead"):
			continue
		var gpos: Vector2i = building.grid_pos
		var gsize: Vector2i = building.grid_size
		var team: int = building.team
		# .tscn 里建筑只设了 team，没设 faction_color；这里按 team 补全并重载贴图
		building.faction_color = Faction.ColorId.BLUE if team == BuildingScript.Team.PLAYER else Faction.ColorId.RED
		if building.has_method("_setup_texture"):
			building._setup_texture()
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
	# 科技点：摧毁敌方建筑
	var main_node := get_tree().current_scene
	if main_node and main_node.get("tech_point_manager"):
		var team_val = building.get("team")
		if team_val == BuildingScript.Team.ENEMY:
			var TPD := preload("res://scripts/tech/tech_point_data.gd")
			main_node.tech_point_manager.add_points(TPD.BASE_POINTS.get("kill_building", 100), TPD.CATEGORY_KILL_ENEMY_BUILDING)


func _on_building_construction_finished(building: Node2D) -> void:
	# 科技点：建造建筑完成
	var main_node := get_tree().current_scene
	if main_node and main_node.get("tech_point_manager"):
		var bt = building.get("building_type")
		var TPD := preload("res://scripts/tech/tech_point_data.gd")
		var pts: int = TPD.get_build_points(bt)
		if pts > 0:
			main_node.tech_point_manager.add_points(pts, TPD.CATEGORY_BUILD_CONSTRUCTION)
	# PR-4：祭坛建造完成 → 把据点 captured ring 升级为 activated（拓展区可造任意建筑）
	var bt2 = building.get("building_type")
	if bt2 == D.BuildingScript.BuildingType.ALTAR_ARCHER:
		promote_captured_to_activated(building.global_position)


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
