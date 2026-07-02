extends Node
## 建筑驻军系统：敌方建筑内存储单位，受击/被求救时分批释放
## 挂载为建筑子节点，命名为 "Garrison"

const D := preload("res://scripts/systems/game_data.gd")
const UnitScript := preload("res://scripts/units/unit.gd")

# ── @export 配置 ──
@export var garrison_config: Array[Dictionary] = []  # [{"type": 0, "weight": 3, "stats_id": ""}, ...]
@export var production_cooldown: float = 15.0
@export var max_capacity: int = 10
@export var release_batch_size: int = 3
@export var release_cooldown: float = 10.0
@export var release_interval: float = 0.5    # 逐个释放间隔
@export var trigger_hp_high: float = 0.75    # 第一次触发血量阈值
@export var trigger_hp_low: float = 0.40     # 强制触发血量阈值

# ── 内部状态 ──
var _disabled: bool = false
var garrison: Array[Dictionary] = []         # 有序列表 [{"type": int, "stats_id": ""}, ...]
var release_timer: float = 0.0               # 释放CD
var production_timer: float = 0.0
var _triggered_75: bool = false
var _triggered_40: bool = false
var _release_queue: Array[Dictionary] = []   # 正在逐个释放的队列
var _release_interval_timer: float = 0.0
var _building: Node2D
var _garrison_bar: ProgressBar = null


func _ready() -> void:
	_building = get_parent() as Node2D
	# 判断是否启用：仅敌方 + 非箭塔
	var bteam: int = _building.get("team")
	var btype: int = _building.get("building_type")
	if bteam != 1 or btype == 1:  # PLAYER=0, ENEMY=1; TOWER=1
		_disabled = true
		return
	# 按建筑类型设置默认配置（编辑器 @export 值会被覆盖）
	if garrison_config.is_empty():
		_apply_default_config(btype)
	# 初始填满驻军
	_fill_garrison_to_capacity()
	# 连接信号
	if _building.has_signal("damaged"):
		_building.damaged.connect(_on_building_damaged)
	if _building.has_signal("died"):
		_building.died.connect(_on_building_died)
	call_deferred("_create_garrison_bar")


func _apply_default_config(btype: int) -> void:
	match btype:
		2:  # CASTLE
			garrison_config = [{"type": 0, "weight": 3}, {"type": 1, "weight": 1}, {"type": 2, "weight": 1}]
			max_capacity = 12
			production_cooldown = 12.0
			release_batch_size = 4
		3:  # BARRACKS
			garrison_config = [{"type": 0, "weight": 3}, {"type": 1, "weight": 1}]
			max_capacity = 8
			production_cooldown = 10.0
			release_batch_size = 3
		5:  # ARCHERY
			garrison_config = [{"type": 1, "weight": 2}, {"type": 0, "weight": 1}]
			max_capacity = 6
			production_cooldown = 10.0
			release_batch_size = 3
		4:  # MONASTERY
			garrison_config = [{"type": 3, "weight": 1}]
			max_capacity = 4
			production_cooldown = 15.0
			release_batch_size = 2
		0:  # WALL
			garrison_config = [{"type": 0, "weight": 1}]
			max_capacity = 3
			production_cooldown = 20.0
			release_batch_size = 2


func _fill_garrison_to_capacity() -> void:
	while garrison.size() < max_capacity:
		var chosen := _weighted_random_pick(garrison_config)
		if chosen.is_empty():
			break
		garrison.append({
			"type": chosen.get("type", 0),
			"stats_id": chosen.get("stats_id", ""),
		})


func _process(delta: float) -> void:
	if _disabled:
		return
	if _building == null or not is_instance_valid(_building) or _building.is_dead():
		return
	_production_tick(delta)
	# 释放CD倒计时
	if release_timer > 0.0:
		release_timer -= delta
	# 处理逐个释放队列
	_process_release_queue(delta)
	# 更新UI
	_update_garrison_bar()


# ============================================================
# 生产系统
# ============================================================
func _production_tick(delta: float) -> void:
	if garrison_config.is_empty():
		return
	if garrison.size() >= max_capacity:
		return
	production_timer += delta
	if production_timer >= production_cooldown:
		production_timer = 0.0
		_produce_one_unit()


func _produce_one_unit() -> void:
	var chosen := _weighted_random_pick(garrison_config)
	if chosen == null:
		return
	garrison.append({
		"type": chosen.get("type", 0),
		"stats_id": chosen.get("stats_id", ""),
	})


func _weighted_random_pick(items: Array[Dictionary]) -> Dictionary:
	var total_weight: float = 0.0
	for item in items:
		total_weight += item.get("weight", 1.0)
	if total_weight <= 0.0:
		return {}
	var roll := randf() * total_weight
	var accum: float = 0.0
	for item in items:
		accum += item.get("weight", 1.0)
		if roll <= accum:
			return item
	return items[-1] if items.size() > 0 else {}


# ============================================================
# 触发检测
# ============================================================
func _on_building_damaged(_amount, _attacker) -> void:
	if _building == null or not is_instance_valid(_building):
		return
	var hp_ratio: float = _building.health.hp / float(_building.health.max_hp)

	# 40% 强制触发（无视CD）
	if hp_ratio <= trigger_hp_low and not _triggered_40:
		_triggered_40 = true
		_force_release()
		return

	# 75% 首次触发（受CD限制）
	if hp_ratio <= trigger_hp_high and not _triggered_75:
		_triggered_75 = true
		_try_release()


