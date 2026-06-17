extends Node2D
## 力场屏障倒计时：duration 秒后自动销毁；最后 3 秒所有非 Label 子节点闪烁。
## 与 shield_wall_timer.gd 类似，但闪烁针对 Node2D 视觉节点（不含 Sprite2D 假设）。

var duration: float = 8.0
var _elapsed: float = 0.0
var _base_alphas: Dictionary = {}  # 子节点路径 -> 初始 alpha


func _ready() -> void:
	# 记录所有非 Label 子节点的初始 alpha
	for child in get_children():
		if child is Label:
			continue
		if child is CanvasItem:
			_base_alphas[child.get_path()] = child.modulate.a


func _process(delta: float) -> void:
	_elapsed += delta
	var remaining := duration - _elapsed

	# 更新倒计时标签
	for child in get_children():
		if child is Label:
			child.text = "%.0fs" % remaining

	# 最后 3 秒闪烁所有非 Label 子节点
	if remaining < 3.0:
		var factor := 0.4 + 0.5 * sin(_elapsed * 8.0)
		for path in _base_alphas:
			var node := get_node_or_null(path)
			if node and is_instance_valid(node) and node is CanvasItem:
				node.modulate.a = _base_alphas[path] * factor

	if _elapsed >= duration:
		queue_free()
