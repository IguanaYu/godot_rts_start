# 游戏倍速控制 (1x / 2x / 4x) — 详细实现计划

## Context

RTS游戏需要倍速功能加快游戏节奏。当前项目所有游戏逻辑基于 delta 更新，用 `Engine.time_scale` 即可全局加速，无需修改各个游戏系统。

### 核心原理

设置 `Engine.time_scale = 2.0` 会让 Godot 在 `_process` 和 `_physics_process` 中传入翻倍的 `delta`，所有基于 delta 的逻辑自动加速。

### 调研结论

- `Engine.time_scale` 同时影响 `_process(delta)` 和 `_physics_process(delta)` 的 delta 值
- Tween 动画不受 time_scale 影响（保持实际时长）
- 音频播放不受 time_scale 影响
- Timer 节点受 time_scale 影响
- 4x 下物理稳定性安全：delta ≈ 0.067s，单位速度 200-400px/s，每帧移动 ~13px，小于碰撞半径

---

## 修改文件一：`scripts/systems/game_ui.gd`

### 1.1 新增状态变量（第27行 `panel_bg` 之后）

```gdscript
# 倍速控制
var _game_speed: float = 1.0
const SPEED_OPTIONS: Array[float] = [1.0, 2.0, 4.0]
var _speed_button: Button
var _speed_label: Label
var _speed_wrapper: Control
```

### 1.2 `initialize()` 方法（第87行），在方法体开头加两行

```gdscript
func initialize(main_node: Node2D, map_config: Resource, gold: int) -> void:
    Engine.time_scale = 1.0          # ← 新增：重置倍速
    _game_speed = 1.0                # ← 新增：重置状态
    _main_node = main_node
    _preprocess_textures()
    ...
```

### 1.3 `_create_ui()` 方法（第398行 FPS label 之后），新增倍速按钮

在 `_fps_label` 创建并 `canvas.add_child(_fps_label)` 之后，`_create_ui()` 函数结束之前，插入：

```gdscript
    # --- 倍速按钮（右上角）---
    _speed_wrapper = Control.new()
    _speed_wrapper.anchor_left = 1.0
    _speed_wrapper.anchor_right = 1.0
    _speed_wrapper.anchor_top = 0.0
    _speed_wrapper.anchor_bottom = 0.0
    _speed_wrapper.offset_left = -58.0
    _speed_wrapper.offset_right = -10.0
    _speed_wrapper.offset_top = 10.0
    _speed_wrapper.offset_bottom = 38.0
    canvas.add_child(_speed_wrapper)

    var speed_bg := _make_ninepatch(np_btn_blue)
    speed_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _speed_wrapper.add_child(speed_bg)

    _speed_label = Label.new()
    _speed_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _speed_label.offset_left = 4
    _speed_label.offset_right = -4
    _speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _speed_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _speed_label.add_theme_font_size_override("font_size", 16)
    _speed_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
    _speed_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
    _speed_label.add_theme_constant_override("shadow_offset_x", 1)
    _speed_label.add_theme_constant_override("shadow_offset_y", 1)
    _speed_label.text = "1x"
    _speed_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _speed_wrapper.add_child(_speed_label)

    _speed_button = Button.new()
    _speed_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _speed_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    var speed_empty := StyleBoxEmpty.new()
    _speed_button.add_theme_stylebox_override("normal", speed_empty)
    _speed_button.add_theme_stylebox_override("hover", speed_empty)
    _speed_button.add_theme_stylebox_override("pressed", speed_empty)
    _speed_button.add_theme_stylebox_override("focus", speed_empty)
    _speed_button.pressed.connect(_on_speed_button_pressed)
    var BF4 := preload("res://scripts/ui/button_factory.gd")
    BF4.add_hover_anim(_speed_wrapper, speed_bg, np_btn_blue_prs.texture, np_btn_blue.texture)
    _speed_wrapper.add_child(_speed_button)
```

### 1.4 新增方法（在 `_process()` 方法附近）

```gdscript
func _on_speed_button_pressed() -> void:
    var idx := SPEED_OPTIONS.find(_game_speed)
    var next_idx := (idx + 1) % SPEED_OPTIONS.size()
    set_game_speed(SPEED_OPTIONS[next_idx])

func set_game_speed(speed: float) -> void:
    _game_speed = speed
    Engine.time_scale = speed
    if _speed_label:
        _speed_label.text = "%dx" % int(speed)

func increase_game_speed() -> void:
    var idx := SPEED_OPTIONS.find(_game_speed)
    if idx < SPEED_OPTIONS.size() - 1:
        set_game_speed(SPEED_OPTIONS[idx + 1])

func decrease_game_speed() -> void:
    var idx := SPEED_OPTIONS.find(_game_speed)
    if idx > 0:
        set_game_speed(SPEED_OPTIONS[idx - 1])
```

---

## 修改文件二：`scripts/main.gd`

### 2.1 `_process()` 第512行，相机调用补偿 time_scale

```gdscript
# 原代码:
camera_module.process_camera(delta)
# 改为:
camera_module.process_camera(delta / Engine.time_scale)
```

### 2.2 `_input()` 第673行 match 块内，KEY_Q 之前新增

```gdscript
            KEY_MINUS, KEY_KP_SUBTRACT:
                ui_module.decrease_game_speed()
            KEY_EQUAL, KEY_KP_ADD:
                ui_module.increase_game_speed()
            KEY_Q:
                if not event.ctrl_pressed:
                    input_mode.enter_unit_production()
```

---

## 不需要修改的文件

| 文件 | 原因 |
|------|------|
| `game_camera.gd` | 相机补偿在 main.gd 的调用处完成 |
| `unit.gd` | `_physics_process(delta)` 中 delta 自动被 time_scale 缩放 |
| `building.gd` | `_process(delta)` 同上 |
| `arrow.gd` | `_process(delta)` 同上 |
| `wave_manager.gd` | `_process(delta)` 同上 |
| `enemy_ai.gd` | `_process(delta)` 同上 |
| `combat_controller.gd` | 无时间相关逻辑 |
| 翻译文件 | "1x"/"2x"/"4x" 是数字格式，无需翻译 |

---

## 边界情况处理

- **暂停**: `get_tree().paused = true` 冻结所有处理，time_scale 无影响，恢复后继续当前倍速
- **重启关卡**: `initialize()` 中 `Engine.time_scale = 1.0` 重置
- **Tween 动画**: Engine.time_scale 不影响 Tween 持续时间，死亡动画保持正常时长（合理）
- **音频**: 不受 time_scale 影响，正常播放
- **物理稳定性**: 4x下 delta ≈ 0.067s，单位速度 200-400px/s，每帧移动 ~13px，小于碰撞半径，安全

---

## 验证方式

1. 启动游戏，右上角出现 "1x" 按钮
2. 点击按钮：1x → 2x → 4x → 1x 循环，观察单位移动/战斗/建造/波次倒计时加速
3. 键盘 `-` 减速、`=` 加速，确认响应正确
4. 4x下相机滚动速度与1x一致（不变快）
5. 4x下按 ESC 暂停，再恢复，继续4x运行
6. 4x下重启关卡（R键或暂停菜单），确认重置为1x
