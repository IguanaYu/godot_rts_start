extends Control
## 指挥官选择界面：选关后、进入关卡前选择指挥官 + 配置 loadout/技能/被动
## 由 level_select._on_start_pressed 路由进入
## 确认后写入 CommanderChoice.player_selected_id + SaveManager.last_selected_commander，
## 并通过 MainScript 持久化 loadout/skills/passives，然后加载关卡

const BF := preload("res://scripts/ui/button_factory.gd")
const D := preload("res://scripts/systems/game_data.gd")
const CSD := preload("res://scripts/commander_skill/commander_skill_data.gd")
const UD := preload("res://scripts/upgrade/upgrade_data.gd")
const MainScript := preload("res://scripts/main.gd")

const MAX_LOADOUT := 15       # 单位+建筑共享配额
const MAX_SKILLS := 4
const MAX_PASSIVES := 3

const COLOR_SELECTED_TINT := Color(0.25, 0.45, 0.65, 0.7)
const COLOR_UNIT_TINT := Color(0.2, 0.3, 0.5, 0.45)
const COLOR_BUILDING_TINT := Color(0.4, 0.35, 0.2, 0.45)
const COLOR_SKILL_TINT := Color(0.3, 0.25, 0.4, 0.45)
const COLOR_PASSIVE_TINT := Color(0.25, 0.3, 0.25, 0.45)
const COLOR_CARD_BORDER_SELECTED := Color(1.0, 0.85, 0.3, 1.0)
const COLOR_CARD_BORDER_HOVER := Color(0.75, 0.75, 0.75, 0.6)
const COLOR_CARD_BORDER_IDLE := Color(0.0, 0.0, 0.0, 0.0)

# Tab 索引
const TAB_UNITS := 0
const TAB_BUILDINGS := 1
const TAB_SKILLS := 2
const TAB_PASSIVES := 3

var _selected_id: StringName = &""
var _card_wrappers: Array = []  # Array[Control]
var _confirm_button: Button
var _back_button: Button

# 右列 Tab
var _tab_buttons: Array = []
var _tab_panels: Array = []
var _current_tab: int = TAB_UNITS

# 配置状态
var _selected_loadout: Array = []    # PlaceMode 数组（单位+建筑混合）
var _selected_skills: Array = []     # SkillId 数组
var _selected_passives: Array = []   # UpgradeId 数组

# 卡片缓存：tab_index -> { item_id -> Control }
var _card_cache: Dictionary = {}

