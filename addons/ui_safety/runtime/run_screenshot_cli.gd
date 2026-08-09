extends SceneTree
## L3 截图回归 CLI 入口。
##
## **重要**：必须用 `--no-window` 而不是 `--headless`！
## headless 模式禁用渲染，截不到图（get_image() 返回 null）。
## --no-window 隐藏窗口但仍渲染。
##
## 用法：
##   # 首次跑，建 baseline：
##   godot --no-window --path <project> --script res://addons/ui_safety/runtime/run_screenshot_cli.gd -- --update-baseline
##
##   # 后续跑，对比：
##   godot --no-window --path <project> --script res://addons/ui_safety/runtime/run_screenshot_cli.gd
##
##   # 指定状态名（多个用逗号）：
##   godot --no-window --path <project> --script res://addons/ui_safety/runtime/run_screenshot_cli.gd -- --states=init,unit_selected
##
## 退出码：
##   0 = 无回归（OK）
##   1 = 有回归 / 有差异（FAIL）
##   2 = 加载/初始化失败（ERROR）
##
## 比 L4 bounds check 慢（10-20s），所以默认不挂在 PostToolUse，建议手动 / pre-commit。

const SC_SCRIPT := preload("res://addons/ui_safety/runtime/screenshot_compare.gd")
const DEFAULT_SCENE_PATH := "res://scenes/main.tscn"
const DEFAULT_STATES := ["init"]  # 默认只截初始状态。多状态需要在 _trigger_state 里实现。
const RENDER_WAIT_FRAMES := 12  # 等主场景 + UI _ready + 第一帧稳定绘制


## UI-only 模式下隐藏的"世界空间根节点"类型。
## 这些节点是游戏世界（单位/建筑/地形），渲染非确定性（动画/粒子/镜头抖动），
## 截图回归只关心 UI 布局，所以隐藏它们让结果稳定。
const _WORLD_ROOT_TYPES := ["Node2D", "Node3D"]


func _init() -> void:
	_start()


