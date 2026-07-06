extends Control
## 小地图面板：显示单位/建筑/目标的缩略位置，点击跳转相机
##
## v2 新特性：
##   - 统一动画引擎（预计算动画值，替换各方法手写 sin/%）
##   - 12 种特效（脉动/闪烁/扩散环/弹跳/收缩/颜色呼吸/旋转/波纹/抖动/爆发）
##   - 密度聚类（敌方单位密集区域画成半透明团块）
##   - 注册标记 API（外部系统通过 register_marker / send_ping 添加自定义标记）
##   - 比例修正（建筑 4~7px，单位 2~3.5px）

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

# === 目标标记颜色 ===
const COLOR_OBJ_PROTECT := Color(0.2, 0.9, 0.2)    # 绿色=保护
const COLOR_OBJ_KILL    := Color(0.9, 0.15, 0.15)   # 红色=击杀
const COLOR_OBJ_PRIMARY := Color(1.0, 0.85, 0.0)    # 金色=主目标
const COLOR_OBJ_NAV     := Color(0.2, 0.6, 1.0)     # 蓝色=导航

# === 刷新控制 ===
var _update_interval: float = 0.1
var _update_timer: float = 0.0
var _frame: int = 0
var _time: float = 0.0

# === 预计算动画值（_process 每帧更新） ===
var _pulse_slow: float = 0.0    # 慢呼吸 0~1, ~0.5Hz
var _pulse_fast: float = 0.0    # 快呼吸 0~1, ~1.5Hz
var _bounce: float = 0.0        # 弹跳 0~2px
var _color_t: float = 0.0       # 颜色渐变 0~1

# === 注册标记系统 ===
var _markers: Array[MinimapMarkerData] = []
var _next_marker_id: int = 1

# === 密度聚类参数 ===
const CLUSTER_GRID_SIZE: int = 10


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
		_frame += 1
		_time += _update_interval

		# 预计算动画值（所有 _draw_* 方法共享）
		_pulse_slow = sin(_time * 0.5) * 0.5 + 0.5
		_pulse_fast = sin(_time * 1.5) * 0.5 + 0.5
		_bounce = abs(sin(_time * 0.3)) * 2.0
		_color_t = sin(_time * 0.8) * 0.5 + 0.5

		# 更新注册标记（过期移除）
		_update_markers()

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
# 注册标记 API
# ============================================================

## 注册一个标记，返回 marker_id（可用于 unregister）
func register_marker(data: MinimapMarkerData) -> int:
	var id := _next_marker_id
	_next_marker_id += 1
	data._marker_id = id
	data._elapsed = 0.0
	_markers.append(data)
	return id


## 注销标记
func unregister_marker(marker_id: int) -> void:
	for i in range(_markers.size()):
		if _markers[i]._marker_id == marker_id:
			_markers.remove_at(i)
			return


## 快速发送一个 ping（自动创建标记 + 到期消失），返回 marker_id
func send_ping(world_pos: Vector2, color: Color, shape: MinimapMarkerData.Shape = MinimapMarkerData.Shape.CROSS,
		duration: float = 1.5) -> int:
	var m := MinimapMarkerData.make_ping(world_pos, color, duration, shape)
	return register_marker(m)


## 显示/隐藏整个分组的标记
func show_group(group: String) -> void:
	for m in _markers:
		if m.group == group:
			m.visible = true


func hide_group(group: String) -> void:
	for m in _markers:
		if m.group == group:
			m.visible = false


## 清空所有注册标记
func clear_all_markers() -> void:
	_markers.clear()


func _update_markers() -> void:
	var dt := _update_interval
	var i: int = 0
	while i < _markers.size():
		var m := _markers[i]
		m._elapsed += dt
		if m.lifetime > 0.0 and m._elapsed >= m.lifetime:
			_markers.remove_at(i)
			continue
		i += 1


