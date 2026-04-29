extends Node2D

const UnitScript := preload("res://scripts/unit.gd")

# 框选相关
var is_selecting: bool = false
var selection_start: Vector2 = Vector2.ZERO
var selected_units: Array = []

# 节点引用
@onready var camera: Camera2D = $Camera2D
@onready var selection_box: ColorRect = $SelectionBox
@onready var ground: ColorRect = $Ground
@onready var player_units_node: Node2D = $PlayerUnits
@onready var enemy_units_node: Node2D = $EnemyUnits
@onready var result_label: Label = $ResultLabel

# 摄像机控制
var camera_speed: float = 400.0

func _ready() -> void:
	result_label.visible = false
	_spawn_units()
	await get_tree().process_frame

func _spawn_units() -> void:
	var player_spawns := [
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(200, 200)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(200, 280)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(200, 360)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(150, 240)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(150, 320)},
	]

	var enemy_spawns := [
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(900, 200)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(900, 280)},
		{"type": UnitScript.UnitType.SOLDIER, "pos": Vector2(900, 360)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(950, 240)},
		{"type": UnitScript.UnitType.ARCHER, "pos": Vector2(950, 320)},
	]

	for spawn in player_spawns:
		var unit := _create_unit(spawn.type, UnitScript.Team.PLAYER, spawn.pos)
		player_units_node.add_child(unit)
		unit.add_to_group("player_units")

	for spawn in enemy_spawns:
		var unit := _create_unit(spawn.type, UnitScript.Team.ENEMY, spawn.pos)
		enemy_units_node.add_child(unit)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.set_script(load("res://scripts/enemy_ai.gd"))
		unit.add_child(ai)

func _create_unit(type: int, team: int, pos: Vector2) -> CharacterBody2D:
	var unit_scene := load("res://scenes/unit.tscn")
	var unit: CharacterBody2D = unit_scene.instantiate()
	unit.set("unit_type", type)
	unit.set("team", team)
	unit.position = pos
	unit.connect("died", _on_unit_died)
	return unit

func _on_unit_died(unit: CharacterBody2D) -> void:
	if selected_units.has(unit):
		selected_units.erase(unit)

func _process(delta: float) -> void:
	_camera_control(delta)
	_check_victory()

	if is_selecting:
		var current_pos := get_global_mouse_position()
		var rect := _get_selection_rect(selection_start, current_pos)
		selection_box.position = rect.position
		selection_box.size = rect.size
		selection_box.visible = true
	else:
		selection_box.visible = false

func _camera_control(delta: float) -> void:
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input.x += 1
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input.y += 1
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input.y -= 1
	camera.position += input.normalized() * camera_speed * delta / camera.zoom.x

func _check_victory() -> void:
	if result_label.visible:
		return

	var player_alive := get_tree().get_nodes_in_group("player_units").filter(
		func(u): return u.get("state") != UnitScript.UnitState.DEAD if u is CharacterBody2D else false
	)
	var enemy_alive := get_tree().get_nodes_in_group("enemy_units").filter(
		func(u): return u.get("state") != UnitScript.UnitState.DEAD if u is CharacterBody2D else false
	)

	if enemy_alive.is_empty():
		result_label.text = "Victory!"
		result_label.visible = true
	elif player_alive.is_empty():
		result_label.text = "Defeat!"
		result_label.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_selecting = true
				selection_start = get_global_mouse_position()
			else:
				is_selecting = false
				_selection_released()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_right_click()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()

func _selection_released() -> void:
	var end_pos := get_global_mouse_position()
	var rect := _get_selection_rect(selection_start, end_pos)

	if rect.size.length() < 5.0:
		rect = Rect2(end_pos - Vector2(10, 10), Vector2(20, 20))

	_deselect_all()

	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and u.get("state") != UnitScript.UnitState.DEAD:
			if rect.has_point(u.global_position):
				u.call("set_selected", true)
				selected_units.append(u)

func _right_click() -> void:
	if selected_units.is_empty():
		return

	var click_pos := get_global_mouse_position()

	var clicked_enemy: CharacterBody2D = null
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and u.get("state") != UnitScript.UnitState.DEAD:
			if u.global_position.distance_to(click_pos) < 20.0:
				clicked_enemy = u
				break

	if clicked_enemy != null:
		for unit in selected_units:
			unit.call("command_attack", clicked_enemy)
			var ai_nodes := clicked_enemy.get_children().filter(func(c): return c.has_method("on_attacked"))
			for ai in ai_nodes:
				ai.on_attacked(unit)
	else:
		var count := selected_units.size()
		for i in range(count):
			var offset := _formation_offset(i, count)
			selected_units[i].call("move_to", click_pos + offset)

func _formation_offset(index: int, total: int) -> Vector2:
	if total == 1:
		return Vector2.ZERO
	var angle := (float(index) / float(total)) * PI - PI / 2.0
	var radius := 30.0 + total * 5.0
	return Vector2(cos(angle), sin(angle)) * radius

func _deselect_all() -> void:
	for unit in selected_units:
		unit.call("set_selected", false)
	selected_units.clear()

func _get_selection_rect(start: Vector2, end: Vector2) -> Rect2:
	var pos := Vector2(min(start.x, end.x), min(start.y, end.y))
	var size := Vector2(abs(end.x - start.x), abs(end.y - start.y))
	return Rect2(pos, size)
