extends Node2D
## 据点指挥官状态浮动 panel（世界空间，圈中心定位 + viewport culling）
##
## 由于 OutpostCommander.visible=false（隐身士气节点），
## panel 不能作为 commander 子节点（否则会被 parent 的 visible=false 隐藏）。
## panel 作为 commander 的 sibling（添加到 scene root），每帧追踪 commander.global_position。
##
## 显隐逻辑（v4）：
## - master 开关（F4）：默认关。OutpostCommanderManager 持有 _panels_visible
## - viewport culling：F4 开启后，仅当相机视野与该指挥官领地圈相交时才显示
## - panel 中心 = commander.global_position（领地圈中心），用户接受"可能挡战斗"的 trade-off
##
## 显示内容：
## 1. 指挥官 uid（小字）+ current_strategy（中文）
## 2. 法力进度条 + 数值
## 3. 战术点进度条 + 数值
## 4. 金币数值
## 5. 5 个 spell cooldown 方格（H/I/S/C/R 字母 + ready/cooldown 状态）

var commander: Node2D = null  # 弱引用，commander queue_free 时自动 queue_free
var _user_enabled: bool = false  # F4 总开关状态，由 manager 设置

const PANEL_W := 220.0
const PANEL_H := 148.0
const BAR_W := 140.0
const BAR_H := 8.0
const SQUARE_SIZE := 22.0
const SQUARE_GAP := 6.0

const MANA_COLOR := Color(0.63, 0.25, 1.00)        # 紫
const SP_COLOR := Color(1.00, 0.55, 0.16)          # 橙
const BG_COLOR := Color(0.05, 0.05, 0.10, 0.88)
const BORDER_COLOR := Color(0.30, 0.30, 0.40, 0.95)

const STRATEGY_LABEL := {
	&"attack": "出击",
	&"coordinate": "协同",
	&"defend": "防守",
	&"expand": "扩张",
	&"": "—",
}

# 5 个 spell 的字母 + 颜色（与 telegraph_overlay 一致）
const SPELL_LETTERS := [
	{ id = &"heal",            letter = "H", color = Color(0.15, 0.95, 0.35) },
	{ id = &"inspire",         letter = "I", color = Color(1.00, 0.82, 0.29) },
	{ id = &"shield",          letter = "S", color = Color(0.00, 0.85, 0.95) },
	{ id = &"call_to_arms",    letter = "C", color = Color(1.00, 0.40, 0.30) },
	{ id = &"release_garrison", letter = "R", color = Color(0.85, 0.60, 0.40) },
]

var _info_label: Label


func _ready() -> void:
	z_index = 60
	_info_label = Label.new()
	_info_label.name = "InfoLabel"
	_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_info_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_info_label.add_theme_font_size_override("font_size", 13)
	_info_label.add_theme_color_override("font_color", Color.WHITE)
	_info_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_info_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	_info_label.add_theme_constant_override("shadow_offset_x", 1)
	_info_label.add_theme_constant_override("shadow_offset_y", 1)
	_info_label.add_theme_constant_override("outline_size", 4)
	_info_label.size = Vector2(PANEL_W - 16.0, PANEL_H)
	_info_label.position = Vector2(8.0, 6.0)
	add_child(_info_label)


func _process(_delta: float) -> void:
	if commander == null or not is_instance_valid(commander):
		queue_free()
		return
	# panel 中心 = commander 位置（领地圈中心）
	global_position = commander.global_position - Vector2(PANEL_W / 2.0, PANEL_H / 2.0)
	# 显隐：master 开关 AND viewport culling
	visible = _user_enabled and _is_in_camera_viewport()
	if visible:
		queue_redraw()


## 由 OutpostCommanderManager._refresh_panel_layout 调用：设置 F4 总开关状态
func set_user_enabled(enabled: bool) -> void:
	_user_enabled = enabled


## 检测指挥官领地圈是否与相机视野相交（相交即显示 panel）
func _is_in_camera_viewport() -> bool:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return true  # 兜底：没相机就一直显示
	var cam_center := cam.get_screen_center_position()
	var half := get_viewport_rect().size / 2.0
	var cam_rect := Rect2(cam_center - half, half * 2.0)
	var radius: float = float(commander.config.territory_radius) if commander.config != null else 350.0
	# 扩边 radius：相机视野与领地圈相交就显示
	return cam_rect.grow(radius).has_point(commander.global_position)


