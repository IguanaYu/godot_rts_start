extends Node

## Lockstep 同步器 - 确保两端在同一个 tick 执行同一批命令
## 策略：命令到齐才推进，否则暂停 TickManager

var _last_executed_tick := -1
var _game: Node2D = null
var _net_id_map: Dictionary = {}

func _ready() -> void:
	CommandBuffer.commands_ready.connect(_on_commands_ready)
	TickManager.enabled = false
	if not RelayManager.both_loaded.is_connected(_start_game):
		RelayManager.both_loaded.connect(_start_game)

func set_game(game: Node2D) -> void:
	_game = game

func register_unit(unit) -> void:
	if unit.net_id > 0:
		_net_id_map[unit.net_id] = unit

func unregister_unit(unit) -> void:
	if unit.net_id > 0:
		_net_id_map.erase(unit.net_id)

func get_unit_by_net_id(nid: int):
	return _net_id_map.get(nid, null)

func _start_game(seed: int) -> void:
	TickManager.init_rng(seed)
	TickManager.enabled = true
	TickManager.resume()
	_last_executed_tick = -1
	print("LockstepSync: 同步已启动 (seed=%d)" % seed)

func stop() -> void:
	TickManager.enabled = false
	print("LockstepSync: 同步已停止")

func _on_commands_ready(tick_num: int, commands: Array) -> void:
	if tick_num <= _last_executed_tick:
		return
	_execute_commands(tick_num, commands)
	_last_executed_tick = tick_num

func _execute_commands(tick_num: int, commands: Array) -> void:
	for cmd in commands:
		var cmd_type: String = cmd.get("type", "")
		var player: int = cmd.get("player", 0)
		match cmd_type:
			"move":
				var target := Vector2(cmd["target"]["x"], cmd["target"]["y"])
				_execute_move(player, cmd.get("unit_ids", []), target)
			"attack":
				_execute_attack(player, cmd.get("unit_ids", []), cmd.get("target_id", 0))
			"attack_move":
				var target := Vector2(cmd["target"]["x"], cmd["target"]["y"])
				_execute_attack_move(player, cmd.get("unit_ids", []), target)
			"build":
				var pos := Vector2(cmd["pos"]["x"], cmd["pos"]["y"])
				_execute_build(player, cmd.get("building_type", 0), pos)
			"spawn":
				var pos := Vector2(cmd["pos"]["x"], cmd["pos"]["y"])
				_execute_spawn(player, cmd.get("unit_type", 0), pos)
			"skill":
				var target := Vector2(cmd["target"]["x"], cmd["target"]["y"])
				_execute_skill(player, cmd.get("skill_id", ""), target)
			"":
				pass

func _execute_move(player: int, unit_ids: Array, target: Vector2) -> void:
	if _game == null:
		return
	for nid in unit_ids:
		var unit = get_unit_by_net_id(int(nid))
		if unit and unit.has_method("move_to"):
			unit.move_to(target)

func _execute_attack(player: int, unit_ids: Array, target_id: int) -> void:
	if _game == null:
		return
	var target = get_unit_by_net_id(target_id)
	if target == null:
		return
	for nid in unit_ids:
		var unit = get_unit_by_net_id(int(nid))
		if unit and unit.has_method("command_attack"):
			unit.command_attack(target)

func _execute_attack_move(player: int, unit_ids: Array, target: Vector2) -> void:
	if _game == null:
		return
	for nid in unit_ids:
		var unit = get_unit_by_net_id(int(nid))
		if unit and unit.has_method("attack_move_to"):
			unit.attack_move_to(target)

func _execute_build(player: int, building_type: int, pos: Vector2) -> void:
	if _game == null:
		return
	if _game.has_method("mp_place_building"):
		_game.mp_place_building(player, building_type, pos)

func _execute_spawn(player: int, unit_type: int, pos: Vector2) -> void:
	if _game == null:
		return
	if _game.has_method("mp_spawn_unit"):
		_game.mp_spawn_unit(player, unit_type, pos)

func _execute_skill(player: int, skill_id: String, target: Vector2) -> void:
	pass
