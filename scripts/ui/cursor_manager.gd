extends CanvasLayer

## 自定义光标管理器
## 在 Inspector 中可直接调整：光标贴图、大小、偏移

@export_group("默认光标")
@export var default_cursor: Texture2D = preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Cursors/Cursor_01.png")
@export var default_scale: float = 2.0
@export var default_offset: Vector2 = Vector2(16, 16)

@export_group("攻击光标")
@export var attack_cursor: Texture2D = preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_05.png")
@export var attack_scale: float = 2.0
@export var attack_offset: Vector2 = Vector2(0, 0)

@onready var cursor_sprite: Sprite2D = $CursorSprite

var _is_attack: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_update_cursor()

func _process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	if _is_attack:
		cursor_sprite.global_position = mouse_pos + attack_offset
	else:
		cursor_sprite.global_position = mouse_pos + default_offset

func set_attack(is_attack: bool) -> void:
	_is_attack = is_attack
	_update_cursor()

func _update_cursor() -> void:
	if _is_attack:
		cursor_sprite.texture = attack_cursor
		cursor_sprite.scale = Vector2(attack_scale, attack_scale)
	else:
		cursor_sprite.texture = default_cursor
		cursor_sprite.scale = Vector2(default_scale, default_scale)
