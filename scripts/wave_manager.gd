class_name WaveManager
extends Node

## Wave dictionary format:
## {delay: float, units: Array[{type: int, pos: Vector2}],
##  post_clear_delay: float, wave_attack: bool, wave_target: Vector2}
@export var waves: Array[Dictionary] = []
@export var clear_then_next: bool = false

var current_wave: int = -1
var wave_active: bool = false
var game_controller: Node2D = null
var _countdown: float = 0.0
var _waiting: bool = false

signal wave_started(wave_number: int)
signal all_waves_completed

func set_game_controller(gc: Node2D) -> void:
	game_controller = gc

func start_waves() -> void:
	if waves.is_empty():
		return
	current_wave = -1
	wave_active = false
	_start_next_wave()

func _start_next_wave() -> void:
	current_wave += 1
	if current_wave >= waves.size():
		all_waves_completed.emit()
		return

	var wave_data: Dictionary = waves[current_wave]
	var delay: float = wave_data.get("delay", 0.0)
	_countdown = delay
	_waiting = true
	wave_started.emit(current_wave)

var _dbg: float = 0.0

func _process(delta: float) -> void:
	_dbg += delta
	if _dbg > 5.0:
		_dbg = 0.0
		print("WaveManager _process: waiting=", _waiting, " countdown=", _countdown, " current_wave=", current_wave)
	if not _waiting:
		return
	_countdown -= delta
	if _countdown <= 0.0:
		_waiting = false
		_on_countdown_finished()

func _on_countdown_finished() -> void:
	if current_wave < 0 or current_wave >= waves.size():
		return

	var wave_data: Dictionary = waves[current_wave]
	var units: Array = wave_data.get("units", [])
	var wave_attack: bool = wave_data.get("wave_attack", false)
	var wave_target: Vector2 = wave_data.get("wave_target", Vector2.ZERO)

	if game_controller != null and game_controller.has_method("spawn_enemy_wave"):
		game_controller.call("spawn_enemy_wave", units, wave_attack, wave_target)

	if clear_then_next:
		wave_active = true
	else:
		_start_next_wave()

func on_wave_cleared() -> void:
	if not clear_then_next:
		return

	wave_active = false

	# Read post_clear_delay from current wave, then advance to next wave
	var post_delay: float = 0.0
	if current_wave >= 0 and current_wave < waves.size():
		post_delay = waves[current_wave].get("post_clear_delay", 0.0)

	# Advance to next wave
	current_wave += 1
	if current_wave >= waves.size():
		all_waves_completed.emit()
		return

	# Start countdown for next wave
	var next_delay: float = post_delay if post_delay > 0 else waves[current_wave].get("delay", 0.0)
	_countdown = next_delay
	_waiting = true
	wave_started.emit(current_wave)

func get_current_wave_number() -> int:
	return current_wave

func get_total_waves() -> int:
	return waves.size()

func is_waves_complete() -> bool:
	return current_wave >= waves.size() and not wave_active
