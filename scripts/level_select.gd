extends Control

var level_buttons: Array[Button] = []

var levels := [
	{
		"name": "Map 1: Blitz",
		"desc": "No base, no gold. Capture strongpoints to reinforce and push forward!",
		"scene": "res://scenes/maps/map_1.tscn"
	},
	{
		"name": "Map 2: Basic Attack",
		"desc": "Build your base, train your army, and destroy the enemy castle!",
		"scene": "res://scenes/maps/map_2.tscn"
	},
	{
		"name": "Map 3: Tower Defense",
		"desc": "Survive 3 waves of enemy attacks! Build defenses and hold your ground.",
		"scene": "res://scenes/maps/map_3.tscn"
	},
	{
		"name": "Map 4: Expand & Defend",
		"desc": "Capture 4 neutral camps while defending against waves of enemies!",
		"scene": "res://scenes/maps/map_4.tscn"
	},
]

func _ready() -> void:
	# Title
	var title := Label.new()
	title.text = "Select Level"
	title.add_theme_font_size_override("font_size", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left = 0.0
	title.anchor_right = 1.0
	title.offset_top = 60.0
	title.offset_bottom = 100.0
	add_child(title)

	# Button container
	var container := VBoxContainer.new()
	container.anchor_left = 0.2
	container.anchor_right = 0.8
	container.anchor_top = 0.15
	container.anchor_bottom = 0.85
	container.add_theme_constant_override("separation", 15)
	add_child(container)

	for i in range(levels.size()):
		var level: Dictionary = levels[i]
		var btn := Button.new()
		btn.text = level.name
		btn.custom_minimum_size = Vector2(0, 60)
		btn.add_theme_font_size_override("font_size", 22)
		var scene_path: String = level.scene
		btn.pressed.connect(func(): _load_level(scene_path))
		container.add_child(btn)
		level_buttons.append(btn)

		# Description label
		var desc := Label.new()
		desc.text = level.desc
		desc.add_theme_font_size_override("font_size", 16)
		desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(desc)

	# Esc hint
	var hint := Label.new()
	hint.text = "Press Esc to quit"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.anchor_left = 0.0
	hint.anchor_right = 1.0
	hint.anchor_top = 0.9
	hint.anchor_bottom = 0.95
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)

func _load_level(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
