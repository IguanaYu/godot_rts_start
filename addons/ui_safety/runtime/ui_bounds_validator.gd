extends CanvasLayer
## UI Safety 核心 autoload。
##
## 跨所有 CanvasLayer 递归遍历 Control 节点，检测：
## - OUT_OF_BOUNDS：rect 越出 viewport
## - OVERLAP：同级 Control 重叠（MarginContainer 白名单）
## - SIZE_TOO_SMALL：size 小于 combined_minimum_size
##
## 三种交互模式：
## - F3 Outline：所有 Control 描边，按 issue 类型上色
## - F4 Pick：鼠标悬停 Control，显示该节点 + 祖先链的 rect/mouse_filter/visible
## - F5 Stats：跑一次校验，push_warning 所有 issue + 屏幕左下角统计
## - ESC：关闭所有模式
##
## 借鉴：Flutter debugPaintSizeEnabled / Unreal Widget Reflector Pick Hit-Testable
## 参考：scripts/debug/aggro_debug_hud.gd（CanvasLayer layer=50 + F1 切换 + Control overlay）

signal validation_completed(issues: Array[Dictionary])

enum Mode { DISABLED, OUTLINE, PICK, STATS }

const SELF_PATH_PREFIX := "/root/UIBoundsValidator"

const COLOR_OK := Color(0.30, 1.00, 0.30, 0.65)
const COLOR_OUT_OF_BOUNDS := Color(1.00, 0.25, 0.25, 0.95)
const COLOR_OVERLAP := Color(1.00, 0.85, 0.20, 0.90)
const COLOR_SIZE_TOO_SMALL := Color(0.30, 0.55, 1.00, 0.90)
const COLOR_IN_SCROLL := Color(0.55, 0.55, 0.60, 0.40)
const OUTLINE_WIDTH := 1.5
const VIEWPORT_TOLERANCE := 0.5

const _STATS_LABEL_NAME := "UIBoundsStatsLabel"
const _PICK_LABEL_NAME := "UIBoundsPickLabel"
const _OVERLAY_NAME := "UIBoundsOutlineOverlay"

var _mode: Mode = Mode.DISABLED
var _overlay: Control
var _pick_label: Label
var _stats_label: Label
var _stats_issues: Array[Dictionary] = []
var _stats_total_scanned: int = 0
var _last_stats_at_msec: int = 0


func _ready() -> void:
	layer = 50
	_build_ui()
	print("[UIBoundsValidator] ready — F3 outline / F4 pick / F5 stats / ESC close")


func _build_ui() -> void:
	_overlay = Control.new()
	_overlay.name = _OVERLAY_NAME
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.draw.connect(_on_overlay_draw)
	_overlay.visible = false
	add_child(_overlay)

	_pick_label = Label.new()
	_pick_label.name = _PICK_LABEL_NAME
	_pick_label.add_theme_font_size_override("font_size", 13)
	_pick_label.add_theme_color_override("font_color", Color.WHITE)
	_pick_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	_pick_label.add_theme_constant_override("shadow_offset_x", 1)
	_pick_label.add_theme_constant_override("shadow_offset_y", 1)
	_pick_label.visible = false
	add_child(_pick_label)

	_stats_label = Label.new()
	_stats_label.name = _STATS_LABEL_NAME
	_stats_label.add_theme_font_size_override("font_size", 13)
	_stats_label.add_theme_color_override("font_color", Color.WHITE)
	_stats_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	_stats_label.add_theme_constant_override("shadow_offset_x", 1)
	_stats_label.add_theme_constant_override("shadow_offset_y", 1)
	_stats_label.position = Vector2(10, 100)
	_stats_label.size = Vector2(560, 400)
	_stats_label.visible = false
	add_child(_stats_label)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_F3:
			_cycle_mode()
			get_viewport().set_input_as_handled()
		KEY_F4:
			_set_mode(Mode.PICK if _mode != Mode.PICK else Mode.DISABLED)
			get_viewport().set_input_as_handled()
		KEY_F5:
			_run_stats_once()
			get_viewport().set_input_as_handled()
		KEY_ESCAPE:
			if _mode != Mode.DISABLED:
				_set_mode(Mode.DISABLED)
				get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if _mode == Mode.OUTLINE:
		_overlay.queue_redraw()
	elif _mode == Mode.PICK:
		_update_pick_label()


