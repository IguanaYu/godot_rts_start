extends Node2D
## 通用持续作用区域：参数化的 DOT（伤害）/ HOT（治疗）区域。
## 由凝固汽油弹 / 毒气云（伤害敌方）/ 维修无人机（治疗友方）共用。

var radius: float = 100.0
var duration: float = 5.0
var amount_per_sec: int = 10  # 正=伤害 负=治疗
var tick_interval: float = 1.0
var target_group: String = "enemy_units"        # "enemy_units" or "player_units"
var affect_buildings: bool = false              # 是否影响建筑（仅伤害场景有意义）
var building_group: String = ""                 # 建筑组（如 "enemy_buildings"）；空=不查建筑
var main_ref: Node2D = null                     # 用于 show_floating_text
var float_text_color: Color = Color(1, 0.3, 0.1)

var _elapsed: float = 0.0
var _tick_acc: float = 0.0


func _process(delta: float) -> void:
	_elapsed += delta
	_tick_acc += delta
	while _tick_acc >= tick_interval and _elapsed <= duration:
		_tick_acc -= tick_interval
		_apply_tick()

	# 最后 2 秒视觉闪烁预警
	if duration - _elapsed < 2.0:
		for child in get_children():
			if child is Sprite2D:
				child.modulate.a = 0.4 + 0.5 * sin(_elapsed * 8.0)

	if _elapsed >= duration:
		queue_free()


func _apply_tick() -> void:
	if main_ref == null or not is_instance_valid(main_ref):
		return
	var tree := get_tree()
	var applied_count := 0
	for unit in tree.get_nodes_in_group(target_group):
		if unit is CharacterBody2D and not unit.health.is_dead():
			if unit.global_position.distance_to(global_position) <= radius:
				if amount_per_sec >= 0:
					unit.take_damage(amount_per_sec)
				else:
					unit.heal(-amount_per_sec)
				applied_count += 1

	if affect_buildings and building_group != "":
		for building in tree.get_nodes_in_group(building_group):
			if building.has_method("is_dead") and not building.is_dead():
				if building.global_position.distance_to(global_position) <= radius:
					var health_node = building.get("health")
					if health_node:
						if amount_per_sec >= 0:
							health_node.take_damage(amount_per_sec)
						else:
							health_node.heal(-amount_per_sec)
						applied_count += 1

	if applied_count > 0 and main_ref.has_method("show_floating_text"):
		var text := "-%d" % amount_per_sec if amount_per_sec >= 0 else "+%d" % (-amount_per_sec)
		main_ref.show_floating_text(text, float_text_color, global_position + Vector2(0, -15))
