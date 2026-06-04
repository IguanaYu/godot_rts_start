extends RefCounted
## 通用按钮动画工厂：给按钮添加悬停放大+按下缩小的视觉反馈
## 只管动画效果，不管按钮外观（大小/颜色/贴图由各处自行决定）

const HOVER_SCALE := Vector2(1.08, 1.08)
const NORMAL_SCALE := Vector2(1.0, 1.0)
const PRESS_SCALE := Vector2(0.95, 0.95)


## 给已有 wrapper(Control) 的按钮添加缩放动画 + 贴图切换
## wrapper: 包含 NinePatchRect bg + Button + Label 的外层 Control
## bg: 背景九宫格，用于贴图切换
## prs_texture: 按下状态贴图
## reg_texture: 常规状态贴图
static func add_hover_anim(wrapper: Control, bg: NinePatchRect, prs_texture: Texture2D, reg_texture: Texture2D) -> void:
	wrapper.item_rect_changed.connect(func(): wrapper.pivot_offset = wrapper.size * 0.5)
	var btn: Button = _find_button(wrapper)
	if btn == null:
		return
	btn.mouse_entered.connect(func(): wrapper.scale = HOVER_SCALE)
	btn.mouse_exited.connect(func(): wrapper.scale = NORMAL_SCALE)
	btn.button_down.connect(func(): wrapper.scale = PRESS_SCALE; bg.texture = prs_texture)
	btn.button_up.connect(func(): wrapper.scale = HOVER_SCALE; bg.texture = reg_texture)


## 给纯 Button（无 wrapper）添加缩放动画
static func add_hover_anim_button(btn: Button) -> void:
	btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size * 0.5)
	btn.mouse_entered.connect(func(): btn.scale = HOVER_SCALE)
	btn.mouse_exited.connect(func(): btn.scale = NORMAL_SCALE)
	btn.button_down.connect(func(): btn.scale = PRESS_SCALE)
	btn.button_up.connect(func(): btn.scale = HOVER_SCALE)


static func _find_button(node: Node) -> Button:
	for child in node.get_children():
		if child is Button:
			return child
	return null
