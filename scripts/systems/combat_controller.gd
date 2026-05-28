extends Node
## 选择/战斗系统：框选、右键指令、攻击移动、停止、坚守
## SC2增强：双击选同类、Shift/Ctrl修饰、F2全选军队

const D := preload("res://scripts/systems/game_data.gd")

var selected_units: Array = []
var is_selecting: bool = false
var selection_start: Vector2 = Vector2.ZERO
var attack_move_mode: bool = false

# 双击标记（由 main.gd 传入）
var _pending_double_click: bool = false

# 建筑选择（集结点用）
var selected_building = null

signal selection_changed(units: Array)

var _spawner_module: Node


func initialize(spawner_module: Node) -> void:
	_spawner_module = spawner_module


func start_selection(pos: Vector2, is_double_click: bool = false) -> void:
	is_selecting = true
	selection_start = pos
	_pending_double_click = is_double_click


func update_selection(current_pos: Vector2, selection_box: ColorRect) -> void:
	if is_selecting:
		var rect := _get_selection_rect(selection_start, current_pos)
		selection_box.position = rect.position
		selection_box.size = rect.size
		selection_box.visible = true
	else:
		selection_box.visible = false


func release_selection(end_pos: Vector2, selection_box: ColorRect, shift_held: bool = false, ctrl_held: bool = false) -> void:
	is_selecting = false
	selection_box.visible = false
	var rect := _get_selection_rect(selection_start, end_pos)
	var is_point_click := rect.size.length() < 5.0

	if is_point_click:
		# 点选模式
		var clicked_unit: Variant = _find_player_unit_at(end_pos)
		if clicked_unit == null:
			# 尝试选中玩家建筑
			var clicked_building: Variant = _find_player_building_at(end_pos)
			if clicked_building != null:
				select_building(clicked_building)
				selected_units.clear()
				_pending_double_click = false
				return
			if not shift_held:
				_deselect_all()
				select_building(null)
			_pending_double_click = false
			return

		if _pending_double_click or ctrl_held:
			# 双击 / Ctrl+点击：选中屏幕内所有同类单位
			if shift_held:
				# Ctrl+Shift+点击：添加所有同类到选择
				_add_all_of_type_to_selection(clicked_unit)
			else:
				select_all_of_type_on_screen(clicked_unit)
		elif shift_held:
			# Shift+点击：添加/移除单个单位
			if clicked_unit.selected:
				clicked_unit.set_selected(false)
				selected_units.erase(clicked_unit)
			else:
				clicked_unit.set_selected(true)
				selected_units.append(clicked_unit)
		else:
			# 普通点击：替换选择
			_deselect_all()
			clicked_unit.set_selected(true)
			selected_units.append(clicked_unit)
	else:
		# 框选模式
		if not shift_held:
			_deselect_all()
		for u in get_tree().get_nodes_in_group("player_units"):
			if u is CharacterBody2D and not u.is_dead():
				var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
				if rect.has_point(sp) and not u.selected:
					u.set_selected(true)
					selected_units.append(u)

	_pending_double_click = false


## 双击/Ctrl+点击：选中屏幕内所有同类单位
func select_all_of_type_on_screen(reference_unit) -> void:
	_deselect_all()
	var ref_type: int = reference_unit.unit_type
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var screen_rect := camera.get_viewport().get_visible_rect()
	var cam_center := camera.global_position
	var zoom_val := camera.zoom.x
	var half_size := screen_rect.size / (2.0 * zoom_val)
	var view_rect := Rect2(cam_center - half_size, half_size * 2.0)

	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead() and u.unit_type == ref_type:
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if view_rect.has_point(sp):
				u.set_selected(true)
				selected_units.append(u)


## Ctrl+Shift+点击：添加所有同类到选择
func _add_all_of_type_to_selection(reference_unit) -> void:
	var ref_type: int = reference_unit.unit_type
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var screen_rect := camera.get_viewport().get_visible_rect()
	var cam_center := camera.global_position
	var zoom_val := camera.zoom.x
	var half_size := screen_rect.size / (2.0 * zoom_val)
	var view_rect := Rect2(cam_center - half_size, half_size * 2.0)

	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead() and u.unit_type == ref_type and not u.selected:
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if view_rect.has_point(sp):
				u.set_selected(true)
				selected_units.append(u)


## F2：全选军队
func select_all_army() -> void:
	_deselect_all()
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			u.set_selected(true)
			selected_units.append(u)
	selection_changed.emit(selected_units)


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


## 巡逻指令
var _patrol_first_point: Variant = null

func do_patrol(click_pos: Vector2, shift_held: bool = false) -> void:
	if selected_units.is_empty():
		return
	if not shift_held and _patrol_first_point == null:
		# 第一次点击：记住起点
		_patrol_first_point = click_pos
		return
	# 第二次点击或Shift+点击：设置巡逻路线
	var points: Array = []
	if _patrol_first_point != null:
		points.append(_patrol_first_point)
		_patrol_first_point = null
	points.append(click_pos)
	for unit in selected_units:
		unit.command_patrol(points)
	_spawner_module.spawn_click_effect(D.AttackClickEffectScene, click_pos)

## Tab子组循环
var _subgroup_types: Array = []
var _subgroup_index: int = -1

func cycle_subgroup(forward: bool = true) -> void:
	if selected_units.size() <= 1:
		return
	# 收集所有单位类型
	var types := {}
	for u in selected_units:
		types[u.unit_type] = true
	_subgroup_types = types.keys()
	if _subgroup_types.size() <= 1:
		return
	# 循环
	if forward:
		_subgroup_index = (_subgroup_index + 1) % _subgroup_types.size()
	else:
		_subgroup_index = (_subgroup_index - 1 + _subgroup_types.size()) % _subgroup_types.size()
	# 高亮当前子组（改变选择圈颜色或大小可做，暂时用打印）

func _deselect_all() -> void:
	for unit in selected_units:
		unit.set_selected(false)
	selected_units.clear()
	selection_changed.emit(selected_units)


## 查找点击位置的玩家单位
func _find_player_unit_at(pos: Vector2):
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if sp.distance_to(pos) < 20.0:
				return u
	return null


func _find_friendly_unit_at(pos: Vector2):
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead() and not u.selected:
			var sp: Vector2 = u.get_node("BodySprite").global_position if u.has_node("BodySprite") else u.global_position
			if sp.distance_to(pos) < 20.0:
				return u
	return null

func _find_player_building_at(pos: Vector2):
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead() and b.get_rect().has_point(pos):
			return b
	return null

func select_building(building) -> void:
	selected_building = building

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
