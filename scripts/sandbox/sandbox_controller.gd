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
const D := preload("res://scripts/systems/game_data.gd")
const SPAWN_SPACING := 35.0
const DRAG_THRESHOLD := 8.0

var show_damage_numbers: bool = true
## unit.gd::_spawn_arrow 经 current_scene.spawner_module 发射弹道，沙盒挂一个最小实例
var spawner_module: Node

# PR-4 建筑沙盒兼容：building.gd 直接读写 current_scene 的这些字段/方法
var _units_trained := 0
var gold := 1000

var _player_units: Node2D
var _enemy_units: Node2D
var _targets: Node2D
var _buildings: Node2D

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
var _pool_stats_label: Label
var _pool_stats_accum: float = 0.0
# PR-4: 建筑占格 + 模拟升级
var _occupied: Dictionary = {}          # Vector2i -> true
var _sim_upgrades: Array = []           # {building, t, dur}
var _building_debug_box: VBoxContainer = null


func _ready() -> void:
	_player_units = $PlayerUnits
	_enemy_units = $EnemyUnits
	_targets = $Targets
	_buildings = $Buildings
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
	top_bar.add_child(_make_top_button("池", _toggle_pool_stats))
	# PR-3 调试按钮：对选中单位施加状态/事件，验证 UnitVisualFeedback
	top_bar.add_child(_make_top_button("减速", _apply_debug.bind(&"slow")))
	top_bar.add_child(_make_top_button("中毒", _apply_debug.bind(&"poison")))
	top_bar.add_child(_make_top_button("护盾", _apply_debug.bind(&"shield")))
	top_bar.add_child(_make_top_button("受击", _apply_debug.bind(&"hit")))
	top_bar.add_child(_make_top_button("治疗", _apply_debug.bind(&"heal")))
	top_bar.add_child(_make_top_button("狂暴", _apply_debug.bind(&"enrage")))
	top_bar.add_child(_make_top_button("祝福", _apply_debug.bind(&"bless")))
	# PR-4 建筑调试按钮：对选中建筑触发事件（未选建筑时忽略）
	top_bar.add_child(_make_top_button("入队", _apply_building_debug.bind(&"queue")))
	top_bar.add_child(_make_top_button("产金", _apply_building_debug.bind(&"gold")))
	top_bar.add_child(_make_top_button("受击50", _apply_building_debug.bind(&"hit")))
	top_bar.add_child(_make_top_button("施工3s", _apply_building_debug.bind(&"build")))
	top_bar.add_child(_make_top_button("升级5s", _apply_building_debug.bind(&"upgrade")))
	top_bar.add_child(_make_top_button("摧毁", _apply_building_debug.bind(&"destroy")))

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

	# PR-4: 建筑按钮（同一套 toggle/点击放置交互）
	var bld_label := Label.new()
	bld_label.text = "建筑"
	bld_label.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(bld_label)
	for entry in Cfg.SPAWNABLE_BUILDINGS:
		left_vbox.add_child(_make_spawn_button(entry))


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
		if _selected_entry.has("building_type"):
			_spawn_building(world_pos)
		else:
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
		# stats 覆盖：必须在 add_child 前赋（_ready 里 _setup_stats 读取）
		if _selected_entry.has("stats"):
			unit.stats_data = _selected_entry.stats
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
		ParticlePool.spawn("dust", pos)


func _spawn_dummy(center: Vector2) -> void:
	var dummy := Cfg.DUMMY_SCENE.instantiate()
	dummy.max_hp = _selected_entry.hp
	dummy.team = _spawn_team
	var parent := _player_units if _spawn_team == 0 else _enemy_units
	parent.add_child(dummy)
	dummy.global_position = center
	dummy.add_to_group("player_units" if _spawn_team == 0 else "enemy_units")
	dummy.connect("died", _on_spawn_died)
	ParticlePool.spawn("dust", center)


