@tool
class_name OutpostCommander
extends Node2D
## 据点敌人指挥官节点（设计师在场景中放置）
## - 编辑器：画领地圆圈（实线红 + 中心标记 + 半径标尺），所见即所得
## - 运行时：visible = false，由 OutpostCommanderManager 周期 tick 触发决策
##
## 失败条件：圈内所有敌方建筑被摧毁 → queue_free（指挥官本身不可选中、不可攻击）

const OutpostCommanderConfigClass := preload("res://scripts/outpost/outpost_commander_config.gd")

@export var config: OutpostCommanderConfig = null:
	set(v):
		config = v
		queue_redraw()

# === 运行时状态（不 @export）===
var mana: float = 0.0
var gold: int = 0
var strategy_points: float = 0.0
var current_strategy: StringName = &"defend"
var _tick_accumulator: float = 0.0
var _is_registered: bool = false
var _last_strategy_eval_msec: int = -10000


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	visible = false
	if config != null:
		mana = config.mana_max
		gold = config.gold_max
		strategy_points = float(config.strategy_max)
	_register_to_manager()


func _register_to_manager() -> void:
	var main_node := get_tree().current_scene
	if main_node == null:
		call_deferred("_register_to_manager")
		return
	var manager = main_node.get_node_or_null("OutpostCommanderManager")
	if manager == null:
		call_deferred("_register_to_manager")
		return
	if manager.has_method("register_commander"):
		manager.register_commander(self)
		_is_registered = true


# ============================================================
# 编辑器可视化
# ============================================================
func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var radius: float = 350.0
	if config != null:
		radius = config.territory_radius
	# 实线领地圈
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(1.0, 0.3, 0.3, 0.7), 2.0)
	# 半透明填充
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.3, 0.3, 0.08))
	# 中心标记
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.5, 0.5, 0.9))
	# 半径标尺
	draw_line(Vector2.ZERO, Vector2(radius, 0), Color(1.0, 0.8, 0.3, 0.6), 1.5)


# ============================================================
# Manager 周期调用
# ============================================================
func tick(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if config == null:
		return
	_regen_resources(delta)
	_tick_accumulator += delta
	if _tick_accumulator < 1.0:
		return
	_tick_accumulator = 0.0
	_on_decision_tick()


func _regen_resources(delta: float) -> void:
	mana = minf(mana + (config.mana_max / 60.0) * delta, config.mana_max)
	gold = mini(int(gold + config.gold_regen * delta), config.gold_max)
	strategy_points = minf(strategy_points + config.strategy_regen * delta, float(config.strategy_max))


# P1 阶段：仅打印圈内建筑/单位数，验证归属逻辑
# 后续阶段会扩展为完整决策树
func _on_decision_tick() -> void:
	var buildings := _get_managed_buildings()
	var units := _get_managed_units()
	print("[OutpostCommander:%s] tick: mana=%.0f gold=%d sp=%.1f 圈内 %d 建筑 %d 单位" %
		[_uid_str(), mana, gold, strategy_points, buildings.size(), units.size()])
	# 失败检测：圈内无敌方建筑 → 据点消灭
	if buildings.is_empty():
		print("[OutpostCommander:%s] 圈内无敌方建筑, 据点消灭" % _uid_str())
		_despawn()
		return


func _despawn() -> void:
	var main_node := get_tree().current_scene
	if main_node != null:
		var manager = main_node.get_node_or_null("OutpostCommanderManager")
		if manager != null and manager.has_method("unregister_commander"):
			manager.unregister_commander(self)
	queue_free()


# ============================================================
# 圈内查询
# ============================================================
func _get_managed_buildings() -> Array:
	var result: Array = []
	if config == null:
		return result
	var center: Vector2 = global_position
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if not is_instance_valid(b):
			continue
		if b.global_position.distance_to(center) <= config.territory_radius:
			result.append(b)
	return result


func _get_managed_units() -> Array:
	var result: Array = []
	if config == null:
		return result
	var center: Vector2 = global_position
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(u):
			continue
		if u.global_position.distance_to(center) <= config.territory_radius:
			result.append(u)
	return result


# ============================================================
# 外部接口
# ============================================================
func contains_entity(entity) -> bool:
	if config == null or not is_instance_valid(entity):
		return false
	return entity.global_position.distance_to(global_position) <= config.territory_radius


func get_uid() -> StringName:
	return config.commander_uid if config != null else &""


func _uid_str() -> String:
	if config == null:
		return "<no_config>"
	return String(config.commander_uid)