# 计数 label
var _count_labels: Array = []  # 4 个 Label


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size

	# 顶部标题
	var title := Label.new()
	title.text = tr("COMMANDER_SELECT_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.position = Vector2(0, 20)
	title.size = Vector2(vp_size.x, 50)
	add_child(title)

	# 左列：指挥官卡片
	var left_container := VBoxContainer.new()
	left_container.position = Vector2(20, 90)
	left_container.size = Vector2(280, 560)
	left_container.add_theme_constant_override("separation", 16)
	add_child(left_container)

	# 加载所有已解锁的 profile
	var sm := get_node_or_null("/root/SaveManager")
	var last_id: String = "balanced"
	if sm:
		last_id = sm.get_last_selected_commander()
		if not sm.is_commander_unlocked(last_id):
			last_id = "balanced"
	_selected_id = StringName(last_id)

	var unlocked: Array = ["balanced"]
	if sm:
		unlocked = sm.get_unlocked_commanders()

	var profiles: Array = []
	for cmd_id in unlocked:
		var sn_id: StringName = StringName(cmd_id)
		if CommanderRegistry.has_profile(sn_id):
			profiles.append(CommanderRegistry.get_profile(sn_id))
	if profiles.is_empty():
		profiles.append(CommanderRegistry.get_profile(&"balanced"))

	for profile in profiles:
		var card := _create_commander_card(profile)
		card.set_meta("cmd_id", profile.id)
		left_container.add_child(card)
		_card_wrappers.append(card)

	# 右列：Tab 详情面板
	_build_right_panel(vp_size)

	# 初始化配置状态（从持久化加载）
	_selected_loadout = MainScript.load_player_loadout()
	_selected_skills = MainScript.load_player_selected_skills()
	_selected_passives = MainScript.load_player_passives()

	_refresh_card_selection()
	_refresh_all_tabs()

	# 底部按钮行
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.position = Vector2(0, 670)
	btn_row.size = Vector2(vp_size.x, 40)
	add_child(btn_row)

	_back_button = Button.new()
	_back_button.text = tr("BTN_BACK")
	_back_button.custom_minimum_size = Vector2(180, 48)
	_back_button.add_theme_font_size_override("font_size", 20)
	BF.add_hover_anim_button(_back_button)
	btn_row.add_child(_back_button)
	_back_button.pressed.connect(_on_back_pressed)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(80, 0)
	btn_row.add_child(spacer)

	_confirm_button = Button.new()
	_confirm_button.text = tr("BTN_CONFIRM")
	_confirm_button.custom_minimum_size = Vector2(240, 48)
	_confirm_button.add_theme_font_size_override("font_size", 20)
	BF.add_hover_anim_button(_confirm_button)
	btn_row.add_child(_confirm_button)
	_confirm_button.pressed.connect(_on_confirm_pressed)


# ============================================================
# 左列：指挥官卡片
# ============================================================
func _create_commander_card(profile) -> Control:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(260, 170)
	wrapper.mouse_filter = Control.MOUSE_FILTER_PASS

	var bg := PanelContainer.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_PASS
	wrapper.add_child(bg)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.17, 0.22, 0.9)
	sb.border_width_left = 3
	sb.border_width_right = 3
	sb.border_width_top = 3
	sb.border_width_bottom = 3
	sb.border_color = COLOR_CARD_BORDER_IDLE
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	bg.add_theme_stylebox_override("panel", sb)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(vbox)

	var tint_rect := ColorRect.new()
	tint_rect.color = profile.unit_color_tint if profile.unit_color_tint != Color.WHITE else Color(0.6, 0.7, 0.9)
	tint_rect.custom_minimum_size = Vector2(0, 20)
	tint_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(tint_rect)

	var name_lbl := Label.new()
	name_lbl.text = tr(profile.display_name) if profile.display_name != "" else String(profile.id)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	var desc_text: String = tr(profile.description) if profile.description != "" else ""
	if desc_text.length() > 28:
		desc_text = desc_text.substr(0, 28) + "..."
	var desc_lbl := Label.new()
	desc_lbl.text = desc_text
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(230, 30)
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc_lbl)

	var click_btn := Button.new()
	click_btn.name = "ClickButton"
	click_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_btn.flat = true
	click_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	wrapper.add_child(click_btn)
	click_btn.pressed.connect(func():
		_selected_id = profile.id
		_refresh_card_selection()
		_refresh_all_tabs()
	)
	click_btn.mouse_entered.connect(func():
		if wrapper.get_meta("cmd_id", &"") != _selected_id:
			_apply_card_border(bg, COLOR_CARD_BORDER_HOVER)
	)
	click_btn.mouse_exited.connect(func():
		if wrapper.get_meta("cmd_id", &"") != _selected_id:
			_apply_card_border(bg, COLOR_CARD_BORDER_IDLE)
	)
	BF.add_hover_anim_button(click_btn)
	return wrapper


func _apply_card_border(bg: PanelContainer, color: Color) -> void:
	var sb: StyleBoxFlat = bg.get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		sb = (sb as StyleBoxFlat).duplicate()
		sb.border_color = color
		bg.add_theme_stylebox_override("panel", sb)


func _refresh_card_selection() -> void:
	for i in range(_card_wrappers.size()):
		var wrapper: Control = _card_wrappers[i]
		var bg: PanelContainer = wrapper.get_child(0)
		var is_selected: bool = (wrapper.get_meta("cmd_id", &"") == _selected_id)
		_apply_card_border(bg, COLOR_CARD_BORDER_SELECTED if is_selected else COLOR_CARD_BORDER_IDLE)


