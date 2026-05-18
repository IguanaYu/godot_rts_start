@tool
extends Node2D
class_name ShadowComponent
## 影子渲染组件：生成椭圆阴影精灵并管理其生命周期。
## 挂载为需要阴影的实体的子节点。

var _shadow: Sprite2D = null
var _owner: Node2D = null


func _ready() -> void:
	_owner = get_parent() as Node2D


## 重建影子精灵（在参数变化时由父节点调用）
func rebuild(width: int, height: int, alpha: float, offset_x: float = 0.0, offset_y: float = 0.0) -> void:
	if not is_node_ready():
		return

	# 移除旧阴影
	if _shadow and is_instance_valid(_shadow):
		_shadow.queue_free()
		_shadow = null

	if width <= 0 or height <= 0:
		return

	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for x in range(width):
		for y in range(height):
			var dx := (float(x) - width / 2.0) / (width / 2.0)
			var dy := (float(y) - height / 2.0) / (height / 2.0)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, alpha))

	_shadow = Sprite2D.new()
	_shadow.texture = ImageTexture.create_from_image(img)
	_shadow.z_index = 0
	_shadow.position = Vector2(offset_x, offset_y)

	# 将影子精灵添加到父节点最底层
	if _owner:
		_owner.add_child(_shadow)
		_owner.move_child(_shadow, 0)


## 调整目标精灵的位置和缩放
func apply_sprite_position(sprite: Sprite2D, scale_x: float, scale_y: float,
		lift: float, offset_x: float = 0.0, offset_y: float = 0.0) -> void:
	if not sprite:
		return
	sprite.scale = Vector2(scale_x, scale_y)
	sprite.position.x = offset_x
	sprite.position.y = -lift + offset_y
