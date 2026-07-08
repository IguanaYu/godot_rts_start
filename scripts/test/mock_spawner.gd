extends Node
## Mock 生成器：duck-typed 实现 skill_effects.gd 需要的 spawner_module 接口
## 视觉方法 no-op，spawn_unit_near 创建真实单位用于验证

var _spawned_units: Array = []


func spawn_dust_effect(_pos: Vector2) -> void:
	# no-op（视觉特效）
	pass


func show_floating_text(_text: String, _color: Color, _pos: Vector2) -> void:
	# no-op（视觉特效）
	pass


func spawn_unit_near(unit_type: int, pos: Vector2, team: int):
	# 简化版：创建一个空 CharacterBody2D 占位
	# 真实测试中如果需要完整单位行为，可加载 res://scenes/units/soldier.tscn
	var unit := CharacterBody2D.new()
	unit.global_position = pos
	_spawned_units.append(unit)
	return unit


func get_spawned_units() -> Array:
	return _spawned_units
