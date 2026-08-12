extends Control
## T2 PR-3: 详情面板（L1-L5 切换）

const D := preload("res://scripts/systems/game_data.gd")
const StatSetClass := preload("res://scripts/stats/stat_set.gd")
const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

# 状态机
enum Mode { DEFAULT, BUILDING, UNIT, TEMPORARY }
var _current_mode: int = Mode.DEFAULT
var _permanent_building = null
var _permanent_units: Array = []
var _saved_mode: int = Mode.DEFAULT

# UI 引用
var _main_node: Node2D
var _title_label: Label
var _content_vbox: VBoxContainer
var _tech_vbox: VBoxContainer

# T3 PR: 左右分栏结构
var _info_column: VBoxContainer
var _command_card: VBoxContainer
var _command_scroll: ScrollContainer
var _age_upgrade_btn: Button = null
var _produce_btns: Array = []

# 升级进度轮询
var _age_upgrade_active: bool = false
# PR-T2-4: 金币变化轮询（刷新升级按钮状态）
var _last_gold: int = -1


func initialize(main_node: Node2D) -> void:
	_main_node = main_node
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	show_default()


func _build_ui() -> void:
	# 不加背景底板，WoodTable 由底部 UI 条的区段提供
	# T3 PR: 左右分栏 — 左=信息区（只读），右=命令卡（时代/造兵/科技，可滚动）
	var root_hbox := HBoxContainer.new()
	root_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_hbox.offset_left = 10
	root_hbox.offset_right = -6
	root_hbox.offset_top = 6
	root_hbox.offset_bottom = -6
	root_hbox.add_theme_constant_override("separation", 8)
	root_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_hbox)

	# === 左半：信息区（只读） ===
	_info_column = VBoxContainer.new()
	_info_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_info_column.size_flags_stretch_ratio = 1.0
	_info_column.add_theme_constant_override("separation", 6)
	_info_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_hbox.add_child(_info_column)

	# 标题
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_title_label.add_theme_constant_override("shadow_offset_x", 1)
	_title_label.add_theme_constant_override("shadow_offset_y", 1)
	_info_column.add_child(_title_label)

	_info_column.add_child(HSeparator.new())

	# 现状区
	var section_label_1 := _make_section_label("现状")
	_info_column.add_child(section_label_1)
	_content_vbox = VBoxContainer.new()
	_content_vbox.add_theme_constant_override("separation", 4)
	_content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_info_column.add_child(_content_vbox)

	# === 右半：命令卡（时代/造兵/科技升级，单列可滚动） ===
	_command_card = VBoxContainer.new()
	_command_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_command_card.size_flags_stretch_ratio = 1.0
	_command_card.add_theme_constant_override("separation", 4)
	_command_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_hbox.add_child(_command_card)

	var section_label_2 := _make_section_label("科技 / 升级")
	_command_card.add_child(section_label_2)

	_command_scroll = ScrollContainer.new()
	_command_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_command_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_command_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_command_card.add_child(_command_scroll)

	_tech_vbox = VBoxContainer.new()
	_tech_vbox.add_theme_constant_override("separation", 4)
	_tech_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_command_scroll.add_child(_tech_vbox)


func _make_section_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = "  " + text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	return lbl


func _clear_content() -> void:
	for c in _content_vbox.get_children():
		c.queue_free()


func _clear_tech() -> void:
	_age_upgrade_btn = null
	_produce_btns.clear()
	for c in _tech_vbox.get_children():
		c.queue_free()


func _add_info_line(text: String, color: Color = Color(0.9, 0.9, 0.9)) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	_content_vbox.add_child(lbl)


# ============================================================
# L1: 默认状态（启动 / 点空地）
# ============================================================
func show_default() -> void:
	_current_mode = Mode.DEFAULT
	_permanent_building = null
	_permanent_units = []
	_clear_content()
	_clear_tech()

	var castle = _main_node.player_castle
	if castle == null or not is_instance_valid(castle):
		_title_label.text = "（无城堡）"
		return

	_title_label.text = "城堡 (主基地)"
	var hp: int = castle.health.hp
	var max_hp: int = castle.health.max_hp
	_add_info_line("血量: %d / %d" % [hp, max_hp])
	_add_info_line("时代: T%d" % _main_node.player_age)
	_add_info_line("产能: 50 金 / 10s")

	# 升级按钮
	_add_age_upgrade_button()


