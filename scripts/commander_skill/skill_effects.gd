extends RefCounted
## 指挥官技能效果实现

const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")


static func orbital_strike(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var radius: float = config.get("radius", 80.0)
	var damage: int = config.get("damage", 150)

	# 创建爆炸特效
	var explosion_scene := load("res://scenes/effects/explosion.tscn")
	var effect: Node2D = explosion_scene.instantiate()
	effect.global_position = target_pos
	main_node.add_child(effect)
	# 放大特效以匹配范围
	if effect.has_node("Sprite"):
		var sprite: Sprite2D = effect.get_node("Sprite")
		var scale_factor := radius / 40.0
		sprite.scale = Vector2(scale_factor, scale_factor)

	# 播放灰尘特效
	spawner_module.spawn_dust_effect(target_pos)

	# 对范围内敌人造成伤害
	var tree := main_node.get_tree()
	for unit in tree.get_nodes_in_group("enemy_units"):
		if unit is CharacterBody2D and not unit.health.is_dead():
			if unit.global_position.distance_to(target_pos) <= radius:
				unit.take_damage(damage)

	# 对范围内敌方建筑也造成伤害
	for building in tree.get_nodes_in_group("enemy_buildings"):
		if building.has_method("is_dead") and not building.is_dead():
			if building.global_position.distance_to(target_pos) <= radius:
				building.take_damage(damage)

	# 显示范围指示器
	_show_area_indicator(main_node, target_pos, radius, Color(1.0, 0.3, 0.1, 0.4))

	# 浮动文字
	spawner_module.show_floating_text("-%d" % damage, Color(1, 0.3, 0.1), target_pos)


static func heal_field(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var radius: float = config.get("radius", 120.0)
	var heal_amount: int = config.get("heal_amount", 50)

	# 对范围内友方单位治疗
	var tree := main_node.get_tree()
	var healed_count := 0
	for unit in tree.get_nodes_in_group("player_units"):
		if unit is CharacterBody2D and not unit.health.is_dead():
			if unit.global_position.distance_to(target_pos) <= radius:
				unit.heal(heal_amount)
				healed_count += 1

	# 治疗范围指示器
	_show_area_indicator(main_node, target_pos, radius, Color(0.1, 0.9, 0.3, 0.35))

	# 浮动文字
	if healed_count > 0:
		spawner_module.show_floating_text("+%d" % heal_amount, Color(0.1, 0.9, 0.3), target_pos)


static func shield_wall(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var duration: float = config.get("duration", 15.0)

	# 创建临时墙体节点
	var wall := Node2D.new()
	wall.name = "ShieldWall"
	wall.position = target_pos
	wall.z_index = 2

	# 墙体精灵
	var wall_sprite := Sprite2D.new()
	# 使用现有 Wall 纹理
	wall_sprite.texture = load("res://assets/buildings/blue_house/House1.png")
	wall_sprite.scale = Vector2(0.35, 0.35)
	wall_sprite.modulate = Color(0.4, 0.6, 1.0, 0.8)
	wall.add_child(wall_sprite)

	# 阴影
	var shadow := Sprite2D.new()
	shadow.texture = load("res://assets/buildings/blue_house/House1.png")
	shadow.scale = Vector2(0.3, 0.15)
	shadow.modulate = Color(0, 0, 0, 0.3)
	shadow.position = Vector2(0, 10)
	shadow.z_index = -1
	wall.add_child(shadow)

	# 血量组件
	var health_node := Node2D.new()
	health_node.set_script(load("res://scripts/core/health_component.gd"))
	wall.add_child(health_node)
	health_node.setup(500)

	# 倒计时标签
	var timer_label := Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 14)
	timer_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	timer_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	timer_label.position = Vector2(-15, -25)
	wall.add_child(timer_label)

	# 倒计时脚本
	var timer_script := load("res://scripts/commander_skill/shield_wall_timer.gd")
	wall.set_script(timer_script)
	wall.set("duration", duration)

	# 血条
	var hp_bar := ProgressBar.new()
	hp_bar.max_value = 500
	hp_bar.value = 500
	hp_bar.custom_minimum_size = Vector2(40, 5)
	hp_bar.position = Vector2(-20, -30)
	hp_bar.show_percentage = false
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.7)
	hp_bar.add_theme_stylebox_override("background", bg_style)
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.4, 0.6, 1.0)
	hp_bar.add_theme_stylebox_override("fill", fill_style)
	wall.add_child(hp_bar)
	health_node.hp_bar = hp_bar

	main_node.add_child(wall)
	# 将临时墙加入建筑组以便被敌方攻击
	wall.add_to_group("player_buildings")

	# 浮动文字
	spawner_module.show_floating_text("Shield Wall", Color(0.4, 0.6, 1.0), target_pos)


