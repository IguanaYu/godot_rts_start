extends Node
## AI 队友战略层调度 + 玩家 ping 指挥（autoload 单例）
## 接收玩家 Alt+左键 ping，广播给所有 AI 队友（owner_id=-2）切换 FORCE_ATTACK 状态

signal attack_order_issued(world_pos: Vector2)
signal defend_order_issued(world_pos: Vector2)


# 玩家 ping 攻击点：所有 AI 队友 attack_move 到该位置
func issue_attack_order(world_pos: Vector2) -> void:
	attack_order_issued.emit(world_pos)
	for u in get_tree().get_nodes_in_group("player_units"):
		if not (u is CharacterBody2D):
			continue
		if u.is_dead():
			continue
		if u.owner_id != -2:
			continue
		var ai := u.get_node_or_null("AllyAI")
		if ai != null and ai.has_method("issue_attack_order"):
			ai.issue_attack_order(world_pos)


# 玩家 ping 防御点：所有 AI 队友 move 到该位置后驻防
func issue_defend_order(world_pos: Vector2) -> void:
	defend_order_issued.emit(world_pos)
	for u in get_tree().get_nodes_in_group("player_units"):
		if not (u is CharacterBody2D):
			continue
		if u.is_dead():
			continue
		if u.owner_id != -2:
			continue
		var ai := u.get_node_or_null("AllyAI")
		if ai != null and ai.has_method("issue_defend_order"):
			ai.issue_defend_order(world_pos)
