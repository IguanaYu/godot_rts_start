extends RefCounted
## 通用按钮动画工厂：给按钮添加悬停放大+按下缩小的视觉反馈

const HOVER_SCALE := Vector2(1.12, 1.12)
const NORMAL_SCALE := Vector2(1.0, 1.0)
const PRESS_SCALE := Vector2(0.90, 0.90)
const HOVER_MODULATE := Color(1.15, 1.15, 1.15)
const NORMAL_MODULATE := Color(1.0, 1.0, 1.0)
const PRESS_MODULATE := Color(0.8, 0.8, 0.8)
const TWEEN_DURATION := 0.12


static func _tween_scale(node: Control, target_scale: Vector2, target_mod: Color) -> void:
	node.remove_meta("_btn_tween")
	var tween := node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "scale", target_scale, TWEEN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", target_mod, TWEEN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	node.set_meta("_btn_tween", tween)


## 给已有 wrapper(Control) 的按钮添加缩放动画 + 贴图切换
static func add_hover_anim(wrapper: Control, bg: NinePatchRect, prs_texture: Texture2D, reg_texture: Texture2D) -> void:
	wrapper.item_rect_changed.connect(func(): wrapper.pivot_offset = wrapper.size * 0.5)
	var btn: Button = _find_button(wrapper)
	if btn == null:
		return
	btn.mouse_entered.connect(func(): _tween_scale(wrapper, HOVER_SCALE, HOVER_MODULATE))
	btn.mouse_exited.connect(func(): _tween_scale(wrapper, NORMAL_SCALE, NORMAL_MODULATE))
	btn.button_down.connect(func(): _tween_scale(wrapper, PRESS_SCALE, PRESS_MODULATE); bg.texture = prs_texture)
	btn.button_up.connect(func(): _tween_scale(wrapper, HOVER_SCALE, HOVER_MODULATE); bg.texture = reg_texture)


## 给纯 Button（无 wrapper）添加缩放动画
static func add_hover_anim_button(btn: Button) -> void:
	btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size * 0.5)
	btn.mouse_entered.connect(func(): _tween_scale(btn, HOVER_SCALE, HOVER_MODULATE))
	btn.mouse_exited.connect(func(): _tween_scale(btn, NORMAL_SCALE, NORMAL_MODULATE))
	btn.button_down.connect(func(): _tween_scale(btn, PRESS_SCALE, PRESS_MODULATE))
	btn.button_up.connect(func(): _tween_scale(btn, HOVER_SCALE, HOVER_MODULATE))


static func _find_button(node: Node) -> Button:
	for child in node.get_children():
		if child is Button:
			return child
	return null
