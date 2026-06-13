extends Control

var _loading_complete := false
var _other_loaded := false
var _progress_bar: ProgressBar
var _status_label: Label
var _scene_path := "res://scenes/maps/" + RelayManager._map_name + ".tscn"

func _ready():
	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	var cm := CursorManagerScene.instantiate()
	add_child(cm)
	_build_ui()
	RelayManager.both_loaded.connect(_on_both_loaded)
	_start_loading()

func _build_ui():
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_status_label = Label.new()
	_status_label.text = "Loading..."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 32)
	_status_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_status_label.anchor_left = 0.1
	_status_label.anchor_right = 0.9
	_status_label.anchor_top = 0.35
	_status_label.anchor_bottom = 0.45
	add_child(_status_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.anchor_left = 0.2
	_progress_bar.anchor_right = 0.8
	_progress_bar.anchor_top = 0.5
	_progress_bar.anchor_bottom = 0.55
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 100.0
	add_child(_progress_bar)

func _start_loading():
	var err := ResourceLoader.load_threaded_request(_scene_path)
	if err != OK:
		push_error("LoadingScreen: failed to start async load: ", err)
		return
	_loading_complete = false

func _process(_delta):
	if _loading_complete:
		return

	var progress = []
	var status := ResourceLoader.load_threaded_get_status(_scene_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress.size() > 0:
				_progress_bar.value = progress[0] * 100.0
		ResourceLoader.THREAD_LOAD_LOADED:
			_loading_complete = true
			_progress_bar.value = 100.0
			_status_label.text = "Waiting for other player..."
			RelayManager.send_load_complete()
		ResourceLoader.THREAD_LOAD_FAILED:
			_status_label.text = "Load failed!"
			push_error("LoadingScreen: async load failed")

func _on_both_loaded(seed: int):
	RelayManager._game_seed = seed
	var game_scene := ResourceLoader.load_threaded_get(_scene_path)
	get_tree().change_scene_to_packed(game_scene)