# ============================================================
# 主绘制管线（从底到顶）
# ============================================================
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, _minimap_size), COLOR_BG)

	_draw_units()
	_draw_buildings()
	_draw_registered_markers()   # 外部标记（在建筑之上）
	_draw_capture_points()
	_draw_collectibles()
	_draw_spawn_points()
	_draw_objective_markers()
	_draw_distress_pings()
	_draw_camera_view()

	draw_rect(Rect2(Vector2.ZERO, _minimap_size), COLOR_BORDER, false, 1.5)


# ============================================================
# 单位绘制（友方独立点 + 敌方密度聚类）
# ============================================================
func _draw_units() -> void:
	var unit_radius := clampf(_draw_area_size.x / _map_bounds.size.x * 10.0, 2.0, 3.5)

	for unit in _main_node.player_units_node.get_children():
		if not _is_alive(unit):
			continue
		var pos := world_to_minimap(unit.global_position)
		if _in_bounds(pos):
			draw_circle(pos, unit_radius, COLOR_FRIENDLY_UNIT)

	_draw_enemy_clusters(unit_radius)


func _draw_enemy_clusters(unit_radius: float) -> void:
	# 收集所有敌方位置
	var enemy_positions: Array[Vector2] = []
	for unit in _main_node.enemy_units_node.get_children():
		if not _is_alive(unit):
			continue
		var pos := world_to_minimap(unit.global_position)
		if _in_bounds(pos):
			enemy_positions.append(pos)

	if enemy_positions.is_empty():
		return

	# 网格聚类
	var cell_w := _draw_area_size.x / CLUSTER_GRID_SIZE
	var cell_h := _draw_area_size.y / CLUSTER_GRID_SIZE

	# grid[Vector2i(cx, cy)] = { pos_sum: Vector2, count: int }
	var grid: Dictionary = {}
	for p in enemy_positions:
		var cx := clampi(int((p.x - _margin) / cell_w), 0, CLUSTER_GRID_SIZE - 1)
		var cy := clampi(int((p.y - _margin) / cell_h), 0, CLUSTER_GRID_SIZE - 1)
		var key := Vector2i(cx, cy)
		if not grid.has(key):
			grid[key] = { pos_sum = Vector2.ZERO, count = 0 }
		var cell := grid[key]
		cell.pos_sum += p
		cell.count += 1

	# 标记已绘制的单位
	var drawn: Array[bool] = []
	drawn.resize(enemy_positions.size())
	drawn.fill(false)

	for i in range(enemy_positions.size()):
		if drawn[i]:
			continue
		var p := enemy_positions[i]
		var cx := clampi(int((p.x - _margin) / cell_w), 0, CLUSTER_GRID_SIZE - 1)
		var cy := clampi(int((p.y - _margin) / cell_h), 0, CLUSTER_GRID_SIZE - 1)
		var key := Vector2i(cx, cy)
		var cell := grid.get(key)

		if cell == null or cell.count <= 3:
			# 稀疏区域：画独立点
			draw_circle(p, unit_radius, COLOR_ENEMY_UNIT)
			drawn[i] = true
		else:
			# 密集区域：画半透明团块 + 中心实心点
			var center := cell.pos_sum / cell.count
			var blob_radius := 2.5 + sqrt(cell.count) * 1.2
			draw_circle(center, blob_radius, Color(0.9, 0.15, 0.15, 0.35))
			draw_circle(center, unit_radius, COLOR_ENEMY_UNIT)

			# 标记该格所有单位为已绘制
			for j in range(i, enemy_positions.size()):
				if drawn[j]:
					continue
				var p2 := enemy_positions[j]
				var cx2 := clampi(int((p2.x - _margin) / cell_w), 0, CLUSTER_GRID_SIZE - 1)
				var cy2 := clampi(int((p2.y - _margin) / cell_h), 0, CLUSTER_GRID_SIZE - 1)
				if cx2 == cx and cy2 == cy:
					drawn[j] = true


# ============================================================
# 建筑绘制
# ============================================================
func _draw_buildings() -> void:
	var bsize := clampf(_draw_area_size.x / _map_bounds.size.x * 30.0, 4.0, 7.0)
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