func _add_age_upgrade_button() -> void:
	var next_age = _main_node.player_age + 1
	if next_age not in _main_node.AGE_UPGRADE_COST:
		return
	var cost: int = _main_node.AGE_UPGRADE_COST[next_age]
	var time: float = _main_node.AGE_UPGRADE_TIME[next_age]

	var btn := Button.new()
	btn.text = "升级到 T%d（%d 金 / %.0fs）" % [next_age, cost, time]
	btn.custom_minimum_size = Vector2(0, 36)
	btn.disabled = _main_node.gold < cost or _main_node.age_upgrade_target > 0
	btn.pressed.connect(func(): _main_node._start_age_upgrade())
	_tech_vbox.add_child(btn)
	_age_upgrade_btn = btn


# ============================================================
# L2: 点单个建筑
# ============================================================
func show_building(building, is_peek: bool = false) -> void:
	_current_mode = Mode.BUILDING
	_permanent_building = building
	# PR-T2-5 L9: peek 时保留单位选中，点空地后 restore 仍能恢复单位汇总
	if not is_peek:
		_permanent_units = []
	_clear_content()
	_clear_tech()

	if building == null or not is_instance_valid(building) or building.is_dead():
		show_default()
		return

	var btype: int = building.building_type
	_title_label.text = _building_title(btype)

	# 通用 HP
	_add_info_line("血量: %d / %d" % [building.health.hp, building.health.max_hp])

	# 按类型补字段
	match btype:
		BuildingScript.BuildingType.CASTLE:
			_add_info_line("时代: T%d" % _main_node.player_age)
			_add_info_line("产能: 50 金 / 10s")
			_add_age_upgrade_button()
		BuildingScript.BuildingType.BARRACKS:
			_add_production_progress(building)
			_add_info_line("完成反还: 2 soldier")
			_add_produce_button(D.PlaceMode.SOLDIER)
			_add_produce_button(D.PlaceMode.LANCER)
		BuildingScript.BuildingType.ARCHERY:
			_add_production_progress(building)
			_add_info_line("完成反还: 1 archer")
			_add_produce_button(D.PlaceMode.ARCHER)
		BuildingScript.BuildingType.MONASTERY:
			# T3 PR-1: 修道院生产僧侣（之前缺这个分支，详情面板没有生产按钮）
			_add_production_progress(building)
			_add_info_line("完成反还: 1 monk")
			_add_produce_button(D.PlaceMode.MONK_UNIT)
		BuildingScript.BuildingType.FARM:
			_add_info_line("产能: 20 金 / 10s")
			_add_info_line("完成反还: 100 金")
		BuildingScript.BuildingType.TOWER:
			_add_info_line("攻击: %d DMG / %.0f 射程" % [int(building.attack_damage), building.attack_range])
		BuildingScript.BuildingType.WALL:
			pass  # 只显示 HP
		BuildingScript.BuildingType.ACADEMY:
			_add_t3_research_buttons(building)

	# PR-T2-4: 全局升级按钮（按建筑类型）
	_show_unit_upgrade_section(btype, -1)


func _building_title(btype: int) -> String:
	match btype:
		BuildingScript.BuildingType.CASTLE: return "城堡 (主基地)"
		BuildingScript.BuildingType.BARRACKS: return "兵营"
		BuildingScript.BuildingType.ARCHERY: return "靶场"
		BuildingScript.BuildingType.FARM: return "农场"
		BuildingScript.BuildingType.TOWER: return "箭塔"
		BuildingScript.BuildingType.WALL: return "城墙"
		BuildingScript.BuildingType.ACADEMY: return "学院"
		_: return "建筑"


