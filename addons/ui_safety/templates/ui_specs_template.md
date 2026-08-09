# UI Specs（项目特定）

UI Safety addon 的项目侧配置。本文件描述屏幕分区、面板尺寸、已知问题，**改 UI 前必读**。

## 屏幕基准

- Base resolution: **{{VIEWPORT_W}}×{{VIEWPORT_H}}**
- Stretch mode: `{{STRETCH_MODE}}`，aspect: `{{STRETCH_ASPECT}}`
- CanvasLayer 分层：
  - {{LAYER_DEBUG}} = 调试 / UIBoundsValidator
  - {{LAYER_MAIN_UI}} = 主 UI
  - {{LAYER_OVERLAY}} = 浮窗 / pause / load

## 主 UI 分区

> TODO: 填入本项目主要 UI 面板的尺寸约束。例：

| 面板 | 位置 | 尺寸 | 备注 |
|---|---|---|---|
| 主 HUD | | | |
| 菜单 | | | |
| 浮窗 | | | |

## 已知问题（OOB 真实，但暂不修）

> TODO: 跑一次 `godot --headless --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd`，
> 把输出贴这里，并标注每个是否需要修。

## 装饰组白名单（validator 已自动过滤）

下列 wrapper 模式 validator 不报 OVERLAP：

- **button_factory 模式**：wrapper Control → ButtonBG(NinePatchRect) + TextureRect + Label + Button + CostLabel
- **frame + content 模式**：wrapper Control → NinePatchRect 背景 + 内容

判定逻辑：父节点含 Button 子节点 OR 含 NinePatchRect 子节点 → 装饰组，跳过 OVERLAP。

## 添加新 UI 的检查清单

改 UI 代码前：

- [ ] 读父节点 rect
- [ ] 算目标节点预计 rect
- [ ] 算父容器剩余空间
- [ ] 跑一遍校验：`godot --headless --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd`
- [ ] 必要时启动 game 按 F3 肉眼验证
