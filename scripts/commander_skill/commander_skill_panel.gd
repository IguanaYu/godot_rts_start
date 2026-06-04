extends Node
## 指挥官技能面板UI：顶部技能栏 + 能量条

const SD := preload("res://scripts/commander_skill/commander_skill_data.gd")

const PATH_BAR_BASE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/SmallBar_Base.png"
const PATH_BAR_FILL := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/SmallBar_Fill.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"

# 技能图标路径
const SKILL_ICONS := {
	SD.SkillId.ORBITAL_STRIKE: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_01.png",
	SD.SkillId.HEAL_FIELD: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_02.png",
	SD.SkillId.SHIELD_WALL: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_03.png",
	SD.SkillId.UNIT_DROP: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_04.png",
}

var _main_node: Node2D
var _ui_canvas: CanvasLayer
var _skill_manager: Node

# UI 引用
var energy_bar: ProgressBar
var energy_label: Label
var skill_buttons: Dictionary = {}  # skill_id -> Control wrapper
var cooldown_overlays: Dictionary = {}  # skill_id -> ColorRect
var cooldown_labels: Dictionary = {}  # skill_id -> Label

# 目标预览
var target_preview: Node2D
var _current_preview_radius: float = 0.0

# Tooltip
var tooltip_panel: PanelContainer
var tooltip_label: Label
var tooltip_timer: Timer
var tooltip_target_skill: int = -1


signal skill_button_pressed(skill_id: int)


func initialize(main_node: Node2D, skill_manager: Node) -> void:
	_main_node = main_node
	_skill_manager = skill_manager
	_create_panel()
	_create_tooltip()
	_connect_signals()


func _connect_signals() -> void:
	_skill_manager.energy_changed.connect(_on_energy_changed)
	_skill_manager.skill_cooldown_updated.connect(_on_cooldown_updated)
	_skill_manager.skill_cast_started.connect(_on_cast_started)
	_skill_manager.skill_cast_cancelled.connect(_on_cast_cancelled)
	_skill_manager.skill_cast_completed.connect(_on_cast_completed)


func _create_panel() -> void:
	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = 10
	_main_node.add_child(_ui_canvas)

	# 主容器：屏幕顶部居中
	var main_container := HBoxContainer.new()
	main_container.anchor_left = 0.5
	main_container.anchor_right = 0.5
	main_container.anchor_top = 0.0
	main_container.anchor_bottom = 0.0
	main_container.offset_top = 10.0
	main_container.offset_left = -200.0
	main_container.offset_right = 200.0
	main_container.offset_bottom = 60.0
	main_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_theme_constant_override("separation", 10)
	_ui_canvas.add_child(main_container)

	# --- 能量条区域 ---
	var energy_container := VBoxContainer.new()
	energy_container.custom_minimum_size = Vector2(100, 50)
	energy_container.add_theme_constant_override("separation", 2)
	main_container.add_child(energy_container)

	# 能量标签
	energy_label = Label.new()
	energy_label.text = "%d/%d" % [int(SD.MAX_ENERGY), int(SD.MAX_ENERGY)]
	energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	energy_label.add_theme_font_size_override("font_size", 12)
	energy_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	energy_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	energy_label.add_theme_constant_override("shadow_offset_x", 1)
	energy_label.add_theme_constant_override("shadow_offset_y", 1)
	energy_container.add_child(energy_label)

	# 能量条
	energy_bar = ProgressBar.new()
	energy_bar.max_value = SD.MAX_ENERGY
	energy_bar.value = SD.MAX_ENERGY
	energy_bar.custom_minimum_size = Vector2(100, 12)
	energy_bar.show_percentage = false
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	bg_style.set_corner_radius_all(3)
	energy_bar.add_theme_stylebox_override("background", bg_style)
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.3, 0.6, 1.0)
	fill_style.set_corner_radius_all(2)
	energy_bar.add_theme_stylebox_override("fill", fill_style)
	energy_container.add_child(energy_bar)

	# --- 分隔线 ---
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(2, 40)
	sep.color = Color(0.5, 0.5, 0.5, 0.4)
	sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	main_container.add_child(sep)

	# --- 技能按钮 ---
	for skill_id in _skill_manager.available_skills:
		_create_skill_button(skill_id, main_container)