# ============================================================
# 占领点绘制
# ============================================================
func _draw_capture_points() -> void:
	for child in _main_node.get_children(true):
		if not child is Area2D:
			continue
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
			var cap_team = child.get("capturing_team")
			if cap_team != null and cap_team >= 0:
				# 占领中：颜色呼吸（alpha 脉动）
				var base_color := COLOR_CAPTURE_PLAYER if cap_team == 0 else COLOR_CAPTURE_ENEMY
				var breath_alpha := 0.3 + _pulse_slow * 0.7
				color = Color(base_color.r, base_color.g, base_color.b, breath_alpha)

		_draw_diamond(pos, 3.5, color)


# ============================================================
# 收集品绘制
# ============================================================
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


# ============================================================
# 刷怪点绘制（修复：直接读 wave_data）
# ============================================================
func _draw_spawn_points() -> void:
	# 闪烁约 1Hz
	if _frame % 4 >= 2:
		return
	var wm := _main_node.get_node_or_null("WaveManager")
	if wm == null:
		return
	var wave_active = wm.get("wave_active")
	if wave_active == null or not wave_active:
		return
	var current_wave = wm.get("current_wave")
	var waves = wm.get("waves")
	if current_wave == null or waves == null or current_wave < 0 or current_wave >= waves.size():
		return

	var wave_data: Dictionary = waves[current_wave]

	# 从 wave_data 中解析出生位置
	var spawn_positions: Array[Vector2] = []

	# 新格式：spawn_center
	if wave_data.has("spawn_center"):
		spawn_positions.append(wave_data.spawn_center)

	# 新格式：spawn_point_path
	if wave_data.has("spawn_point_path"):
		var path: NodePath = wave_data.spawn_point_path
		var marker: Node2D = wm.get_node_or_null(path)
		if marker != null:
			spawn_positions.append(marker.global_position)

	# 旧格式：units 数组中的各自位置
	if wave_data.has("units"):
		for u in wave_data.units:
			if u.has("pos"):
				spawn_positions.append(u.pos)

	if spawn_positions.is_empty():
		return

	# 用集合去重（同一位置只画一次）
	var seen: Array[Vector2] = []
	for sp in spawn_positions:
		var already := false
		for s in seen:
			if s.distance_squared_to(sp) < 100.0:
				already = true
				break
		if already:
			continue
		seen.append(sp)
		var pos := world_to_minimap(sp)
		if _in_bounds(pos):
			_draw_triangle(pos, 3.0, COLOR_SPAWN_POINT)


# ============================================================
# 任务目标绘制
# ============================================================
func _draw_objective_markers() -> void:
	for marker in get_tree().get_nodes_in_group("objective_markers"):
		if not is_instance_valid(marker):
			continue
		var parent = marker.get_target() if marker.has_method("get_target") else null
		if parent == null or not is_instance_valid(parent):
			continue
		if parent.has_method("is_dead") and parent.is_dead():
			continue
		var pos := world_to_minimap(parent.global_position)
		if not _in_bounds(pos):
			continue
		var color := _marker_color(marker.marker_type)
		# 脉动呼吸替代原来的方波闪烁
		var breath := 0.5 + _pulse_slow * 0.5
		color = Color(color.r, color.g, color.b, breath)
		_draw_diamond(pos, 4.0, color)


# ============================================================
# 求救 ping（脉动黄点）
# ============================================================
func _draw_distress_pings() -> void:
	var positions: Array = AllyDistressSignal.get_active_positions()
	if positions.is_empty():
		return
	for world_pos in positions:
		var mp := world_to_minimap(world_pos)
		if not _in_bounds(mp):
			continue
		var r := 4.0 + _pulse_slow * 2.5
		draw_circle(mp, r + 3.0, Color(1.0, 0.85, 0.0, 0.3))
		draw_circle(mp, r, Color(1.0, 0.85, 0.0, 0.9))


