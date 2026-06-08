extends Node2D
## 刷兵特效：使用 Pipoya LightPillar 三层精灵图
## back 层在单位后方，main 层为主体光柱，front 层在单位前方
## team_color: 0=玩家(蓝色), 1=敌人(紫色)

var team_color: int = 0
var reveal_target: Node2D = null

const HFRAMES := 5
const VFRAMES := 2
const TOTAL_FRAMES := 10
const FPS := 20.0
const REVEAL_FRAME := 8

var _back: Sprite2D
var _main: Sprite2D
var _front: Sprite2D
var _frame: int = 0
var _timer: float = 0.0


func _ready() -> void:
	var color_name := "blue" if team_color == 0 else "purple"
	var base := "res://assets/effects/spawn/spawn_%s" % color_name
	var tint := Color.WHITE if team_color == 0 else Color(1.0, 0.35, 0.3)

	_back = _make_sprite("%s_back.png" % base, -1, tint)
	_main = _make_sprite("%s.png" % base, 0, tint)
	_front = _make_sprite("%s_front.png" % base, 1, tint)
	add_child(_back)
	add_child(_main)
	add_child(_front)

	if reveal_target and is_instance_valid(reveal_target):
		reveal_target.modulate.a = 0.0
		reveal_target.process_mode = Node.PROCESS_MODE_DISABLED


func _make_sprite(tex_path: String, z: int, tint: Color) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(tex_path)
	s.hframes = HFRAMES
	s.vframes = VFRAMES
	s.z_index = z
	s.scale = Vector2(0.4, 0.4)
	s.modulate = tint
	return s


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= 1.0 / FPS:
		_timer -= 1.0 / FPS
		_frame += 1
		if _frame >= TOTAL_FRAMES:
			queue_free()
			return
		_back.frame = _frame
		_main.frame = _frame
		_front.frame = _frame
		# 快播完时渐显并解冻单位
		if _frame == REVEAL_FRAME and reveal_target and is_instance_valid(reveal_target):
			reveal_target.process_mode = Node.PROCESS_MODE_INHERIT
			var tw := create_tween()
			tw.tween_property(reveal_target, "modulate:a", 1.0, 0.15)