func _create_skill_button(skill_id: int, container: HBoxContainer) -> void:
	var config: Dictionary = SD.SKILL_CONFIGS[skill_id]
	var icon_path: String = SKILL_ICONS.get(skill_id, "")
	var cost_type: int = config.get("cost_type", SD.CostType.ENERGY)
	var cost: int = config.get("cost", 0)
	var hotkey: Key = config.get("hotkey", KEY_Z)
	var hotkey_name: String = OS.get_keycode_string(hotkey)

	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(56, 56)
	container.add_child(wrapper)

	# 蓝色按钮背景
	var bg := NinePatchRect.new()
	var btn_tex: Texture2D = load(PATH_BTN_BLUE_REG)
	bg.texture = btn_tex
	bg.patch_margin_left = 17
	bg.patch_margin_right = 17
	bg.patch_margin_top = 17
	bg.patch_margin_bottom = 17
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.name = "ButtonBG"
	wrapper.add_child(bg)

	# 图标
	if icon_path != "":
		var icon_tex: Texture2D = load(icon_path)
		if icon_tex:
			var icon := TextureRect.new()
			icon.texture = icon_tex
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			icon.offset_left = 6
			icon.offset_right = -6
			icon.offset_top = 6
			icon.offset_bottom = -6
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			wrapper.add_child(icon)

	# 快捷键标签（左上角）
	var key_label := Label.new()
	key_label.text = hotkey_name
	key_label.add_theme_font_size_override("font_size", 12)
	key_label.add_theme_color_override("font_color", Color(1, 1, 1))
	key_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	key_label.add_theme_constant_override("shadow_offset_x", 1)
	key_label.add_theme_constant_override("shadow_offset_y", 1)
	key_label.anchor_left = 0.0
	key_label.anchor_right = 0.0
	key_label.anchor_top = 0.0
	key_label.anchor_bottom = 0.0
	key_label.offset_left = 4
	key_label.offset_right = 16
	key_label.offset_top = 2
	key_label.offset_bottom = 14
	key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(key_label)

	# 消耗标签（右下角）
	var cost_label := Label.new()
	if cost_type == SD.CostType.ENERGY:
		cost_label.text = "%dE" % cost
		cost_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	else:
		cost_label.text = "$%d" % cost
		cost_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	cost_label.add_theme_font_size_override("font_size", 10)
	cost_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	cost_label.add_theme_constant_override("shadow_offset_x", 1)
	cost_label.add_theme_constant_override("shadow_offset_y", 1)
	cost_label.anchor_left = 0.0
	cost_label.anchor_right = 0.0
	cost_label.anchor_top = 0.0
	cost_label.anchor_bottom = 0.0
	cost_label.offset_left = 2
	cost_label.offset_right = -2
	cost_label.offset_top = 40
	cost_label.offset_bottom = 54
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(cost_label)

	# 冷却遮罩
	var cooldown_overlay := ColorRect.new()
	cooldown_overlay.color = Color(0, 0, 0, 0.6)
	cooldown_overlay.anchor_left = 0.0
	cooldown_overlay.anchor_right = 1.0
	cooldown_overlay.anchor_top = 0.0
	cooldown_overlay.anchor_bottom = 1.0
	cooldown_overlay.offset_left = 6
	cooldown_overlay.offset_right = -6
	cooldown_overlay.offset_top = 6
	cooldown_overlay.offset_bottom = -6  # 从底部开始遮罩（初始全遮）
	cooldown_overlay.visible = false
	cooldown_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(cooldown_overlay)
	cooldown_overlays[skill_id] = cooldown_overlay

	# 冷却倒计时文字
	var cd_label := Label.new()
	cd_label.text = ""
	cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cd_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cd_label.add_theme_font_size_override("font_size", 16)
	cd_label.add_theme_color_override("font_color", Color(1, 1, 1))
	cd_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	cd_label.anchor_left = 0.0
	cd_label.anchor_right = 1.0
	cd_label.anchor_top = 0.0
	cd_label.anchor_bottom = 1.0
	cd_label.offset_left = 6
	cd_label.offset_right = -6
	cd_label.offset_top = 6
	cd_label.offset_bottom = -6
	cd_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cd_label.visible = false
	wrapper.add_child(cd_label)
	cooldown_labels[skill_id] = cd_label

	# 点击按钮
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	var pressed_tex: Texture2D = load(PATH_BTN_BLUE_PRS)
	btn.pressed.connect(func(): skill_button_pressed.emit(skill_id))
	btn.pressed.connect(func(): skill_button_pressed.emit(skill_id))
	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim(wrapper, bg, pressed_tex, btn_tex)
	btn.mouse_entered.connect(_on_skill_hover.bind(skill_id))
	btn.mouse_exited.connect(_on_skill_unhover)

	skill_buttons[skill_id] = wrapper


# === 信号回调 ===

func _on_energy_changed(current: float, max_energy: float) -> void:
	if energy_bar:
		energy_bar.value = current
	if energy_label:
		energy_label.text = "%d/%d" % [int(current), int(max_energy)]
	_update_affordability()


