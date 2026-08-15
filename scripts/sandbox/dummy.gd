extends CharacterBody2D
## 沙盒木桩：静态可被打靶。无移动、无反击、无 AI。
## 接口对齐 unit.gd 的最小子集（take_damage / is_dead / stats_data），
## 让攻击方的命中判定与伤害飘字路径照常工作。

signal died(unit)

const HealthComp := preload("res://scripts/core/health_component.gd")

var health: Node
var team: int = 1  # 木桩算敌方阵营，玩家单位 attack-move 会打它
var alliance_id: int = 1
var unit_type: int = -1
var stats_data = null

@export var max_hp: int = 500:
	set(v):
		max_hp = v
		if is_node_ready() and health != null:
			health.setup(max_hp, $HPBar, 1)


func _ready() -> void:
	health = HealthComp.new()
	health.name = "HealthComponent"
	add_child(health)
	health.setup(max_hp, $HPBar, 1)
	health.died.connect(_on_died)


func take_damage(amount: int, _attacker = null) -> void:
	if health == null or health.is_dead():
		return
	health.take_damage(amount)


func is_dead() -> bool:
	return health != null and health.is_dead()


func _on_died(entity) -> void:
	died.emit(self)
	queue_free()
