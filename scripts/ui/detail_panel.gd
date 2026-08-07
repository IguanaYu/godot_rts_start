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

# 升级进度轮询
var _age_upgrade_active: bool = false


func initialize(main_node: Node2D) -> void:
	_main_node = main_node
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	show_default()


func _build_ui() -> void:
	# 不加背景底板，WoodTable 由底部 UI 条的区段提供
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 10
	vbox.offset_right = -10
	vbox.offset_top = 6
	vbox.offset_bottom = -6
	vbox.add_theme_constant_override("separation", 6)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)

	# 标题
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_title_label.add_theme_constant_override("shadow_offset_x", 1)
	_title_label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(_title_label)

	vbox.add_child(HSeparator.new())

	# 现状区
	var section_label_1 := _make_section_label("现状")
	vbox.add_child(section_label_1)
	_content_vbox = VBoxContainer.new()
	_content_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_content_vbox)

	# 科技区（PR-T2-4 接入，本 PR 占位）
	vbox.add_child(HSeparator.new())
	var section_label_2 := _make_section_label("科技 / 升级")
	vbox.add_child(section_label_2)
	_tech_vbox = VBoxContainer.new()
	_tech_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_tech_vbox)


func _make_section_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = "  " + text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	return lbl


func _clear_content() -> void:
	for c in _content_vbox.get_children():
		c.queue_free()


func _clear_tech() -> void:
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


# ============================================================
# L2: 点单个建筑
# ============================================================
func show_building(building) -> void:
	_current_mode = Mode.BUILDING
	_permanent_building = building
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
		BuildingScript.BuildingType.FARM:
			_add_info_line("产能: 20 金 / 10s")
			_add_info_line("完成反还: 100 金")
		BuildingScript.BuildingType.TOWER:
			_add_info_line("攻击: %d DMG / %.0f 射程" % [int(building.attack_damage), building.attack_range])
		BuildingScript.BuildingType.WALL:
			pass  # 只显示 HP


func _building_title(btype: int) -> String:
	match btype:
		BuildingScript.BuildingType.CASTLE: return "城堡 (主基地)"
		BuildingScript.BuildingType.BARRACKS: return "兵营"
		BuildingScript.BuildingType.ARCHERY: return "靶场"
		BuildingScript.BuildingType.FARM: return "农场"
		BuildingScript.BuildingType.TOWER: return "箭塔"
		BuildingScript.BuildingType.WALL: return "城墙"
		_: return "建筑"


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
	btn.add_theme_font_size_override("font_size", 13)
	btn.disabled = _main_node.gold < cost
	btn.pressed.connect(func(): _main_node._quick_produce_unit(mode))
	_tech_vbox.add_child(btn)


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

	_title_label.text = _unit_title(unit.unit_type)

	# HP
	_add_info_line("血量: %d / %d" % [unit.health.hp, unit.health.max_hp])

	# 战斗属性
	var dmg = unit.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
	var rng = unit.stat_set.get_value(StatSetClass.ATTACK_RANGE)
	var cd = unit.stat_set.get_value(StatSetClass.ATTACK_COOLDOWN)
	var spd = unit.stat_set.get_value(StatSetClass.MOVE_SPEED)
	_add_info_line("攻击: %d DMG / %.0f 射程 / %.1fs 攻速" % [dmg, rng, cd])
	_add_info_line("移速: %.0f" % spd)

	# 单兵等级（占位）
	if unit.has_method("get_upgrade_level"):
		_add_info_line("单兵等级: %d" % unit.get_upgrade_level())

	# PR-T2-4 全局升级占位
	var tech_lbl := Label.new()
	tech_lbl.text = "(T2 全局升级待接入)"
	tech_lbl.add_theme_font_size_override("font_size", 12)
	tech_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	_tech_vbox.add_child(tech_lbl)


func _unit_title(utype: int) -> String:
	match utype:
		UnitScript.UnitType.SOLDIER: return "步兵"
		UnitScript.UnitType.ARCHER: return "弓兵"
		UnitScript.UnitType.LANCER: return "枪兵"
		UnitScript.UnitType.MONK: return "僧侣"
		_: return "单位"


# ============================================================
# 多选单位 → 汇总
# ============================================================
func show_units_multi(units: Array) -> void:
	_current_mode = Mode.UNIT
	_permanent_building = null
	_permanent_units = units.duplicate()
	_clear_content()
	_clear_tech()

	# 过滤无效单位
	var valid_units: Array = []
	for u in units:
		if u != null and is_instance_valid(u) and not u.is_dead():
			valid_units.append(u)

	if valid_units.is_empty():
		show_default()
		return

	var count := valid_units.size()
	var total_hp := 0
	var total_max_hp := 0
	var total_atk := 0
	var total_spd := 0.0
	var type_counts := {}

	for u in valid_units:
		if u.health:
			total_hp += u.health.hp
			total_max_hp += u.health.max_hp
		if u.stat_set:
			total_atk += u.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
			total_spd += u.stat_set.get_value(StatSetClass.MOVE_SPEED)
		var ut: int = u.unit_type
		var name_str := _unit_title(ut)
		type_counts[name_str] = type_counts.get(name_str, 0) + 1

	_title_label.text = "选中 %d 个单位" % count

	_add_info_line("总血量: %d / %d" % [total_hp, total_max_hp])
	if count > 0:
		_add_info_line("平均攻击: %d DMG" % int(total_atk / count))
		_add_info_line("平均移速: %.0f" % (total_spd / count))

	# 类型明细
	for name_str in type_counts:
		_add_info_line("  %s x%d" % [name_str, type_counts[name_str]], Color(0.7, 0.85, 1.0))


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