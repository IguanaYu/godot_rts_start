extends RefCounted
## L3 截图回归工具：截图 + baseline 对比 + diff PNG 产出。
##
## 三目录结构：
##   res://tests/screenshots/
##   ├── baseline/   首次跑或主动更新时存
##   ├── current/    每次跑都会重写
##   └── diff/       有差异时产出（白=一致，红=差异）
##
## 用法：
##   1. screenshot_compare.take_screenshot("init_state")
##   2. screenshot_compare.compare_with_baseline("init_state") → Dictionary
##   3. 想更新 baseline: screenshot_compare.update_baseline("init_state")
##
## 像素对比逻辑：逐像素 RGB Manhattan 距离，任一通道差 > PIXEL_THRESHOLD 即视为 diff。
## 容差：默认 0.1%（PERCENT_TOLERANCE），防字体抗锯齿抖动。

const SCREENSHOT_ROOT := "res://tests/screenshots"
const BASELINE_DIR := SCREENSHOT_ROOT + "/baseline"
const CURRENT_DIR := SCREENSHOT_ROOT + "/current"
const DIFF_DIR := SCREENSHOT_ROOT + "/diff"

const PIXEL_THRESHOLD := 30  # 0-255，单通道差 ≥30 视为该像素 diff
const PERCENT_TOLERANCE := 0.001  # 0.1% 像素 diff 算"通过"


static func take_screenshot(name: String) -> String:
	## 截当前 viewport，存到 current/<name>.png。返回绝对路径。
	## 调用方需要 await（防止黑帧）。
	##
	## headless 模式 RenderingServer.frame_post_draw 信号不一定发（draw_calls=0），
	## 改用 SceneTree.process_frame 兜底等几帧。
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	for i in 3:
		await tree.process_frame
	var root_vp: Viewport = Engine.get_main_loop().root
	var tex: ViewportTexture = root_vp.get_texture()
	var img: Image = tex.get_image()
	if img == null:
		push_error("[screenshot_compare] failed to grab viewport image (headless might not render)")
		return ""
	# 转 RGBA8 保证 baseline/current 格式一致
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	_ensure_dir(CURRENT_DIR)
	var path := "%s/%s.png" % [CURRENT_DIR, name]
	var err := img.save_png(path)
	if err != OK:
		push_error("[screenshot_compare] failed to save %s (err=%d)" % [path, err])
		return ""
	return path


static func compare_with_baseline(name: String, percent_tolerance: float = PERCENT_TOLERANCE) -> Dictionary:
	## 与 baseline/<name>.png 对比。返回：
	##   {
	##     has_baseline: bool,
	##     regressed: bool,           # percent > tolerance
	##     diff_count: int,           # diff 像素数
	##     percent_diff: float,       # 0.0~1.0
	##     diff_image_path: String,   # 有 diff 时产出，否则空
	##     size_mismatch: bool,       # baseline 与 current 尺寸不一致
	##   }
	var baseline_path := "%s/%s.png" % [BASELINE_DIR, name]
	var current_path := "%s/%s.png" % [CURRENT_DIR, name]

	if not FileAccess.file_exists(baseline_path):
		return {
			"has_baseline": false, "regressed": false,
			"diff_count": 0, "percent_diff": 0.0,
			"diff_image_path": "", "size_mismatch": false,
		}
	if not FileAccess.file_exists(current_path):
		push_error("[screenshot_compare] current not found: %s" % current_path)
		return {
			"has_baseline": true, "regressed": true,
			"diff_count": -1, "percent_diff": 1.0,
			"diff_image_path": "", "size_mismatch": false,
		}

	var baseline := Image.load_from_file(baseline_path)
	var current := Image.load_from_file(current_path)
	if baseline.get_size() != current.get_size():
		return {
			"has_baseline": true, "regressed": true,
			"diff_count": -1, "percent_diff": 1.0,
			"diff_image_path": "", "size_mismatch": true,
		}

	# 转 RGBA8 保证 bytes 长度对齐
	if baseline.get_format() != Image.FORMAT_RGBA8:
		baseline.convert(Image.FORMAT_RGBA8)
	if current.get_format() != Image.FORMAT_RGBA8:
		current.convert(Image.FORMAT_RGBA8)

	var b_bytes := baseline.get_data()
	var c_bytes := current.get_data()
	var px_count := baseline.get_width() * baseline.get_height()
	var diff_bytes := PackedByteArray()
	diff_bytes.resize(b_bytes.size())

	var diff_count := 0
	for i in range(px_count):
		var o := i * 4  # RGBA stride
		var dr := absi(int(b_bytes[o]) - int(c_bytes[o]))
		var dg := absi(int(b_bytes[o + 1]) - int(c_bytes[o + 1]))
		var db := absi(int(b_bytes[o + 2]) - int(c_bytes[o + 2]))
		if dr >= PIXEL_THRESHOLD or dg >= PIXEL_THRESHOLD or db >= PIXEL_THRESHOLD:
			diff_count += 1
			diff_bytes[o] = 255
			diff_bytes[o + 1] = 0
			diff_bytes[o + 2] = 0
		else:
			diff_bytes[o] = 255
			diff_bytes[o + 1] = 255
			diff_bytes[o + 2] = 0
		diff_bytes[o + 3] = 255

	var percent := float(diff_count) / float(px_count)
	var diff_path := ""
	if diff_count > 0:
		_ensure_dir(DIFF_DIR)
		var diff_img := Image.create_from_data(baseline.get_width(), baseline.get_height(), false, Image.FORMAT_RGBA8, diff_bytes)
		diff_path = "%s/%s.png" % [DIFF_DIR, name]
		diff_img.save_png(diff_path)
	else:
		# 无 diff，删旧 diff PNG（如果之前有）
		var old_diff := "%s/%s.png" % [DIFF_DIR, name]
		if FileAccess.file_exists(old_diff):
			DirAccess.remove_absolute(old_diff)

	return {
		"has_baseline": true,
		"regressed": percent > percent_tolerance,
		"diff_count": diff_count,
		"percent_diff": percent,
		"diff_image_path": diff_path,
		"size_mismatch": false,
	}


static func update_baseline(name: String) -> bool:
	## 把 current/<name>.png 拷到 baseline/<name>.png（首次或主动更新时用）
	var current_path := "%s/%s.png" % [CURRENT_DIR, name]
	if not FileAccess.file_exists(current_path):
		push_error("[screenshot_compare] current not found: %s" % current_path)
		return false
	_ensure_dir(BASELINE_DIR)
	var baseline_path := "%s/%s.png" % [BASELINE_DIR, name]
	var err := DirAccess.copy_absolute(current_path, baseline_path)
	if err != OK:
		push_error("[screenshot_compare] copy failed: %s → %s (err=%d)" % [current_path, baseline_path, err])
		return false
	return true


static func _ensure_dir(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		return
	DirAccess.make_dir_recursive_absolute(path)
