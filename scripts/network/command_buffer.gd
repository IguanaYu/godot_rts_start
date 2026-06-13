extends Node

## 命令缓冲器 - 收集玩家操作，批量同步
## 每帧收集本地命令 → RelayManager 发给对方 → 双方到齐后回调执行

## 命令格式: { "type": String, "tick": int, "player": int, "data": Dictionary }
## type: "move" | "attack" | "build" | "spawn" | "skill"

signal commands_ready(tick_num: int, commands: Array)

## 命令队列：tick_num → { player_id: Array[Command] }
var _pending: Dictionary = {}
var _local_commands: Array = []
var _current_tick := 0

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick() -> void:
	if not NetworkManager.is_online:
		return
	_current_tick = TickManager.tick_count
	var cmds: Array = []
	if _local_commands.size() > 0:
		cmds = _local_commands.duplicate()
		_local_commands.clear()
		for cmd in cmds:
			cmd["tick"] = _current_tick
			cmd["player"] = NetworkManager.my_id
	else:
		pass  # 空包也发，确保对方不卡等

	RelayManager.send_game_data({
		"type": "commands",
		"tick": _current_tick,
		"player": NetworkManager.my_id,
		"commands": cmds,
	})
	_add_to_pending(_current_tick, NetworkManager.my_id, cmds)

func receive_remote_commands(tick_num: int, player_id: int, cmds: Array) -> void:
	if tick_num == 0:
		tick_num = _current_tick
	_add_to_pending(tick_num, player_id, cmds)

## 添加本地命令（游戏层调用）
func add_move_command(unit_ids: Array, target: Vector2) -> void:
	_local_commands.append({
		"type": "move",
		"unit_ids": unit_ids,
		"target": {"x": target.x, "y": target.y},
	})

func add_attack_command(unit_ids: Array, target_unit_id: int) -> void:
	_local_commands.append({
		"type": "attack",
		"unit_ids": unit_ids,
		"target_id": target_unit_id,
	})

func add_attack_move_command(unit_ids: Array, target: Vector2) -> void:
	_local_commands.append({
		"type": "attack_move",
		"unit_ids": unit_ids,
		"target": {"x": target.x, "y": target.y},
	})

func add_build_command(building_type: int, pos: Vector2) -> void:
	_local_commands.append({
		"type": "build",
		"building_type": building_type,
		"pos": {"x": pos.x, "y": pos.y},
	})

func add_spawn_command(unit_type: int, pos: Vector2) -> void:
	_local_commands.append({
		"type": "spawn",
		"unit_type": unit_type,
		"pos": {"x": pos.x, "y": pos.y},
	})

func add_skill_command(skill_id: String, target: Vector2) -> void:
	_local_commands.append({
		"type": "skill",
		"skill_id": skill_id,
		"target": {"x": target.x, "y": target.y},
	})

func _add_to_pending(tick_num: int, player_id: int, cmds: Array) -> void:
	if not _pending.has(tick_num):
		_pending[tick_num] = {}
	_pending[tick_num][player_id] = cmds
	_check_ready(tick_num)

func _check_ready(tick_num: int) -> void:
	var tick_data: Dictionary = _pending.get(tick_num, {})
	var expected_players := 2  # TODO: 动态获取玩家数
	if tick_data.size() >= expected_players:
		var all_cmds: Array = []
		for pid in tick_data:
			all_cmds.append_array(tick_data[pid])
		_pending.erase(tick_num)
		commands_ready.emit(tick_num, all_cmds)
