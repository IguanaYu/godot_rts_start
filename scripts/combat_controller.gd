extends Node
## 选择/战斗系统：框选、右键指令、攻击移动、停止、坚守

const D := preload("res://scripts/game_data.gd")

var selected_units: Array = []
var is_selecting: bool = false
var selection_start: Vector2 = Vector2.ZERO
var attack_move_mode: bool = false

var _spawner_module: Node


func initialize(spawner_module: Node) -> void:
	_spawner_module = spawner_module


func start_selection(pos: Vector2) -> void:
	is_selecting = true
	selection_start = pos


func update_selection(current_pos: Vector2, selection_box: ColorRect) -> void:
	if is_selecting:
		var rect := _get_selection_rect(selection_start, current_pos)
		selection_box.position = rect.position
		selection_box.size = rect.size
		selection_box.visible = true
	else:
		selection_box.visible = false


func release_selection(end_pos: Vector2, selection_box: ColorRect) -> void:
	is_selecting = false
	selection_box.visible = false
	var rect := _get_selection_rect(selection_start, end_pos)
	if rect.size.length() < 5.0:
		rect = Rect2(end_pos - Vector2(10, 10), Vector2(20, 20))
	_deselect_all()
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if rect.has_point(sp):
				u.set_selected(true)
				selected_units.append(u)


func right_click(click_pos: Vector2) -> void:
	if selected_units.is_empty():
		return
	var target = _find_enemy_at(click_pos)
	if target != null:
		for unit in selected_units:
			unit.command_attack(target)
		if target.has_method("get_children"):
			for ai in target.get_children():
				if ai.has_method("on_attacked"):
					ai.on_attacked(selected_units[0])
		_spawner_module.spawn_click_effect(D.AttackClickEffectScene, click_pos)
		return
	for i in range(selected_units.size()):
		selected_units[i].move_to(click_pos + _formation_offset(i, selected_units.size()))
	_spawner_module.spawn_click_effect(D.MoveClickEffectScene, click_pos)


func do_attack_move(click_pos: Vector2) -> void:
	if selected_units.is_empty():
		return
	var target = _find_enemy_at(click_pos)
	if target != null:
		for u in selected_units:
			u.command_attack(target)
		if target.has_method("get_children"):
			for ai in target.get_children():
				if ai.has_method("on_attacked") and selected_units.size() > 0:
					ai.on_attacked(selected_units[0])
		_spawner_module.spawn_click_effect(D.AttackClickEffectScene, click_pos)
		return
	for i in range(selected_units.size()):
		selected_units[i].attack_move_to(click_pos + _formation_offset(i, selected_units.size()))
	_spawner_module.spawn_click_effect(D.AttackClickEffectScene, click_pos)


func stop_selected() -> void:
	for unit in selected_units:
		unit.stop()


func hold_position_selected() -> void:
	for unit in selected_units:
		unit.hold_position()


func remove_dead_unit(unit) -> void:
	if selected_units.has(unit):
		selected_units.erase(unit)


func is_empty() -> bool:
	return selected_units.is_empty()


func deselect_all() -> void:
	_deselect_all()


func set_attack_move_mode(value: bool) -> void:
	attack_move_mode = value


func _deselect_all() -> void:
	for unit in selected_units:
		unit.set_selected(false)
	selected_units.clear()


func _find_enemy_at(pos: Vector2):
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if sp.distance_to(pos) < 25.0:
				return u
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.has_method("is_dead") and not b.is_dead() and b.get_rect().has_point(pos):
			return b
	return null


func _formation_offset(index: int, total: int) -> Vector2:
	if total == 1:
		return Vector2.ZERO
	var angle := (float(index) / float(total)) * PI - PI / 2.0
	return Vector2(cos(angle), sin(angle)) * (30.0 + total * 5.0)


func _get_selection_rect(start: Vector2, end: Vector2) -> Rect2:
	return Rect2(Vector2(min(start.x, end.x), min(start.y, end.y)), Vector2(abs(end.x - start.x), abs(end.y - start.y)))