func _cycle_mode() -> void:
	var next: int = _mode + 1
	if next > Mode.STATS:
		next = Mode.DISABLED
	_set_mode(next as Mode)


func _set_mode(m: Mode) -> void:
	_mode = m
	_overlay.visible = (m == Mode.OUTLINE)
	_pick_label.visible = (m == Mode.PICK)
	_stats_label.visible = (m == Mode.STATS and not _stats_issues.is_empty())
	if _overlay.visible:
		_overlay.queue_redraw()


# ========== 校验主逻辑 ==========

func validate_all() -> Array[Dictionary]:
	## 跨所有 CanvasLayer 递归扫所有 Control，返回 issue 列表。
	## 副作用：无。可被 hook / CLI 反复调用。
	var issues: Array[Dictionary] = []
	var vp := get_viewport().get_visible_rect()
	var vp_end := Vector2(vp.end.x, vp.end.y)
	var vp_pos := Vector2(vp.position.x, vp.position.y)
	var total_scanned: int = 0
	# 已知 OOB 节点路径集合：用于跳过其后代（避免一个 OOB 容器报 N 次子节点）
	var oob_paths: PackedStringArray = []

	var all_controls: Array[Node] = []
	_collect_all_controls(get_tree().root, all_controls)

	for c in all_controls:
		if not (c is Control):
			continue
		if not (c as Control).is_visible_in_tree():
			continue
		if _is_self_debug(c):
			continue
		if not _is_in_main_viewport(c):
			continue
		total_scanned += 1
		var ctrl := c as Control
		var r := ctrl.get_global_rect()
		var clip_ancestor := _find_clipping_scroll_ancestor(ctrl)

		# 越界检测
		var out_of_bounds := false
		var path_str := str(ctrl.get_path())
		if clip_ancestor != null:
			# 在 clip 的 ScrollContainer 内，仅检查是否越出 scroll 本身（scroll 自己另有判定）
			pass
		elif _has_oob_ancestor(ctrl, oob_paths):
			# 父节点已经 OOB，子节点必然 OOB，跳过避免噪声
			out_of_bounds = true
		elif r.end.x > vp_end.x + VIEWPORT_TOLERANCE \
		  or r.end.y > vp_end.y + VIEWPORT_TOLERANCE \
		  or r.position.x < vp_pos.x - VIEWPORT_TOLERANCE \
		  or r.position.y < vp_pos.y - VIEWPORT_TOLERANCE:
			issues.append({
				"type": "OUT_OF_BOUNDS",
				"path": path_str,
				"rect": _rect_to_str(r),
			})
			oob_paths.append(path_str)
			out_of_bounds = true

		# size 不足（不与越界叠加报）
		if not out_of_bounds:
			var min_size := ctrl.get_combined_minimum_size()
			if min_size.x > ctrl.size.x + VIEWPORT_TOLERANCE \
		   or min_size.y > ctrl.size.y + VIEWPORT_TOLERANCE:
				issues.append({
					"type": "SIZE_TOO_SMALL",
					"path": str(ctrl.get_path()),
					"rect": _rect_to_str(r),
					"min_size": "%.0f,%.0f" % [min_size.x, min_size.y],
				})

		# 同级重叠（白名单：MarginContainer 故意让子重叠 margin 区）
		var parent := ctrl.get_parent()
		# 装饰组白名单：父节点是 wrapper（含 Button 子节点，或含 NinePatchRect 背景），
		# 它的孩子们（ButtonBG + TextureRect + Label + Button + CostLabel / 框架 + 内容）故意叠在同区域
		var parent_is_decorator_wrapper := false
		if parent != null and not (parent is MarginContainer):
			parent_is_decorator_wrapper = _is_decorator_wrapper(parent)
		if not parent_is_decorator_wrapper and parent != null and not (parent is MarginContainer):
			for sib in parent.get_children():
				if sib == ctrl:
					continue
				if not (sib is Control):
					continue
				if not (sib as Control).is_visible_in_tree():
					continue
				if _is_self_debug(sib):
					continue
				var sib_ctrl := sib as Control
				var sib_r := sib_ctrl.get_global_rect()
				if not r.intersects(sib_r):
					continue
				# 装饰层叠白名单：一个 sib 完全 contain 另一个 → 跳过
				# （例如 button_factory 的 ButtonBG + TextureRect + Label 故意叠在同区域）
				if r.encloses(sib_r) or sib_r.encloses(r):
					continue
				issues.append({
					"type": "OVERLAP",
					"path": str(ctrl.get_path()),
					"rect": _rect_to_str(r),
					"sibling": str(sib.get_path()),
				})
				break  # 同节点只报一次重叠

	_stats_total_scanned = total_scanned
	_stats_issues = issues
	_last_stats_at_msec = Time.get_ticks_msec()
	validation_completed.emit(issues.duplicate(true))
	return issues


