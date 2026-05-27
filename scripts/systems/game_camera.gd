extends Node
## 相机模块：边缘滚动、方向键、缩放、中键拖拽、边界约束

signal jump_to_base_requested

var camera: Camera2D
var map_bounds: Rect2 = Rect2(-500, -500, 2000, 1700)

var camera_speed: float = 600.0
var speed_multiplier: float = 1.0
var edge_margin: float = 30.0
var zoom_step: float = 0.15
var min_zoom: float = 0.4
var max_zoom: float = 2.0

var _mid_dragging: bool = false
var _mid_drag_start_mouse := Vector2.ZERO
var _mid_drag_start_cam := Vector2.ZERO

# UI 豁免区域：鼠标在这些矩形内时不触发对应方向的边缘滚动
var ui_exclusion_rects: Array[Rect2] = []

func initialize(cam: Camera2D, bounds: Rect2) -> void:
	camera = cam
	map_bounds = bounds

	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 10.0

func process_camera(delta: float) -> void:
	var move_dir := Vector2.ZERO
	var viewport_size := camera.get_viewport().get_visible_rect().size

	# --- 边缘滚动 ---
	var mouse_pos := camera.get_viewport().get_mouse_position()

	var blocked_left := false
	var blocked_right := false
	var blocked_top := false
	var blocked_bottom := false

	# 检查鼠标是否在任何 UI 豁免区域内
	for rect in ui_exclusion_rects:
		if rect.has_point(mouse_pos):
			# 判断豁免区域在屏幕的哪个边缘
			if rect.position.y < edge_margin:
				blocked_top = true
			if rect.end.y > viewport_size.y - edge_margin:
				blocked_bottom = true
			if rect.position.x < edge_margin:
				blocked_left = true
			if rect.end.x > viewport_size.x - edge_margin:
				blocked_right = true

	if not blocked_left and mouse_pos.x < edge_margin:
		move_dir.x -= 1.0
	elif not blocked_right and mouse_pos.x > viewport_size.x - edge_margin:
		move_dir.x += 1.0
	if not blocked_top and mouse_pos.y < edge_margin:
		move_dir.y -= 1.0
	elif not blocked_bottom and mouse_pos.y > viewport_size.y - edge_margin:
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
		camera.position += move_dir * camera_speed * speed_multiplier * delta / current_zoom

	# --- 中键拖拽 ---
	if _mid_dragging:
		var mouse_delta := camera.get_viewport().get_mouse_position() - _mid_drag_start_mouse
		var current_zoom := camera.zoom.x
		camera.position = _mid_drag_start_cam - mouse_delta / current_zoom

	clamp_camera()

func clamp_camera() -> void:
	var viewport_size := camera.get_viewport().get_visible_rect().size
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

func jump_to_base(base_pos: Vector2) -> void:
	camera.position = base_pos
	clamp_camera()

func start_mid_drag(mouse_pos: Vector2, cam_pos: Vector2) -> void:
	_mid_dragging = true
	_mid_drag_start_mouse = mouse_pos
	_mid_drag_start_cam = cam_pos

func stop_mid_drag() -> void:
	_mid_dragging = false

func zoom_in() -> void:
	var new_zoom := clampf(camera.zoom.x + zoom_step, min_zoom, max_zoom)
	camera.zoom = Vector2(new_zoom, new_zoom)
	clamp_camera()

func zoom_out() -> void:
	var new_zoom := clampf(camera.zoom.x - zoom_step, min_zoom, max_zoom)
	camera.zoom = Vector2(new_zoom, new_zoom)
	clamp_camera()
