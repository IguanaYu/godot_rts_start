@tool
extends Node
## 大战术释放测试 spawner：参考 stress_test_spawner.gd 模式。
## spawn_kind: 0=玩家方阵 1=玩家小队 2=敌方释放者

const EnemyAIScript := preload("res://scripts/units/enemy_ai.gd")
const FactionClass := preload("res://scripts/faction.gd")

const TacticWave := preload("res://resources/tactics/tactic_summon_wave.tres")

const SoldierScene := preload("res://scenes/units/soldier.tscn")
const ArcherScene := preload("res://scenes/units/archer.tscn")
const ReleaserScene := preload("res://scenes/units/grand_tactic_releaser.tscn")

@export var spawn_kind: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var root := get_tree().current_scene
	if root == null:
		push_error("[GTSpawner] current_scene is null")
		return

	match spawn_kind:
		0: _spawn_player_squad(root)
		1: _spawn_player_squad(root)
		2: _spawn_releaser(root)
		_: push_error("[GTSpawner] unknown spawn_kind=%d" % spawn_kind)


func _spawn_player_squad(root: Node) -> void:
	var parent_node := root.get_node_or_null("PlayerUnits")
	if parent_node == null:
		push_error("[GTSpawner] 找不到 PlayerUnits")
		return
	var positions := [
		Vector2(-300, -80),
		Vector2(-300, -40),
		Vector2(-300, 0),
		Vector2(-300, 40),
		Vector2(-350, -40),
	]
	var scenes := [SoldierScene, SoldierScene, SoldierScene, SoldierScene, ArcherScene]
	for i in range(positions.size()):
		_spawn_unit(parent_node, scenes[i], positions[i], 0, FactionClass.ColorId.BLUE, "player_units")
	print("[GTSpawner] 玩家小队: 5 个单位")


func _spawn_releaser(root: Node) -> void:
	var parent_node := root.get_node_or_null("EnemyUnits")
	if parent_node == null:
		push_error("[GTSpawner] 找不到 EnemyUnits")
		return
	var unit := ReleaserScene.instantiate()
	var ai := unit.get_node_or_null("GrandTacticReleaserAI")
	if ai:
		ai.set("tactic", TacticWave)
	parent_node.add_child(unit)
	unit.global_position = Vector2(300, -300)
	unit.add_to_group("enemy_units")

	# 注册死亡信号
	if root.has_method("_on_unit_died") and unit.has_signal("died"):
		unit.died.connect(root._on_unit_died)
	print("[GTSpawner] 大战术释放者已生成 @ (300, -300)")


func _spawn_unit(parent: Node, scene: PackedScene, pos: Vector2, alliance: int, color: int, group: String) -> void:
	var unit := scene.instantiate()
	unit.team = alliance
	unit.alliance_id = alliance
	unit.faction_color = color
	parent.add_child(unit)
	unit.global_position = pos
	unit.add_to_group(group)
	if alliance == 1:
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(EnemyAIScript)
		unit.add_child(ai)
	var root := get_tree().current_scene
	if root and root.has_method("_on_unit_died") and unit.has_signal("died"):
		unit.died.connect(root._on_unit_died)