# ============================================================
# 注册标记绘制层
# ============================================================
func _draw_registered_markers() -> void:
	if _markers.is_empty():
		return

	# 按优先级排序（高优先级的盖在上面）
	_markers.sort_custom(func(a: MinimapMarkerData, b: MinimapMarkerData) -> bool:
		return a.priority > b.priority)

	for m in _markers:
		if not m.visible:
			continue

		var pos := world_to_minimap(m.world_pos)
		if not _in_bounds(pos):
			continue

		var draw_pos := pos
		var draw_size := m.size
		var draw_color := m.color
		var draw_alpha: float = 1.0
		var do_shape := true

		match m.anim_type:
			MinimapMarkerData.Anim.NONE:
				pass

			MinimapMarkerData.Anim.PULSE:
				draw_size = m.size + _pulse_slow * 2.0
				draw_alpha = 0.4 + _pulse_slow * 0.6

			MinimapMarkerData.Anim.BLINK:
				if int(_time * 2.0) % 2 == 0:
					do_shape = false

			MinimapMarkerData.Anim.EXPAND_RING:
				# 扩散环：不画形状，画环
				var max_r := maxf(m.size * 4.0, 10.0)
				var progress := m._elapsed / m.lifetime if m.lifetime > 0.0 else 1.0
				progress = clampf(progress, 0.0, 1.0)
				var r := progress * max_r
				var a := (1.0 - progress) * 0.6
				draw_circle(pos, r, Color(draw_color.r, draw_color.g, draw_color.b, a))
				# 十字形状
				var cross_sz := 2.0 + (1.0 - progress) * 3.0
				_draw_cross(pos, cross_sz, draw_color)
				do_shape = false

			MinimapMarkerData.Anim.BOUNCE:
				draw_pos.y -= _bounce

			MinimapMarkerData.Anim.FADE_OUT:
				var progress := clampf(m._elapsed / m.lifetime if m.lifetime > 0.0 else 0.0, 0.0, 1.0)
				draw_size = m.size * (1.0 - progress * 0.5)
				draw_alpha = 1.0 - progress

			MinimapMarkerData.Anim.COLOR_BREATHE:
				var target := m.color_b
				draw_color = m.color.lerp(target, _color_t)
				draw_alpha = 0.5 + _color_t * 0.5

			MinimapMarkerData.Anim.ROTATE:
				var angle := _time * 2.0 * m.anim_speed
				_draw_rotated_shape(pos, m.shape, draw_size, m.color, angle)
				do_shape = false

			MinimapMarkerData.Anim.RIPPLE:
				_draw_ripple(pos, m._elapsed, m.lifetime, maxf(m.size * 3.0, 8.0), m.color, m.anim_speed)
				do_shape = false

			MinimapMarkerData.Anim.SHAKE:
				draw_pos = _shake_offset(pos, maxf(m.size * 0.3, 1.0))

			MinimapMarkerData.Anim.BURST:
				if m._elapsed < 0.3:
					var burst_t := m._elapsed / 0.3
					draw_size = m.size + (1.0 - burst_t) * 4.0
					draw_alpha = 0.6 + burst_t * 0.4

		if do_shape:
			draw_color = Color(draw_color.r, draw_color.g, draw_color.b, draw_color.a * draw_alpha)
			_draw_marker_shape(draw_pos, m.shape, draw_size, draw_color)


# ============================================================
# 相机视口绘制
# ============================================================
func _draw_camera_view() -> void:
	if _camera_module == null or not _camera_module.has_method("get_camera_view_rect"):
		return
	var view_rect: Rect2 = _camera_module.get_camera_view_rect()
	var tl := world_to_minimap(view_rect.position)
	var br := world_to_minimap(view_rect.position + view_rect.size)
	draw_rect(Rect2(tl, br - tl), COLOR_VIEW_RECT, false, 1.0)


# ============================================================
# 特效绘制函数库
# ============================================================

## 扩散环：从 0→max_r + alpha 1→0（用于 ping）
func _draw_expand_ring(center: Vector2, elapsed: float, duration: float, max_r: float, color: Color) -> void:
	var progress := clampf(elapsed / duration if duration > 0.0 else 0.0, 0.0, 1.0)
	var r := progress * max_r
	var a := (1.0 - progress) * 0.6
	draw_circle(center, r, Color(color.r, color.g, color.b, a))


