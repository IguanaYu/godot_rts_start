extends Control
## 战前配置弹窗：Tab 切换的统一配置入口
## - 指挥官技能（4 槽位）
## - 部队编制（10 槽位，单位+建筑共用数字键 1-9, 0）
## - 战前被动（3 槽位，整局永久生效）

const CSD := preload("res://scripts/commander_skill/commander_skill_data.gd")
const D := preload("res://scripts/systems/game_data.gd")
const UD := preload("res://scripts/upgrade/upgrade_data.gd")
const BF := preload("res://scripts/ui/button_factory.gd")
const MainScript := preload("res://scripts/main.gd")

const MAX_SKILLS := 4
const MAX_LOADOUT := 15
const MAX_PASSIVES := 3

const SLOT_HOTKEYS := ["Z", "X", "C", "V"]

const COLOR_UNIT_TINT := Color(0.2, 0.3, 0.5, 0.45)
const COLOR_BUILDING_TINT := Color(0.4, 0.35, 0.2, 0.45)
const COLOR_SELECTED_TINT := Color(0.25, 0.45, 0.65, 0.7)
const COLOR_UNSELECTED_TINT := Color(0.18, 0.18, 0.22, 0.5)

# === 外部传入的九宫格纹理（来自 level_select，避免重复预处理）===
var np_paper: Dictionary
var np_btn_blue: Dictionary
var np_btn_blue_prs: Dictionary
var np_btn_red: Dictionary
var np_btn_red_prs: Dictionary

# === 状态 ===
var _current_tab: int = 0  # 0=技能, 1=编制, 2=被动
var _selected_skills: Array = []  # int[]
var _selected_loadout: Array = []  # int[PlaceMode]
var _selected_passives: Array = []  # int[UpgradeId]

# === UI 引用 ===
var _tab_buttons: Array = []  # [wrapper, bg, label]
var _slot_label: Label
var _hint_label: Label
var _content_container: VBoxContainer  # 当前 Tab 的卡片列表容器（在 ScrollContainer 内）

# 卡片缓存（按 tab → {id → wrapper}）
var _card_cache: Dictionary = {
	0: {}, 1: {}, 2: {},
}

signal closed


# ============================================================
# 入口：调用方传入九宫格纹理，弹窗自管状态
# ============================================================
func setup(np_paper_: Dictionary, np_btn_blue_: Dictionary, np_btn_blue_prs_: Dictionary,
		np_btn_red_: Dictionary, np_btn_red_prs_: Dictionary) -> void:
	np_paper = np_paper_
	np_btn_blue = np_btn_blue_
	np_btn_blue_prs = np_btn_blue_prs_
	np_btn_red = np_btn_red_
	np_btn_red_prs = np_btn_red_prs_


func _ready() -> void:
	# 读取玩家已选
	_selected_skills = MainScript.load_player_selected_skills()
	_selected_loadout = MainScript.load_player_loadout()
	_selected_passives = MainScript.load_player_passives()
	_build_ui()


# ============================================================
# 主 UI 构建
# ============================================================
func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# 半透明遮罩
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# 中央面板（宽 540 / 高 520）
	var panel_wrapper := Control.new()
	panel_wrapper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_wrapper.offset_left = -270
	panel_wrapper.offset_right = 270
	panel_wrapper.offset_top = -260
	panel_wrapper.offset_bottom = 260
	add_child(panel_wrapper)

	var panel_bg := _make_ninepatch(np_paper)
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(panel_bg)

	# 主容器
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 16
	vbox.offset_bottom = -16
	vbox.add_theme_constant_override("separation", 8)
	panel_wrapper.add_child(vbox)

	# 标题
	var title := Label.new()
	title.text = tr("PRE_BATTLE_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	vbox.add_child(title)

	# Tab 栏
	_create_tab_bar(vbox)

	# 已选计数 + 提示行
	var info_row := HBoxContainer.new()
	info_row.alignment = BoxContainer.ALIGNMENT_CENTER
	info_row.add_theme_constant_override("separation", 16)
	vbox.add_child(info_row)

	_slot_label = Label.new()
	_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slot_label.add_theme_font_size_override("font_size", 14)
	_slot_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	info_row.add_child(_slot_label)

	_hint_label = Label.new()
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 11)
	_hint_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	info_row.add_child(_hint_label)

	# 滚动列表区域
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	_content_container = VBoxContainer.new()
	_content_container.add_theme_constant_override("separation", 6)
	_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_content_container)

	# 底部按钮行
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	_create_dialog_button(btn_row, "SKILL_CONFIG_CONFIRM", np_btn_blue, np_btn_blue_prs, _on_confirm_pressed)
	_create_dialog_button(btn_row, "ESC_BACK_MAIN_MENU", np_btn_red, np_btn_red_prs, _on_cancel_pressed)

	# 默认显示 Tab 0
	_switch_tab(0)


