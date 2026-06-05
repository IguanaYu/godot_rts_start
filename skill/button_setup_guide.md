# 按钮创建配置指南

项目按钮统一使用 `scripts/ui/button_factory.gd` 的动画系统。
本指南覆盖两种按钮模式和所有配置步骤，可直接复制模板使用。

---

## 可用贴图资源

路径前缀：`res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/`

| 类型 | 常规 | 按下 |
|------|------|------|
| 大蓝按钮 | `Buttons/BigBlueButton_Regular.png` | `Buttons/BigBlueButton_Pressed.png` |
| 大红按钮 | `Buttons/BigRedButton_Regular.png` | `Buttons/BigRedButton_Pressed.png` |
| 小蓝方按钮 | `Buttons/SmallBlueSquareButton_Regular.png` | `Buttons/SmallBlueSquareButton_Pressed.png` |
| 小红方按钮 | `Buttons/SmallRedSquareButton_Regular.png` | `Buttons/SmallRedSquareButton_Pressed.png` |
| 小蓝圆按钮 | `Buttons/SmallBlueRoundButton_Regular.png` | `Buttons/SmallBlueRoundButton_Pressed.png` |
| 小红圆按钮 | `Buttons/SmallRedRoundButton_Regular.png` | `Buttons/SmallRedRoundButton_Pressed.png` |

其他资源：`Papers/`、`Ribbons/`、`Wood Table/` 等。

---

## 模式 A：贴图按钮（推荐，有视觉背景）

适用于：需要按钮贴图外观的主按钮（开始、确认、删除等）

### 节点结构

```
wrapper (Control, custom_minimum_size = 按钮尺寸)
 ├── bg (NinePatchRect, FULL_RECT, mouse_filter = IGNORE)  ← 贴图背景
 ├── btn (Button, FULL_RECT, StyleBoxEmpty 四状态)         ← 事件接收
 └── label (Label, FULL_RECT, mouse_filter = IGNORE)       ← 显示文字
```

### 关键规则

1. **必须先把 btn 加入 wrapper，再调用 `add_hover_anim`**
2. `add_hover_anim` 内部通过 `_find_button` 查找子 Button，如果 btn 还没加入就返回 null，动画不会注册
3. 九宫格切边参数因贴图而异，用 `_process_ninepatch` 处理

### 完整模板代码

```gdscript
# 1. 准备九宫格贴图（在 _ready 中调用一次即可）
var np_btn_blue: Dictionary
var np_btn_blue_prs: Dictionary

func _ready():
    np_btn_blue = _process_ninepatch(PATH_BTN_BLUE_REG,
        [[17, 63], [128, 191], [256, 302]],    # 行切边
        [[19, 63], [128, 191], [256, 300]])     # 列切边
    np_btn_blue_prs = _process_ninepatch(PATH_BTN_BLUE_PRS,
        [[28, 63], [128, 191], [256, 304]],
        [[14, 63], [128, 191], [256, 305]])


# 2. 创建按钮（注意顺序！）
func create_textured_button(text: String, size: Vector2, callback: Callable) -> Control:
    var wrapper := Control.new()
    wrapper.custom_minimum_size = size

    # 背景
    var bg := _make_ninepatch(np_btn_blue)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    wrapper.add_child(bg)

    # 按钮（透明，仅接收事件）
    var btn := Button.new()
    btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    var es := StyleBoxEmpty.new()
    btn.add_theme_stylebox_override("normal", es)
    btn.add_theme_stylebox_override("hover", es)
    btn.add_theme_stylebox_override("pressed", es)
    btn.add_theme_stylebox_override("focus", es)
    btn.pressed.connect(callback)
    wrapper.add_child(btn)  # ← 先加入

    # 文字标签
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_color_override("font_color", Color(1, 1, 1))
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    wrapper.add_child(label)

    # 动画（必须在 btn 加入 wrapper 之后！）
    var BF := preload("res://scripts/ui/button_factory.gd")
    BF.add_hover_anim(wrapper, bg, np_btn_blue_prs.texture, np_btn_blue.texture)

    return wrapper
```

---

## 模式 B：纯文字按钮（无贴图背景）

适用于：语言切换、小文字链接等不需要按钮外观的场景

### 模板代码

```gdscript
func create_text_button(text: String, callback: Callable) -> Button:
    var btn := Button.new()
    btn.text = text
    btn.custom_minimum_size = Vector2(90, 28)
    btn.add_theme_font_size_override("font_size", 14)
    btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

    btn.pressed.connect(callback)
    # add_hover_anim_button 对顺序无要求，因为直接操作 btn 自身
    var BF := preload("res://scripts/ui/button_factory.gd")
    BF.add_hover_anim_button(btn)

    return btn
```

---

## button_factory.gd 接口

