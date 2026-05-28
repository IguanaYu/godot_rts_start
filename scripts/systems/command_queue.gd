extends RefCounted
## 命令队列：支持Shift连续指令（移动、攻击移动、攻击目标）

enum CommandType { MOVE, ATTACK_MOVE, ATTACK_TARGET, PATROL_POINT }

class QueuedCommand:
	var type: int = CommandType.MOVE
	var target_pos: Vector2 = Vector2.ZERO
	var target_unit = null  # WeakRef

var commands: Array = []  # Array[QueuedCommand]
var max_size: int = 30


func is_empty() -> bool:
	return commands.is_empty()


func enqueue(cmd: QueuedCommand) -> void:
	if commands.size() < max_size:
		commands.append(cmd)


func dequeue() -> QueuedCommand:
	if commands.is_empty():
		return null
	return commands.pop_front()


func clear() -> void:
	commands.clear()


func get_all_positions() -> Array:
	var positions := []
	for cmd in commands:
		if cmd.target_pos != Vector2.ZERO:
			positions.append(cmd.target_pos)
	return positions
