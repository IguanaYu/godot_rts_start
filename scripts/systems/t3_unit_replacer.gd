extends Node
## T3 升级场景替换：t3_upgrade_visual_started 信号触发后，
## 把场上所有该兵种单位替换为变体单位
## 状态继承：位置 / 移动目标 / 攻击目标 / HP 按比例 / T1/T2 升级 modifier

var _main_node: Node2D = null
var _t3_manager: Node = null
var _unit_upgrade_manager: Node = null

func initialize(main_node: Node2D, t3_manager: Node, uum: Node) -> void:
	_main_node = main_node
	_t3_manager = t3_manager
	_unit_upgrade_manager = uum
	t3_manager.t3_upgrade_visual_started.connect(_on_visual_started)

func _on_visual_started(unit_type: int) -> void:
	var choice_id = _t3_manager.get_selected_choice(unit_type)
	var data = _t3_manager.get_upgrade_data(unit_type)
	var choice: Resource = null
	for c in data.choices:
		if c.choice_id == choice_id:
			choice = c
			break
	if choice == null:
		push_error("T3 替换找不到 choice: %s" % choice_id)
		return

	# 收集所有该兵种单位
	var to_replace: Array = []
	for u in get_tree().get_nodes_in_group("player_units"):
		if not is_instance_valid(u):
			continue
		if u.unit_type != unit_type:
			continue
		if u.is_dead():
			continue
		to_replace.append(u)

	# 逐个替换
	for old_unit in to_replace:
		_replace_one(old_unit, choice)

func _replace_one(old_unit: Node2D, choice: Resource) -> void:
	# 1. 保存状态
	var pos: Vector2 = old_unit.global_position
	var move_target = old_unit.get("move_target") if old_unit.get("move_target") else null
	var attack_target = old_unit.attack_target if old_unit.attack_target else null
	var hp_ratio := float(old_unit.health.hp) / float(old_unit.health.max_hp) if old_unit.health.max_hp > 0 else 1.0
	var alliance_id = old_unit.alliance_id
	var faction_color = old_unit.faction_color
	var was_selected: bool = old_unit.selected
	var combat_ctrl = _main_node.combat_ctrl if _main_node.get("combat_ctrl") else null

	# 2. 播放闪光特效
	var FX := preload("res://scenes/effects/t3_transform_flash.tscn")
	var fx = FX.instantiate()
	fx.global_position = pos
	_main_node.add_child(fx)

	# 3. 从选中列表移除（避免 queue_free 后留下死引用，右键命令崩溃）
	if combat_ctrl:
		combat_ctrl.remove_dead_unit(old_unit)
	old_unit.set_selected(false)

	# 4. 释放旧单位
	old_unit.queue_free()

	# 5. 实例化新单位
	var new_unit: CharacterBody2D = choice.variant_scene.instantiate()
	_main_node.get_node("PlayerUnits").add_child(new_unit)
	new_unit.global_position = pos
	new_unit.alliance_id = alliance_id
	new_unit.faction_color = faction_color
	new_unit.add_to_group("player_units")

	# 5. HP 按比例继承
	await new_unit.ready
	var new_max = new_unit.health.max_hp
	var new_hp = int(new_max * hp_ratio)
	new_unit.health.hp = new_hp
	new_unit.health._update_hp_bar()

	# 6. 应用 T1/T2 已购升级
	_unit_upgrade_manager.apply_to_new_unit(new_unit)

	# 7. 恢复移动 / 攻击目标
	if move_target != null:
		new_unit.set("move_target", move_target)
	if attack_target != null and is_instance_valid(attack_target):
		new_unit.attack_target = attack_target

	# 8. 转移选中状态：旧单位被选中则新单位也选中
	if was_selected and combat_ctrl:
		new_unit.set_selected(true)
		combat_ctrl.selected_units.append(new_unit)