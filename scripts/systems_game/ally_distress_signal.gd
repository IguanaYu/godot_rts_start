extends Node
## AI 队友求救信号黑板（autoload 单例）
## 接收来自 AI 队友（owner_id=-2）的求救上报，区域 CD 去重，广播给 UI 监听者

signal distress_reported(world_pos: Vector2, victim: Node)
signal distress_cleared(world_pos: Vector2)

const AREA_CD: float = 10.0          # 同区域 10s 内只报一次
const AREA_RADIUS: float = 200.0     # 区域判定半径
const RESCUE_RADIUS: float = 300.0   # 玩家进入此距离视为已救援

var _active_signals: Array[Dictionary] = []
# { "pos": Vector2, "time": float, "victim": Node }


func _process(_delta: float) -> void:
	if _active_signals.is_empty():
		return
	var now: float = Time.get_ticks_msec() / 1000.0
	var expired_indices: Array[int] = []
	for i in _active_signals.size():
		if now - _active_signals[i].time > AREA_CD:
			expired_indices.append(i)
	expired_indices.reverse()
	for i in expired_indices:
		var entry: Dictionary = _active_signals.pop_at(i)
		distress_cleared.emit(entry.pos)


func report(world_pos: Vector2, victim: Node) -> void:
	for entry in _active_signals:
		if world_pos.distance_to(entry.pos) < AREA_RADIUS:
			return
	_active_signals.append({
		"pos": world_pos,
		"time": Time.get_ticks_msec() / 1000.0,
		"victim": victim,
	})
	distress_reported.emit(world_pos, victim)


func clear_at(world_pos: Vector2) -> void:
	var cleared_indices: Array[int] = []
	for i in _active_signals.size():
		if world_pos.distance_to(_active_signals[i].pos) < RESCUE_RADIUS:
			cleared_indices.append(i)
	cleared_indices.reverse()
	for i in cleared_indices:
		var entry: Dictionary = _active_signals.pop_at(i)
		distress_cleared.emit(entry.pos)


func get_active_positions() -> Array:
	var positions: Array = []
	for entry in _active_signals:
		positions.append(entry.pos)
	return positions
