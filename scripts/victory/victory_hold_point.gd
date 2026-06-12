class_name VictoryHoldPoint
extends VictoryCondition

## 占领据点 → 坚守计时 → 击退反攻 → 胜利
## 配合 VictoryMultiStage 使用，每个 Stage 包含一个此节点

@export var capture_point_path: NodePath = ^""
@export var hold_time: float = 60.0
@export var counterattack_delay: float = 5.0
@export var counterattack_groups: Array[Dictionary] = []  # [{"type": 0, "count": 5}]
@export var counterattack_spawn_path: NodePath = ^""

var _hold_start_msec: float = 0.0
var _captured: bool = false
var _counterattack_spawned: bool = false
var _counterattack_start_msec: float = 0.0
var _capture_point: CapturePoint = null
var _initialized: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_capture_point = get_node_or_null(capture_point_path)
	if _capture_point:
		_capture_point.disable()
		if _capture_point.has_signal("captured"):
			_capture_point.captured.connect(_on_captured)
		if _capture_point.has_signal("lost"):
			_capture_point.lost.connect(_on_lost)

func check() -> int:
	if _capture_point == null:
		return 0

	if not _initialized:
		_initialized = true
		_capture_point.enable()

	if _captured:
		var now := Time.get_ticks_msec()
		if not _counterattack_spawned and now - _counterattack_start_msec >= counterattack_delay * 1000.0:
			_spawn_counterattack()
			_counterattack_spawned = true
		if now - _hold_start_msec >= hold_time * 1000.0:
			return 1
	return 0

func get_objectives() -> Array[Dictionary]:
	if _captured:
		var elapsed := (Time.get_ticks_msec() - _hold_start_msec) / 1000.0
		var remaining := maxi(0, int(ceil(hold_time - elapsed)))
		return [{
			"text": tr("OBJ_HOLD_POINT") if description_key.is_empty() else tr(description_key),
			"progress": tr("OBJ_HOLD_REMAINING") % remaining if elapsed < hold_time else tr("OBJ_COMPLETED"),
			"state": 1 if elapsed >= hold_time else 0,
		}]
	return [{
		"text": tr("OBJ_HOLD_POINT") if description_key.is_empty() else tr(description_key),
		"progress": tr("OBJ_CAPTURE_FIRST"),
		"state": 0,
	}]

func get_progress_fraction() -> float:
	if not _captured:
		return 0.0
	var elapsed := (Time.get_ticks_msec() - _hold_start_msec) / 1000.0
	return minf(elapsed / hold_time, 1.0)

func _on_captured(team: int) -> void:
	if team == 0:
		_captured = true
		_hold_start_msec = Time.get_ticks_msec()
		_counterattack_start_msec = Time.get_ticks_msec()
		_counterattack_spawned = false
		objective_updated.emit()

func _on_lost(_previous_team: int) -> void:
	_captured = false
	_counterattack_spawned = false
	objective_updated.emit()

func _spawn_counterattack() -> void:
	if counterattack_groups.is_empty():
		return
	var spawn_node := get_node_or_null(counterattack_spawn_path)
	var spawn_pos := Vector2.ZERO
	if spawn_node and spawn_node is Node2D:
		spawn_pos = spawn_node.global_position
	elif _capture_point:
		spawn_pos = _capture_point.global_position

	if game_controller and game_controller.has_method("spawn_unit_near"):
		for g in counterattack_groups:
			var type: int = g.get("type", 0)
			var count: int = g.get("count", 1)
			for i in count:
				game_controller.call("spawn_unit_near", type, spawn_pos, 1)

func reset() -> void:
	_captured = false
	_hold_start_msec = 0.0
	_counterattack_spawned = false
	_initialized = false
