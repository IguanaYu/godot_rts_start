extends Node2D

enum EffectType { MOVE, ATTACK }

@onready var sprite: Sprite2D = $Sprite

var type: int = EffectType.MOVE

func _ready() -> void:
	var duration := 0.5

	if type == EffectType.MOVE:
		sprite.scale = Vector2(0.5, 0.5)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), duration)
		tween.tween_property(sprite, "modulate:a", 0.0, duration)
		tween.chain().tween_callback(queue_free)

	elif type == EffectType.ATTACK:
		sprite.scale = Vector2(0.3, 0.3)
		sprite.rotation = deg_to_rad(randf_range(-20, 20))
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), duration * 0.6)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(sprite, "modulate:a", 0.0, duration)
		tween.chain().tween_callback(queue_free)
