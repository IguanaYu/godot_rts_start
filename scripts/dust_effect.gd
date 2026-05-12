extends Node2D

@onready var sprite: Sprite2D = $Sprite

var _frame: int = 0
var _total_frames: int = 6
var _fps: float = 20.0
var _timer: float = 0.0

func _ready() -> void:
	if randi() % 2 == 0:
		sprite.texture = load("res://assets/effects/Dust_01.png")
	else:
		sprite.texture = load("res://assets/effects/Dust_02.png")

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= 1.0 / _fps:
		_timer -= 1.0 / _fps
		_frame += 1
		if _frame >= _total_frames:
			queue_free()
			return
		sprite.frame = _frame
