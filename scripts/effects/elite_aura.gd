extends Node2D
## EliteAura：精英兵（elite_vanguard）脚下金色呼吸光环
## 由 unit.gd._setup_stats 在 stats.id == "elite_vanguard" 时挂载为子节点
# z_index 5：高于 BodySprite(0)，低于 HPBar(100)
var _t: float = 0.0

func _ready() -> void:
	z_index = 5

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var pulse: float = 1.0 + sin(_t * 3.0) * 0.1
	var alpha: float = 0.6 + sin(_t * 3.0) * 0.3
	var radius: float = 22.0 * pulse
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32,
		Color(1.0, 0.84, 0.0, alpha), 2.5)
