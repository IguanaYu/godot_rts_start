@tool
class_name CapturePoint
extends Area2D

const UnitScript := preload("res://scripts/units/unit.gd")

const UNIT_TYPE_NAMES := {
	UnitScript.UnitType.SOLDIER: "ENTITY_SOLDIER",
	UnitScript.UnitType.ARCHER: "ENTITY_ARCHER",
	UnitScript.UnitType.LANCER: "ENTITY_LANCER",
	UnitScript.UnitType.MONK: "ENTITY_MONK",
}

enum TriggerType { CLEAR_AREA, KILL_TARGETS, MISSION_COUNTER }

# --- 触发条件 ---
@export var trigger_type: TriggerType = TriggerType.CLEAR_AREA:
	set(v): trigger_type = v; queue_redraw()
@export var detection_area: NodePath = ^"":  # 拖拽一个Node2D作为检测区域中心，为空则用自身位置
	set(v): detection_area = v; queue_redraw()
@export var detection_radius: float = 200.0:
	set(v): detection_radius = v; queue_redraw()
@export var kill_targets: Array[NodePath] = []
@export var kill_count: int = 10

# --- 奖励圈 ---
@export var capture_radius: float = 80.0:
	set(v): capture_radius = v; queue_redraw()
@export var capture_speed: float = 50.0
@export var can_enemy_capture: bool = true
@export var allow_recapture: bool = false

# --- 奖励效果 ---
@export var reward_gold: int = 0
@export var reward_soldiers: int = 0
@export var reward_archers: int = 0
@export var reward_lancers: int = 0
@export var reward_monks: int = 0

# --- 控制 ---
@export var enabled_on_start: bool = true

# --- 内部状态 ---
var is_enabled: bool = false       # 触发检测是否启用
var is_active: bool = false        # 奖励圈是否已激活（可占领）
var capture_progress: float = 0.0
var capturing_team: int = -1
var captured_by: int = -1

var _tracked_enemies: Array = []   # 类型A: 记录的敌人
var _tracked_targets: Array = []   # 类型B: 引用的目标
var _kill_counter: int = 0         # 类型C: 杀敌计数
var _trigger_initialized: bool = false

var game_controller: Node2D = null

signal captured(team: int)
signal lost(previous_team: int)
signal zone_triggered()

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 创建碰撞形状
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = capture_radius
	collision.shape = shape
	add_child(collision)

	# 创建奖励圈视觉
	_setup_capture_visual()

	# 初始不可见
	visible = false

	if enabled_on_start:
		enable()

func _setup_capture_visual() -> void:
	var ring := ColorRect.new()
	ring.name = "CaptureRing"
	ring.size = Vector2(capture_radius * 2, capture_radius * 2)
	ring.position = Vector2(-capture_radius, -capture_radius)
	ring.color = Color(0.3, 1.0, 0.3, 0.2)
	ring.z_index = 5
	add_child(ring)

func set_game_controller(gc: Node2D) -> void:
	game_controller = gc

func enable() -> void:
	is_enabled = true

func disable() -> void:
	is_enabled = false

func activate() -> void:
	is_active = true
	visible = true

func deactivate() -> void:
	is_active = false
	visible = false

func _get_detection_pos() -> Vector2:
	var det_node := get_node_or_null(detection_area)
	if det_node != null and det_node is Node2D:
		return det_node.global_position
	return global_position

func _init_trigger() -> void:
	match trigger_type:
		TriggerType.CLEAR_AREA:
			var det_pos := _get_detection_pos()
			_tracked_enemies.clear()
			for u in get_tree().get_nodes_in_group("enemy_units"):
				if u is CharacterBody2D and not u.is_dead():
					if u.global_position.distance_to(det_pos) <= detection_radius:
						_tracked_enemies.append(u)
			for b in get_tree().get_nodes_in_group("enemy_buildings"):
				if b.has_method("is_dead") and not b.is_dead():
					if b.global_position.distance_to(det_pos) <= detection_radius:
						_tracked_enemies.append(b)
		TriggerType.KILL_TARGETS:
			_tracked_targets.clear()
			for np in kill_targets:
				var node := get_node_or_null(np)
				if node != null:
					_tracked_targets.append(node)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return

	if not is_enabled:
		return

	if is_active:
		_process_capture(delta)
	else:
		_check_trigger()

func _check_trigger() -> void:
	if not _trigger_initialized:
		_init_trigger()
		_trigger_initialized = true
	var triggered := false
	match trigger_type:
		TriggerType.CLEAR_AREA:
			triggered = true
			for e in _tracked_enemies:
				if is_instance_valid(e) and (not e.has_method("is_dead") or not e.is_dead()):
					triggered = false
					break
		TriggerType.KILL_TARGETS:
			triggered = true
			for t in _tracked_targets:
				if is_instance_valid(t) and (not t.has_method("is_dead") or not t.is_dead()):
					triggered = false
					break
		TriggerType.MISSION_COUNTER:
			triggered = _kill_counter >= kill_count

	if triggered:
		zone_triggered.emit()
		activate()