# ============================================================
# 右列：Tab 详情面板
# ============================================================
func _build_right_panel(vp_size: Vector2) -> void:
	var right_root := Control.new()
	right_root.position = Vector2(320, 90)
	right_root.size = Vector2(vp_size.x - 340, 560)
	add_child(right_root)

	# Tab Bar
	var tab_bar := HBoxContainer.new()
	tab_bar.position = Vector2(0, 0)
	tab_bar.size = Vector2(right_root.size.x, 44)
	tab_bar.add_theme_constant_override("separation", 4)
	right_root.add_child(tab_bar)

	var tab_titles: Array = [
		tr("CMD_TAB_UNITS"),
		tr("CMD_TAB_BUILDINGS_LOADOUT"),
		tr("CMD_TAB_SKILLS"),
		tr("CMD_TAB_PASSIVES"),
	]
	for i in range(4):
		var tab_btn := Button.new()
		tab_btn.text = tab_titles[i]
		tab_btn.custom_minimum_size = Vector2(160, 40)
		tab_btn.add_theme_font_size_override("font_size", 16)
		tab_btn.toggle_mode = true
		BF.add_hover_anim_button(tab_btn)
		tab_bar.add_child(tab_btn)
		tab_btn.pressed.connect(_on_tab_pressed.bind(i))
		_tab_buttons.append(tab_btn)

	# 4 个 Tab 内容面板
	for i in range(4):
		var panel := Control.new()
		panel.position = Vector2(0, 50)
		panel.size = Vector2(right_root.size.x, right_root.size.y - 50)
		panel.visible = (i == _current_tab)
		right_root.add_child(panel)
		_tab_panels.append(panel)
		_card_cache[i] = {}
		# 每个 panel 内：顶部计数 label + ScrollContainer+VBox
		_build_tab_panel(panel, i)

	_update_tab_button_states()


func _build_tab_panel(panel: Control, tab_idx: int) -> void:
	# 顶部计数 label
	var count_lbl := Label.new()
	count_lbl.position = Vector2(8, 0)
	count_lbl.size = Vector2(panel.size.x - 16, 24)
	count_lbl.add_theme_font_size_override("font_size", 14)
	count_lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	panel.add_child(count_lbl)
	_count_labels.append(count_lbl)

	# ScrollContainer + VBox
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 28)
	scroll.size = Vector2(panel.size.x, panel.size.y - 28)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)


func _on_tab_pressed(tab_idx: int) -> void:
	_current_tab = tab_idx
	for i in range(_tab_panels.size()):
		_tab_panels[i].visible = (i == tab_idx)
	_update_tab_button_states()


func _update_tab_button_states() -> void:
	for i in range(_tab_buttons.size()):
		var btn: Button = _tab_buttons[i]
		btn.set_pressed_no_signal(i == _current_tab)
		if i == _current_tab:
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		else:
			btn.remove_theme_color_override("font_color")


# ============================================================
# 刷新所有 Tab 内容（指挥官切换时调用）
# ============================================================
func _refresh_all_tabs() -> void:
	# 切换指挥官时，过滤掉当前指挥官不支持的技能
	var profile = CommanderRegistry.get_profile(_selected_id) if CommanderRegistry.has_profile(_selected_id) else null
	if profile != null:
		var filtered: Array = []
		for sid in _selected_skills:
			if profile.active_skills.has(sid) and not filtered.has(sid):
				filtered.append(sid)
		_selected_skills = filtered
	_refresh_units_tab()
	_refresh_buildings_tab()
	_refresh_skills_tab()
	_refresh_passives_tab()


# ============================================================
# Tab 1: 单位编制
# ============================================================
func _refresh_units_tab() -> void:
	var vbox: VBoxContainer = _get_tab_vbox(TAB_UNITS)
	_clear_tab(TAB_UNITS)
	for mode in D.DISPLAY_ORDER:
		if not D.is_unit_mode(mode):
			continue
		_create_place_mode_card(vbox, TAB_UNITS, mode)
	_update_count_label(TAB_UNITS)


