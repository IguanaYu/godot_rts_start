class_name CollectibleItem
extends Area2D

## 可收集物品系统
## 玩家单位靠近自动拾取

signal collected(item: CollectibleItem)

@export var item_id: String = ""
@export var item_name_key: String = "ITEM_GENERIC"
@export var reward_gold: int = 0
@export var auto_collect: bool = true
@export var glow_color: Color = Color(1, 1, 0, 0.3)

var _collected: bool = false
var _float_offset: float = 0.0
var _float_time: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	add_to_group("collectible_items")

	# 创建碰撞形状
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 20.0
	collision.shape = shape
	add_child(collision)

	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# 浮动动画
	_float_time += delta * 2.0
	_float_offset = sin(_float_time) * 3.0
	position.y += _float_offset * delta

func _on_body_entered(body: Node) -> void:
	if _collected or not auto_collect:
		return

	# 只允许玩家单位拾取
	if body.is_in_group("player_units"):
		_collect()

func _collect() -> void:
	_collected = true
	collected.emit(self)

	# 播放拾取动画/效果
	_play_collect_effect()

	# 延迟删除
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _play_collect_effect() -> void:
	# 创建飘字效果
	if reward_gold > 0:
		pass  # 可以在这里添加金币飘字

	# 创建闪光效果
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.3)
