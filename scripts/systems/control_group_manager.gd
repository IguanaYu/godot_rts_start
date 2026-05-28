extends RefCounted
## 编队管理器：Ctrl+数字编队，数字选队，双击居中

const NUM_GROUPS := 10

var groups: Array = []       # Array[Array]，index 0 = 按键"1"，index 9 = 按键"0"


func _init() -> void:
	for i in range(NUM_GROUPS):
		groups.append([])


func assign_group(index: int, units: Array) -> void:
	if index < 0 or index >= NUM_GROUPS:
		return
	groups[index] = _clean_dead_units(units)


func select_group(index: int, combat_ctrl: Node) -> void:
	if index < 0 or index >= NUM_GROUPS:
		return
	var units := _clean_dead_units(groups[index])
	groups[index] = units
	if units.is_empty():
		return
	combat_ctrl.deselect_all()
	for u in units:
		if u.has_method("set_selected"):
			u.set_selected(true)
	combat_ctrl.selected_units = units.duplicate()


func add_group_to_selection(index: int, combat_ctrl: Node) -> void:
	if index < 0 or index >= NUM_GROUPS:
		return
	var units := _clean_dead_units(groups[index])
	groups[index] = units
	for u in units:
		if not u.get("selected") and u.has_method("set_selected"):
			u.set_selected(true)
			combat_ctrl.selected_units.append(u)


func center_camera_on_group(index: int, camera_module: Node) -> void:
	if index < 0 or index >= NUM_GROUPS:
		return
	var units := _clean_dead_units(groups[index])
	groups[index] = units
	if units.is_empty():
		return
	var center := Vector2.ZERO
	for u in units:
		center += u.global_position
	center /= units.size()
	camera_module.jump_to_base(center)


func _clean_dead_units(units: Array) -> Array:
	var cleaned := []
	for u in units:
		if is_instance_valid(u) and u.has_method("is_dead") and not u.is_dead():
			cleaned.append(u)
	return cleaned