func _process_capture(delta: float) -> void:
	var player_count := 0
	var enemy_count := 0

	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			if u.global_position.distance_to(global_position) <= capture_radius:
				player_count += 1

	if can_enemy_capture:
		for u in get_tree().get_nodes_in_group("enemy_units"):
			if u is CharacterBody2D and not u.is_dead():
				if u.global_position.distance_to(global_position) <= capture_radius:
					enemy_count += 1

	var dominant_team := -1
	if player_count > enemy_count:
		dominant_team = UnitScript.Team.PLAYER
	elif can_enemy_capture and enemy_count > player_count:
		dominant_team = UnitScript.Team.ENEMY

	if dominant_team != -1:
		if captured_by == -1 or captured_by == dominant_team:
			capture_progress += capture_speed * delta
		else:
			capture_progress -= capture_speed * delta * 1.5

		capture_progress = clamp(capture_progress, 0.0, 100.0)
		capturing_team = dominant_team

		if capture_progress >= 100.0 and captured_by != capturing_team:
			var was_previously_captured := captured_by != -1
			var previous_team := captured_by
			captured_by = capturing_team
			if allow_recapture:
				if was_previously_captured:
					lost.emit(previous_team)
				capture_progress = 0.0
			else:
				is_enabled = false
				is_active = false
				visible = false
			captured.emit(captured_by)
			_grant_reward()
	else:
		if captured_by == -1:
			capture_progress = max(0.0, capture_progress - capture_speed * delta * 0.5)

func _grant_reward() -> void:
	if game_controller == null:
		return

	# 金币奖励
	if reward_gold > 0:
		if game_controller.has_method("add_gold"):
			game_controller.call("add_gold", reward_gold)
		if game_controller.has_method("show_floating_text"):
			game_controller.call("show_floating_text",
				"+%d" % reward_gold,
				Color(1.0, 0.85, 0.0),
				global_position)

	# 单位奖励
	var rewards := [
		[UnitScript.UnitType.SOLDIER, reward_soldiers],
		[UnitScript.UnitType.ARCHER, reward_archers],
		[UnitScript.UnitType.LANCER, reward_lancers],
		[UnitScript.UnitType.MONK, reward_monks],
	]
	if game_controller.has_method("spawn_unit_near"):
		for entry in rewards:
			var type: int = entry[0]
			var count: int = entry[1]
			for i in count:
				game_controller.call("spawn_unit_near", type, global_position, captured_by)
	if game_controller.has_method("show_floating_text"):
		var parts: Array[String] = []
		for entry in rewards:
			var type: int = entry[0]
			var count: int = entry[1]
			if count <= 0:
				continue
			var unit_name: String = tr(UNIT_TYPE_NAMES.get(type, "ENTITY_UNIT"))
			if count > 1:
				parts.append(tr("REWARD_UNITS_PLURAL") % [count, unit_name])
			else:
				parts.append(tr("REWARD_UNITS_SINGLE") % [count, unit_name])
		if not parts.is_empty():
			game_controller.call("show_floating_text",
				" ".join(parts),
				Color(0.3, 1.0, 0.3),
				global_position)

func notify_kill() -> void:
	_kill_counter += 1

func get_capture_progress() -> float:
	return capture_progress

func get_captured_by() -> int:
	return captured_by

func is_captured() -> bool:
	return captured_by != -1

# --- 编辑器可视化 ---
func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	# 红色检测区域（仅类型A）
	if trigger_type == TriggerType.CLEAR_AREA:
		var det_node := get_node_or_null(detection_area)
		var det_local := Vector2.ZERO
		if det_node != null and det_node is Node2D:
			det_local = det_node.global_position - global_position
		draw_arc(det_local, detection_radius, 0, TAU, 64, Color(1, 0.3, 0.3, 0.5), 2.0)
		draw_circle(det_local, detection_radius, Color(1, 0.3, 0.3, 0.08))

	# 奖励圈（玩家专属=蓝色，可争夺=绿色）
	var ring_color := Color(0.3, 0.6, 1.0, 0.7) if not can_enemy_capture else Color(0.3, 1.0, 0.3, 0.7)
	var fill_color := Color(0.3, 0.6, 1.0, 0.12) if not can_enemy_capture else Color(0.3, 1.0, 0.3, 0.12)
	draw_arc(Vector2.ZERO, capture_radius, 0, TAU, 64, ring_color, 2.0)
	draw_circle(Vector2.ZERO, capture_radius, fill_color)
