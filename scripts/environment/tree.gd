extends "res://scripts/environment/neutral.gd"

@export var sway_amplitude: float = 2.0
@export var sway_period: float = 3.0

func _ready() -> void:
	super._ready()
	# 随机延迟避免所有树同步摇摆
	await get_tree().create_timer(randf() * sway_period).timeout
	_start_sway()

func _start_sway() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(body_sprite, "rotation", deg_to_rad(sway_amplitude), sway_period / 2.0)
	tween.tween_property(body_sprite, "rotation", deg_to_rad(-sway_amplitude), sway_period / 2.0)