func _make_ninepatch(np: Dictionary) -> NinePatchRect:
	var npr := NinePatchRect.new()
	npr.texture = np.texture
	npr.patch_margin_left = np.margin_left
	npr.patch_margin_right = np.margin_right
	npr.patch_margin_top = np.margin_top
	npr.patch_margin_bottom = np.margin_bottom
	npr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return npr


# ============================================================
# Tab 栏
# ============================================================
func _create_tab_bar(parent: VBoxContainer) -> void:
	var tab_row := HBoxContainer.new()
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_row.add_theme_constant_override("separation", 8)
	parent.add_child(tab_row)

	var tab_specs := [
		{"key": "TAB_COMMANDER_SKILLS", "tab": 0},
		{"key": "TAB_LOADOUT", "tab": 1},
		{"key": "TAB_PASSIVES", "tab": 2},
	]
	for spec in tab_specs:
		var wrapper := Control.new()
		wrapper.custom_minimum_size = Vector2(160, 36)
		tab_row.add_child(wrapper)

		var bg := _make_ninepatch(np_btn_blue)
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wrapper.add_child(bg)

		var btn := Button.new()
		btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var es := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", es)
		btn.add_theme_stylebox_override("hover", es)
		btn.add_theme_stylebox_override("pressed", es)
		btn.add_theme_stylebox_override("focus", es)
		btn.pressed.connect(_switch_tab.bind(spec.tab))
		wrapper.add_child(btn)

		var label := Label.new()
		label.text = tr(spec.key)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrapper.add_child(label)

		BF.add_hover_anim_button(btn)

		_tab_buttons.append([wrapper, bg, label])


func _switch_tab(tab: int) -> void:
	_current_tab = tab
	# 更新 Tab 外观（选中红/未选中蓝）
	for i in range(_tab_buttons.size()):
		var entry: Array = _tab_buttons[i]
		var bg: NinePatchRect = entry[1]
		var label: Label = entry[2]
		if i == tab:
			bg.texture = np_btn_red.texture
			bg.patch_margin_left = np_btn_red.margin_left
			bg.patch_margin_right = np_btn_red.margin_right
			bg.patch_margin_top = np_btn_red.margin_top
			bg.patch_margin_bottom = np_btn_red.margin_bottom
			label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		else:
			bg.texture = np_btn_blue.texture
			bg.patch_margin_left = np_btn_blue.margin_left
			bg.patch_margin_right = np_btn_blue.margin_right
			bg.patch_margin_top = np_btn_blue.margin_top
			bg.patch_margin_bottom = np_btn_blue.margin_bottom
			label.add_theme_color_override("font_color", Color(1, 1, 1))
	# 重建内容
	_rebuild_content()


func _rebuild_content() -> void:
	# 清空旧卡片
	for child in _content_container.get_children():
		_content_container.remove_child(child)
		child.queue_free()
	_card_cache[_current_tab] = {}

	# 提示文字
	match _current_tab:
		0:
			_hint_label.text = ""
		1:
			_hint_label.text = tr("LOADOUT_HINT")
		2:
			_hint_label.text = tr("PASSIVES_HINT")

	# 创建卡片
	match _current_tab:
		0:
			for skill_id in CSD.ALL_SKILLS:
				_create_skill_card(skill_id)
		1:
			for mode in D.DISPLAY_ORDER:
				_create_loadout_card(mode)
		2:
			for upgrade_id in _all_passive_ids():
				_create_passive_card(upgrade_id)

	_update_slot_label()


