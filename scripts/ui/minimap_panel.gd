extends Control
## 小地图面板：显示单位/建筑/目标的缩略位置，点击跳转相机

# === 引用 ===
var _main_node: Node2D
var _camera_module: Node
var _map_bounds: Rect2

# === 绘制参数 ===
var _minimap_size := Vector2(172, 172)
var _margin := 2
var _draw_area_size: Vector2

# === 颜色常量 ===
const COLOR_BG := Color(0.06, 0.06, 0.10, 1.0)
const COLOR_FRIENDLY_UNIT := Color(0.2, 0.9, 0.2)
const COLOR_ENEMY_UNIT := Color(0.9, 0.15, 0.15)
const COLOR_FRIENDLY_BUILDING := Color(0.2, 0.5, 1.0)
const COLOR_ENEMY_BUILDING := Color(0.7, 0.1, 0.1)
const COLOR_VIEW_RECT := Color(1.0, 1.0, 1.0, 0.5)
const COLOR_CAPTURE_POINT := Color(0.7, 0.3, 1.0)
const COLOR_CAPTURE_PLAYER := Color(0.2, 0.9, 0.2)
const COLOR_CAPTURE_ENEMY := Color(0.9, 0.15, 0.15)
const COLOR_COLLECTIBLE := Color(1.0, 0.85, 0.0)
const COLOR_DESTINATION := Color(0.2, 0.9, 0.3)
const COLOR_SPAWN_POINT := Color(1.0, 0.85, 0.0)
const COLOR_BORDER := Color(0.4, 0.3, 0.2, 0.8)

# === 刷新控制 ===
var _update_interval: float = 0.1
var _update_timer: float = 0.0
var _anim_frame: int = 0


func initialize(main_node: Node2D, camera_module: Node, map_bounds: Rect2) -> void:
	_main_node = main_node
	_camera_module = camera_module
	_map_bounds = map_bounds

	_draw_area_size = _minimap_size - Vector2(_margin * 2, _margin * 2)

	custom_minimum_size = _minimap_size
	size = _minimap_size
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= _update_interval:
		_update_timer = 0.0
		_anim_frame += 1
		queue_redraw()


# ============================================================
# 坐标映射
# ============================================================
func world_to_minimap(world_pos: Vector2) -> Vector2:
	var nx := (world_pos.x - _map_bounds.position.x) / _map_bounds.size.x
	var ny := (world_pos.y - _map_bounds.position.y) / _map_bounds.size.y
	return Vector2(_margin + nx * _draw_area_size.x, _margin + ny * _draw_area_size.y)


func minimap_to_world(pixel_pos: Vector2) -> Vector2:
	var nx := (pixel_pos.x - _margin) / _draw_area_size.x
	var ny := (pixel_pos.y - _margin) / _draw_area_size.y
	return Vector2(
		_map_bounds.position.x + nx * _map_bounds.size.x,
		_map_bounds.position.y + ny * _map_bounds.size.y,
	)


# ============================================================
# 绘制
# ============================================================
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, _minimap_size), COLOR_BG)

	_draw_units()
	_draw_buildings()
	_draw_capture_points()
	_draw_collectibles()
	_draw_spawn_points()
	_draw_camera_view()

	draw_rect(Rect2(Vector2.ZERO, _minimap_size), COLOR_BORDER, false, 1.5)


func _draw_units() -> void:
	var unit_radius := clampf(_draw_area_size.x / _map_bounds.size.x * 10.0, 1.5, 3.0)

	for unit in _main_node.player_units_node.get_children():
		if not _is_alive(unit):
			continue
		var pos := world_to_minimap(unit.global_position)
		if _in_bounds(pos):
			draw_circle(pos, unit_radius, COLOR_FRIENDLY_UNIT)

	for unit in _main_node.enemy_units_node.get_children():
		if not _is_alive(unit):
			continue
		var pos := world_to_minimap(unit.global_position)
		if _in_bounds(pos):
			draw_circle(pos, unit_radius, COLOR_ENEMY_UNIT)


func _draw_buildings() -> void:
	var bsize := clampf(_draw_area_size.x / _map_bounds.size.x * 20.0, 2.0, 4.0)
	var half := bsize / 2.0

	for building in _main_node.buildings_node.get_children():
		if not is_instance_valid(building) or building.is_dead():
			continue
		var pos := world_to_minimap(building.global_position)
		if not _in_bounds(pos):
			continue
		var rect := Rect2(pos.x - half, pos.y - half, bsize, bsize)
		var color := COLOR_FRIENDLY_BUILDING if building.team == 0 else COLOR_ENEMY_BUILDING
		draw_rect(rect, color)


