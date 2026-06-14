extends CanvasLayer

# 进入地图的统一入口。常驻 root，不被 change_scene 销毁。
# 单人：资源加载完直接切场景；多人：等 both_loaded 信号再切。
# main.gd._ready 分帧期间，本 CanvasLayer 浮在游戏场景上方挡住半完成画面。

const ASYNC_RATIO := 0.6
const INIT_RATIO := 0.4
const FADE_DURATION := 0.25

enum State { IDLE, LOADING, WAITING_BOTH, INIT_STEPS, FADING_OUT }

var _state: State = State.IDLE
var _scene_path: String = ""
var _is_multiplayer: bool = false
var _packed_scene: PackedScene = null

var _ui_root: Control
var _bg: ColorRect
var _progress_bar: ProgressBar
var _status_label: Label
var _fade_tween: Tween


func _ready() -> void:
	layer = 100
	_build_ui()
	_ui_root.visible = false


func _build_ui() -> void:
	_ui_root = Control.new()
	_ui_root.name = "LoadRouterUI"
	_ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_ui_root)

	_bg = ColorRect.new()
	_bg.name = "Background"
	_bg.color = Color(0.1, 0.1, 0.15, 1)
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_root.add_child(_bg)

	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.text = "Loading..."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 32)
	_status_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_status_label.anchor_left = 0.1
	_status_label.anchor_right = 0.9
	_status_label.anchor_top = 0.35
	_status_label.anchor_bottom = 0.45
	_ui_root.add_child(_status_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.name = "ProgressBar"
	_progress_bar.anchor_left = 0.2
	_progress_bar.anchor_right = 0.8
	_progress_bar.anchor_top = 0.5
	_progress_bar.anchor_bottom = 0.55
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 100.0
	_progress_bar.value = 0.0
	_ui_root.add_child(_progress_bar)


func request_load(scene_path: String, is_multiplayer: bool) -> void:
	if _state != State.IDLE and _state != State.FADING_OUT:
		push_warning("LoadRouter: request_load called while busy, ignoring previous load")
		if _fade_tween:
			_fade_tween.kill()

	_scene_path = scene_path
	_is_multiplayer = is_multiplayer
	_packed_scene = null
	_progress_bar.value = 0.0
	_bg.color = Color(0.1, 0.1, 0.15, 1)
	_status_label.text = "Loading..."
	_status_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_ui_root.visible = true

	var err := ResourceLoader.load_threaded_request(_scene_path)
	if err != OK:
		push_error("LoadRouter: load_threaded_request failed: ", err)
		_show_failure()
		return

	if _is_multiplayer:
		if not RelayManager.both_loaded.is_connected(_on_both_loaded):
			RelayManager.both_loaded.connect(_on_both_loaded)
	_state = State.LOADING
	set_process(true)


func _process(_delta: float) -> void:
	if _state != State.LOADING:
		return

	var progress = []
	var status := ResourceLoader.load_threaded_get_status(_scene_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress.size() > 0:
				_set_progress(progress[0] * ASYNC_RATIO)
		ResourceLoader.THREAD_LOAD_LOADED:
			_packed_scene = ResourceLoader.load_threaded_get(_scene_path)
			_set_progress(ASYNC_RATIO)
			set_process(false)
			_on_resource_loaded()
		ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			_show_failure()


func _on_resource_loaded() -> void:
	if _is_multiplayer:
		_status_label.text = "Waiting for other player..."
		RelayManager.send_load_complete()
		_state = State.WAITING_BOTH
	else:
		_instantiate_scene()


func _on_both_loaded(seed: int) -> void:
	RelayManager._game_seed = seed
	if RelayManager.both_loaded.is_connected(_on_both_loaded):
		RelayManager.both_loaded.disconnect(_on_both_loaded)
	if _state == State.WAITING_BOTH:
		_instantiate_scene()


func _instantiate_scene() -> void:
	if _packed_scene == null:
		push_error("LoadRouter: packed scene is null, cannot instantiate")
		_show_failure()
		return
	_state = State.INIT_STEPS
	get_tree().change_scene_to_packed(_packed_scene)


func report_init_progress(ratio01: float) -> void:
	if not _ui_root.visible:
		return
	_set_progress(ASYNC_RATIO + INIT_RATIO * clampf(ratio01, 0.0, 1.0))


func finish_init() -> void:
	if not _ui_root.visible:
		return
	_set_progress(1.0)
	_status_label.text = "Entering..."
	_start_fade_out()


func _start_fade_out() -> void:
	_state = State.FADING_OUT
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_bg, "color:a", 0.0, FADE_DURATION)
	_fade_tween.parallel().tween_property(_status_label, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.parallel().tween_property(_progress_bar, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.tween_callback(_on_fade_out_done)


func _on_fade_out_done() -> void:
	_ui_root.visible = false
	_bg.color = Color(0.1, 0.1, 0.15, 1)
	_status_label.modulate = Color(1, 1, 1, 1)
	_progress_bar.modulate = Color(1, 1, 1, 1)
	_state = State.IDLE


func _set_progress(ratio01: float) -> void:
	_progress_bar.value = ratio01 * 100.0


func _show_failure() -> void:
	_state = State.IDLE
	_status_label.text = "Load failed!"
	_status_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