func _start() -> void:
	await process_frame

	# headless viewport 默认 1280×1280，必须强制设项目配置值
	var vp_w: int = int(ProjectSettings.get_setting("display/window/size/viewport_width", 1280))
	var vp_h: int = int(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
	root.size = Vector2i(vp_w, vp_h)
	root.set_size(Vector2i(vp_w, vp_h))
	await process_frame

	var args := _parse_args()
	var do_update_baseline: bool = args.get("update_baseline", false)
	var ui_only: bool = args.get("ui_only", true)  # 默认开，世界节点非确定性
	var states: PackedStringArray = args.get("states", PackedStringArray(DEFAULT_STATES))

	print("[run_screenshot_cli] loading scene: %s (viewport=%dx%d) states=%s update_baseline=%s ui_only=%s" % [
		DEFAULT_SCENE_PATH, vp_w, vp_h, ",".join(states), do_update_baseline, ui_only,
	])

	var packed: PackedScene = load(DEFAULT_SCENE_PATH)
	if packed == null:
		printerr("[run_screenshot_cli] ERROR: failed to load %s" % DEFAULT_SCENE_PATH)
		quit(2)
		return

	var instance: Node = packed.instantiate()
	root.add_child(instance)

	# 等 UI 完整 _ready + sort_children 完成 + 第一帧画完
	for i in RENDER_WAIT_FRAMES:
		await process_frame

	# UI-only 模式：隐藏世界空间根节点（Node2D/Node3D），让截图只反映 UI 布局
	if ui_only:
		_hide_world_roots(instance)

	var results: Array[Dictionary] = []
	var regressed_count: int = 0
	var missing_baseline_count: int = 0
	var error_count: int = 0

	for state_name in states:
		# 触发状态（默认空状态 = init，未来扩展在 _trigger_state 里加）
		_trigger_state(instance, state_name)
		# 等一帧让 UI 反应
		await process_frame
		await process_frame

		# 截图
		var path := await SC_SCRIPT.take_screenshot(state_name)
		if path == "":
			printerr("[run_screenshot_cli] ERROR: take_screenshot failed for state=%s" % state_name)
			error_count += 1
			results.append({"state": state_name, "status": "ERROR"})
			continue

		if do_update_baseline:
			var ok := SC_SCRIPT.update_baseline(state_name)
			print("[run_screenshot_cli] UPDATE base: state=%s ok=%s path=%s" % [state_name, ok, path])
			results.append({"state": state_name, "status": "UPDATED", "path": path})
			continue

		# 对比
		var cmp := SC_SCRIPT.compare_with_baseline(state_name)
		var status: String
		if not cmp.has_baseline:
			status = "NO_BASELINE"
			missing_baseline_count += 1
		elif cmp.size_mismatch:
			status = "SIZE_MISMATCH"
			regressed_count += 1
		elif cmp.regressed:
			status = "REGRESSED"
			regressed_count += 1
		else:
			status = "OK"
		results.append({
			"state": state_name,
			"status": status,
			"diff_count": cmp.get("diff_count", 0),
			"percent_diff": cmp.get("percent_diff", 0.0),
			"diff_image": cmp.get("diff_image_path", ""),
		})

	# 总结报告
	print("\n[run_screenshot_cli] ===== summary =====")
	for r in results:
		var line := "  [%s] %s" % [r.status, r.state]
		if r.has("diff_count"):
			line += " diff=%d (%.2f%%)" % [r.diff_count, r.percent_diff * 100.0]
		if r.has("diff_image") and r.diff_image != "":
			line += " diff_png=%s" % r.diff_image
		print(line)

	# 退出码逻辑
	if do_update_baseline:
		print("\n[run_screenshot_cli] baseline updated, no comparison done.")
		quit(0)
		return
	if error_count > 0:
		printerr("\n[run_screenshot_cli] FAIL: %d error(s) during capture" % error_count)
		quit(2)
		return
	if missing_baseline_count > 0:
		printerr("\n[run_screenshot_cli] WARN: %d state(s) missing baseline. Run with --update-baseline first." % missing_baseline_count)
		# 不算回归，但提醒
	if regressed_count > 0:
		printerr("\n[run_screenshot_cli] FAIL: %d state(s) regressed" % regressed_count)
		printerr("=== Screenshot regression found in %d state(s) ===" % regressed_count)
		for r in results:
			if r.status == "REGRESSED" or r.status == "SIZE_MISMATCH":
				var msg := "  [%s] %s" % [r.status, r.state]
				if r.has("diff_count"):
					msg += " diff=%d (%.2f%%)" % [r.diff_count, r.percent_diff * 100.0]
				if r.has("diff_image") and r.diff_image != "":
					msg += " → %s" % r.diff_image
				printerr(msg)
		printerr("=== To review: open diff PNGs in tests/screenshots/diff/ ===")
		printerr("=== If intentional, update baseline: rerun with --update-baseline ===")
		quit(1)
		return

	print("\n[run_screenshot_cli] OK: no regression in %d state(s)" % results.size())
	quit(0)


func _trigger_state(scene_root: Node, state_name: String) -> void:
	## 未来扩展：根据 state_name 触发不同 UI 状态。
	## 例如：
	##   "init" → 不做事（默认状态）
	##   "unit_selected" → 调 game_ui 选中第一个 PlayerUnits 子节点
	##   "build_mode" → 触发建造模式
	##
	## 当前仅实现 "init"。
	match state_name:
		"init":
			pass
		_:
			push_warning("[run_screenshot_cli] unknown state: %s (skipping trigger)" % state_name)


func _hide_world_roots(scene_root: Node) -> void:
	## 隐藏场景根下所有 Node2D/Node3D 直接子节点。
	## 这些是世界空间节点（单位/建筑/地形），渲染非确定性。
	## CanvasLayer / Control 等保持显示。
	for c in scene_root.get_children():
		if c == null or not is_instance_valid(c):
			continue
		var t := c.get_class()
		if t in _WORLD_ROOT_TYPES:
			(c as CanvasItem).visible = false


func _parse_args() -> Dictionary:
	## 支持：
	##   --update-baseline  (boolean flag)
	##   --states=init,unit_selected  (comma separated)
	## 用 OS.get_cmdline_user_args() 拿 godot --script xxx -- 后面的参数
	var out: Dictionary = {}
	var real_args: PackedStringArray = OS.get_cmdline_user_args()
	# 兜底：兼容老版本 / 直接调用
	if real_args.is_empty():
		for a in OS.get_cmdline_args():
			if a.begins_with("--states") or a == "--update-baseline" \
				or a == "--ui-only" or a == "--no-ui-only":
				real_args.append(a)

	for a in real_args:
		if a == "--update-baseline":
			out["update_baseline"] = true
		elif a == "--ui-only":
			out["ui_only"] = true
		elif a == "--no-ui-only":
			out["ui_only"] = false
		elif a.begins_with("--states="):
			var val := a.substr("--states=".length())
			out["states"] = PackedStringArray(val.split(",", false))
	return out
