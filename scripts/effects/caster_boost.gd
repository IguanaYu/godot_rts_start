class_name CasterBoost

## 在指定 Node2D 上播放"施法者放大"效果
## 用于让玩家清楚看到"是这只小兵在释放技能"
## - 选中 caster 时 sprite 放大 boost_ratio 倍（默认 1.3）
## - 持续 duration 秒后自动缩回原始大小
## - 同节点重复触发时 kill 旧 tween（避免叠加）
##
## 用法：
##   CasterBoost.play(unit.sprite, 1.3, 8.0)  # 放大 1.3x，8s 后恢复
##   CasterBoost.clear(unit.sprite)            # 提前清除（如 caster 死亡）

static func play(target: Node2D, boost_ratio: float = 1.3, duration: float = 8.0) -> void:
	if not target or not is_instance_valid(target):
		return
	# 记录原始 scale（仅首次记录，避免重复触发时把已放大的 scale 当作"原始"）
	if not target.has_meta("_caster_boost_original_scale"):
		target.set_meta("_caster_boost_original_scale", target.scale)
	var original_scale: Vector2 = target.get_meta("_caster_boost_original_scale")

	# 杀掉同节点上旧的 boost Tween
	if target.has_meta("_caster_boost_tween"):
		var old_tween: Tween = target.get_meta("_caster_boost_tween") as Tween
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	# 杀掉回缩定时器
	if target.has_meta("_caster_boost_timer"):
		var old_timer: SceneTreeTimer = target.get_meta("_caster_boost_timer") as SceneTreeTimer
		if old_timer:
			old_timer.timeout.disconnect(_restore.bind(target))

	# 放大（带 ease，避免突变）
	var tween := target.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "scale", original_scale * boost_ratio, 0.3)
	target.set_meta("_caster_boost_tween", tween)

	# duration 秒后回缩
	var timer := target.get_tree().create_timer(duration)
	timer.timeout.connect(_restore.bind(target))
	target.set_meta("_caster_boost_timer", timer)


static func _restore(target: Node2D) -> void:
	if not target or not is_instance_valid(target):
		return
	if not target.has_meta("_caster_boost_original_scale"):
		return
	var original_scale: Vector2 = target.get_meta("_caster_boost_original_scale")
	# 杀掉放大 tween（如果还在跑）
	if target.has_meta("_caster_boost_tween"):
		var old_tween: Tween = target.get_meta("_caster_boost_tween") as Tween
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	# 平滑回缩
	var tween := target.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, "scale", original_scale, 0.4)
	target.set_meta("_caster_boost_tween", tween)
	# 清除 meta（下次 play 会重新记录 original）
	target.remove_meta("_caster_boost_original_scale")
	target.remove_meta("_caster_boost_timer")


## 提前清除（如 caster 死亡时）—— 不播放回缩动画，直接还原 scale
static func clear(target: Node2D) -> void:
	if not target or not is_instance_valid(target):
		return
	if not target.has_meta("_caster_boost_original_scale"):
		return
	var original_scale: Vector2 = target.get_meta("_caster_boost_original_scale")
	target.scale = original_scale
	if target.has_meta("_caster_boost_tween"):
		var old_tween: Tween = target.get_meta("_caster_boost_tween") as Tween
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	target.remove_meta("_caster_boost_original_scale")
	target.remove_meta("_caster_boost_timer")
