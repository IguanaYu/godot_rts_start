extends Node2D
## 帧表单位播放器：Tiny Swords 横条精灵表 + 手动步帧。
## 复刻 unit.gd 的播放口径（idle 8fps / run 10fps / attack 12fps，attack 播完停末帧），
## 用于和拆件 puppet 同节奏并排对比。

const FRAME_W := 192
const FRAME_H := 192

var sprite: Sprite2D
var states := {}        # name -> {tex, fps}
var state := "idle"
var _f := 0
var _t := 0.0


func setup(p_states: Dictionary, scale_f: float) -> void:
	states = p_states
	sprite = Sprite2D.new()
	sprite.centered = false
	sprite.scale = Vector2(scale_f, scale_f)
	# Warrior 帧内角色 bbox x:62-140 y:48-136 → 脚点 (101,136) 对齐到本节点原点
	sprite.position = Vector2(-101 * scale_f, -136 * scale_f)
	add_child(sprite)
	_apply("idle")
	queue_redraw()


func set_state(s: String) -> void:
	if not states.has(s):
		return
	if s == state and s != "attack":
		return
	state = s
	_apply(s)


func _apply(s: String) -> void:
	var st: Dictionary = states[s]
	sprite.texture = st["tex"]
	sprite.hframes = int(st["tex"].get_width() / FRAME_W)
	_f = 0
	_t = 0.0
	sprite.frame = 0


func _process(delta: float) -> void:
	_t += delta
	var st: Dictionary = states[state]
	var dur := 1.0 / float(st["fps"])
	while _t >= dur:
		_t -= dur
		var last := sprite.hframes - 1
		if state == "attack":
			_f = mini(_f + 1, last)  # 播完停最后一帧（对齐 unit.gd）
		else:
			_f = (_f + 1) % sprite.hframes
		sprite.frame = _f


func _draw() -> void:
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-16, 0), Vector2(0, -6), Vector2(16, 0), Vector2(0, 6),
		]),
		Color(0.1, 0.1, 0.2, 0.25)
	)
