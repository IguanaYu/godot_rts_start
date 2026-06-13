extends Node

## 状态哈希器 - 检测不同步
## 每 N 帧计算所有关键游戏状态的哈希值，通过 RelayManager 比对

const HASH_INTERVAL := 60
var _last_hash := 0

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick() -> void:
	if TickManager.tick_count % HASH_INTERVAL != 0:
		return
	if TickManager.tick_count == 0:
		return
	_compute_and_compare()

func _compute_and_compare() -> void:
	var h := _compute_hash()
	_last_hash = h
	RelayManager.send_game_data({
		"type": "hash",
		"tick": TickManager.tick_count,
		"hash": h,
	})

func receive_remote_hash(tick: int, remote_hash: int) -> void:
	var local_hash := _last_hash
	if remote_hash != local_hash:
		push_warning("StateHasher: DESYNC! tick=%d local=0x%08X remote=0x%08X" % [
			tick, local_hash, remote_hash])
	else:
		print("StateHasher: tick=%d OK hash=0x%08X" % [tick, local_hash])

func _compute_hash() -> int:
	var h := TickManager.tick_count
	h = hash_combine(h, TickManager.rng.seed)
	h = hash_combine(h, TickManager.rng.state)
	return h

func compute_full_hash(units_node: Node, buildings_node: Node, gold: int) -> int:
	var h := TickManager.tick_count
	h = hash_combine(h, TickManager.rng.state)
	if units_node:
		var children := units_node.get_children()
		children.sort_custom(func(a, b): return a.get_instance_id() < b.get_instance_id())
		for unit in children:
			h = hash_combine(h, hash_f(unit.global_position.x))
			h = hash_combine(h, hash_f(unit.global_position.y))
			if "hp" in unit:
				h = hash_combine(h, unit.hp)
			if "state" in unit:
				h = hash_combine(h, unit.state)
	if buildings_node:
		var children := buildings_node.get_children()
		children.sort_custom(func(a, b): return a.get_instance_id() < b.get_instance_id())
		for bld in children:
			if "hp" in bld:
				h = hash_combine(h, bld.hp)
	h = hash_combine(h, gold)
	return h

static func hash_combine(hash_val: int, value: int) -> int:
	return hash_val * 31 + value

static func hash_f(val: float) -> int:
	return int(val * 1000.0)
