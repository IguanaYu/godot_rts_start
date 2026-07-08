extends Node
## 测试运行器：加载并执行所有测试套件，汇总结果，退出码 0=全过 1=有失败
## 带截图功能：在关键节点截图保存到 user://test_screenshots/

const Assertions := preload("res://scripts/test/assertions.gd")

# 测试注册表：套件名 -> 测试脚本路径
const _SUITES := {
	"commander_skill.can_cast": "res://scripts/test/commander_skill/test_can_cast.gd",
	"combat.attack_building": "res://scripts/test/combat/test_attack_building.gd",
	# 后续追加：
	# "commander_skill.energy_cooldown": "res://scripts/test/commander_skill/test_energy_cooldown.gd",
	# "commander_skill.cast_flow": "res://scripts/test/commander_skill/test_cast_flow.gd",
}

var _assertions: RefCounted
var _filter: String = ""
var _screenshot_dir: String = "user://test_screenshots/"
var _screenshot_index: int = 0
var _status_label: Label
var _detail_label: Label


func _ready() -> void:
	_assertions = Assertions.new()
	_parse_args()
	_ensure_screenshot_dir()
	_create_ui()
	print("\n=== rts_base 测试运行器 ===")
	print("截图目录: %s" % ProjectSettings.globalize_path(_screenshot_dir))
	if _filter != "":
		print("过滤: %s" % _filter)
	print("")
	_update_status("测试启动中...")
	_take_screenshot("00_start")
	await get_tree().create_timer(0.3).timeout  # 等一帧让 UI 渲染
	await _run_all_tests()
	_print_summary()
	_take_screenshot("99_summary")
	await get_tree().create_timer(0.3).timeout
	var exit_code: int = 1 if _assertions.get_fail_count() > 0 else 0
	get_tree().quit(exit_code)


func _parse_args() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_filter = args[0]


func _ensure_screenshot_dir() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("test_screenshots"):
		dir.make_dir("test_screenshots")


func _create_ui() -> void:
	# CanvasLayer 确保 UI 在最上层
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	# 背景面板
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 20
	panel.offset_top = 20
	panel.offset_right = -20
	panel.offset_bottom = -20
	layer.add_child(panel)

	# 标题 Label
	_status_label = Label.new()
	_status_label.position = Vector2(40, 40)
	_status_label.add_theme_font_size_override("font_size", 28)
	_status_label.text = "rts_base 测试运行器"
	panel.add_child(_status_label)

	# 详情 Label
	_detail_label = Label.new()
	_detail_label.position = Vector2(40, 90)
	_detail_label.add_theme_font_size_override("font_size", 18)
	_detail_label.text = "准备中..."
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.custom_minimum_size = Vector2(800, 400)
	panel.add_child(_detail_label)


func _update_status(status: String) -> void:
	if _status_label:
		_status_label.text = status


func _update_detail(detail: String) -> void:
	if _detail_label:
		_detail_label.text = detail


func _take_screenshot(name: String) -> void:
	await get_tree().process_frame  # 等一帧确保渲染完成
	var img := get_viewport().get_texture().get_image()
	if img == null:
		print("  [截图失败] %s - 无法获取视口图像" % name)
		return
	var path := _screenshot_dir + name + ".png"
	var err := img.save_png(path)
	if err == OK:
		var abs_path := ProjectSettings.globalize_path(path)
		print("  [截图] %s -> %s" % [name, abs_path])
	else:
		print("  [截图失败] %s - 保存错误 code=%d" % [name, err])


func _run_all_tests() -> void:
	var detail_lines := []
	for suite_name in _SUITES:
		if _filter != "" and not _filter.is_subsequence_of(suite_name):
			continue
		print("[ %s ]" % suite_name)
		_update_status("运行: %s" % suite_name)
		_update_detail("")
		_take_screenshot("%02d_%s_start" % [_screenshot_index, suite_name.get_file()])
		_screenshot_index += 1

		var script := load(_SUITES[suite_name])
		if script == null:
			print("  ERROR: 无法加载 %s" % _SUITES[suite_name])
			detail_lines.append("%s: 加载失败" % suite_name)
			_update_detail("\n".join(detail_lines))
			continue
		var test = script.new()
		var before_pass: int = _assertions.get_pass_count()
		var before_fail: int = _assertions.get_fail_count()
		await test.run(_assertions, self)
		var suite_pass: int = _assertions.get_pass_count() - before_pass
		var suite_fail: int = _assertions.get_fail_count() - before_fail
		print("  -> %d 通过, %d 失败\n" % [suite_pass, suite_fail])
		detail_lines.append("%s: %d 通过 / %d 失败" % [suite_name, suite_pass, suite_fail])
		_update_detail("\n".join(detail_lines))
		_take_screenshot("%02d_%s_end" % [_screenshot_index, suite_name.get_file()])
		_screenshot_index += 1


func _print_summary() -> void:
	var total: int = _assertions.get_pass_count() + _assertions.get_fail_count()
	print("=== 汇总 ===")
	print("测试数: %d | 通过: %d | 失败: %d" % [total, _assertions.get_pass_count(), _assertions.get_fail_count()])
	var result_text := "全部通过" if _assertions.get_fail_count() == 0 else "发现失败"
	if _assertions.get_fail_count() > 0:
		print("RESULT: 发现失败")
	else:
		print("RESULT: 全部通过")
	_update_status("完成: %d 通过 / %d 失败" % [_assertions.get_pass_count(), _assertions.get_fail_count()])
	_update_detail("结果: %s\n总计: %d | 通过: %d | 失败: %d" % [result_text, total, _assertions.get_pass_count(), _assertions.get_fail_count()])