func _on_spawn_died(unit) -> void:
	_selected_units.erase(unit)
	# 沙盒专属：死亡时用池放爆炸演示（正式对局里爆炸只在建筑死亡时触发）
	ParticlePool.spawn("explosion", unit.global_position, {"scale": Vector2(0.8, 0.8)})


# ============================================================
# PR-4: 建筑 spawn + 占格 + 调试事件
# ============================================================

func _spawn_building(world_pos: Vector2) -> void:
	var btype: int = _selected_entry.building_type
	var grid: Vector2i = D.get_building_grid_size(btype)
	# snap 到 64px 网格（建筑中心 = footprint 中心）
	var gpos := Vector2i(floori(world_pos.x / D.GRID_SIZE), floori(world_pos.y / D.GRID_SIZE))
	var offset := Vector2((grid.x - 1) * 32.0, (grid.y - 1) * 32.0)
	var world := Vector2(gpos.x * 64.0 + 32.0 + offset.x, gpos.y * 64.0 + 32.0 + offset.y)
	# 占格检查（左上角为基准，覆盖整个 footprint）
	var origin := gpos - Vector2i((grid.x - 1) / 2, (grid.y - 1) / 2)
	for dy in range(grid.y):
		for dx in range(grid.x):
			if _occupied.has(origin + Vector2i(dx, dy)):
				_show_sandbox_tip("该格已被占用")
				return
	var scene: PackedScene = load(D.BUILDING_SCENES[btype])
	var b := scene.instantiate()
	b.team = _spawn_team
	b.alliance_id = _spawn_team
	b.faction_color = FactionClass.ColorId.BLUE if _spawn_team == 0 else FactionClass.ColorId.RED
	_buildings.add_child(b)
	b.global_position = world
	b.grid_pos = origin
	# 登记占格（死亡时释放）
	for dy in range(grid.y):
		for dx in range(grid.x):
			_occupied[origin + Vector2i(dx, dy)] = b
	b.connect("died", _on_building_died)
	var dim := maxf(float(grid.x), float(grid.y))
	ParticlePool.spawn("dust", world, {"scale": Vector2(dim * 0.8, dim * 0.8)})


func _on_building_died(building) -> void:
	_selected_units.erase(building)
	# 释放占格
	var keys_to_remove: Array = []
	for k in _occupied.keys():
		if _occupied[k] == building:
			keys_to_remove.append(k)
	for k in keys_to_remove:
		_occupied.erase(k)


func _apply_building_debug(action: StringName) -> void:
	var targets: Array = _selected_units.filter(func(u):
		return u != null and is_instance_valid(u) and not u.is_dead() and "building_type" in u)
	if targets.is_empty():
		return
	for b in targets:
		match action:
			&"queue":
				# 按建筑类型选默认兵种 stats_id
				var sid: StringName = &"soldier"
				match int(b.building_type):
					5: sid = &"archer"      # ARCHERY
					4: sid = &"monk"        # MONASTERY
				b.queue_unit(sid)
			&"gold":
				b._produce_gold()
			&"hit":
				b.take_damage(50)
			&"build":
				b.start_construction(3.0)
			&"upgrade":
				_sim_upgrades.append({"building": b, "t": 0.0, "dur": 5.0})
			&"destroy":
				b.die()


func _advance_sim_upgrades(delta: float) -> void:
	for i in range(_sim_upgrades.size() - 1, -1, -1):
		var s: Dictionary = _sim_upgrades[i]
		var b = s.building
		if not is_instance_valid(b) or b.is_dead():
			_sim_upgrades.remove_at(i)
			continue
		s.t += delta
		var ratio: float = clampf(s.t / s.dur, 0.0, 1.0)
		b.set_age_upgrade_progress(ratio)
		if ratio >= 1.0:
			if b.has_method("notify_age_upgrade_completed"):
				b.notify_age_upgrade_completed()
			else:
				b.set_age_upgrade_progress(0.0)
			_sim_upgrades.remove_at(i)


## building.gd::_produce_gold / _refund_gold_on_completion 经 has_method("add_gold") 回调
func add_gold(amount: int) -> void:
	gold += amount