# T3 PR-2: 学院研究按钮
func _add_t3_research_buttons(building) -> void:
	_add_info_line("T3 升级研究（每项 1000 金，不可更改）")
	var t3_mgr = _main_node.t3_upgrade_manager
	if t3_mgr == null:
		return
	for unit_type in [0, 1, 3, 2]:  # SOLDIER, ARCHER, MONK, LANCER
		var data = t3_mgr.get_upgrade_data(unit_type)
		if data == null:
			continue
		if t3_mgr.is_completed(unit_type):
			var choice_id = t3_mgr.get_selected_choice(unit_type)
			_add_info_line("%s: 已研究 [%s]" % [data.unit_class_label, choice_id])
		else:
			var btn := Button.new()
			btn.text = "%s T3 升级（%d 金）" % [data.unit_class_label, data.cost]
			btn.custom_minimum_size = Vector2(0, 32)
			btn.disabled = _main_node.gold < data.cost
			btn.pressed.connect(func():
				_on_academy_research_clicked(unit_type, data))
			_tech_vbox.add_child(btn)

func _on_academy_research_clicked(unit_type: int, data: Resource) -> void:
	var dialog = _main_node.get_node_or_null("T3ChoiceDialog")
	if dialog != null:
		dialog.show_for_unit(unit_type, data)

func _add_production_progress(building) -> void:
	if building.production_queue.is_empty():
		_add_info_line("在造: 无（队列空）")
		return
	var state: Dictionary = building.get_queue_state()
	var progress: float = 0.0
	if state.total > 0:
		progress = 1.0 - state.remaining / state.total
	_add_info_line("在造: %s (%d%%)" % [state.current, int(progress * 100)])
	_add_info_line("队列: %d / %d" % [building.production_queue.size(), building.queue_max])


func _add_produce_button(mode: int) -> void:
	# 检查是否已解锁
	if int(mode) not in _main_node.unlocked_items:
		return
	var cost: int = D.COSTS.get(mode, 0)
	var name_str: String = tr(D.MODE_NAMES.get(mode, "?"))
	var btn := Button.new()
	btn.text = "造 %s（%d 金）" % [name_str, cost]
	btn.custom_minimum_size = Vector2(0, 32)
	btn.add_theme_font_size_override("font_size", 14)
	btn.disabled = _main_node.gold < cost
	btn.pressed.connect(func():
		if _main_node._quick_produce_unit(mode):
			_main_node.show_floating_text(tr("UU_FEEDBACK_QUEUED"), Color(0.4, 1.0, 0.4), _main_node.get_global_mouse_position()))
	_tech_vbox.add_child(btn)
	_produce_btns.append({"btn": btn, "cost": cost})


# ============================================================
# L3: 点单个单位
# ============================================================
func show_unit(unit) -> void:
	_current_mode = Mode.UNIT
	_permanent_building = null
	_permanent_units = [unit]
	_clear_content()
	_clear_tech()

	if unit == null or not is_instance_valid(unit) or unit.is_dead():
		show_default()
		return

	_title_label.text = _unit_title(unit)

	# HP
	_add_info_line("血量: %d / %d" % [unit.health.hp, unit.health.max_hp])

	# 战斗属性
	var dmg = unit.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
	var rng = unit.stat_set.get_value(StatSetClass.ATTACK_RANGE)
	var cd = unit.stat_set.get_value(StatSetClass.ATTACK_COOLDOWN)
	var spd = unit.stat_set.get_value(StatSetClass.MOVE_SPEED)
	_add_info_line("攻击: %d DMG / %.0f 射程 / %.1fs 攻速" % [dmg, rng, cd])
	_add_info_line("移速: %.0f" % spd)

	# PR-T2-4: 全局升级按钮（按单位类型）
	_show_unit_upgrade_section(-1, unit.unit_type)


func _unit_title(unit) -> String:
	# T3 变体优先用 stats_data.display_name（如 "狂战士"/"神射手"），fallback 基础枚举名
	if unit != null and is_instance_valid(unit):
		if unit.get("stats_data") != null:
			var dn: String = unit.stats_data.get("display_name")
			if dn != "":
				return dn
		match unit.unit_type:
			UnitScript.UnitType.SOLDIER: return "步兵"
			UnitScript.UnitType.ARCHER: return "弓兵"
			UnitScript.UnitType.LANCER: return "枪兵"
			UnitScript.UnitType.MONK: return "僧侣"
	return "单位"