func _on_cooldown_updated(skill_id: int, remaining: float, total: float) -> void:
	var overlay: ColorRect = cooldown_overlays.get(skill_id)
	var cd_label: Label = cooldown_labels.get(skill_id)
	if overlay == null:
		return

	if remaining <= 0.0:
		overlay.visible = false
		if cd_label:
			cd_label.visible = false
		return

	overlay.visible = true
	# 遮罩从下往上填充（剩余比例越大，遮住越多）
	var ratio := remaining / total
	var overlay_height := 44.0
	overlay.offset_top = 6 + overlay_height * (1.0 - ratio)
	overlay.offset_bottom = -6
	if cd_label:
		cd_label.visible = true
		cd_label.text = "%.0f" % remaining


func _on_cast_started(skill_id: int, cast_type: int, radius: float) -> void:
	_current_preview_radius = radius
	_show_target_preview(radius)


func _on_cast_cancelled() -> void:
	_hide_target_preview()


func _on_cast_completed(_skill_id: int) -> void:
	_hide_target_preview()
	_update_affordability()


func _update_affordability() -> void:
	for skill_id in skill_buttons:
		var can_cast: bool = _skill_manager.can_cast(skill_id)
		var wrapper: Control = skill_buttons[skill_id]
		if _skill_manager.cooldowns.get(skill_id, 0.0) > 0.0:
			# 冷却中由遮罩控制显示
			continue
		wrapper.modulate.a = 1.0 if can_cast else 0.5


# === 目标预览 ===

func _show_target_preview(radius: float) -> void:
	_hide_target_preview()
	target_preview = Node2D.new()
	target_preview.set_script(load("res://scripts/commander_skill/target_preview.gd"))
	target_preview.set("preview_radius", radius)
	_main_node.add_child(target_preview)


func _hide_target_preview() -> void:
	if target_preview and is_instance_valid(target_preview):
		target_preview.queue_free()
		target_preview = null


func update_target_preview(world_pos: Vector2) -> void:
	if target_preview and is_instance_valid(target_preview):
		target_preview.global_position = world_pos


# === Tooltip ===

func _create_tooltip() -> void:
	tooltip_timer = Timer.new()
	tooltip_timer.one_shot = true
	tooltip_timer.wait_time = 0.6
	tooltip_timer.timeout.connect(_show_skill_tooltip)
	add_child(tooltip_timer)

	tooltip_panel = PanelContainer.new()
	tooltip_panel.z_index = 100
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.92)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	tooltip_panel.add_theme_stylebox_override("panel", style)
	tooltip_panel.visible = false
	_ui_canvas.add_child(tooltip_panel)

	tooltip_label = Label.new()
	tooltip_label.add_theme_font_size_override("font_size", 13)
	tooltip_label.add_theme_color_override("font_color", Color(1, 1, 1))
	tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.add_child(tooltip_label)


func _on_skill_hover(skill_id: int) -> void:
	tooltip_target_skill = skill_id
	tooltip_timer.start()


func _on_skill_unhover() -> void:
	tooltip_timer.stop()
	tooltip_panel.visible = false
	tooltip_target_skill = -1


func _show_skill_tooltip() -> void:
	if tooltip_target_skill < 0:
		return
	var skill_id: int = tooltip_target_skill
	var config: Dictionary = SD.SKILL_CONFIGS[skill_id]
	var name_str: String = tr(config.get("name", "?"))
	var desc_str: String = tr(config.get("description", ""))
	var cost_type: int = config.get("cost_type", SD.CostType.ENERGY)
	var cost: int = config.get("cost", 0)
	var cooldown: float = config.get("cooldown", 0.0)
	var hotkey: Key = config.get("hotkey", KEY_Z)
	var hotkey_name: String = OS.get_keycode_string(hotkey)

	var cost_str: String
	if cost_type == SD.CostType.ENERGY:
		cost_str = "%d %s" % [cost, tr("SKILL_ENERGY")]
	else:
		cost_str = "$%d" % cost

	tooltip_label.text = "%s [%s]\n%s\n%s: %s | %s: %.0fs" % [
		name_str, hotkey_name,
		desc_str,
		tr("SKILL_COST"), cost_str,
		tr("SKILL_COOLDOWN"), cooldown
	]
	tooltip_panel.visible = true

	var mouse_pos := _main_node.get_viewport().get_mouse_position()
	tooltip_panel.anchor_left = 0.0
	tooltip_panel.anchor_right = 0.0
	tooltip_panel.anchor_top = 0.0
	tooltip_panel.anchor_bottom = 0.0
	tooltip_panel.offset_left = mouse_pos.x - 40
	tooltip_panel.offset_right = mouse_pos.x + 180
	tooltip_panel.offset_top = mouse_pos.y + 20
	tooltip_panel.offset_bottom = mouse_pos.y + 80