## building.gd::_spawn_unit_by_stats_id 经 has_method("_on_unit_died") 连接单位死亡信号
func _on_unit_died(unit) -> void:
	pass


func _show_sandbox_tip(text: String) -> void:
	var ft := Node2D.new()
	ft.set_script(preload("res://scripts/effects/floating_text.gd"))
	add_child(ft)
	ft.setup(text, Color(1.0, 0.4, 0.3), get_global_mouse_position())


# ============================================================
# PR-3 调试：对选中单位施加状态/事件（验证 UnitVisualFeedback）
# ============================================================
func _apply_debug(action: StringName) -> void:
	var targets: Array = _selected_units.filter(func(u): return u != null and is_instance_valid(u) and not u.is_dead())
	if targets.is_empty():
		return
	for u in targets:
		match action:
			&"slow":
				u.apply_slow(0.6, 5.0)
			&"poison":
				u.apply_poison(8.0, 6.0)
			&"shield":
				u.set_shield_hp(60)
			&"hit":
				u.take_damage(8)  # 无 attacker：验证向上小跳兜底
			&"heal":
				u.heal(10)
			&"enrage":
				_toggle_unit_tint(u, "enrage")
			&"bless":
				_toggle_unit_tint(u, "bless")


var _tint_on := {}
func _toggle_unit_tint(unit, kind: String) -> void:
	var key := str(unit.get_instance_id()) + kind
	var on: bool = not _tint_on.get(key, false)
	_tint_on[key] = on
	var fb: Node = unit.get_node_or_null("UnitVisualFeedback")
	if fb:
		if kind == "enrage":
			fb.set_enraged(on)
		else:
			fb.set_blessed(on)


# ============================================================
# 时间控制
# ============================================================
func _toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused = paused
	_pause_btn.text = "继续" if paused else "暂停"


func _set_time_scale(scale: float) -> void:
	Engine.time_scale = scale


# ============================================================
# 粒子池统计面板（PR-2）：顶栏「池」toggle，节流刷新
# ============================================================
func _toggle_pool_stats() -> void:
	if _pool_stats_label != null:
		_pool_stats_label.queue_free()
		_pool_stats_label = null
		return
	var ui := get_node("SandboxUI")
	_pool_stats_label = Label.new()
	_pool_stats_label.name = "PoolStatsLabel"
	_pool_stats_label.position = Vector2(8, 40)
	_pool_stats_label.add_theme_font_size_override("font_size", 13)
	_pool_stats_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7))
	ui.add_child(_pool_stats_label)
	_pool_stats_accum = 0.3  # 立即刷一次


func _refresh_pool_stats() -> void:
	if _pool_stats_label == null:
		return
	_pool_stats_accum += get_process_delta_time()
	if _pool_stats_accum < 0.3:
		return
	_pool_stats_accum = 0.0
	var lines: Array = []
	var stats: Dictionary = ParticlePool.get_stats()
	for key in stats:
		var s: Dictionary = stats[key]
		lines.append("%s 闲%d/活%d/峰%d/扩%d" % [key, s.idle, s.active, s.peak, s.extra])
	_pool_stats_label.text = "\n".join(lines)


func _reset() -> void:
	get_tree().paused = false
	_pause_btn.text = "暂停"
	Engine.time_scale = 1.0
	_clear_selection()
	_show_detail([])
	ParticlePool.recall_all()
	_sim_upgrades.clear()
	_occupied.clear()
	for container in [_player_units, _enemy_units, _targets, _buildings]:
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
		if "building_type" in unit:
			_add_detail_line("状态: %s" % ("施工中" if not unit.is_constructed else "已建成"))
			return
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
	if "building_type" in unit:
		match int(unit.building_type):
			0: return "城墙"
			1: return "箭塔"
			2: return "城堡"
			3: return "兵营"
			4: return "修道院"
			5: return "靶场"
			6: return "农场"
			7: return "弓兵祭坛"
			8: return "学院"
		return "建筑"
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

	_advance_sim_upgrades(delta)
	_refresh_pool_stats()
