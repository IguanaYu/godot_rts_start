extends CanvasLayer

## 网络状态 UI（常驻 CanvasLayer）
## - 顶部状态条：连接状态 + ping 值（绿/黄/红）
## - 错误对话框：掉线/超时/对方离开/DESYNC 时弹出，提供返回主菜单/退出按钮
##
## 监听 RelayManager.connection_lost 和 RelayManager.ping_updated
## 注意：节点命名遵循 CLAUDE.md 规范，避免 get_children() 误匹配

const COLOR_OK := Color(0.4, 0.9, 0.4)
const COLOR_WARN := Color(1.0, 0.85, 0.0)
const COLOR_BAD := Color(1.0, 0.3, 0.3)

const REASON_TEXT := {
	"disconnected": "你已与服务器断开连接",
	"stale": "网络连接超时（15 秒未收到服务器响应）",
	"peer_left": "对方玩家已断开连接",
	"desync": "游戏状态不一致（DESYNC），无法继续",
	"manual": "",  # 主动断开，不弹窗
}

var _status_bar: PanelContainer
var _status_label: Label
var _dialog: Control
var _dialog_title: Label
var _dialog_desc: Label

var _dialog_shown: bool = false


func _ready() -> void:
	layer = 90
	_build_status_bar()
	_build_dialog()
	_hide_dialog()

	# 监听 RelayManager 的网络事件
	# 注意：connection_lost 信号覆盖了所有异常原因（disconnected/stale/peer_left/desync）
	RelayManager.connection_lost.connect(_on_connection_lost)
	RelayManager.ping_updated.connect(_on_ping_updated)
	RelayManager.connected_to_server.connect(_on_connected)

	# 初始状态：未连接（RelayManager 还没 connect_to_server 时不显示）
	_status_bar.visible = false


# ============== 顶部状态条 ==============

func _build_status_bar() -> void:
	_status_bar = PanelContainer.new()
	_status_bar.name = "NetworkStatusBar"
	_status_bar.anchor_left = 0.0
	_status_bar.anchor_right = 0.0
	_status_bar.anchor_top = 0.0
	_status_bar.anchor_bottom = 0.0
	_status_bar.offset_left = 8.0
	_status_bar.offset_top = 8.0
	# 用 custom_minimum_size + sizeFlagsHorizontal 让 panel 自适应宽度
	_status_bar.custom_minimum_size = Vector2(220, 28)
	add_child(_status_bar)

	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.text = "Connecting..."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 14)
	_status_label.add_theme_color_override("font_color", COLOR_WARN)
	_status_bar.add_child(_status_label)


func _set_status(text: String, color: Color) -> void:
	_status_label.text = text
	_status_label.add_theme_color_override("font_color", color)


# ============== 错误对话框 ==============

func _build_dialog() -> void:
	_dialog = Control.new()
	_dialog.name = "NetworkErrorDialog"
	_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	_dialog.visible = false
	add_child(_dialog)

	var dim := ColorRect.new()
	dim.name = "DimBackground"
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dialog.add_child(dim)

	var panel := PanelContainer.new()
	panel.name = "DialogPanel"
	panel.anchor_left = 0.25
	panel.anchor_right = 0.75
	panel.anchor_top = 0.35
	panel.anchor_bottom = 0.65
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	_dialog.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "DialogVBox"
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	_dialog_title = Label.new()
	_dialog_title.name = "DialogTitle"
	_dialog_title.text = "网络异常"
	_dialog_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dialog_title.add_theme_font_size_override("font_size", 28)
	_dialog_title.add_theme_color_override("font_color", COLOR_BAD)
	vbox.add_child(_dialog_title)

	_dialog_desc = Label.new()
	_dialog_desc.name = "DialogDesc"
	_dialog_desc.text = ""
	_dialog_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dialog_desc.add_theme_font_size_override("font_size", 18)
	_dialog_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_dialog_desc)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 24)
	btn_row.name = "DialogButtonRow"
	vbox.add_child(btn_row)

	btn_row.add_child(_make_dialog_button("返回主菜单", true, _on_back_to_menu_pressed))
	btn_row.add_child(_make_dialog_button("退出游戏", false, _on_quit_pressed))


func _make_panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.12, 0.12, 0.18, 0.98)
	s.border_color = Color(0.8, 0.6, 0.2)
	s.border_width_left = 3
	s.border_width_right = 3
	s.border_width_top = 3
	s.border_width_bottom = 3
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_bottom_right = 8
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 24
	s.content_margin_bottom = 24
	return s


func _make_dialog_button(text: String, primary: bool, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(140, 44)
	btn.add_theme_font_size_override("font_size", 18)
	if primary:
		btn.add_theme_color_override("font_color", COLOR_WARN)
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.6))
	btn.pressed.connect(callback)
	return btn


func _show_dialog(reason: String) -> void:
	if _dialog_shown:
		return
	if not REASON_TEXT.has(reason):
		reason = "disconnected"
	var desc: String = REASON_TEXT[reason]
	if desc == "":
		return
	_dialog_shown = true
	_dialog_desc.text = desc
	_dialog.visible = true
	# 状态条同步变红
	_set_status("Disconnected", COLOR_BAD)


func _hide_dialog() -> void:
	_dialog_shown = false
	_dialog.visible = false


# ============== RelayManager 信号回调 ==============

func _on_connected() -> void:
	_status_bar.visible = true
	_set_status("Connected", COLOR_OK)


func _on_connection_lost(reason: String) -> void:
	_set_status("Disconnected", COLOR_BAD)
	_show_dialog(reason)


func _on_ping_updated(ms: int) -> void:
	if not _status_bar.visible:
		_status_bar.visible = true
	if ms <= 100:
		_set_status("Connected · %dms" % ms, COLOR_OK)
	elif ms <= 250:
		_set_status("Connected · %dms" % ms, COLOR_WARN)
	else:
		_set_status("Lag · %dms" % ms, COLOR_WARN)


# ============== 对话框按钮回调 ==============

func _on_back_to_menu_pressed() -> void:
	_hide_dialog()
	_status_bar.visible = false
	# 清理网络状态再切场景
	if RelayManager.is_online:
		RelayManager.disconnect_from_server()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
