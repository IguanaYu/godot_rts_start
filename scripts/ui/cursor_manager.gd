extends CanvasLayer

## 自定义光标管理器
## 使用 Input.set_custom_mouse_cursor() 实现 OS 级硬件光标，
## 在 Popup/Window（如 OptionButton 的下拉菜单）之上正确显示。
## 在 Inspector 中可直接调整：光标贴图、大小、偏移（offset 即 hotspot 偏移）

@export_group("默认光标")
@export var default_cursor: Texture2D = preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Cursors/Cursor_01.png")
@export var default_scale: float = 2.0
@export var default_offset: Vector2 = Vector2(16, 16)

@export_group("攻击光标")
@export var attack_cursor: Texture2D = preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_05.png")
@export var attack_scale: float = 2.0
@export var attack_offset: Vector2 = Vector2(0, 0)

var _is_attack: bool = false

func _ready() -> void:
	_update_cursor()

func set_attack(is_attack: bool) -> void:
	_is_attack = is_attack
	_update_cursor()

func _update_cursor() -> void:
	var tex: Texture2D = attack_cursor if _is_attack else default_cursor
	var s: float = attack_scale if _is_attack else default_scale
	var offset: Vector2 = attack_offset if _is_attack else default_offset
	var scaled_tex := _make_scaled_texture(tex, s)
	var hotspot := Vector2i(int(round(offset.x * s)), int(round(offset.y * s)))
	Input.set_custom_mouse_cursor(scaled_tex, Input.CURSOR_ARROW, hotspot)

static func _make_scaled_texture(tex: Texture2D, s: float) -> ImageTexture:
	var img := tex.get_image()
	if s != 1.0:
		img = img.duplicate()
		img.resize(int(round(img.get_width() * s)), int(round(img.get_height() * s)))
	return ImageTexture.create_from_image(img)
