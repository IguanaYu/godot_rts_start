extends Node

## 固定帧率驱动器 + 同步随机数生成器
## 所有游戏逻辑通过 tick 信号驱动，而非 _physics_process(delta)
## 随机数使用共享种子，确保各端一致

signal tick()

const TICK_RATE := 30
const TICK_TIME := 1.0 / TICK_RATE

var tick_count := 0
var _accumulator := 0.0
var _paused := false
var rng := RandomNumberGenerator.new()

## 是否启用固定帧模式（单机=false，多人=true）
var enabled := false

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not enabled:
		return
	if _paused:
		return
	_accumulator += delta
	while _accumulator >= TICK_TIME:
		tick_count += 1
		emit_signal("tick")
		_accumulator -= TICK_TIME

## 初始化同步 RNG（房间创建时由 NetworkManager 调用）
func init_rng(seed_value: int) -> void:
	rng.seed = seed_value
	rng.state = 0

func sync_randf() -> float:
	return rng.randf()

func sync_randi() -> int:
	return rng.randi()

func sync_randf_range(min_val: float, max_val: float) -> float:
	return rng.randf_range(min_val, max_val)

func sync_randi_range(min_val: int, max_val: int) -> int:
	return rng.randi_range(min_val, max_val)

func pause() -> void:
	_paused = true

func resume() -> void:
	_paused = false