# ============================================================
# 释放逻辑
# ============================================================
func _try_release() -> void:
	if release_timer > 0.0:
		return
	if garrison.is_empty():
		return
	var batch := mini(release_batch_size, garrison.size())
	_queue_release(batch)
	release_timer = release_cooldown


func _force_release() -> void:
	if garrison.is_empty():
		return
	var batch := mini(release_batch_size, garrison.size())
	_queue_release(batch)


func _queue_release(count: int) -> void:
	for i in count:
		if garrison.is_empty():
			break
		_release_queue.append(garrison.pop_front())
	_release_interval_timer = 0.0  # 立即开始释放第一个


func _process_release_queue(delta: float) -> void:
	if _release_queue.is_empty():
		return
	_release_interval_timer += delta
	if _release_interval_timer >= release_interval:
		_release_interval_timer = 0.0
		var unit_data: Dictionary = _release_queue.pop_front()
		_spawn_garrison_unit(unit_data)


func _spawn_garrison_unit(data: Dictionary) -> void:
	var unit_type: int = data.get("type", 0)
	var stats_id: StringName = StringName(data.get("stats_id", ""))
	# 选择场景
	var scene_path: String = ""
	if stats_id != &"":
		scene_path = D.ENEMY_VARIANT_SCENES.get(stats_id, "")
	if scene_path == "":
		scene_path = D.UNIT_SCENES.get(unit_type, "")
	if scene_path == "":
		return
	var unit_scene := load(scene_path)
	if unit_scene == null:
		return
	var unit: CharacterBody2D = unit_scene.instantiate()
	# 继承建筑的势力字段（alliance_id setter 同步 team）
	unit.set("alliance_id", _building.alliance_id)
	unit.set("owner_id", _building.owner_id)
	unit.set("faction_color", _building.faction_color)
	unit.set("slot_id", _building.slot_id)
	# 分配 net_id 并注册（同 building.gd._spawn_produced_unit）
	var _main := get_tree().current_scene
	if _main and "spawner_module" in _main and _main.spawner_module:
		unit.net_id = _main.spawner_module._next_net_id
		_main.spawner_module._next_net_id += 1
		LockstepSync.register_unit(unit)
	# 找到建筑旁的有效出生位置
	var spawn_pos: Vector2 = _building._find_valid_spawn_position(16.0)
	unit.position = spawn_pos
	# 找父节点
	var main_node := get_tree().current_scene
	var parent_node := main_node.get_node_or_null("EnemyUnits")
	if parent_node == null:
		unit.queue_free()
		return
	parent_node.add_child(unit)
	# 逃出建筑检测
	if unit.has_method("_start_escape") and unit.has_method("_is_inside_any_building"):
		if unit._is_inside_any_building():
			unit._start_escape()
	# 召唤特效
	var dust := D.DustEffectScene.instantiate()
	main_node.add_child(dust)
	dust.global_position = unit.global_position
	# 加入组
	unit.add_to_group("enemy_units")
	# 连接死亡信号
	if main_node.has_method("_on_unit_died"):
		unit.connect("died", Callable(main_node, "_on_unit_died"))
	# 添加AI
	var ai := Node2D.new()
	ai.name = "EnemyAI"
	ai.set_script(load("res://scripts/units/enemy_ai.gd"))
	unit.add_child(ai)


# ============================================================
# 外部接口
# ============================================================
func alert_from_ally() -> void:
	_try_release()


## 强制释放全部驻军（供据点指挥官 release_garrison 法术调用）
## 一次性把当前 garrison 全部推入 _release_queue，由 _process_release_queue 逐个生成
func force_release_all() -> void:
	if _disabled or garrison.is_empty():
		return
	while not garrison.is_empty():
		_release_queue.append(garrison.pop_front())
	_release_interval_timer = 0.0  # 立即开始释放第一个


func get_garrison_count() -> int:
	return garrison.size() + _release_queue.size()


func _on_building_died(_building) -> void:
	# 被摧毁时不释放，奖励玩家处理得快
	garrison.clear()
	_release_queue.clear()
	if _garrison_bar:
		_garrison_bar.queue_free()
		_garrison_bar = null


# ============================================================
# UI — 驻军数量条
# ============================================================
func _create_garrison_bar() -> void:
	if _building == null or not is_instance_valid(_building):
		return
	_garrison_bar = ProgressBar.new()
	_garrison_bar.max_value = max_capacity
	_garrison_bar.value = 0
	_garrison_bar.show_percentage = false
	_garrison_bar.custom_minimum_size = Vector2(0, 4)
	# 位置：在HP条下方
	var hp_bar: ProgressBar = _building.get_node_or_null("HPBar")
	if hp_bar:
		_garrison_bar.offset_left = hp_bar.offset_left
		_garrison_bar.offset_right = hp_bar.offset_right
		_garrison_bar.offset_top = hp_bar.offset_bottom + 2.0
		_garrison_bar.offset_bottom = hp_bar.offset_bottom + 6.0
	# 样式
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
	bg_style.set_corner_radius_all(1)
	_garrison_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.3, 0.7, 1.0, 0.9)  # 蓝色表示驻军
	fill_style.set_corner_radius_all(1)
	_garrison_bar.add_theme_stylebox_override("fill", fill_style)

	_building.add_child(_garrison_bar)


func _update_garrison_bar() -> void:
	if _garrison_bar == null or not is_instance_valid(_garrison_bar):
		return
	_garrison_bar.value = get_garrison_count()
