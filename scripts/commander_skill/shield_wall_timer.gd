extends Node2D
## 护盾墙倒计时：duration 秒后自动销毁

var duration: float = 15.0
var _elapsed: float = 0.0


func _process(delta: float) -> void:
	_elapsed += delta
	var remaining := duration - _elapsed

	# 更新倒计时标签
	for child in get_children():
		if child is Label:
			child.text = "%.0fs" % remaining

	# 闪烁预警
	if remaining < 5.0:
		var sprite_node := get_node_or_null("Sprite2D")
		if sprite_node:
			sprite_node.modulate.a = 0.5 + 0.5 * sin(_elapsed * 6.0)

	if _elapsed >= duration:
		queue_free()