func _draw_capture_points() -> void:
	for child in _main_node.get_children(true):
		if not child is Area2D:
			continue
		# duck typing 检测 CapturePoint
		if not (child.has_signal("captured") or child.has_method("enable")):
			continue

		var is_enabled: bool = child.get("is_enabled") if child.get("is_enabled") != null else false
		var is_active: bool = child.get("is_active") if child.get("is_active") != null else false
		var captured_by: int = child.get("captured_by") if child.get("captured_by") != null else -1

		if not is_enabled and not is_active and captured_by < 0:
			continue

		var pos := world_to_minimap(child.global_position)
		if not _in_bounds(pos):
			continue

		var color := COLOR_CAPTURE_POINT
		if captured_by == 0:
			color = COLOR_CAPTURE_PLAYER
		elif captured_by == 1:
			color = COLOR_CAPTURE_ENEMY
		else:
			# 占领中闪烁
			var cap_team = child.get("capturing_team")
			if cap_team != null and cap_team >= 0:
				if _anim_frame % 2 == 0:
					return
				color = COLOR_CAPTURE_PLAYER if cap_team == 0 else COLOR_CAPTURE_ENEMY

		_draw_diamond(pos, 3.5, color)


func _draw_collectibles() -> void:
	var items := get_tree().get_nodes_in_group("collectible_items")
	for item in items:
		if not is_instance_valid(item):
			continue
		var collected = item.get("_collected")
		if collected != null and collected:
			continue
		var pos := world_to_minimap(item.global_position)
		if _in_bounds(pos):
			_draw_star(pos, 2.5, COLOR_COLLECTIBLE)


func _draw_spawn_points() -> void:
	# 波次生成点闪烁
	if _anim_frame % 4 >= 2:
		return
	var wm := _main_node.get_node_or_null("WaveManager")
	if wm == null:
		return
	# duck typing: 检查 wave_active
	var wave_active = wm.get("wave_active")
	if wave_active == null or not wave_active:
		return
	# 尝试获取生成点
	if wm.has_method("get_spawn_points"):
		for sp in wm.get_spawn_points():
			var pos := world_to_minimap(sp)
			if _in_bounds(pos):
				_draw_triangle(pos, 3.0, COLOR_SPAWN_POINT)


func _draw_camera_view() -> void:
	if _camera_module == null or not _camera_module.has_method("get_camera_view_rect"):
		return
	var view_rect: Rect2 = _camera_module.get_camera_view_rect()
	var tl := world_to_minimap(view_rect.position)
	var br := world_to_minimap(view_rect.position + view_rect.size)
	draw_rect(Rect2(tl, br - tl), COLOR_VIEW_RECT, false, 1.0)


# ============================================================
# 辅助绘制
# ============================================================
func _draw_diamond(center: Vector2, size: float, color: Color) -> void:
	var pts := PackedVector2Array([
		center + Vector2(0, -size),
		center + Vector2(size, 0),
		center + Vector2(0, size),
		center + Vector2(-size, 0),
	])
	draw_colored_polygon(pts, color)


func _draw_star(center: Vector2, size: float, color: Color) -> void:
	var d := size * 0.7
	draw_line(center + Vector2(-d, -d), center + Vector2(d, d), color, 1.5)
	draw_line(center + Vector2(-d, d), center + Vector2(d, -d), color, 1.5)


func _draw_triangle(center: Vector2, size: float, color: Color) -> void:
	var pts := PackedVector2Array([
		center + Vector2(0, size),
		center + Vector2(-size * 0.8, -size * 0.6),
		center + Vector2(size * 0.8, -size * 0.6),
	])
	draw_colored_polygon(pts, color)


# ============================================================
# 工具
# ============================================================
func _is_alive(node: Node) -> bool:
	if not is_instance_valid(node):
		return false
	if node.has_method("is_dead"):
		return not node.is_dead()
	return true


func _in_bounds(pos: Vector2) -> bool:
	return pos.x >= _margin and pos.y >= _margin \
		and pos.x <= _minimap_size.x - _margin \
		and pos.y <= _minimap_size.y - _margin


# ============================================================
# 交互：点击跳转
# ============================================================
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		var world_pos := minimap_to_world(event.position)
		_camera_module.jump_to_base(world_pos)
		accept_event()
