class_name JellyEffect

## 在指定 Sprite2D 上播放果冻弹性效果
## sprite: 目标精灵
## original_scale: 精灵的原始缩放（用于回弹目标）
## squash_ratio: 压扁强度（横向膨胀倍数，默认 1.3）
## duration: 回弹时长（秒，默认 0.4）
static func play(sprite: Sprite2D, original_scale: Vector2,
		squash_ratio: float = 1.3, duration: float = 0.4) -> void:
	if not sprite or not is_instance_valid(sprite):
		return

	# 杀掉同节点上旧的果冻 Tween（通过 meta 标记）
	if sprite.has_meta("_jelly_tween"):
		var old_tween: Tween = sprite.get_meta("_jelly_tween") as Tween
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	# 瞬间压扁：横向膨胀，纵向压缩（保持面积大致不变）
	var squash_y := original_scale.y * (2.0 - squash_ratio)
	sprite.scale = Vector2(original_scale.x * squash_ratio, squash_y)

	# 弹性回弹到原始比例
	var tween := sprite.create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", original_scale, duration)

	# 用 meta 保存 tween 引用，避免重复冲突
	sprite.set_meta("_jelly_tween", tween)