static func format_issues(issues: Array[Dictionary]) -> String:
	## 给 hook / CLI 用，输出 Claude 可读的多行文本。
	var lines: PackedStringArray = []
	for i in issues:
		lines.append(format_one_issue(i))
	return "\n".join(lines)


static func format_one_issue(i: Dictionary) -> String:
	var s := "[%s] %s rect=%s" % [str(i.get("type", "?")), str(i.get("path", "?")), str(i.get("rect", "?"))]
	if i.has("sibling"):
		s += " sibling=" + str(i.sibling)
	if i.has("min_size"):
		s += " min_size=" + str(i.min_size)
	return s


# ========== Stats 模式 ==========

func _run_stats_once() -> void:
	var issues := validate_all()
	if issues.is_empty():
		print("[UIBoundsValidator] No issues found (%d controls scanned)" % _stats_total_scanned)
	else:
		print("[UIBoundsValidator] %d issues found:" % issues.size())
		for i in issues:
			var line := format_one_issue(i)
			push_warning("[UIBounds] " + line)
			print("  " + line)
	_stats_label.text = _format_stats_summary()
	_set_mode(Mode.STATS)


func _format_stats_summary() -> String:
	var counts := {"OUT_OF_BOUNDS": 0, "OVERLAP": 0, "SIZE_TOO_SMALL": 0}
	for i in _stats_issues:
		var t := str(i.get("type", ""))
		counts[t] = counts.get(t, 0) + 1
	var age_sec: float = (Time.get_ticks_msec() - _last_stats_at_msec) / 1000.0
	return "[UIBoundsValidator Stats — F3 cycle / F5 rerun / ESC close]\n" + \
		"Scanned: %d controls   Issues: %d   (last run %.1fs ago)\n" % [_stats_total_scanned, _stats_issues.size(), age_sec] + \
		"  OUT_OF_BOUNDS  : %d\n" % counts["OUT_OF_BOUNDS"] + \
		"  OVERLAP        : %d\n" % counts["OVERLAP"] + \
		"  SIZE_TOO_SMALL : %d" % counts["SIZE_TOO_SMALL"]


# ========== Pick 模式 ==========

func _update_pick_label() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered == null or _is_self_debug(hovered):
		_pick_label.text = "[UIBounds Pick — F4 close]\n(hover a Control)"
		_pick_label.size = Vector2(300, 50)
	else:
		var lines: PackedStringArray = []
		lines.append("[UIBounds Pick — F4 close]")
		lines.append("(top of stack is what receives the click)")
		lines.append("")
		var p: Node = hovered
		var depth := 0
		while p != null and p is Control and depth < 24:
			var ctrl := p as Control
			var mf: String = _mouse_filter_name(ctrl.mouse_filter)
			var vis: String = "V" if ctrl.is_visible_in_tree() else "HIDDEN"
			var r := ctrl.get_global_rect()
			lines.append("%s%s [mf=%s vis=%s] rect=(%.0f,%.0f %.0fx%.0f)" % [
				"  ".repeat(depth), ctrl.name, mf, vis,
				r.position.x, r.position.y, r.size.x, r.size.y,
			])
			p = p.get_parent()
			depth += 1
		_pick_label.text = "\n".join(lines)
	_pick_label.position = Vector2(vp_size.x - _pick_label.size.x - 12, 12)
	_pick_label.size = Vector2(min(_pick_label.size.x + 20, vp_size.x - 24), _pick_label.get_combined_minimum_size().y + 12)


static func _mouse_filter_name(mf: int) -> String:
	match mf:
		Control.MOUSE_FILTER_STOP:
			return "STOP"
		Control.MOUSE_FILTER_PASS:
			return "PASS"
		Control.MOUSE_FILTER_IGNORE:
			return "IGNORE"
		_:
			return str(mf)


# ========== Outline 绘制 ==========

