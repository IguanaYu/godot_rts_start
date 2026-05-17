extends "res://scripts/frame_animated_effect.gd"
## 灰尘特效：随机纹理，6 帧 20fps


func _ready() -> void:
	_total_frames = 6
	_fps = 20.0
	if randi() % 2 == 0:
		sprite.texture = load("res://assets/effects/Dust_01.png")
	else:
		sprite.texture = load("res://assets/effects/Dust_02.png")
	super._ready()