# _get_tab_vbox: 取 Tab panel 的 VBox（panel 的第 2 个子节点 = ScrollContainer 的 VBox）
func _get_tab_vbox(tab_idx: int) -> VBoxContainer:
	var panel: Control = _tab_panels[tab_idx]
	var scroll: ScrollContainer = panel.get_child(1) as ScrollContainer
	return scroll.get_child(0) as VBoxContainer


func _clear_tab(tab_idx: int) -> void:
	var vbox: VBoxContainer = _get_tab_vbox(tab_idx)
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	_card_cache[tab_idx] = {}


# ============================================================
# Tab 2: 建筑编制
# ============================================================
func _refresh_buildings_tab() -> void:
	var vbox: VBoxContainer = _get_tab_vbox(TAB_BUILDINGS)
	_clear_tab(TAB_BUILDINGS)
	for mode in D.DISPLAY_ORDER:
		if not D.is_building_mode(mode):
			continue
		_create_place_mode_card(vbox, TAB_BUILDINGS, mode)
	_update_count_label(TAB_BUILDINGS)


# PlaceMode 卡片（单位/建筑共用），建筑卡片描述含该指挥官可用变体
func _create_place_mode_card(parent: VBoxContainer, tab_idx: int, mode: int) -> void:
	var name_key: String = D.MODE_NAMES.get(mode, "")
	var icon_path: String = D.MODE_ICONS.get(mode, "")
	var is_unit: bool = (tab_idx == TAB_UNITS)
	var tint: Color = COLOR_UNIT_TINT if is_unit else COLOR_BUILDING_TINT
	var hotkey: Key = D.MODE_HOTKEYS.get(mode, KEY_0)
	var key_str: String = "0" if hotkey == KEY_0 else OS.get_keycode_string(hotkey)
	var cost: int = D.COSTS.get(mode, 0)
	var type_str: String = tr("TAB_UNITS") if is_unit else tr("TAB_BUILDINGS")
	var desc_str: String = "%s | $%d" % [type_str, cost]

	# 建筑卡片附加变体说明
	if not is_unit:
		var variants_str: String = _get_building_variants_str(mode)
		if variants_str != "":
			desc_str += " | " + variants_str

	_create_selectable_card(parent, tab_idx, mode, tr(name_key), desc_str, icon_path, key_str, tint)


func _get_building_variants_str(mode: int) -> String:
	# mode → BuildingType，查 profile.building_variants
	var profile = CommanderRegistry.get_profile(_selected_id) if CommanderRegistry.has_profile(_selected_id) else null
	if profile == null:
		return ""
	var bt: int = D.PLACE_MODE_TO_BUILDING.get(mode, -1)
	if bt < 0:
		return ""
	var variants: Array = profile.building_variants.get(bt, [])
	if variants.is_empty():
		return ""
	var names: Array = []
	for vid in variants:
		names.append(String(vid))
	return "变体: " + ", ".join(names)


# ============================================================
# Tab 3: 面板技能
# ============================================================
func _refresh_skills_tab() -> void:
	var vbox: VBoxContainer = _get_tab_vbox(TAB_SKILLS)
	_clear_tab(TAB_SKILLS)
	var profile = CommanderRegistry.get_profile(_selected_id) if CommanderRegistry.has_profile(_selected_id) else null
	# 该指挥官可用的技能 = profile.active_skills（指挥官独占技能集）
	# 玩家从中选最多 4 个
	var available: Array = profile.active_skills if profile != null else []
	for skill_id in available:
		var config: Dictionary = CSD.SKILL_CONFIGS.get(skill_id, {})
		if config.is_empty():
			continue
		var icon_path: String = CSD.SKILL_ICONS_BY_ID.get(skill_id, "")
		var name_text: String = tr(config.get("name", ""))
		var cost: int = config.get("cost", 0)
		var cooldown: float = config.get("cooldown", 0.0)
		var desc_text: String = "%s | %s" % [tr("CMD_SKILL_COST") % cost, tr("CMD_SKILL_COOLDOWN") % int(cooldown)]
		_create_selectable_card(vbox, TAB_SKILLS, skill_id, name_text, desc_text, icon_path, "", COLOR_SKILL_TINT)
	_update_count_label(TAB_SKILLS)


