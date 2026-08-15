extends Node2D
class_name FrameAnimatedEffect
## 帧动画特效基类：自动推进帧，播完销毁。
## 子类在 _ready() 中设置 _total_frames / _fps 即可。
## 池化模式（pooled=true，由 ParticlePool 设置）：播完发 finished 信号归还池，不销毁。

signal finished

@onready var sprite: Sprite2D = $Sprite

var pooled: bool = false

var _frame: int = 0
var _total_frames: int = 8
var _fps: float = 16.0
var _timer: float = 0.0


func _ready() -> void:
	# 从场景 hframes 推断总帧数（如果子类没覆盖）
	if sprite and sprite.texture and sprite.hframes > 0:
		_total_frames = sprite.hframes
	set_process(false)


func begin_play() -> void:
	_frame = 0
	_timer = 0.0
	sprite.frame = 0
	set_process(true)


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= 1.0 / _fps:
		_timer -= 1.0 / _fps
		_frame += 1
		if _frame >= _total_frames:
			if pooled:
				set_process(false)
				finished.emit()
			else:
				queue_free()
			return
		sprite.frame = _frame
