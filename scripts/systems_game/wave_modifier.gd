extends Node

## 根据占领点数量动态修改波次敌人数
## 连接到 CapturePoint 的 captured 信号和 WaveManager 的 wave_started 信号

@export var wave_manager_path: NodePath = ^""
@export var target_wave: int = -1  # 要修改的波次索引
@export var modifiers_per_capture: Array[Dictionary] = []  # [{"type": 0, "delta": -3}]
@export var capture_points: Array[NodePath] = []

var _capture_count: int = 0
var _applied: bool = false
var _wave_manager: Node = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_wave_manager = get_node_or_null(wave_manager_path)
	for cp_path in capture_points:
		var cp := get_node_or_null(cp_path)
		if cp and cp.has_signal("captured"):
			cp.captured.connect(_on_capture)
	if _wave_manager and _wave_manager.has_signal("wave_started"):
		_wave_manager.wave_started.connect(_on_wave_started)

func _on_capture(_team: int) -> void:
	_capture_count += 1

func _on_wave_started(wave_num: int) -> void:
	var target := target_wave
	if target < 0:
		target = _wave_manager.waves.size() - 1
	if wave_num != target or _applied:
		return
	_applied = true
	if target < 0 or target >= _wave_manager.waves.size():
		return
	var wave: Dictionary = _wave_manager.waves[target]
	if not wave.has("groups"):
		return
	var groups: Array = wave.groups
	for mod in modifiers_per_capture:
		var mod_type: int = mod.get("type", -1)
		var mod_delta: int = mod.get("delta", 0)
		for g in groups:
			if g.get("type", -1) == mod_type:
				g.count = maxi(1, g.get("count", 1) + mod_delta * _capture_count)