# ============================================================
# Tab 4: 被动技能
# ============================================================
func _refresh_passives_tab() -> void:
	var vbox: VBoxContainer = _get_tab_vbox(TAB_PASSIVES)
	_clear_tab(TAB_PASSIVES)
	# 被动池 = UD.CONFIGS 全部（与 pre_battle_config_dialog 一致）
	# 玩家选最多 3 个
	for upgrade_id in UD.CONFIGS.keys():
		var config: Dictionary = UD.CONFIGS[upgrade_id]
		var icon_path: String = config.get("icon", "")
		var tier: int = config.get("tier", UD.Tier.SILVER)
		var tier_color: Color = UD.TIER_COLORS.get(tier, Color(0.78, 0.78, 0.78))
		var tint: Color = Color(tier_color.r * 0.4, tier_color.g * 0.4, tier_color.b * 0.4, 0.45)
		_create_selectable_card(vbox, TAB_PASSIVES, upgrade_id, tr(config.get("name", "")), tr(config.get("desc", "")), icon_path, "", tint)
	_update_count_label(TAB_PASSIVES)


# ============================================================
# 可交互卡片工厂（4 个 Tab 共用）
# ============================================================
func _create_selectable_card(parent: VBoxContainer, tab_idx: int, item_id: int,
		name_text: String, desc_text: String, icon_path: String,
		badge_text: String, base_tint: Color) -> void:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(0, 64)
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(wrapper)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = base_tint
	wrapper.add_child(bg)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 8
	hbox.offset_right = -8
	hbox.offset_top = 4
	hbox.offset_bottom = -4
	hbox.add_theme_constant_override("separation", 10)
	wrapper.add_child(hbox)

	if icon_path != "":
		var icon_tex := load(icon_path) as Texture2D
		if icon_tex:
			var tw := icon_tex.get_width()
			var th := icon_tex.get_height()
			if tw > th and th > 0 and tw % th == 0:
				var atlas := AtlasTexture.new()
				atlas.atlas = icon_tex
				atlas.region = Rect2(0, 0, th, th)
				icon_tex = atlas
			var icon := TextureRect.new()
			icon.texture = icon_tex
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2(48, 48)
			icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			hbox.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 2)
	hbox.add_child(text_box)

	var name_label := Label.new()
	name_label.text = name_text
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	text_box.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = desc_text
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	text_box.add_child(desc_label)

	# badge（loadout 的数字键）
	var badge := Label.new()
	badge.name = "BadgeLabel"
	badge.text = badge_text
	badge.custom_minimum_size = Vector2(28, 0)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	badge.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	hbox.add_child(badge)

	# 选中标记
	var check_label := Label.new()
	check_label.name = "CheckLabel"
	check_label.custom_minimum_size = Vector2(28, 0)
	check_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	check_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	check_label.add_theme_font_size_override("font_size", 20)
	check_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	hbox.add_child(check_label)

	# 透明按钮
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var es := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", es)
	btn.add_theme_stylebox_override("hover", es)
	btn.add_theme_stylebox_override("pressed", es)
	btn.add_theme_stylebox_override("focus", es)
	btn.pressed.connect(_on_card_pressed.bind(tab_idx, item_id))
	wrapper.add_child(btn)

	_card_cache[tab_idx][item_id] = wrapper
	_refresh_card_visual(tab_idx, item_id)


func _on_card_pressed(tab_idx: int, item_id: int) -> void:
	var selected: Array = _current_selection(tab_idx)
	var max_count: int = _max_for_tab(tab_idx)
	if selected.has(item_id):
		selected.erase(item_id)
	else:
		if selected.size() >= max_count:
			return
		selected.append(item_id)
	_refresh_card_visual(tab_idx, item_id)
	# loadout 是单位+建筑共享配额，两个 Tab 的计数都要更新
	if tab_idx == TAB_UNITS or tab_idx == TAB_BUILDINGS:
		_update_count_label(TAB_UNITS)
		_update_count_label(TAB_BUILDINGS)
	else:
		_update_count_label(tab_idx)


