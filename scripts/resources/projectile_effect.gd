class_name ProjectileEffect
extends Resource

## 弹道效果基类。命中目标时调用 apply()。
## 子类实现具体效果逻辑（减速、溅射、穿透等）。

@warning_ignore("unused_parameter")
func apply(_projectile: Node2D, _target: Node2D) -> void:
	pass
