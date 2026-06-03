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
	for unit_type in units:
		spawner_module.spawn_unit_near(unit_type, target_pos, UnitScript.Team.PLAYER)

	# 空投特效：灰尘
	spawner_module.spawn_dust_effect(target_pos)

	# 浮动文字
	spawner_module.show_floating_text("Unit Drop", Color(0.3, 0.8, 1.0), target_pos)


static func _show_area_indicator(main_node: Node2D, pos: Vector2, radius: float, color: Color) -> void:
	var indicator := Node2D.new()
	indicator.position = pos
	var script := load("res://scripts/commander_skill/area_indicator.gd")
	indicator.set_script(script)
	indicator.set("radius", radius)
	indicator.set("indicator_color", color)
	main_node.add_child(indicator)
