extends RefCounted
## 集成测试：士兵进攻敌方兵营

const TestScene = preload("res://scenes/test/test_combat_scene.tscn")
const FactionClass = preload("res://scripts/faction.gd")

var scene_instance: Node2D
var soldiers = []
var enemy_building = null
var building_died = false
var building_max_hp = 0

func run(a: RefCounted, runner: Node) -> void:
	var test_name = "士兵进攻敌方兵营"
	print("\n[%s]" % test_name)

	# 1. 加载测试场景
	scene_instance = TestScene.instantiate()
	runner.add_child(scene_instance)
	await runner.get_tree().process_frame

	# 2. 生成单位
	await _spawn_units(runner)
	await _take_screenshot(runner, "combat_01_units_spawned")

	# 3. 验证初始状态
	a.assert_not_null(enemy_building, "敌方建筑生成成功")
	a.assert_eq(soldiers.size(), 5, "5个士兵生成成功")
	var hp_before = enemy_building.get_node("HealthComponent").hp
	a.assert_gt(hp_before, 0, "建筑初始HP > 0")
	print("  PASS: 初始状态验证完成")

	# 4. 下达进攻指令
	for soldier in soldiers:
		soldier.command_attack(enemy_building)
	await runner.get_tree().create_timer(0.1).timeout
	await _take_screenshot(runner, "combat_02_attack_ordered")
	print("  PASS: 进攻指令已下达")

	# 5. 等待战斗进行（3秒后截图，士兵应该到达建筑旁）
	await runner.get_tree().create_timer(3.0).timeout
	await _take_screenshot(runner, "combat_03_combat_progress")
	print("  PASS: 战斗进行中...")

	# 6. 等待建筑死亡（超时30秒）
	var timeout = 30.0
	var elapsed = 0.0
	while elapsed < timeout and enemy_building and is_instance_valid(enemy_building):
		await runner.get_tree().create_timer(0.2).timeout
		elapsed += 0.2

	var building_still_alive = enemy_building and is_instance_valid(enemy_building)
	if building_still_alive:
		print("  FAIL: 30秒超时，建筑未被摧毁")
	else:
		print("  PASS: %.1f秒建筑被摧毁" % elapsed)

	await _take_screenshot(runner, "combat_04_building_destroyed")

	# 7. 最终验证
	a.assert_false(building_still_alive, "敌方建筑被摧毁")

	# 统计存活士兵数
	var alive_count = 0
	for soldier in soldiers:
		if soldier and is_instance_valid(soldier):
			alive_count += 1
	a.assert_gt(alive_count, 0, "至少1个士兵存活")

	print("  PASS: 全部验证通过 (%d/%d士兵存活)" % [alive_count, soldiers.size()])

	# 清理
	scene_instance.queue_free()


func _spawn_units(runner: Node) -> void:
	var setup = scene_instance.get_script()

	# 生成5个玩家士兵
	soldiers = scene_instance.spawn_soldiers(5, Vector2(200, 300))

	# 生成敌方兵营
	enemy_building = scene_instance.spawn_enemy_barracks(Vector2(700, 300))

	# 等待 _ready 完成
	await runner.get_tree().process_frame
	await runner.get_tree().process_frame

	# 记录建筑最大血量
	if enemy_building and is_instance_valid(enemy_building):
		var health = enemy_building.get_node_or_null("HealthComponent")
		if health:
			building_max_hp = health.max_hp
			print("  兵营初始HP: %d" % building_max_hp)


func _take_screenshot(runner: Node, name: String) -> void:
	# 确保渲染帧
	await runner.get_tree().process_frame
	await runner.get_tree().process_frame

	var viewport = runner.get_viewport()
	var img := viewport.get_texture().get_image()
	if img == null:
		print("  [截图失败] %s - 无法获取图像" % name)
		return

	var dir = "user://test_screenshots/"
	var path = dir + name + ".png"
	var err = img.save_png(path)
	if err == OK:
		var abs_path = ProjectSettings.globalize_path(path)
		print("  [截图] %s -> %s" % [name, abs_path])
	else:
		print("  [截图失败] %s - 错误代码%d" % [name, err])