func _draw() -> void:
	if commander == null or not is_instance_valid(commander) or commander.config == null:
		return
	var cfg: Object = commander.config
	# 背景框
	var rect := Rect2(0.0, 0.0, PANEL_W, PANEL_H)
	draw_rect(rect.grow_individual(2, 3, 2, 3), Color(0, 0, 0, 0.45))
	draw_rect(rect, BG_COLOR)
	draw_rect(rect, BORDER_COLOR, false, 1.5)

	# 顶部彩色横条（按 current_strategy 着色）
	var strat_color: Color = _strategy_color(commander.current_strategy)
	draw_rect(Rect2(0.0, 0.0, PANEL_W, 4.0), strat_color)

	# 文本块（uid + 策略 + 金币）
	var uid_text: String = String(cfg.commander_uid)
	var strat_text: String = "策略：%s" % STRATEGY_LABEL.get(commander.current_strategy, "—")
	var gold_text: String = "金币 %d / %d" % [commander.gold, cfg.gold_max]
	_info_label.text = "%s\n%s\n\n\n\n%s" % [uid_text, strat_text, gold_text]

	# 法力条（y=58）
	_draw_progress_bar(Vector2(8.0, 58.0), BAR_W, BAR_H,
		commander.mana / float(cfg.mana_max), MANA_COLOR,
		"%.0f / %.0f" % [commander.mana, float(cfg.mana_max)])
	# 战术条（y=78）
	_draw_progress_bar(Vector2(8.0, 78.0), BAR_W, BAR_H,
		float(commander.strategy_points) / float(cfg.strategy_max), SP_COLOR,
		"%.1f / %d" % [commander.strategy_points, cfg.strategy_max])

	# 分隔线
	draw_line(Vector2(8.0, 100.0), Vector2(PANEL_W - 8.0, 100.0),
		Color(0.30, 0.30, 0.40, 0.7), 1.0)

	# Spell cooldown 方格（y=110）
	_draw_cooldown_squares(8.0, 110.0)


func _draw_progress_bar(top_left: Vector2, w: float, h: float, ratio: float, color: Color, value_text: String) -> void:
	ratio = clampf(ratio, 0.0, 1.0)
	# 背景
	draw_rect(Rect2(top_left, Vector2(w, h)), Color(0.20, 0.20, 0.25, 0.95))
	# 填充
	if ratio > 0.0:
		draw_rect(Rect2(top_left, Vector2(w * ratio, h)), color)
	# 描边
	draw_rect(Rect2(top_left, Vector2(w, h)), Color(0.10, 0.10, 0.15), false, 1.0)
	# 数值文本（条右侧）
	draw_string(_default_font(), top_left + Vector2(w + 6.0, h - 1.0), value_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.90, 0.90, 0.95, 0.95))


func _draw_cooldown_squares(start_x: float, start_y: float) -> void:
	# 检查每个 spell 是否启用 + 是否冷却中
	var enabled: Array = commander.config.enabled_spells
	var cooldowns: Dictionary = commander.spell_cooldowns
	for i in range(SPELL_LETTERS.size()):
		var entry: Dictionary = SPELL_LETTERS[i]
		var pos := Vector2(start_x + i * (SQUARE_SIZE + SQUARE_GAP), start_y)
		var spell_id: StringName = entry.id
		var letter: String = entry.letter
		var color: Color = entry.color
		var enabled_flag: bool = spell_id in enabled
		var cd_remain: float = float(cooldowns.get(spell_id, 0.0))
		var is_ready: bool = enabled_flag and cd_remain <= 0.0
		# 背景方块
		var bg_alpha: float = 0.95 if enabled_flag else 0.30
		draw_rect(Rect2(pos, Vector2(SQUARE_SIZE, SQUARE_SIZE)),
			Color(0.10, 0.10, 0.15, bg_alpha))
		# 描边（ready=彩色，cooldown=灰）
		var border_col: Color = color if is_ready else Color(0.45, 0.45, 0.50, 0.95)
		draw_rect(Rect2(pos, Vector2(SQUARE_SIZE, SQUARE_SIZE)), border_col, false, 1.5)
		# 字母
		var text_col: Color
		if not enabled_flag:
			text_col = Color(0.40, 0.40, 0.45, 0.85)
		elif is_ready:
			text_col = color
		else:
			text_col = Color(0.70, 0.70, 0.75, 0.95)
		draw_string(_default_font(),
			pos + Vector2(SQUARE_SIZE / 2.0 - 5.0, SQUARE_SIZE - 6.0),
			letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, text_col)
		# 冷却剩余秒数（小字）
		if enabled_flag and cd_remain > 0.0:
			draw_string(_default_font(),
				pos + Vector2(SQUARE_SIZE / 2.0 - 7.0, SQUARE_SIZE + 11.0),
				"%.0f" % cd_remain, HORIZONTAL_ALIGNMENT_LEFT, -1, 10,
				Color(0.90, 0.65, 0.40, 0.95))


func _strategy_color(strategy_id: StringName) -> Color:
	match strategy_id:
		&"attack":
			return Color(1.00, 0.25, 0.25)
		&"coordinate":
			return Color(1.00, 0.55, 0.16)
		&"defend":
			return Color(0.30, 0.55, 1.00)
		&"expand":
			return Color(0.30, 1.00, 0.55)
		_:
			return Color(0.50, 0.50, 0.55)


func _default_font() -> Font:
	# Node2D 上没有 get_theme_default_font()，直接用 ThemeDB
	return ThemeDB.get_default_theme().default_font
