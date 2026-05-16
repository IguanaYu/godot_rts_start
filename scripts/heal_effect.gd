extends Node2D

@onready var sprite: Sprite2D = $Sprite

var _frame: int = 0
var _total_frames: int = 5
var _fps: float = 14.0
var _timer: float = 0.0

func _ready() -> void:
	var tex: Texture2D = sprite.texture
	if tex:
		_total_frames = tex.get_width() / 192
		sprite.hframes = _total_frames
		sprite.frame = 0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= 1.0 / _fps:
		_timer -= 1.0 / _fps
		_frame += 1
		if _frame >= _total_frames:
			queue_free()
			return
		sprite.frame = _frame