func _on_overlay_draw() -> void:
	if _mode != Mode.OUTLINE:
		return
	# 用最近一次 stats 结果给 issue 节点上色；没有 stats 就用 OK 色
	var issue_by_path: Dictionary = {}
	for i in _stats_issues:
		issue_by_path[str(i.get("path", ""))] = str(i.get("type", ""))
	var all_controls: Array[Node] = []
	_collect_all_controls(get_tree().root, all_controls)
	for c in all_controls:
		if not (c is Control):
			continue
		if not (c as Control).is_visible_in_tree():
			continue
		if _is_self_debug(c):
			continue
		if not _is_in_main_viewport(c):
			continue
		var ctrl := c as Control
		var r := ctrl.get_global_rect()
		var path_str := str(ctrl.get_path())
		var color: Color = COLOR_OK
		var issue_type: String = str(issue_by_path.get(path_str, ""))
		if issue_type == "OUT_OF_BOUNDS":
			color = COLOR_OUT_OF_BOUNDS
		elif issue_type == "OVERLAP":
			color = COLOR_OVERLAP
		elif issue_type == "SIZE_TOO_SMALL":
			color = COLOR_SIZE_TOO_SMALL
		elif _find_clipping_scroll_ancestor(ctrl) != null:
			color = COLOR_IN_SCROLL
		_overlay.draw_rect(r, color, false, OUTLINE_WIDTH)


# ========== 私有辅助 ==========

func _is_self_debug(n: Node) -> bool:
	if n == null:
		return false
	return str(n.get_path()).begins_with(SELF_PATH_PREFIX)


func _collect_all_controls(node: Node, out: Array) -> void:
	## 递归收集所有 Control 类型的节点（含子类）。
	## 比 find_children 更可靠：能跨 CanvasLayer / SubViewport / 各种 Node 容器。
	if node == null or not is_instance_valid(node):
		return
	if node is Control:
		out.append(node)
	for c in node.get_children():
		_collect_all_controls(c, out)


func _is_in_main_viewport(c: Control) -> bool:
	## 判定 Control 是否在"主 viewport 的 UI 空间"（而非世界空间）：
	## - SubViewport 内的不算（如 SubViewportContainer 嵌入的小预览）
	## - 走祖先链，先碰到 CanvasLayer → UI 空间，校验
	## - 走祖先链，先碰到 Node2D/Node3D → 世界空间（HPBar/伤害飘字/头顶进度条），
	##   它们的 rect 是世界坐标，越界检查无意义，跳过
	## - 都没碰到（纯 Control 树直接挂 root）→ 算 UI 空间
	var p: Node = c.get_parent()
	while p != null:
		if p is SubViewport:
			return false
		if p is CanvasLayer:
			return true
		if p is Node2D or p is Node3D:
			return false
		p = p.get_parent()
	return true


func _find_clipping_scroll_ancestor(c: Control) -> ScrollContainer:
	## 返回最近的 clip_contents=true 的 ScrollContainer 祖先（可能为 null）
	var p: Node = c.get_parent()
	while p != null:
		if p is ScrollContainer:
			var sc := p as ScrollContainer
			if sc.clip_contents:
				return sc
		p = p.get_parent()
	return null


static func _rect_to_str(r: Rect2) -> String:
	return "(%.0f,%.0f %.0fx%.0f)" % [r.position.x, r.position.y, r.size.x, r.size.y]


static func _is_decorator_wrapper(parent: Node) -> bool:
	## 装饰组 wrapper 判定：父节点直接含 Button 子节点（button_factory 模式）
	## 或含 NinePatchRect 背景（按钮 / 地图框 / 技能槽等"frame + content"模式）。
	## 这种 wrapper 的孩子们故意叠在同区域。
	for c in parent.get_children():
		if c is Button:
			return true
		if c is NinePatchRect:
			return true
	return false


static func _has_oob_ancestor(ctrl: Control, oob_paths: PackedStringArray) -> bool:
	## 检查 ctrl 的祖先链是否有任一节点已在 oob_paths 中。
	## 用于"父已 OOB → 子必然 OOB"的去重，避免一次容器越界报 N 次子节点。
	var p: Node = ctrl.get_parent()
	while p != null:
		var p_str := str(p.get_path())
		for op in oob_paths:
			if op == p_str:
				return true
		p = p.get_parent()
	return false
