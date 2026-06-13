class_name BossAI
extends Node

## Boss AI：治疗周围敌军 + 召唤小兵 + 护盾减伤

@export var heal_radius: float = 200.0
@export var heal_amount: float = 50.0
@export var heal_cooldown: float = 25.0
@export var summon_groups: Array[Dictionary] = []  # [{"type": 0, "count": 4}]
@export var summon_cooldown: float = 30.0
@export var summon_range: float = 80.0
@export var shield_buildings: Array[NodePath] = []
@export var shield_damage_reduction: float = 0.95

var game_controller: Node2D = null
var _boss_unit: CharacterBody2D = null
var _heal_timer: float = 0.0
var _summon_timer: float = 0.0
var _shield_alive: int = 0
var _shield_active: bool = true
const StatSetClass := preload("res://scripts/stats/stat_set.gd")

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_boss_unit = get_parent() as CharacterBody2D
	if _boss_unit == null:
		push_error("BossAI: Parent must be a CharacterBody2D (the boss unit)")
		return

	# 设置护盾减伤
	add_to_group("boss_ai")
	_setup_shield()
	# 初始化计时器为冷却时间，让 Boss 首次使用技能延迟
	_heal_timer = heal_cooldown * 0.5
	_summon_timer = summon_cooldown * 0.5

func set_game_controller(gc: Node2D) -> void:
	game_controller = gc

func _process(delta: float) -> void:
	if _boss_unit == null or not is_instance_valid(_boss_unit):
		return
	if _boss_unit.has_method("is_dead") and _boss_unit.is_dead():
		set_process(false)
		return

	_heal_timer += delta
	_summon_timer += delta

	if _heal_timer >= heal_cooldown:
		_heal_timer = 0.0
		_do_heal()

	if _summon_timer >= summon_cooldown:
		_summon_timer = 0.0
		_do_summon()

func _do_heal() -> void:
	var boss_pos: Vector2 = _boss_unit.global_position
	for u: Node in get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(u) or not u is CharacterBody2D:
			continue
		if u.has_method("is_dead") and u.is_dead():
			continue
		var dist: float = boss_pos.distance_to(u.global_position)
		if dist <= heal_radius:
			u.call("heal", int(heal_amount))
	# Boss 自身也回血
	_boss_unit.call("heal", int(heal_amount * 0.5))

func _do_summon() -> void:
	if game_controller == null or not game_controller.has_method("spawn_unit_near"):
		return
	var boss_pos: Vector2 = _boss_unit.global_position
	for g: Dictionary in summon_groups:
		var type: int = g.get("type", 0)
		var count: int = g.get("count", 1)
		for _i: int in count:
			game_controller.call("spawn_unit_near", type, boss_pos, 1)

func _setup_shield() -> void:
	_shield_alive = 0
	for np: NodePath in shield_buildings:
		var building: Node = get_node_or_null(np)
		if building != null:
			_shield_alive += 1
			if building.has_signal("died"):
				building.died.connect(_on_shield_building_died)

	if _shield_alive > 0:
		_apply_shield()
	else:
		_shield_active = false

func _apply_shield() -> void:
	_shield_active = true
	if _boss_unit and _boss_unit.has_method("get") and _boss_unit.get("stat_set") != null:
		var ss = _boss_unit.get("stat_set")
		if ss and ss.has_method("add_modifier"):
			ss.add_modifier("boss_shield", StatSetClass.DAMAGE_REDUCTION, shield_damage_reduction, 1.0)

func _remove_shield() -> void:
	_shield_active = false
	if _boss_unit and is_instance_valid(_boss_unit) and _boss_unit.has_method("get") and _boss_unit.get("stat_set") != null:
		var ss = _boss_unit.get("stat_set")
		if ss and ss.has_method("remove_source"):
			ss.remove_source("boss_shield")

func _on_shield_building_died(_building: Node) -> void:
	_shield_alive -= 1
	if _shield_alive <= 0:
		_remove_shield()