static func unit_drop(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var units: Array = config.get("units", [])

	# 生成单位
	var spawned: Array = []
	for unit_type in units:
		var u = spawner_module.spawn_unit_near(unit_type, target_pos, UnitScript.Team.PLAYER)
		if u:
			spawned.append(u)

	# 空投特效：灰尘
	spawner_module.spawn_dust_effect(target_pos)

	# 浮动文字
	spawner_module.show_floating_text("Unit Drop", Color(0.3, 0.8, 1.0), target_pos)

	# 全局集结点：召唤单位自动前往（移动并攻击）
	if main_node.get("has_global_rally"):
		for u in spawned:
			u.attack_move_to(main_node.global_rally_point)


static func fortify(main_node: Node2D, spawner_module: Node, _target_pos: Vector2, config: Dictionary) -> void:
	# 即时技能：所有玩家建筑瞬间回满血 + max_hp +50%（持续 12s 后恢复 max_hp）
	var duration: float = config.get("duration", 12.0)
	var max_hp_bonus: float = config.get("max_hp_bonus", 0.5)

	var tree := main_node.get_tree()
	var buffed: Array = []  # 记录 buff 状态用于到期恢复
	for building in tree.get_nodes_in_group("player_buildings"):
		if not is_instance_valid(building):
			continue
		if building.has_method("is_dead") and building.is_dead():
			continue
		if building.has_node("HealthComponent"):
			var health = building.get_node("HealthComponent")
			var old_max: int = health.max_hp
			var new_max: int = int(old_max * (1.0 + max_hp_bonus))
			health.max_hp = new_max
			health.hp = new_max  # 回满
			health._update_hp_bar()
			buffed.append({"building": building, "old_max": old_max})

	# 显示一个全屏特效：每个建筑周围画一个绿色光环
	for entry in buffed:
		var b = entry.building
		if is_instance_valid(b):
			_show_area_indicator(main_node, b.global_position, 80.0, Color(0.4, 0.9, 0.5, 0.4))

	# 计时器：duration 秒后恢复 max_hp
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.name = "FortifyTimer"
	main_node.add_child(timer)
	timer.timeout.connect(func():
		for entry in buffed:
			var b = entry.building
			if is_instance_valid(b) and b.has_node("HealthComponent"):
				var health = b.get_node("HealthComponent")
				health.max_hp = entry.old_max
				health.hp = mini(health.hp, health.max_hp)
				health._update_hp_bar()
		timer.queue_free()
	)
	timer.start()

	# 浮动文字
	spawner_module.show_floating_text("FORTIFY!", Color(0.4, 0.9, 0.5), main_node.get_global_mouse_position())


static func _show_area_indicator(main_node: Node2D, pos: Vector2, radius: float, color: Color) -> void:
	var indicator := Node2D.new()
	indicator.position = pos
	var script := load("res://scripts/commander_skill/area_indicator.gd")
	indicator.set_script(script)
	indicator.set("radius", radius)
	indicator.set("indicator_color", color)
	main_node.add_child(indicator)


# ============================================================
# Layer 1 扩展技能
# ============================================================

# --- 持续区域类（凝固汽油弹 / 毒气云 / 维修无人机 共用 _create_persistent_zone） ---

static func napalm_strike(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	_create_persistent_zone(
		main_node, spawner_module, target_pos,
		config.get("radius", 90.0), config.get("duration", 5.0), config.get("dps", 30),
		"enemy_units", true, "enemy_buildings",
		Color(1.0, 0.4, 0.0, 0.35), Color(1.0, 0.3, 0.0),
		"Napalm Strike"
	)


static func poison_cloud(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	_create_persistent_zone(
		main_node, spawner_module, target_pos,
		config.get("radius", 110.0), config.get("duration", 8.0), config.get("dps", 15),
		"enemy_units", false, "",
		Color(0.4, 0.9, 0.2, 0.3), Color(0.4, 0.9, 0.2),
		"Poison Cloud"
	)


static func repair_drone(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	_create_persistent_zone(
		main_node, spawner_module, target_pos,
		config.get("radius", 100.0), config.get("duration", 10.0), -config.get("hps", 8),
		"player_units", false, "",
		Color(0.3, 0.8, 1.0, 0.3), Color(0.3, 0.9, 1.0),
		"Repair Drone"
	)


static func _create_persistent_zone(
		main_node: Node2D, spawner_module: Node, target_pos: Vector2,
		radius: float, duration: float, amount_per_sec: int,
		target_group: String, affect_buildings: bool, building_group: String,
		visual_color: Color, float_text_color: Color,
		label_text: String
) -> void:
	# 视觉：彩色圆圈
	var visual := Node2D.new()
	visual.name = "Visual"
	visual.set_script(load("res://scripts/commander_skill/circle_renderer.gd"))
	visual.set("circle_radius", radius)
	visual.set("circle_color", visual_color)

	# 持续区域逻辑
	var zone := Node2D.new()
	zone.name = "PersistentZone"
	zone.position = target_pos
	zone.z_index = 2
	zone.set_script(load("res://scripts/commander_skill/persistent_zone.gd"))
	zone.set("radius", radius)
	zone.set("duration", duration)
	zone.set("amount_per_sec", amount_per_sec)
	zone.set("target_group", target_group)
	zone.set("affect_buildings", affect_buildings)
	zone.set("building_group", building_group)
	zone.set("main_ref", main_node)
	zone.set("float_text_color", float_text_color)
	zone.add_child(visual)

	main_node.add_child(zone)
	spawner_module.show_floating_text(label_text, visual_color, target_pos)


# --- 集束炸弹 ---

static func cluster_bomb(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var radius: float = config.get("radius", 140.0)
	var damage: int = config.get("damage", 50)
	var sub_explosions: int = config.get("sub_explosions", 6)
	var explosion_scene := load("res://scenes/effects/explosion.tscn")

	_show_area_indicator(main_node, target_pos, radius, Color(1.0, 0.5, 0.1, 0.3))
	spawner_module.show_floating_text("Cluster Bomb", Color(1.0, 0.5, 0.1), target_pos)

	for i in sub_explosions:
		var angle: float = TAU * float(i) / float(sub_explosions) + randf() * 0.3
		var dist: float = radius * (0.3 + randf() * 0.6)
		var pos: Vector2 = target_pos + Vector2(cos(angle), sin(angle)) * dist
		var delay: float = float(i) * 0.12 + randf() * 0.15
		var tree: SceneTree = main_node.get_tree()
		var timer: SceneTreeTimer = tree.create_timer(delay)
		timer.timeout.connect(_detonate_cluster.bind(main_node, spawner_module, pos, damage, explosion_scene))


static func _detonate_cluster(main_node: Node2D, spawner_module: Node, pos: Vector2, damage: int, explosion_scene) -> void:
	if not is_instance_valid(main_node):
		return
	var effect: Node2D = explosion_scene.instantiate()
	effect.global_position = pos
	main_node.add_child(effect)
	if effect.has_node("Sprite"):
		var sprite: Sprite2D = effect.get_node("Sprite")
		sprite.scale = Vector2(0.75, 0.75)

	spawner_module.spawn_dust_effect(pos)

	var tree := main_node.get_tree()
	for unit in tree.get_nodes_in_group("enemy_units"):
		if unit is CharacterBody2D and not unit.health.is_dead():
			if unit.global_position.distance_to(pos) <= 35.0:
				unit.take_damage(damage)
	for building in tree.get_nodes_in_group("enemy_buildings"):
		if building.has_method("is_dead") and not building.is_dead():
			if building.global_position.distance_to(pos) <= 35.0:
				building.take_damage(damage)


# --- 狙击标记 ---

static func sniper_mark(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var radius: float = config.get("radius", 15.0)
	var damage: int = config.get("damage", 500)

	# 锁定最近的敌方单位
	var closest = null
	var closest_dist: float = INF
	for unit in main_node.get_tree().get_nodes_in_group("enemy_units"):
		if unit is CharacterBody2D and not unit.health.is_dead():
			var d: float = unit.global_position.distance_to(target_pos)
			if d <= radius and d < closest_dist:
				closest = unit
				closest_dist = d

	# 锁定标记视觉（红色圆圈）
	var marker := Node2D.new()
	marker.position = target_pos
	marker.z_index = 50
	var ring := Node2D.new()
	ring.set_script(load("res://scripts/commander_skill/circle_renderer.gd"))
	ring.set("circle_radius", radius * 1.8)
	ring.set("circle_color", Color(1.0, 0.2, 0.1, 0.9))
	marker.add_child(ring)
	main_node.add_child(marker)

	spawner_module.show_floating_text("Sniper Mark", Color(1.0, 0.85, 0.0), target_pos)

	# 0.3 秒后伤害（让玩家看到锁定）
	var timer := main_node.get_tree().create_timer(0.3)
	timer.timeout.connect(func():
		if not is_instance_valid(main_node):
			return
		if is_instance_valid(marker):
			marker.queue_free()
		var exp_scene := load("res://scenes/effects/explosion.tscn")
		var exp: Node2D = exp_scene.instantiate()
		exp.global_position = target_pos
		main_node.add_child(exp)
		if closest and is_instance_valid(closest) and not closest.health.is_dead():
			closest.take_damage(damage)
			spawner_module.show_floating_text("-%d" % damage, Color(1.0, 0.3, 0.1), closest.global_position)
	)


# --- 紧急维修（全图友方建筑） ---

static func emergency_repair(main_node: Node2D, spawner_module: Node, _target_pos: Vector2, config: Dictionary) -> void:
	var heal_ratio: float = config.get("heal_ratio", 0.4)
	var tree := main_node.get_tree()
	var count := 0
	for building in tree.get_nodes_in_group("player_buildings"):
		if building.has_method("is_dead") and not building.is_dead():
			var health_node = building.get("health")
			if health_node:
				var amount := int(float(health_node.max_hp) * heal_ratio)
				health_node.heal(amount)
				count += 1
				spawner_module.show_floating_text("+%d" % amount, Color(0.1, 0.9, 0.3), building.global_position)


# --- 力场屏障（无敌阻挡） ---

static func force_field(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var duration: float = config.get("duration", 8.0)
	var radius: float = config.get("radius", 60.0)

	var field := Node2D.new()
	field.name = "ForceField"
	field.position = target_pos
	field.z_index = 2

	# 视觉：紫色圆形
	var visual := Node2D.new()
	visual.name = "Visual"
	visual.set_script(load("res://scripts/commander_skill/circle_renderer.gd"))
	visual.set("circle_radius", radius)
	visual.set("circle_color", Color(0.6, 0.3, 0.9, 0.45))
	field.add_child(visual)

	# 血量组件（HP 巨大模拟无敌）
	var health_node := Node2D.new()
	health_node.set_script(load("res://scripts/core/health_component.gd"))
	field.add_child(health_node)
	health_node.setup(99999)

	# 倒计时标签
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.5, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.position = Vector2(-15, -25)
	field.add_child(label)

	# 倒计时脚本
	field.set_script(load("res://scripts/commander_skill/force_field_timer.gd"))
	field.set("duration", duration)

	main_node.add_child(field)
	field.add_to_group("player_buildings")

	spawner_module.show_floating_text("Force Field", Color(0.6, 0.3, 0.9), target_pos)


# --- 补给箱（立即加金币） ---

static func supply_drop(main_node: Node2D, spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var gold_bonus: int = config.get("gold_bonus", 100)
	spawner_module.spawn_dust_effect(target_pos)
	if main_node.has_method("add_gold"):
		main_node.add_gold(gold_bonus)
	spawner_module.show_floating_text("+%dG" % gold_bonus, Color(1.0, 0.85, 0.0), target_pos)
