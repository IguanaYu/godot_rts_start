extends Node2D
## 反馈跳字：跟随世界坐标建筑/单位头顶，但渲染在独立 CanvasLayer(layer=15)
## 每帧用相机把 _world_pos 投影成屏幕坐标，避免被底部 UI 条(layer=10)遮挡

var _label: Label
var _world_pos: Vector2 = Vector2.ZERO
var _cam: Camera2D = null


func _ready() -> void:
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 24)
	add_child(_label)
	# 跳字自身不再用 z_index（CanvasLayer 已决定层级），但保留防止被同层覆盖
	z_index = 0
	set_process(true)


func _process(_delta: float) -> void:
	if _cam == null:
		_cam = get_viewport().get_camera_2d()
		if _cam == null:
			return
	var vp_size := get_viewport().get_visible_rect().size
	global_position = (_world_pos - _cam.get_screen_center_position()) * _cam.zoom + vp_size * 0.5


## duration_mult: 持续时间倍率（1.0=默认 3.2s；3.0≈重要提示用，约 6s+）
func setup(text: String, color: Color, world_pos: Vector2, duration_mult: float = 1.0) -> void:
	_world_pos = world_pos
	_cam = get_viewport().get_camera_2d()
	# 立刻同步一次位置，避免首帧停在 (0,0)
	if _cam != null:
		var vp_size := get_viewport().get_visible_rect().size
		global_position = (_world_pos - _cam.get_screen_center_position()) * _cam.zoom + vp_size * 0.5

	_label.text = text
	_label.position = Vector2(-80, -30)
	_label.size = Vector2(160, 30)
	_label.add_theme_color_override("font_color", color)
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)

	scale = Vector2(0.3, 0.3)

	var float_dur: float = 2.0 * duration_mult
	var fade_dur: float = 1.2 * duration_mult

	# Tween 改 _world_pos.y 而不是 position.y（position 每帧被 _process 覆盖）
	var tween := create_tween()
	tween.set_parallel(true)
	# 0-0.3s: 弹出放大
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# 向上漂浮（世界坐标）
	tween.tween_method(_set_world_y, _world_pos.y, _world_pos.y - 80, float_dur)\
		.set_ease(Tween.EASE_OUT)
	# 0.3s后: 缩回 + 淡出
	tween.chain().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	tween.tween_property(_label, "modulate:a", 0.0, fade_dur)
	# 结束清理
	tween.chain().tween_callback(queue_free)


func _set_world_y(new_y: float) -> void:
	_world_pos.y = new_y
