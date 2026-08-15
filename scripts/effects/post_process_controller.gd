extends CanvasLayer
## PostProcessController Autoload（PR-5）：屏幕级战斗反馈
## - shake_screen：操纵当前 Camera2D.offset（屏幕空间），不碰 position，clamp/平滑不受影响
## - chromatic_aberration：shader 色差，0 → peak → 0
## - shockwave：shader 扩散环（不扭曲背景），世界坐标自动转 UV，最多 4 个同时
## - layer=5：游戏内容(0)之上，UI(10)/跳字(15)之下

const SHAKE_SMALL := 3.0   # 大伤害（>60）
const SHAKE_MEDIUM := 5.0
const SHAKE_LARGE := 8.0   # 建筑爆炸
const SHAKE_HUGE := 10.0   # Boss 死亡

const MAX_SHOCKWAVES := 4

var _shader: Shader = preload("res://shaders/post_process.gdshader")
var _material: ShaderMaterial

# shake 状态
var _shake_strength := 0.0
var _shake_time_left := 0.0
var _shake_duration := 0.0

# shockwave 槽位：{index: {elapsed, duration, center_uv, max_radius_uv}}
var _active_waves: Dictionary = {}


func _ready() -> void:
	layer = 5
	var rect := ColorRect.new()
	rect.name = "PostProcessRect"
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_material = ShaderMaterial.new()
	_material.shader = _shader
	# tween 前必须先 set 初值，否则 tween shader_parameter 静默失效
	_material.set_shader_parameter("chromatic_strength", 0.0)
	_material.set_shader_parameter("shockwave_count", 0)
	rect.material = _material
	add_child(rect)


func _process(delta: float) -> void:
	_process_shake(delta)
	_process_shockwaves(delta)


# === Screen Shake ===

func shake_screen(strength_px: float = 5.0, duration: float = 0.2) -> void:
	# 新 shake 取 max：大事件不被小事件重置
	_shake_strength = maxf(_shake_strength, strength_px)
	_shake_duration = duration
	_shake_time_left = duration


func _process_shake(delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	if _shake_time_left <= 0.0:
		if cam.offset != Vector2.ZERO:
			cam.offset = Vector2.ZERO
		return
	_shake_time_left = maxf(_shake_time_left - delta, 0.0)
	var t := 1.0 - _shake_time_left / _shake_duration  # 0→1
	var envelope := 1.0 - t  # 线性衰减，结束归零
	# 双频正弦伪随机：高频抖动 + 低频摆动，避免纯随机的闪烁感
	var angle := Time.get_ticks_msec() * 0.05
	cam.offset = Vector2(
		sin(angle * 1.0) + sin(angle * 2.3),
		cos(angle * 1.7) + sin(angle * 0.9)
	).normalized() * _shake_strength * envelope


# === Chromatic Aberration ===

var _chromatic_tween: Tween

func chromatic_aberration(strength: float = 0.005, duration: float = 0.2) -> void:
	if _chromatic_tween and _chromatic_tween.is_valid():
		_chromatic_tween.kill()
	_material.set_shader_parameter("chromatic_strength", 0.0)
	_chromatic_tween = create_tween()
	_chromatic_tween.tween_property(_material, "shader_parameter/chromatic_strength", strength, duration * 0.3)
	_chromatic_tween.tween_property(_material, "shader_parameter/chromatic_strength", 0.0, duration * 0.7)


# === Shockwave ===

func shockwave(world_pos: Vector2, max_radius: float = 200.0, duration: float = 0.4) -> void:
	if _active_waves.size() >= MAX_SHOCKWAVES:
		return  # 峰值场景容忍丢弃
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	# 世界 → 屏幕 → UV
	var screen_pos := cam.get_viewport().get_canvas_transform().affine_inverse() * world_pos
	var vp_size := get_viewport().get_visible_rect().size
	var center_uv := screen_pos / vp_size
	# 半径按屏幕短边归一，保证不同分辨率视觉一致
	var max_radius_uv: float = max_radius / min(vp_size.x, vp_size.y)
	_active_waves[_next_wave_slot()] = {
		"elapsed": 0.0,
		"duration": duration,
		"center_uv": center_uv,
		"max_radius_uv": max_radius_uv,
	}


func _next_wave_slot() -> int:
	for i in MAX_SHOCKWAVES:
		if not _active_waves.has(i):
			return i
	return 0


func _process_shockwaves(delta: float) -> void:
	if _active_waves.is_empty():
		return
	var finished: Array = []
	for idx in _active_waves:
		var w: Dictionary = _active_waves[idx]
		w["elapsed"] = w["elapsed"] + delta
		if w["elapsed"] >= w["duration"]:
			finished.append(idx)
	for idx in finished:
		_active_waves.erase(idx)
	_sync_shockwave_uniforms()


func _sync_shockwave_uniforms() -> void:
	var arr: Array = []
	for j in MAX_SHOCKWAVES:
		arr.append(Vector4(0, 0, 0, 1))
	for idx in _active_waves:
		var w: Dictionary = _active_waves[idx]
		var t: float = clampf(w["elapsed"] / w["duration"], 0.0, 1.0)
		arr[idx] = Vector4(
			w["center_uv"].x, w["center_uv"].y,
			w["max_radius_uv"] * t, w["max_radius_uv"]
		)
	_material.set_shader_parameter("shockwaves", arr)
	_material.set_shader_parameter("shockwave_count", _active_waves.size())


# === 组合快捷 ===

func big_impact(world_pos: Vector2, shake_px: float = SHAKE_HUGE) -> void:
	shake_screen(shake_px, 0.3)
	chromatic_aberration(0.005, 0.25)
	shockwave(world_pos, 240.0, 0.45)


# === 沙盒重置 ===

func reset() -> void:
	_shake_strength = 0.0
	_shake_time_left = 0.0
	if _chromatic_tween and _chromatic_tween.is_valid():
		_chromatic_tween.kill()
	_active_waves.clear()
	_material.set_shader_parameter("chromatic_strength", 0.0)
	_material.set_shader_parameter("shockwave_count", 0)
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.offset = Vector2.ZERO
