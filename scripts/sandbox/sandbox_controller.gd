extends Node2D
## 特效测试沙盒主控（PR-0）：spawn 单位/木桩 + 阵营切换 + 时间控制 + 框选/详情 + 重置。
## 独立场景 F6 运行，不接 main.gd。伤害飘字经 show_damage_number() 被 unit.gd 回调。

const Cfg := preload("res://scripts/sandbox/sandbox_config.gd")
const FactionClass := preload("res://scripts/faction.gd")
const EnemyAIScript := preload("res://scripts/units/enemy_ai.gd")
const StatSetClass := preload("res://scripts/stats/stat_set.gd")
const DummyScript := preload("res://scripts/sandbox/dummy.gd")

const DAMAGE_NUMBER_SCRIPT := preload("res://scripts/effects/damage_number.gd")
const SpawnerScript := preload("res://scripts/systems/game_spawner.gd")
const SPAWN_SPACING := 35.0
const DRAG_THRESHOLD := 8.0

var show_damage_numbers: bool = true
## unit.gd::_spawn_arrow 经 current_scene.spawner_module 发射弹道，沙盒挂一个最小实例
var spawner_module: Node

var _player_units: Node2D
var _enemy_units: Node2D
var _targets: Node2D

# UI
var _unit_buttons_box: VBoxContainer
var _count_option: OptionButton
var _faction_option: OptionButton
var _detail_title: Label
var _detail_box: VBoxContainer
var _detail_panel: PanelContainer
var _pause_btn: Button
var _selection_box: ColorRect

# 状态
var _selected_entry: Dictionary = {}   # 当前选中的可放置项
var _selected_units: Array = []        # 框选/点选的单位
var _spawn_count: int = 5
var _spawn_team: int = 0
var _drag_start: Vector2 = Vector2(INF, INF)
var _detail_refresh_accum: float = 0.0


func _ready() -> void:
	_player_units = $PlayerUnits
	_enemy_units = $EnemyUnits
	_targets = $Targets
	spawner_module = Node.new()
	spawner_module.name = "SandboxSpawnerModule"
	spawner_module.set_script(SpawnerScript)
	add_child(spawner_module)
	spawner_module.initialize(self, _player_units, _enemy_units, _targets)
	_build_selection_box()
	_build_ui()


func _build_selection_box() -> void:
	_selection_box = ColorRect.new()
	_selection_box.name = "SelectionBox"
	_selection_box.visible = false
	_selection_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selection_box.color = Color(0.4, 0.7, 1, 0.25)
	_selection_box.z_index = 50
	add_child(_selection_box)


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.name = "SandboxUI"
	ui.layer = 10
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui)

	# === 顶栏：时间控制 + 重置 ===
	var top_bar := HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.position = Vector2(8, 8)
	top_bar.add_theme_constant_override("separation", 8)
	ui.add_child(top_bar)

	_pause_btn = _make_top_button("暂停", _toggle_pause)
	top_bar.add_child(_pause_btn)
	top_bar.add_child(_make_top_button("1x", _set_time_scale.bind(1.0)))
	top_bar.add_child(_make_top_button("0.5x", _set_time_scale.bind(0.5)))
	top_bar.add_child(_make_top_button("2x", _set_time_scale.bind(2.0)))
	top_bar.add_child(_make_top_button("重置", _reset))

	# === 左面板：阵营 + 数量 + 单位按钮 ===
	var left_panel := PanelContainer.new()
	left_panel.name = "LeftPanel"
	left_panel.position = Vector2(8, 52)
	left_panel.size = Vector2(200, 660)
	ui.add_child(left_panel)

	var left_scroll := ScrollContainer.new()
	left_scroll.name = "UnitButtonScroll"
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left_panel.add_child(left_scroll)

	var left_vbox := VBoxContainer.new()
	left_vbox.name = "UnitButtonBox"
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.add_theme_constant_override("separation", 4)
	left_scroll.add_child(left_vbox)
	_unit_buttons_box = left_vbox

	var faction_label := Label.new()
	faction_label.text = "阵营"
	faction_label.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(faction_label)

	_faction_option = OptionButton.new()
	_faction_option.name = "FactionOption"
	_faction_option.add_item("玩家（蓝）")
	_faction_option.add_item("敌方（红）")
	_faction_option.item_selected.connect(func(idx: int): _spawn_team = idx)
	left_vbox.add_child(_faction_option)

	var count_label := Label.new()
	count_label.text = "数量"
	count_label.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(count_label)

	_count_option = OptionButton.new()
	_count_option.name = "SpawnCountOption"
	for n in [1, 5, 10, 20]:
		_count_option.add_item(str(n))
	_count_option.selected = 1
	_count_option.item_selected.connect(func(idx: int): _spawn_count = [1, 5, 10, 20][idx])
	left_vbox.add_child(_count_option)

	for entry in Cfg.SPAWNABLE_UNITS:
		left_vbox.add_child(_make_spawn_button(entry))
	for d in Cfg.SPAWNABLE_DUMMIES:
		var dummy_entry := { "name": "木桩 HP%d" % d.hp, "hp": d.hp }
		left_vbox.add_child(_make_spawn_button(dummy_entry))


