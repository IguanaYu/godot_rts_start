extends "res://scripts/core/frame_animated_effect.gd"
## 灰尘特效：随机纹理，6 帧 20fps


func _ready() -> void:
	_total_frames = 6
	_fps = 20.0
	super._ready()


func begin_play() -> void:
	# 每次播放重新随机纹理（池复用时不能沿用上一次的）
	if randi() % 2 == 0:
		sprite.texture = load("res://assets/effects/Dust_01.png")
	else:
		sprite.texture = load("res://assets/effects/Dust_02.png")
	super.begin_play()
