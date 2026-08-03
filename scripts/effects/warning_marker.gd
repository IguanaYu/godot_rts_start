extends Node2D
## PR-3：动态骚扰预警标记
## 在敌方城堡周围 spawn_pos 显示红色脉冲圆环 + 中心叉号，warning_time→spawn_time 期间持续显示。
## lifetime 到点 queue_free() 自毁；main.gd 实例化后调用 setup(wave_number, lifetime) 配置。

var _lifetime: float = 30.0
var _elapsed: float = 0.0
var _wave_number: int = 0

func _ready() -> void:
	z_index = 60

func setup(wave_number: int, lifetime: float = 30.0) -> void:
	_wave_number = wave_number
	_lifetime = lifetime

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	# 呼吸脉冲：scale 1.0 ± 0.1，alpha 0.5 ± 0.2
	var pulse: float = 1.0 + sin(_elapsed * 4.0) * 0.1
	var alpha: float = 0.5 + sin(_elapsed * 4.0) * 0.2
	var radius: float = 60.0 * pulse
	var col := Color(1.0, 0.2, 0.2, alpha)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, col, 4.0)
	# 中心红色叉号
	draw_line(Vector2(-10, -10), Vector2(10, 10), col, 3.0)
	draw_line(Vector2(-10, 10), Vector2(10, -10), col, 3.0)
