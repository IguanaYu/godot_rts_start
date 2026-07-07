extends CanvasLayer
## 大战术释放者测试面板：4 个按钮分别召唤 4 种战术的释放者。
## 点击后在屏幕中央随机位置生成。

const TacticWave := preload("res://resources/tactics/tactic_summon_wave.tres")
const TacticElite := preload("res://resources/tactics/tactic_summon_elite.tres")
const TacticMorale := preload("res://resources/tactics/tactic_morale_boost.tres")
const TacticFinal := preload("res://resources/tactics/tactic_final_summon.tres")

const ReleaserScene := preload("res://scenes/units/grand_tactic_releaser.tscn")
const SoldierScene := preload("res://scenes/units/soldier.tscn")
const EnemyAIScript := preload("res://scripts/units/enemy_ai.gd")
const FactionClass := preload("res://scripts/faction.gd")

const ButtonDefs := [
	{label = "1. 持续召唤", tactic = TacticWave, color = Color(0.65, 0.35, 1.00)},
	{label = "2. 召唤精英", tactic = TacticElite, color = Color(1.00, 0.40, 0.40)},
	{label = "3. 鼓舞士气", tactic = TacticMorale, color = Color(1.00, 0.82, 0.29)},
	{label = "4. 结束召唤", tactic = TacticFinal, color = Color(0.20, 0.90, 1.00)},
]


func _ready() -> void:
	layer = 50
	var panel := PanelContainer.new()
	panel.name = "GTTestPanel"
	panel.position = Vector2(10, 10)
	panel.size = Vector2(180, 180)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "大战术测试"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	for def in ButtonDefs:
		var btn := Button.new()
		btn.text = def.label
		btn.custom_minimum_size = Vector2(160, 28)
		btn.add_theme_color_override("font_color", def.color)
		btn.pressed.connect(_spawn_with_tactic.bind(def.tactic))
		vbox.add_child(btn)


func _spawn_with_tactic(tactic_res: Resource) -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	var enemy_parent := root.get_node_or_null("EnemyUnits")
	if enemy_parent == null:
		push_error("[GTTestPanel] 找不到 EnemyUnits")
		return

	# 在敌方区域随机位置生成
	var pos := Vector2(randf_range(150, 600), randf_range(-300, 300))
	var unit := ReleaserScene.instantiate()
	# add_child 之前注入 tactic，让 _ready() 能读到
	var ai := unit.get_node_or_null("GrandTacticReleaserAI")
	if ai:
		ai.set("tactic", tactic_res)
	enemy_parent.add_child(unit)
	unit.global_position = pos
	# 兜底：scene 设了但再加一次保险
	unit.team = 1
	unit.alliance_id = 1
	unit.faction_color = FactionClass.ColorId.RED
	unit.add_to_group("enemy_units")

	# 注册死亡信号
	if root.has_method("_on_unit_died") and unit.has_signal("died"):
		unit.died.connect(root._on_unit_died)
	print("[GTTestPanel] 召唤释放者 @ %s，战术=%s" % [pos, tactic_res.tactic_name])

	# 鼓舞士气需要同队单位在范围内才能看到效果，配套刷 3 个敌方士兵做光环目标
	if tactic_res == TacticMorale:
		_spawn_aura_subjects(enemy_parent, pos, root)


func _spawn_aura_subjects(enemy_parent: Node, center: Vector2, root: Node) -> void:
	# 在释放者周围 100-200 距离生成 3 个敌方士兵，让 aura 有 buff 目标
	var offsets := [Vector2(-150, -80), Vector2(150, -80), Vector2(0, 150)]
	for offset in offsets:
		var minion := SoldierScene.instantiate()
		minion.team = 1
		minion.alliance_id = 1
		minion.faction_color = FactionClass.ColorId.RED
		enemy_parent.add_child(minion)
		minion.global_position = center + offset
		minion.add_to_group("enemy_units")
		# 加 EnemyAI 让他们会主动攻击玩家
		var ai_node := Node2D.new()
		ai_node.name = "EnemyAI"
		ai_node.set_script(EnemyAIScript)
		minion.add_child(ai_node)
		if root.has_method("_on_unit_died") and minion.has_signal("died"):
			minion.died.connect(root._on_unit_died)
	print("[GTTestPanel] 鼓舞士气配套：生成 3 个敌方士兵做光环目标")