# ============================================================
# PR-T2-4: 全局升级按钮（按目标类型映射）
# ============================================================
func _get_upgrades_for_target(building_type: int, unit_type: int) -> Array:
	var result: Array = []
	if building_type >= 0:
		match building_type:
			BuildingScript.BuildingType.CASTLE:
				result = ["generic_hp", "generic_dmg", "generic_spd", "castle_hp"]
			BuildingScript.BuildingType.BARRACKS:
				result = ["soldier_hp", "generic_hp", "generic_dmg", "generic_spd"]
			BuildingScript.BuildingType.ARCHERY:
				result = ["generic_hp", "generic_dmg", "generic_spd"]
			BuildingScript.BuildingType.FARM:
				result = ["farm_yield", "generic_hp", "generic_dmg", "generic_spd"]
		return result
	match unit_type:
		UnitScript.UnitType.SOLDIER:
			result = ["soldier_hp", "generic_hp", "generic_dmg", "generic_spd"]
		_:
			result = ["generic_hp", "generic_dmg", "generic_spd"]
	return result


func _show_unit_upgrade_section(building_type: int, unit_type: int) -> void:
	if _main_node == null or _main_node.unit_upgrade_manager == null:
		return
	var mgr = _main_node.unit_upgrade_manager
	for node_id in _get_upgrades_for_target(building_type, unit_type):
		var btn := preload("res://scripts/ui/upgrade_button.gd").new()
		btn.name = "UpgradeButton_" + node_id
		btn.setup(node_id, mgr, _main_node)
		_tech_vbox.add_child(btn)


# ============================================================
# 多选单位 → 汇总
# ============================================================
func show_units_multi(units: Array) -> void:
	_current_mode = Mode.UNIT
	_permanent_building = null
	_permanent_units = units.duplicate()
	_clear_content()
	_clear_tech()

	# 过滤无效单位（保留选中顺序）
	var valid_units: Array = []
	for u in units:
		if u != null and is_instance_valid(u) and not u.is_dead():
			valid_units.append(u)

	if valid_units.is_empty():
		show_default()
		return

	# 按单位变体分组（同基础兵种但 T3 变体不同 = 不同组），保序累计 HP/DMG
	# group_key 优先 stats_data.id（如 &"soldier" / &"t3_champion_offense"），fallback "__ut_<type>"
	var groups: Array = []
	var group_by_key := {}
	for i in range(valid_units.size()):
		var u = valid_units[i]
		var gkey
		if u.get("stats_data") != null and u.stats_data.get("id") != null:
			gkey = u.stats_data.id
		else:
			gkey = "__ut_%d" % u.unit_type
		if not group_by_key.has(gkey):
			var g := {"utype": u.unit_type, "name": _unit_title(u), "count": 0, "hp": 0, "dmg": 0, "last_idx": i}
			group_by_key[gkey] = g
			groups.append(g)
		var g: Dictionary = group_by_key[gkey]
		g["count"] += 1
		g["last_idx"] = i
		if u.health:
			g["hp"] += u.health.hp
		if u.stat_set:
			g["dmg"] += u.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)

	# 主类型 = 数量最多；并列取最新选中（last_idx 最大）
	var max_count := 0
	for g in groups:
		if g["count"] > max_count:
			max_count = g["count"]
	var main: Dictionary = {}
	for g in groups:
		if g["count"] == max_count and (main.is_empty() or g["last_idx"] > main["last_idx"]):
			main = g

	_title_label.text = "选中 %d 个单位" % valid_units.size()

	# 每类型块
	for g in groups:
		_add_info_line("▸ %s × %d" % [g["name"], g["count"]], Color(0.7, 0.85, 1.0))
		_add_info_line("  总HP: %d   总DMG: %d" % [g["hp"], g["dmg"]])

	# 科技区按主类型
	_show_unit_upgrade_section(-1, main["utype"])


