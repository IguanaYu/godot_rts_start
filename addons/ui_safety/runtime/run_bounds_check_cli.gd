extends SceneTree
## L4 headless 校验 CLI 入口。
##
## 用法：
##   godot --headless --path <project> --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd
##   godot --headless --path <project> --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd -- scene main_menu.tscn
##
## 退出码：
##   0 = 无 issue（OK）
##   1 = 有 issue（FAIL，stderr/stdout 输出详情）
##   2 = 加载/初始化失败（ERROR）
##
## 给 PostToolUse hook 用：Claude 改完 UI 文件后跑这个，issue 报告塞回给 Claude 修复。

const DEFAULT_SCENE_PATH := "res://scenes/main.tscn"
const STAT_FRAMES := 8  # 等待主场景 + UI _ready 的帧数


func _init() -> void:
	_start()


func _start() -> void:
	await process_frame
	# headless 模式默认 viewport 是 1280×1280 而非项目配置的 1280×720，
	# 必须强制设为项目配置值，layout 才会按真实游戏窗口算
	var vp_w: int = int(ProjectSettings.get_setting("display/window/size/viewport_width", 1280))
	var vp_h: int = int(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
	root.size = Vector2i(vp_w, vp_h)
	root.set_size(Vector2i(vp_w, vp_h))
	await process_frame

	var scene_path := _parse_scene_arg()
	print("[run_bounds_check_cli] loading scene: %s (viewport=%dx%d)" % [scene_path, vp_w, vp_h])
	var packed: PackedScene = load(scene_path)
	if packed == null:
		print("[run_bounds_check_cli] ERROR: failed to load %s" % scene_path)
		quit(2)
		return
	var instance: Node = packed.instantiate()
	root.add_child(instance)

	# 等若干帧让 UI 子树完整 _ready（VBoxContainer/HBoxContainer 的 sort_children 是延迟的）
	for i in STAT_FRAMES:
		await process_frame

	var validator: Node = root.get_node_or_null("/root/UIBoundsValidator")
	if validator == null or not is_instance_valid(validator):
		print("[run_bounds_check_cli] ERROR: UIBoundsValidator autoload not found")
		quit(2)
		return

	var issues: Array = validator.validate_all()
	var scanned: int = int(validator.get("_stats_total_scanned"))

	if issues.is_empty():
		print("[run_bounds_check_cli] OK: no UI bounds issues (%d controls scanned)" % scanned)
		quit(0)
	else:
		# stdout 给人类读
		print("[run_bounds_check_cli] FAIL: %d UI bounds issues found (%d controls scanned):" % [issues.size(), scanned])
		for i in issues:
			print("  " + validator.format_one_issue(i))
		# stderr 给 Claude Code hook 读（hook 会把 stderr 当成反馈塞给 Claude）
		printerr("\n=== UI Bounds Validator found %d issue(s) ===" % issues.size())
		printerr(validator.format_issues(issues))
		printerr("=== Please fix these before submitting ===\n")
		quit(1)


func _parse_scene_arg() -> String:
	# 支持 `-- scene foo.tscn` 的方式指定场景
	var args := OS.get_cmdline_args()
	for i in range(args.size() - 1):
		if args[i] == "--scene":
			var val: String = args[i + 1]
			if not val.begins_with("res://"):
				val = "res://" + val
			return val
	# 检测无 -- 前缀的 trailing arg（godot --script xxx -- main_menu.tscn）
	for i in range(args.size()):
		if args[i] == "--" and i + 1 < args.size():
			var val: String = args[i + 1]
			if val.ends_with(".tscn"):
				if not val.begins_with("res://"):
					val = "res://" + val
				return val
	return DEFAULT_SCENE_PATH
