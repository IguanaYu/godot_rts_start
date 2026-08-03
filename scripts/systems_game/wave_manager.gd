class_name WaveManager
extends Node

## Wave dictionary format:
## 旧格式（其他场景在用）:
##   {delay, units/groups, post_clear_delay, wave_attack, wave_target,
##    spawn_point_path 或 spawn_center, formation, spacing}
##   delay: 相对秒数，前一波清/启动后倒数 delay 秒；通常配合 clear_then_next=true
## 新格式 PR-3（T1 测试关卡）:
##   {warning_time, spawn_time, spawn_pos, spawn_pattern, spawn_radius,
##    wave_target, groups, show_warning_marker}
##   warning_time/spawn_time: 绝对游戏秒（从 start_waves 起算）
##   start_waves 时根据 waves[0] 是否含 spawn_time 自动选模式
@export var waves: Array[Dictionary] = []
@export var clear_then_next: bool = false

var current_wave: int = -1
var wave_active: bool = false
var game_controller: Node2D = null

# === 旧路径（delay 驱动）状态 ===
var _countdown: float = 0.0
var _waiting: bool = false
var _diff_preset: Resource = null

# === 新路径（绝对时间驱动）状态 ===
var _mode: String = "legacy"  # "legacy" / "absolute"
var _triggered_warnings: Dictionary = {}  # wave_idx -> bool
var _triggered_spawns: Dictionary = {}     # wave_idx -> bool

signal wave_started(wave_number: int)
signal all_waves_completed
signal countdown_updated(wave_number: int, remaining: float, total_waves: int)
signal wave_warning_triggered(wave_number: int, spawn_pos: Vector2)

func set_game_controller(gc: Node2D) -> void:
	game_controller = gc

func set_difficulty(preset: Resource) -> void:
	_diff_preset = preset

func start_waves() -> void:
	if waves.is_empty():
		return
	if waves[0].has("spawn_time"):
		# PR-3 绝对时间驱动：直接读 main.get_game_time()（统一游戏时间，吃加速）
		_mode = "absolute"
		current_wave = -1
		wave_active = false
		_triggered_warnings.clear()
		_triggered_spawns.clear()
		set_process(true)
	else:
		# 旧路径
		_mode = "legacy"
		current_wave = -1
		wave_active = false
		_start_next_wave_legacy()

# ============================================================
# 旧路径：delay + clear_then_next（保留所有现有场景兼容）
# ============================================================

func _start_next_wave_legacy() -> void:
	current_wave += 1
	if current_wave >= waves.size():
		all_waves_completed.emit()
		return

	var wave_data: Dictionary = waves[current_wave]
	var delay: float = wave_data.get("delay", 0.0)
	if _diff_preset != null:
		delay *= _diff_preset.wave_delay_mult
	_countdown = delay
	_waiting = true
	wave_started.emit(current_wave)

func _process_legacy(delta: float) -> void:
	if not _waiting:
		return
	_countdown -= delta
	countdown_updated.emit(current_wave, _countdown, waves.size())
	if _countdown <= 0.0:
		_waiting = false
		_on_countdown_finished_legacy()

func _on_countdown_finished_legacy() -> void:
	if current_wave < 0 or current_wave >= waves.size():
		return

	var wave_data: Dictionary = waves[current_wave]
	var wave_attack: bool = wave_data.get("wave_attack", false)
	var wave_target: Vector2 = wave_data.get("wave_target", Vector2.ZERO)

	if game_controller == null or not game_controller.has_method("spawn_enemy_wave"):
		push_error("WaveManager: game_controller 没有配置或缺少 spawn_enemy_wave 方法")
		return

	if wave_data.has("groups"):
		var groups: Array = wave_data.groups
		var spawn_center: Vector2 = _resolve_spawn_center(wave_data)
		var formation: String = wave_data.get("formation", "column")
		var spacing: float = wave_data.get("spacing", 50.0)
		game_controller.call("spawn_enemy_wave_v2", groups, spawn_center, wave_attack, wave_target, formation, spacing)
	else:
		var units: Array = wave_data.get("units", [])
		game_controller.call("spawn_enemy_wave", units, wave_attack, wave_target)

	if clear_then_next:
		wave_active = true
	else:
		_start_next_wave_legacy()