# ============================================================
# 技能 Tab
# ============================================================
func _create_skill_card(skill_id: int) -> void:
	var config: Dictionary = CSD.SKILL_CONFIGS[skill_id]
	var icon_path: String = CSD.SKILL_ICONS_BY_ID.get(skill_id, "")
	_create_card_generic(
		skill_id,
		tr(config.get("name", "")),
		tr(config.get("description", "")),
		icon_path,
		"",
		Color(0.2, 0.3, 0.5, 0.4),
		0,
	)


# ============================================================
# 编制 Tab
# ============================================================
func _create_loadout_card(mode: int) -> void:
	var name_key: String = D.MODE_NAMES.get(mode, "")
	var icon_path: String = D.MODE_ICONS.get(mode, "")
	var is_unit: bool = D.is_unit_mode(mode)
	var tint: Color = COLOR_UNIT_TINT if is_unit else COLOR_BUILDING_TINT
	# 显示数字键（1-9, 0）
	var hotkey: Key = D.MODE_HOTKEYS.get(mode, KEY_0)
	var key_str: String = "0" if hotkey == KEY_0 else OS.get_keycode_string(hotkey)
	# 描述：从费用和类型构造
	var cost: int = D.COSTS.get(mode, 0)
	var type_str: String = tr("TAB_UNITS") if is_unit else tr("TAB_BUILDINGS")
	var desc_str: String = "%s | $%d" % [type_str, cost]
	_create_card_generic(
		mode,
		tr(name_key),
		desc_str,
		icon_path,
		key_str,
		tint,
		1,
	)


# ============================================================
# 被动 Tab
# ============================================================
func _all_passive_ids() -> Array:
	# 当前 UD 里所有 STAT_MOD 升级都适合作战前被动；SPAWN_UNITS/GIVE_GOLD 也允许（开局奖励）
	return UD.CONFIGS.keys()


func _create_passive_card(upgrade_id: int) -> void:
	var config: Dictionary = UD.CONFIGS[upgrade_id]
	var icon_path: String = config.get("icon", "")
	var tier: int = config.get("tier", UD.Tier.SILVER)
	var tier_color: Color = UD.TIER_COLORS.get(tier, Color(0.78, 0.78, 0.78))
	_create_card_generic(
		upgrade_id,
		tr(config.get("name", "")),
		tr(config.get("desc", "")),
		icon_path,
		"",
		Color(tier_color.r * 0.4, tier_color.g * 0.4, tier_color.b * 0.4, 0.4),
		2,
	)


# ============================================================
# 通用卡片工厂
# ============================================================
# item_id: 数据 ID（skill_id / PlaceMode / upgrade_id）
# badge_text: 右上角额外显示（如编制的数字键）
# tab_index: 当前 Tab（0/1/2）
# base_tint: 未选中时的底色（区分单位/建筑/tier）
func _create_card_generic(item_id: int, name_text: String, desc_text: String,
		icon_path: String, badge_text: String, base_tint: Color, tab_index: int) -> void:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(0, 64)
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_container.add_child(wrapper)

	# 背景色
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = base_tint
	wrapper.add_child(bg)

	# 内部 HBox
	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 8
	hbox.offset_right = -8
	hbox.offset_top = 4
	hbox.offset_bottom = -4
	hbox.add_theme_constant_override("separation", 10)
	wrapper.add_child(hbox)

	# 图标
	if icon_path != "":
		var icon_tex := load(icon_path) as Texture2D
		if icon_tex:
			# 精灵表（横排多帧正方形）裁出第一帧；单图保持原样
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

	# 文字
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

	# 数字键/槽位标记（右上角）
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

	# 透明按钮接收点击
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var es := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", es)
	btn.add_theme_stylebox_override("hover", es)
	btn.add_theme_stylebox_override("pressed", es)
	btn.add_theme_stylebox_override("focus", es)
	btn.pressed.connect(_on_card_pressed.bind(tab_index, item_id))
	wrapper.add_child(btn)

	_card_cache[tab_index][item_id] = wrapper
	_refresh_card_visual(tab_index, item_id)


# ============================================================
# 选择 / 刷新
# ============================================================
func _on_card_pressed(tab_index: int, item_id: int) -> void:
	var selected: Array = _current_selection(tab_index)
	var max_count: int = _max_for_tab(tab_index)
	if selected.has(item_id):
		selected.erase(item_id)
	else:
		if selected.size() >= max_count:
			return  # 槽位已满，忽略
		selected.append(item_id)
	# 技能 Tab 的 badge 是按槽位显示的，取消中间项会让后面项的槽位变化，
	# 所以必须刷新所有已选卡片，不能只刷当前这一张
	if tab_index == 0:
		for sid in _card_cache[tab_index].keys():
			_refresh_card_visual(tab_index, sid)
	else:
		_refresh_card_visual(tab_index, item_id)
	_update_slot_label()