| 方法 | 用途 | 效果 |
|------|------|------|
| `add_hover_anim(wrapper, bg, prs_tex, reg_tex)` | 贴图按钮 | 缩放 + 亮度 + 贴图切换 |
| `add_hover_anim_button(btn)` | 纯文字按钮 | 缩放 + 亮度 |

### 动画参数

| 状态 | 缩放 | 亮度(modulate) |
|------|------|------|
| 正常 | 1.0 | 白 (1,1,1) |
| 悬停 | 1.12 | 亮 (1.15,1.15,1.15) |
| 按下 | 0.90 | 暗 (0.8,0.8,0.8) |

过渡时间 0.12 秒，使用 Tween + TRANS_QUAD + EASE_OUT。

---

## 辅助函数：九宫格处理

```gdscript
# 将大贴图切成九宫格，返回 { texture, margin_left, margin_right, margin_top, margin_bottom }
func _process_ninepatch(source_path: String, content_rows: Array, content_cols: Array) -> Dictionary

# 用九宫格数据创建 NinePatchRect 节点
func _make_ninepatch(np: Dictionary) -> NinePatchRect
```

这两个函数定义在 `save_select.gd` 中。如果其他脚本需要用，可以提取到公共工具类，或者直接复制。

---

## 九宫格切边参数（已验证无缝隙）

`_process_ninepatch` 把原始贴图切成 3x3 九宫格，参数格式为 `[[start, end], ...]`，
表示取像素范围 start 到 end（包含两端）。

**切边原则**：每个区间 `[start, end]` 的选取要避开贴图边缘的阴影/高光过渡区域，
只取"纯净"的边框像素和中间可拉伸区域。如果取到过渡像素，拉伸时就会出现缝隙。

### 已验证的切边参数

所有按钮贴图原始尺寸为 **320x320**。

| 贴图 | 行切边 (rows) | 列切边 (cols) |
|------|--------------|--------------|
| BigBlueButton Regular | `[[17, 63], [128, 191], [256, 302]]` | `[[19, 63], [128, 191], [256, 300]]` |
| BigBlueButton Pressed | `[[28, 63], [128, 191], [256, 304]]` | `[[14, 63], [128, 191], [256, 305]]` |
| BigRedButton Regular | `[[17, 63], [128, 191], [256, 302]]` | `[[19, 63], [128, 191], [256, 300]]` |
| BigRedButton Pressed | `[[28, 63], [128, 191], [256, 304]]` | `[[14, 63], [128, 191], [256, 305]]` |
| SpecialPaper (320x320) | `[[20, 63], [128, 191], [256, 298]]` | `[[9, 63], [128, 191], [256, 310]]` |
| WoodTable (448x448) | `[[43, 127], [192, 255], [320, 422]]` | `[[44, 127], [192, 255], [320, 403]]` |
| BigBar (320x320) | `[[6, 31], [128, 159], [256, 281]]` | `[[6, 31], [128, 159], [256, 281]]` |

### 缝隙排查方法

如果拼接后出现缝隙（透明线），按以下步骤调整：

1. **打开贴图图片**（用图片编辑器放大到像素级别）
2. **观察边缘过渡带**：按钮贴图的边缘通常有几像素的阴影/高光渐变
3. **切边要避开过渡带**：
   - 行/列的第一段 `[start1, end1]`：取边框内部纯净像素，不要包含最外侧的阴影
   - 行/列的最后一段 `[start3, end3]`：同理，不要包含最外侧的阴影
   - 中间段 `[start2, end2]`：取完全平坦的可拉伸区域
4. **逐步微调**：每次调整 2-3 像素，重新运行看效果
5. **Regular 和 Pressed 用不同参数**：因为按下状态贴图的边框可能偏移了几像素

### 判断切边是否正确的标准

- **无缝隙**：按钮在任意尺寸下渲染，九宫格交界处无透明线
- **无模糊**：边框不会出现异常的模糊条纹（说明取到了半透明过渡像素）
- **拉伸自然**：中间区域放大后，纹理自然不重复

---

## 常见错误

### `add_hover_anim` 在 `add_child(btn)` 之前调用

```gdscript
# 错误！btn 还没加入 wrapper，_find_button 返回 null
BF.add_hover_anim(wrapper, bg, prs_texture, reg_texture)
wrapper.add_child(btn)

# 正确！先把所有子节点加入，再注册动画
wrapper.add_child(btn)
wrapper.add_child(label)
BF.add_hover_anim(wrapper, bg, prs_texture, reg_texture)
```

### 忘记给 Button 设置 StyleBoxEmpty

如果不设置，Godot 默认按钮样式会盖住贴图背景。

### Label 没设 mouse_filter = IGNORE

会导致 Label 拦截鼠标事件，按钮收不到 hover/click。