func _make_top_button(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.name = "TopBtn_" + text
	btn.text = text
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(cb)
	return btn


func _make_spawn_button(entry: Dictionary) -> Button:
	var btn := Button.new()
	btn.name = "SpawnBtn_" + str(entry.name)
	btn.text = str(entry.name)
	btn.add_theme_font_size_override("font_size", 14)
	btn.toggle_mode = true
	btn.toggled.connect(func(on: bool):
		if on:
			_selected_entry = entry
			_clear_selection()
			_show_detail([])
		elif _selected_entry == entry:
			_selected_entry = {}
			btn.set_pressed_no_signal(true)  # 不允许取消选中，只能切换
	)
	return btn


func _refresh_button_states() -> void:
	for c in _unit_buttons_box.get_children():
		if c is Button and c.name.begins_with("SpawnBtn_"):
			var entry_name: String = c.name.substr("SpawnBtn_".length())
			c.set_pressed_no_signal(_selected_entry.get("name", "") == entry_name)


# ============================================================
# 输入：左键 = 点击 spawn/选单位，拖拽 = 框选；右键 = attack-move
# ============================================================
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_start = get_global_mouse_position()
		else:
			_finish_drag_or_click()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_order_attack_move(get_global_mouse_position())


func _finish_drag_or_click() -> void:
	if _drag_start.x == INF:
		return
	var end := get_global_mouse_position()
	var rect := Rect2(_drag_start, end - _drag_start).abs()
	_drag_start = Vector2(INF, INF)
	if rect.size.length() > DRAG_THRESHOLD:
		_select_in_rect(rect)
	else:
		battlefield_click(rect.position)


func battlefield_click(world_pos: Vector2) -> void:
	var picked: Node = _pick_unit(world_pos)
	if picked != null:
		_clear_selection()
		_selected_units = [picked]
		picked.set_selected(true)
		_selected_entry = {}
		_refresh_button_states()
		_show_detail(_selected_units)
	elif not _selected_entry.is_empty():
		_spawn_formation(world_pos)


func _pick_unit(world_pos: Vector2):
	var params := PhysicsPointQueryParameters2D.new()
	params.position = world_pos
	params.collide_with_areas = false
	params.collide_with_bodies = true
	var hits := get_world_2d().direct_space_state.intersect_point(params, 1)
	if hits.is_empty():
		return null
	var collider = hits[0].collider
	if collider != null and collider.has_method("is_dead"):
		return collider
	return null


func _select_in_rect(rect: Rect2) -> void:
	var found: Array = []
	for c in _player_units.get_children():
		if rect.has_point(c.global_position):
			found.append(c)
	if found.is_empty():
		for c in _enemy_units.get_children():
			if rect.has_point(c.global_position):
				found.append(c)
	if found.is_empty():
		_clear_selection()
		_show_detail([])
		return
	_clear_selection()
	_selected_units = found
	for u in found:
		u.set_selected(true)
	_selected_entry = {}
	_refresh_button_states()
	_show_detail(found)


func _clear_selection() -> void:
	for u in _selected_units:
		if is_instance_valid(u) and u.has_method("set_selected"):
			u.set_selected(false)
	_selected_units = []


func _order_attack_move(pos: Vector2) -> void:
	for u in _selected_units:
		if is_instance_valid(u) and u.team == 0 and not u.is_dead():
			u.attack_move_to(pos)


# ============================================================
# Spawn
# ============================================================
func _spawn_formation(center: Vector2) -> void:
	if _selected_entry.has("hp"):
		_spawn_dummy(center)
		return
	var scene: PackedScene = _selected_entry.scene
	var count: int = _spawn_count
	var cols := ceili(sqrt(float(count)))
	var faction_color: int = FactionClass.ColorId.BLUE if _spawn_team == 0 else FactionClass.ColorId.RED
	var group_name := "player_units" if _spawn_team == 0 else "enemy_units"
	var parent := _player_units if _spawn_team == 0 else _enemy_units

	for i in range(count):
		var offset := Vector2(i % cols, i / cols) - Vector2(cols - 1, cols - 1) / 2.0
		var pos := center + offset * SPAWN_SPACING
		var unit := scene.instantiate()
		unit.team = _spawn_team
		unit.alliance_id = _spawn_team
		unit.faction_color = faction_color
		parent.add_child(unit)
		unit.global_position = pos
		unit.add_to_group(group_name)
		unit.connect("died", _on_spawn_died)
		if _spawn_team == 1:
			var ai := Node2D.new()
			ai.name = "EnemyAI"
			ai.set_script(EnemyAIScript)
			unit.add_child(ai)


func _spawn_dummy(center: Vector2) -> void:
	var dummy := Cfg.DUMMY_SCENE.instantiate()
	dummy.max_hp = _selected_entry.hp
	dummy.team = _spawn_team
	var parent := _player_units if _spawn_team == 0 else _enemy_units
	parent.add_child(dummy)
	dummy.global_position = center
	dummy.add_to_group("player_units" if _spawn_team == 0 else "enemy_units")
	dummy.connect("died", _on_spawn_died)


func _on_spawn_died(unit) -> void:
	_selected_units.erase(unit)


# ============================================================
# 时间控制
# ============================================================
func _toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused = paused
	_pause_btn.text = "继续" if paused else "暂停"


func _set_time_scale(scale: float) -> void:
	Engine.time_scale = scale


func _reset() -> void:
	get_tree().paused = false
	_pause_btn.text = "暂停"
	Engine.time_scale = 1.0
	_clear_selection()
	_show_detail([])
	for container in [_player_units, _enemy_units, _targets]:
		for c in container.get_children():
			c.queue_free()


# ============================================================
# 伤害飘字（unit.gd 经 current_scene 回调）
# ============================================================
func show_damage_number(amount: int, world_pos: Vector2) -> void:
	if not show_damage_numbers:
		return
	var dn := Node2D.new()
	dn.set_script(DAMAGE_NUMBER_SCRIPT)
	add_child(dn)
	dn.setup(amount, world_pos)


# ============================================================
# 详情面板（右下角，只读；单选=详情，多选=分组汇总）
# ============================================================
func _ensure_detail_panel() -> void:
	if _detail_title != null:
		return
	var ui := get_node("SandboxUI")
	_detail_panel = PanelContainer.new()
	_detail_panel.name = "DetailPanel"
	_detail_panel.position = Vector2(880, 580)
	_detail_panel.size = Vector2(300, 132)
	ui.add_child(_detail_panel)
	var vbox := VBoxContainer.new()
	vbox.name = "DetailBox"
	vbox.add_theme_constant_override("separation", 4)
	_detail_panel.add_child(vbox)
	_detail_title = Label.new()
	_detail_title.name = "DetailTitle"
	_detail_title.add_theme_font_size_override("font_size", 16)
	_detail_title.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	vbox.add_child(_detail_title)
	_detail_box = vbox


func _show_detail(units: Array) -> void:
	_ensure_detail_panel()
	for c in _detail_box.get_children():
		if c != _detail_title:
			c.queue_free()

	var valid: Array = []
	for u in units:
		if u != null and is_instance_valid(u) and not u.is_dead():
			valid.append(u)

	if valid.is_empty():
		_detail_title.text = "（未选中单位）"
		return

	if valid.size() == 1:
		var unit = valid[0]
		_detail_title.text = _unit_title(unit)
		_add_detail_line("血量: %d / %d" % [unit.health.hp, unit.health.max_hp])
		if unit.get("stat_set") != null:
			var dmg = unit.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
			var rng = unit.stat_set.get_value(StatSetClass.ATTACK_RANGE)
			var cd = unit.stat_set.get_value(StatSetClass.ATTACK_COOLDOWN)
			var spd = unit.stat_set.get_value(StatSetClass.MOVE_SPEED)
			_add_detail_line("攻击: %d DMG / %.0f 射程 / %.1fs" % [dmg, rng, cd])
			_add_detail_line("移速: %.0f" % spd)
		return

	# 多选：按名称分组汇总
	_detail_title.text = "选中 %d 个单位" % valid.size()
	var order: Array = []
	var groups := {}
	for u in valid:
		var key := _unit_title(u)
		if not groups.has(key):
			groups[key] = {"count": 0, "hp": 0}
			order.append(key)
		groups[key]["count"] += 1
		if u.get("health") != null:
			groups[key]["hp"] += u.health.hp
	for key in order:
		var g: Dictionary = groups[key]
		_add_detail_line("▸ %s × %d  HP %d" % [key, g.count, g.hp], Color(0.7, 0.85, 1.0))


func _add_detail_line(text: String, color: Color = Color(0.9, 0.9, 0.9)) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", color)
	_detail_box.add_child(lbl)


func _unit_title(unit) -> String:
	if unit.get_script() == DummyScript:
		return "木桩"
	if unit.get("stats_data") != null and unit.stats_data != null:
		var dn: String = unit.stats_data.get("display_name")
		if dn != "":
			return dn
	match unit.unit_type:
		0: return "步兵"
		1: return "弓兵"
		2: return "枪兵"
		3: return "僧侣"
	return "单位"


func _process(delta: float) -> void:
	# 拖拽框选矩形跟随
	if _drag_start.x != INF:
		var cur := get_global_mouse_position()
		var rect := Rect2(_drag_start, cur - _drag_start).abs()
		_selection_box.visible = true
		_selection_box.position = rect.position
		_selection_box.size = rect.size

	# 详情面板节流刷新（HP 变化/死亡移除）
	_detail_refresh_accum += delta
	if _detail_refresh_accum >= 0.3:
		_detail_refresh_accum = 0.0
		if not _selected_units.is_empty():
			_selected_units = _selected_units.filter(func(u): return u != null and is_instance_valid(u) and not u.is_dead())
			_show_detail(_selected_units)