func _refresh_card_visual(tab_index: int, item_id: int) -> void:
	var wrapper: Control = _card_cache[tab_index].get(item_id)
	if wrapper == null or not is_instance_valid(wrapper):
		return
	var selected: Array = _current_selection(tab_index)
	var is_selected: bool = selected.has(item_id)
	var bg: ColorRect = wrapper.get_child(0) as ColorRect
	if bg:
		bg.color = COLOR_SELECTED_TINT if is_selected else _base_tint_for(tab_index, item_id)
	var check_label: Label = wrapper.find_child("CheckLabel", true, false) as Label
	if check_label:
		check_label.text = "✓" if is_selected else ""
	# 技能 Tab：已选中时 badge 显示槽位热键（Z/X/C/V）
	var badge: Label = wrapper.find_child("BadgeLabel", true, false) as Label
	if badge:
		if tab_index == 0 and is_selected:
			var slot_idx: int = selected.find(item_id)
			if slot_idx >= 0 and slot_idx < SLOT_HOTKEYS.size():
				badge.text = SLOT_HOTKEYS[slot_idx]
				badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
			else:
				badge.text = ""
		elif tab_index == 0:
			badge.text = ""
		# tab_index 1 (loadout) badge 由创建时固定设置，不动


func _base_tint_for(tab_index: int, item_id: int) -> Color:
	match tab_index:
		0:
			return Color(0.2, 0.3, 0.5, 0.4)
		1:
			return COLOR_UNIT_TINT if D.is_unit_mode(item_id) else COLOR_BUILDING_TINT
		2:
			var config: Dictionary = UD.CONFIGS.get(item_id, {})
			var tier: int = config.get("tier", UD.Tier.SILVER)
			var tc: Color = UD.TIER_COLORS.get(tier, Color(0.78, 0.78, 0.78))
			return Color(tc.r * 0.4, tc.g * 0.4, tc.b * 0.4, 0.4)
	return Color(0.18, 0.18, 0.22, 0.5)


func _current_selection(tab_index: int) -> Array:
	match tab_index:
		0: return _selected_skills
		1: return _selected_loadout
		2: return _selected_passives
	return []


func _max_for_tab(tab_index: int) -> int:
	match tab_index:
		0: return MAX_SKILLS
		1: return MAX_LOADOUT
		2: return MAX_PASSIVES
	return 0


func _update_slot_label() -> void:
	if _slot_label == null or not is_instance_valid(_slot_label):
		return
	var selected: Array = _current_selection(_current_tab)
	var max_count: int = _max_for_tab(_current_tab)
	_slot_label.text = "%s: %d / %d" % [tr("SKILL_CONFIG_SELECTED"), selected.size(), max_count]


# ============================================================
# 底部按钮
# ============================================================
func _create_dialog_button(parent: HBoxContainer, label_key: String,
		np_regular: Dictionary, np_pressed: Dictionary, callback: Callable) -> void:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(140, 40)
	wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(wrapper)

	var bg := _make_ninepatch(np_regular)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(bg)

	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var es := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", es)
	btn.add_theme_stylebox_override("hover", es)
	btn.add_theme_stylebox_override("pressed", es)
	btn.add_theme_stylebox_override("focus", es)
	btn.pressed.connect(callback)
	wrapper.add_child(btn)

	var label := Label.new()
	label.text = tr(label_key)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(label)

	BF.add_hover_anim(wrapper, bg, np_pressed.texture, np_regular.texture)


func _on_confirm_pressed() -> void:
	# 不满槽位时也接受（_resolve_* 会兜底）
	MainScript.save_player_selected_skills(_selected_skills)
	MainScript.save_player_loadout(_selected_loadout)
	MainScript.save_player_passives(_selected_passives)
	_close()


func _on_cancel_pressed() -> void:
	_close()


func _close() -> void:
	closed.emit()
	queue_free()


# ============================================================
# ESC 关闭
# ============================================================
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()