func _refresh_card_visual(tab_idx: int, item_id: int) -> void:
	var wrapper: Control = _card_cache[tab_idx].get(item_id)
	if wrapper == null or not is_instance_valid(wrapper):
		return
	var selected: Array = _current_selection(tab_idx)
	var is_selected: bool = selected.has(item_id)
	var bg: ColorRect = wrapper.get_child(0) as ColorRect
	if bg:
		bg.color = COLOR_SELECTED_TINT if is_selected else _base_tint_for(tab_idx, item_id)
	var check_label: Label = wrapper.find_child("CheckLabel", true, false) as Label
	if check_label:
		check_label.text = "✓" if is_selected else ""


func _base_tint_for(tab_idx: int, item_id: int) -> Color:
	match tab_idx:
		TAB_UNITS:
			return COLOR_UNIT_TINT
		TAB_BUILDINGS:
			return COLOR_BUILDING_TINT
		TAB_SKILLS:
			return COLOR_SKILL_TINT
		TAB_PASSIVES:
			var config: Dictionary = UD.CONFIGS.get(item_id, {})
			var tier: int = config.get("tier", UD.Tier.SILVER)
			var tc: Color = UD.TIER_COLORS.get(tier, Color(0.78, 0.78, 0.78))
			return Color(tc.r * 0.4, tc.g * 0.4, tc.b * 0.4, 0.45)
	return Color(0.18, 0.18, 0.22, 0.5)


func _current_selection(tab_idx: int) -> Array:
	match tab_idx:
		TAB_UNITS, TAB_BUILDINGS:
			return _selected_loadout
		TAB_SKILLS:
			return _selected_skills
		TAB_PASSIVES:
			return _selected_passives
	return []


func _max_for_tab(tab_idx: int) -> int:
	match tab_idx:
		TAB_UNITS, TAB_BUILDINGS:
			return MAX_LOADOUT
		TAB_SKILLS:
			return MAX_SKILLS
		TAB_PASSIVES:
			return MAX_PASSIVES
	return 0


func _update_count_label(tab_idx: int) -> void:
	var lbl: Label = _count_labels[tab_idx]
	if lbl == null or not is_instance_valid(lbl):
		return
	var selected: Array = _current_selection(tab_idx)
	var max_count: int = _max_for_tab(tab_idx)
	var key: String = ""
	match tab_idx:
		TAB_UNITS:
			key = "CMD_COUNT_LOADOUT"
		TAB_BUILDINGS:
			key = "CMD_COUNT_LOADOUT"
		TAB_SKILLS:
			key = "CMD_COUNT_SKILLS"
		TAB_PASSIVES:
			key = "CMD_COUNT_PASSIVES"
	lbl.text = tr(key) % [selected.size(), max_count]


# ============================================================
# 确认 / 返回
# ============================================================
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_confirm_pressed() -> void:
	if _selected_id == &"":
		return
	CommanderChoice.select_commander(_selected_id)
	var sm := get_node_or_null("/root/SaveManager")
	if sm:
		sm.set_last_selected_commander(String(_selected_id))
	# 保存三类配置（与 pre_battle_config_dialog 共享 settings.cfg）
	MainScript.save_player_loadout(_selected_loadout)
	MainScript.save_player_selected_skills(_selected_skills)
	MainScript.save_player_passives(_selected_passives)
	# 加载关卡（map 场景用 LoadRouter 显示加载条）
	if CommanderChoice.pending_level_scene != "":
		LoadRouter.request_load(CommanderChoice.pending_level_scene, false)
	else:
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER, KEY_KP_ENTER:
				_on_confirm_pressed()
			KEY_ESCAPE:
				_on_back_pressed()
