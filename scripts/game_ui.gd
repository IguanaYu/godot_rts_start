extends Node
## UI 模块：按钮面板、金币显示、放置模式提示、波次倒计时、暂停菜单

const D := preload("res://scripts/game_data.gd")

signal place_mode_requested(mode: int)
signal restart_requested
signal level_select_requested
signal quit_requested

# UI 引用
var ui_buttons: Dictionary = {}
var place_mode_label: Label
var gold_label: Label
var wave_countdown_label: Label

# 暂停菜单
var pause_menu_open: bool = false
var pause_canvas: CanvasLayer

# Key mapping
var key_to_mode: Dictionary = {}

# 外部引用
var _main_node: Node2D

func initialize(main_node: Node2D, map_config: Resource, gold: int) -> void:
	_main_node = main_node
	_create_ui(map_config, gold)
	_create_pause_menu()

func _create_ui(map_config: Resource, current_gold: int) -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	_main_node.add_child(canvas)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_top = 10.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	# Get available items from config or use all
	var available_items: Array = []
	if map_config != null and not map_config.available_items.is_empty():
		available_items = map_config.available_items
	else:
		available_items = D.ALL_ITEMS

	# Generate buttons dynamically
	var key_index := 0
	var key_list := D.KEY_LIST

	for mode in available_items:
		var cost: int = D.COSTS.get(mode, 0)
		var mode_name: String = D.MODE_NAMES.get(mode, "Unknown")
		var key_key: Key = key_list[key_index] if key_index < key_list.size() else KEY_0

		var btn := Button.new()
		btn.text = "%s[%d] $%d" % [mode_name, (key_index + 1) % 10, cost]
		btn.custom_minimum_size = Vector2(135, 36)
		btn.pressed.connect(func(): place_mode_requested.emit(mode))
		hbox.add_child(btn)
		ui_buttons[mode] = btn

		# Build key mapping
		key_to_mode[key_key] = mode

		key_index += 1

	canvas.add_child(panel)

	# 放置模式提示
	place_mode_label = Label.new()
	place_mode_label.anchor_left = 0.5
	place_mode_label.anchor_right = 0.5
	place_mode_label.anchor_top = 0.0
	place_mode_label.anchor_bottom = 0.0
	place_mode_label.offset_top = 65.0
	place_mode_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	place_mode_label.add_theme_font_size_override("font_size", 18)
	place_mode_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	place_mode_label.visible = false
	canvas.add_child(place_mode_label)

	# 金币显示
	gold_label = Label.new()
	gold_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	gold_label.offset_left = 10.0
	gold_label.offset_top = 10.0
	gold_label.add_theme_font_size_override("font_size", 22)
	gold_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	gold_label.text = "Gold: %d" % current_gold
	canvas.add_child(gold_label)

	# 波次倒计时
	wave_countdown_label = Label.new()
	wave_countdown_label.anchor_left = 0.5
	wave_countdown_label.anchor_right = 0.5
	wave_countdown_label.anchor_top = 0.0
	wave_countdown_label.anchor_bottom = 0.0
	wave_countdown_label.offset_top = 55.0
	wave_countdown_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	wave_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_countdown_label.add_theme_font_size_override("font_size", 20)
	wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	wave_countdown_label.visible = false
	canvas.add_child(wave_countdown_label)

func update_gold_display(current_gold: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % current_gold
	_update_button_affordability(current_gold)

func _update_button_affordability(current_gold: int) -> void:
	for mode in ui_buttons:
		var btn: Button = ui_buttons[mode]
		var cost: int = D.COSTS.get(mode, 0)
		btn.disabled = current_gold < cost
		btn.modulate.a = 0.5 if current_gold < cost else 1.0

func update_wave_countdown(wave_number: int, remaining: float, total: int) -> void:
	if wave_countdown_label == null:
		return
	var display_wave := wave_number + 1
	var secs := ceili(remaining)
	wave_countdown_label.text = "Wave %d/%d incoming in: %ds" % [display_wave, total, secs]
	wave_countdown_label.visible = true
	if remaining <= 5.0:
		wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.1, 0.1))
	else:
		wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func hide_wave_countdown() -> void:
	if wave_countdown_label:
		wave_countdown_label.visible = false

func _create_pause_menu() -> void:
	pause_canvas = CanvasLayer.new()
	pause_canvas.layer = 100
	pause_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	_main_node.add_child(pause_canvas)

	var overlay := ColorRect.new()
	overlay.anchor_left = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_top = 0.0
	overlay.anchor_bottom = 1.0
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_canvas.add_child(overlay)

	# ESC input handler (runs while paused)
	var input_handler := Control.new()
	input_handler.set_script(load("res://scripts/pause_input_handler.gd"))
	input_handler.main_node = _main_node
	input_handler.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_handler.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_canvas.add_child(input_handler)

	var panel_bg := ColorRect.new()
	panel_bg.anchor_left = 0.5
	panel_bg.anchor_right = 0.5
	panel_bg.anchor_top = 0.5
	panel_bg.anchor_bottom = 0.5
	panel_bg.offset_left = -120.0
	panel_bg.offset_right = 120.0
	panel_bg.offset_top = -140.0
	panel_bg.offset_bottom = 140.0
	panel_bg.color = Color(0.1, 0.1, 0.15, 0.95)
	overlay.add_child(panel_bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	var btn_data := [
		["Resume", _close_pause_menu],
		["Restart", _on_pause_restart],
		["Level Select", _on_pause_level_select],
		["Quit Game", _on_pause_quit],
	]
	for data in btn_data:
		var btn := Button.new()
		btn.text = data[0]
		btn.custom_minimum_size = Vector2(200, 40)
		btn.pressed.connect(data[1])
		vbox.add_child(btn)

	var hint := Label.new()
	hint.text = "Press ESC to resume"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(hint)

	pause_canvas.visible = false

func open_pause_menu() -> void:
	pause_menu_open = true
	pause_canvas.visible = true
	_main_node.get_tree().paused = true

func _close_pause_menu() -> void:
	pause_menu_open = false
	pause_canvas.visible = false
	_main_node.get_tree().paused = false

func _on_pause_restart() -> void:
	_main_node.get_tree().paused = false
	_main_node.get_tree().reload_current_scene()

func _on_pause_level_select() -> void:
	_main_node.get_tree().paused = false
	_main_node.get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_pause_quit() -> void:
	_main_node.get_tree().quit()

func close_pause_menu() -> void:
	_close_pause_menu()

func set_place_mode_text(text: String) -> void:
	if place_mode_label:
		place_mode_label.text = text
		place_mode_label.visible = text != ""

func hide_place_mode_label() -> void:
	if place_mode_label:
		place_mode_label.visible = false