func on_wave_cleared() -> void:
	if _mode == "absolute":
		return  # 绝对时间模式不需要 main.gd 触发
	if not clear_then_next:
		return

	wave_active = false

	var post_delay: float = 0.0
	if current_wave >= 0 and current_wave < waves.size():
		post_delay = waves[current_wave].get("post_clear_delay", 0.0)

	current_wave += 1
	if current_wave >= waves.size():
		all_waves_completed.emit()
		return

	var next_delay: float = post_delay if post_delay > 0 else waves[current_wave].get("delay", 0.0)
	if _diff_preset != null:
		next_delay *= _diff_preset.wave_delay_mult
	_countdown = next_delay
	_waiting = true
	wave_started.emit(current_wave)

# ============================================================
# 新路径：绝对时间驱动（PR-3 T1 用）
# ============================================================

func _process_absolute() -> void:
	if game_controller == null or not game_controller.has_method("get_game_time"):
		return
	var now: float = game_controller.get_game_time()
	for i in range(waves.size()):
		if _triggered_spawns.get(i, false):
			continue
		var w: Dictionary = waves[i]
		var warning_time: float = w.get("warning_time", -1.0)
		var spawn_time: float = w.get("spawn_time", -1.0)
		if spawn_time < 0.0:
			continue  # 跳过无效波
		# warning 触发（仅一次）
		if warning_time >= 0.0 and now >= warning_time and not _triggered_warnings.get(i, false):
			_triggered_warnings[i] = true
			var spawn_pos: Vector2 = w.get("spawn_pos", Vector2.ZERO)
			wave_warning_triggered.emit(i, spawn_pos)
		# 倒计时：仅在 warning_time 之后才 emit，避免开局就显示 "Wave 1 in 120s"
		if (warning_time < 0.0 or now >= warning_time) and now < spawn_time:
			countdown_updated.emit(i, spawn_time - now, waves.size())
		# spawn 触发
		if now >= spawn_time:
			_triggered_spawns[i] = true
			# spawn 时 emit remaining=0 触发 objectives_panel 清掉当前 wave row
			countdown_updated.emit(i, 0.0, waves.size())
			_spawn_wave_absolute(i)
			wave_started.emit(i)
			if i == waves.size() - 1:
				all_waves_completed.emit()

func _spawn_wave_absolute(i: int) -> void:
	var w: Dictionary = waves[i]
	var groups: Array = w.get("groups", [])
	var spawn_center: Vector2 = w.get("spawn_pos", _resolve_spawn_center(w))
	# schema 字段 spawn_pattern 优先；兼容旧 formation
	var formation: String = w.get("spawn_pattern", w.get("formation", "column"))
	var spacing: float = w.get("spacing", 50.0)
	var radius: float = w.get("spawn_radius", 80.0)
	var wave_attack: bool = w.get("wave_attack", true)
	var wave_target: Vector2 = w.get("wave_target", Vector2.ZERO)
	if game_controller == null or not game_controller.has_method("spawn_enemy_wave_v2"):
		push_error("WaveManager: game_controller 未配置或缺少 spawn_enemy_wave_v2")
		return
	game_controller.call("spawn_enemy_wave_v2", groups, spawn_center, wave_attack, wave_target, formation, spacing, radius)

# ============================================================
# _process 分发
# ============================================================

func _process(delta: float) -> void:
	if _mode == "absolute":
		_process_absolute()
	else:
		_process_legacy(delta)

# ============================================================
# Public API
# ============================================================

func get_current_wave_number() -> int:
	return current_wave

func get_total_waves() -> int:
	return waves.size()

func is_waves_complete() -> bool:
	if _mode == "absolute":
		# 最后一波 spawn 完成 = 通关
		return _triggered_spawns.get(waves.size() - 1, false)
	return current_wave >= waves.size() and not wave_active

## 解析出生中心点：优先用 spawn_point_path 引用节点，否则用 spawn_center 坐标
func _resolve_spawn_center(wave_data: Dictionary) -> Vector2:
	if wave_data.has("spawn_point_path"):
		var path: NodePath = wave_data.spawn_point_path
		var marker: Node2D = get_node_or_null(path)
		if marker != null:
			return marker.global_position
		push_warning("WaveManager: spawn_point_path '%s' 未找到节点" % path)
	if wave_data.has("spawn_center"):
		return wave_data.spawn_center
	push_warning("WaveManager: 波次缺少 spawn_point_path 和 spawn_center，使用 (0,0)")
	return Vector2.ZERO
