class_name TestSummonSkill
extends Node

## 测试用:按空格召唤 1 个近战兵,CD 5秒,持续 10秒。
## 正式技能在第二阶段做,此节点仅用于验证召唤管线。

var summon_lifecycle: SummonLifecycle
var hero: Unit
var _cd_timer: float = 0.0
const CD: float = 5.0
const LIFETIME: float = 10.0

func initialize(sl: SummonLifecycle, h: Unit) -> void:
	summon_lifecycle = sl
	hero = h

func _process(delta: float) -> void:
	_cd_timer = max(0.0, _cd_timer - delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if _cd_timer > 0.0:
			return
		if hero == null or not is_instance_valid(hero):
			return
		var offset := Vector2(randf_range(-30, 30), randf_range(-30, 30))
		var u := summon_lifecycle.summon(&"soldier", hero.global_position + offset, 0, LIFETIME)
		if u != null:
			_cd_timer = CD
