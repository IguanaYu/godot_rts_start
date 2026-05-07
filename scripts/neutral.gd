@tool
extends Node2D
class_name Neutral

@export var sprite_scale_x: float = 0.5:
	set(v): sprite_scale_x = v; _refresh_editor()
@export var sprite_scale_y: float = 0.5:
	set(v): sprite_scale_y = v; _refresh_editor()
@export var sprite_lift: float = 20.0:
	set(v): sprite_lift = v; _refresh_editor()
@export var shadow_width: int = 20:
	set(v): shadow_width = v; _refresh_editor()
@export var shadow_height: int = 8:
	set(v): shadow_height = v; _refresh_editor()
@export var shadow_alpha: float = 0.3:
	set(v): shadow_alpha = v; _refresh_editor()

@onready var body_sprite: Sprite2D = $Sprite

var _shadow: Sprite2D = null

func _ready() -> void:
	_rebuild_shadow()
	_apply_sprite_position()

func _rebuild_shadow() -> void:
	if not is_node_ready():
		return

	if _shadow and is_instance_valid(_shadow):
		_shadow.queue_free()
		_shadow = null

	if shadow_width <= 0 or shadow_height <= 0:
		return

	var img := Image.create(shadow_width, shadow_height, false, Image.FORMAT_RGBA8)
	for x in range(shadow_width):
		for y in range(shadow_height):
			var dx := (float(x) - shadow_width / 2.0) / (shadow_width / 2.0)
			var dy := (float(y) - shadow_height / 2.0) / (shadow_height / 2.0)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, shadow_alpha))

	_shadow = Sprite2D.new()
	_shadow.texture = ImageTexture.create_from_image(img)
	_shadow.z_index = 0
	add_child(_shadow)
	move_child(_shadow, 0)

func _apply_sprite_position() -> void:
	if not is_node_ready() or not body_sprite:
		return
	body_sprite.scale = Vector2(sprite_scale_x, sprite_scale_y)
	body_sprite.position.y = -sprite_lift

func _refresh_editor() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_node_ready():
		return
	_rebuild_shadow()
	_apply_sprite_position()
