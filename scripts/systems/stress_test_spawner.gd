@tool
extends Node
## 压力测试用 spawner：在 _ready 时批量生成单位方阵。
## 挂在场景里的 Node 节点上，参数化配置方阵尺寸/间距/起始位置/阵营。
## 自己处理 team / faction_color / group / EnemyAI / died 信号，不依赖 main.gd 的 _init_preplaced_units。

const UnitScene := preload("res://scenes/units/soldier.tscn")
const EnemyAIScript := preload("res://scripts/units/enemy_ai.gd")
const FactionClass := preload("res://scripts/faction.gd")

@export_range(0, 1) var team: int = 0  # 0=PLAYER, 1=ENEMY
@export var rows: int = 15
@export var cols: int = 20
@export var spacing: float = 35.0
@export var origin: Vector2 = Vector2.ZERO  # 方阵左上角世界坐标


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var root := get_tree().current_scene
	# 压力测试默认关掉伤害飘字（每个飘字 = 5 Label + 1 Tween，AOE 时累积爆炸）
	if "show_damage_numbers" in root:
		root.show_damage_numbers = false
		print("[StressSpawner] 关闭伤害飘字以减小压力")
	var parent_name := "PlayerUnits" if team == 0 else "EnemyUnits"
	var parent_node := root.get_node_or_null(parent_name)
	if parent_node == null:
		push_error("[StressSpawner] 找不到 %s 节点" % parent_name)
		return

	var faction_color: int = FactionClass.ColorId.BLUE if team == 0 else FactionClass.ColorId.RED
	var group_name := "player_units" if team == 0 else "enemy_units"
	var alliance: int = 0 if team == 0 else 1

	for row in range(rows):
		for col in range(cols):
			var unit := UnitScene.instantiate()
			unit.team = team
			unit.alliance_id = alliance
			unit.faction_color = faction_color
			parent_node.add_child(unit)
			unit.global_position = origin + Vector2(col * spacing, row * spacing)
			unit.add_to_group(group_name)
			if team == 1:
				var ai := Node2D.new()
				ai.name = "EnemyAI"
				ai.set_script(EnemyAIScript)
				unit.add_child(ai)
			if root.has_method("_on_unit_died"):
				unit.connect("died", Callable(root, "_on_unit_died"))

	print("[StressSpawner] team=%d spawned=%d" % [team, rows * cols])