# ============================================================
# PR-T2-5 L7: 多选同类建筑 → 汇总
# ============================================================
func show_buildings_multi(buildings: Array) -> void:
	_current_mode = Mode.BUILDING
	_permanent_building = null
	_permanent_units = []
	_clear_content()
	_clear_tech()

	# 过滤无效建筑
	var valid: Array = []
	for b in buildings:
		if b != null and is_instance_valid(b) and not b.is_dead():
			valid.append(b)

	if valid.is_empty():
		show_default()
		return

	# 按建筑类型分组（保序）
	var groups: Array = []
	var group_by_type := {}
	for b in valid:
		var bt: int = b.building_type
		if not group_by_type.has(bt):
			var g := {"btype": bt, "name": _building_title(bt), "list": []}
			group_by_type[bt] = g
			groups.append(g)
		group_by_type[bt]["list"].append(b)

	# 主类型 = 数量最多
	var main: Dictionary = groups[0]
	for g in groups:
		if g["list"].size() > main["list"].size():
			main = g

	_title_label.text = "选中 %d 个%s" % [valid.size(), main["name"]]

	# 总血量百分比
	var sum_hp := 0
	var sum_max := 0
	for b in valid:
		if b.health:
			sum_hp += b.health.hp
			sum_max += b.health.max_hp
	if sum_max > 0:
		_add_info_line("总血量: %d%%" % int(float(sum_hp) / float(sum_max) * 100.0))

	# 在造进度汇总（产兵建筑）
	var producing := 0
	for b in valid:
		if b.has_method("get_queue_state") and not b.production_queue.is_empty():
			producing += b.production_queue.size()
	if producing > 0:
		_add_info_line("在造: %d 单位" % producing)
	else:
		_add_info_line("在造: 无（队列空）")

	# 科技区按主类型（同 L2）
	_show_unit_upgrade_section(main["btype"], -1)


# ============================================================
# L4: hover QW 图标 → 临时切换
# ============================================================
func show_temporary_mode(mode: int) -> void:
	_saved_mode = _current_mode
	_clear_content()
	_clear_tech()

	var name_str: String = tr(D.MODE_NAMES.get(mode, "?"))
	_title_label.text = name_str + "（预览）"

	var cost: int = D.COSTS.get(mode, 0)
	if _main_node and _main_node.get("building_placer"):
		cost = _main_node.building_placer.get_current_cost(mode)
	_add_info_line("造价: %d 金" % cost, Color(0.6, 0.6, 0.6))
	if D.is_unit_mode(mode):
		_add_info_line("类型: 单位", Color(0.6, 0.6, 0.6))
	else:
		_add_info_line("类型: 建筑", Color(0.6, 0.6, 0.6))


func restore_previous() -> void:
	match _saved_mode:
		Mode.DEFAULT: show_default()
		Mode.BUILDING: show_building(_permanent_building)
		Mode.UNIT:
			if _permanent_units.size() > 1:
				show_units_multi(_permanent_units)
			elif _permanent_units.size() == 1:
				show_unit(_permanent_units[0])
			else:
				show_default()
		Mode.TEMPORARY: show_default()


# ============================================================
# L5: 升级进度轮询
# ============================================================
func _process(_delta: float) -> void:
	var upgrading: bool = _main_node.age_upgrade_target > 0
	if upgrading != _age_upgrade_active:
		_age_upgrade_active = upgrading
		if upgrading:
			# 升级启动 → 强制切到城堡
			if _current_mode == Mode.UNIT:
				show_default()
			elif _current_mode == Mode.BUILDING and _permanent_building != _main_node.player_castle:
				show_default()
		else:
			# 升级完成/取消 → 刷新城堡数据
			if _current_mode == Mode.DEFAULT:
				show_default()

	# PR-T2-4: 金币变化 → 刷新升级按钮（可买/金币不够状态）
	if _main_node != null and _main_node.gold != _last_gold:
		_last_gold = _main_node.gold
		for c in _tech_vbox.get_children():
			if c.has_method("refresh"):
				c.refresh()
		_refresh_command_buttons()


func _refresh_command_buttons() -> void:
	if _main_node == null:
		return
	var gold: int = _main_node.gold
	if _age_upgrade_btn != null:
		var next_age = _main_node.player_age + 1
		if next_age in _main_node.AGE_UPGRADE_COST:
			var cost: int = _main_node.AGE_UPGRADE_COST[next_age]
			_age_upgrade_btn.disabled = gold < cost or _main_node.age_upgrade_target > 0
	for entry in _produce_btns:
		entry.btn.disabled = gold < entry.cost