extends Node2D

## 在单位头顶显示技能名浮动文字（绿色）
## 复用 floating_text.gd 的弹出→上飘→淡出动画
static func show(unit: Node2D, skill_name: String) -> void:
	if not is_instance_valid(unit):
		return
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	unit.get_tree().current_scene.add_child(ft)
	ft.setup(skill_name, Color(0.3, 1.0, 0.3), unit.global_position + Vector2(0, -40))