## 脉动圆：用 pulse(0~1) 驱动大小和 alpha
func _draw_pulse_circle(center: Vector2, base_r: float, pulse: float, color: Color, outer_alpha: float = 0.3) -> void:
	var r := base_r + pulse * 2.0
	draw_circle(center, r + 2.0, Color(color.r, color.g, color.b, outer_alpha))
	draw_circle(center, r, Color(color.r, color.g, color.b, 0.9))


## 旋转形状
func _draw_rotated_shape(center: Vector2, shape: MinimapMarkerData.Shape, size: float, color: Color, angle: float) -> void:
	draw_set_transform(center, angle, Vector2.ONE)
	var local := Vector2.ZERO
	match shape:
		MinimapMarkerData.Shape.DIAMOND:
			_draw_diamond(local, size, color)
		MinimapMarkerData.Shape.TRIANGLE:
			_draw_triangle(local, size, color)
		MinimapMarkerData.Shape.SQUARE:
			draw_rect(Rect2(local.x - size / 2.0, local.y - size / 2.0, size, size), color)
		MinimapMarkerData.Shape.STAR:
			_draw_star(local, size, color)
		MinimapMarkerData.Shape.CROSS:
			_draw_cross(local, size, color)
		_: # CIRCLE
			draw_circle(local, size, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## 波纹：多圈连续扩散环
func _draw_ripple(center: Vector2, elapsed: float, lifetime: float, max_r: float, color: Color, speed: float = 1.0) -> void:
	var interval: float = 0.4 / speed
	var ring_life: float = minf(lifetime, 1.5)
	var t := elapsed
	var num_rings := int(t / interval)
	for i in range(max(0, num_rings - 4), num_rings + 1):
		var ring_elapsed := t - i * interval
		if ring_elapsed < 0.0 or ring_elapsed > ring_life:
			continue
		var progress := ring_elapsed / ring_life
		var r := progress * max_r
		var a := (1.0 - progress) * 0.4
		draw_circle(center, r, Color(color.r, color.g, color.b, a))


## 抖动偏移
func _shake_offset(pos: Vector2, intensity: float) -> Vector2:
	var r1 := fmod(_frame * 7.31, 100.0) / 100.0
	var r2 := fmod(_frame * 13.97, 100.0) / 100.0
	return pos + Vector2((r1 - 0.5) * 2.0 * intensity, (r2 - 0.5) * 2.0 * intensity)


## 统一形状分发
func _draw_marker_shape(center: Vector2, shape: MinimapMarkerData.Shape, size: float, color: Color) -> void:
	match shape:
		MinimapMarkerData.Shape.CIRCLE:
			draw_circle(center, size, color)
		MinimapMarkerData.Shape.DIAMOND:
			_draw_diamond(center, size, color)
		MinimapMarkerData.Shape.TRIANGLE:
			_draw_triangle(center, size, color)
		MinimapMarkerData.Shape.SQUARE:
			var half := size / 2.0
			draw_rect(Rect2(center.x - half, center.y - half, size, size), color)
		MinimapMarkerData.Shape.STAR:
			_draw_star(center, size, color)
		MinimapMarkerData.Shape.CROSS:
			_draw_cross(center, size, color)


# ============================================================
# 基础形状绘制
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


func _draw_cross(center: Vector2, size: float, color: Color) -> void:
	var w := maxf(size * 0.3, 1.0)
	draw_line(center + Vector2(-size, 0), center + Vector2(size, 0), color, w)
	draw_line(center + Vector2(0, -size), center + Vector2(0, size), color, w)


# ============================================================
# 目标标记颜色映射
# ============================================================
func _marker_color(type: int) -> Color:
	match type:
		0, 1: return COLOR_OBJ_PROTECT   # CROWN, SHIELD
		2, 3: return COLOR_OBJ_KILL       # SKULL, CROSSHAIR
		4:    return COLOR_OBJ_PRIMARY     # STAR
		5, 6: return COLOR_OBJ_NAV        # FLAG, DIAMOND
		_:    return COLOR_OBJ_PRIMARY


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
