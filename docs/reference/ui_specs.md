# UI Specs（项目特定）

UI Safety addon 的项目侧配置。本文件描述屏幕分区、面板尺寸、已知问题，**改 UI 前必读**。

## 屏幕基准

- Base resolution: **1280×720**
- Stretch mode: `canvas_items`，aspect: `expand`
- CanvasLayer 分层：
  - 8 = objectives
  - 10 = 主 UI（game_ui / bottom_ui_bar / detail_panel 等）
  - 50 = 调试（aggro_debug_hud / UIBoundsValidator / 倍速按钮）
  - 90 = network_status
  - 100 = pause / load / result

## 底部 UI 条（核心约束区）

**整体**: [0, 500, 1280, 220]，由 `bottom_ui_bar.gd` 创建。

**三段横排（HBox separation=4）**:
| 段 | 比例 | 实际宽度 | 内容 |
|---|---|---|---|
| QW 建造栏 | 30% | ~384px | panel_wrapper → tab_row + unit/building/outpost_container |
| 详情面板 | 40% | ~512px | detail_panel.gd |
| 小地图 | 20% | ~256px | CenterContainer + minimap_wrapper（186×186 固定） |

**内部高度可用**: 220 - 8（上下 padding） = ~212px

## 已知问题（OOB 真实，但暂不修）

UIBoundsValidator 在 main.tscn 跑出 3 个 OUT_OF_BOUNDS，都是历史遗留：

1. **VBoxContainer@28 in QW 建造栏** (rect 14,510 2532×200)
   - 根因：HBox 横排 16+ 个建造按钮，每个 90×94，总宽 >384px 父段
   - 当前状态：button alignment=CENTER，溢出右侧看不见的部分被剪
   - 修复方向：改用 FlowContainer 自动换行 / ScrollContainer / 分页

2. **MinimapPanel** (rect 1049,524 358×358)
   - 根因：minimap_panel.gd:52 `size = _minimap_size` (172,172) 被 PRESET_FULL_RECT anchors 覆盖
   - 当前状态：实际渲染 358×358，下沿溢出底部 UI 条
   - 修复方向：minimap_panel 用固定 size + 不要 PRESET_FULL_RECT，或调 wrapper 约束

3. **倍速按钮 bg NinePatchRect** (rect 10,680 90×94)
   - 根因：_speed_wrapper 设了 size=(48,30)，但 NinePatchRect 子节点 minimum_size 把它撑到 90×94，下沿溢出 viewport
   - 当前状态：用户已知，肉眼能看到完整按钮（texture 居中渲染）
   - 修复方向：调 wrapper position.y 到 -84，或换更小的 NinePatch texture

**注意**：改这三处前先和用户确认，可能是 accepted trade-off。

## 顶部 / 浮窗面板

- **ResourcePanel**（左上）：[10, 10, ~200, ~120]
- **ObjectivesPanel**（右上）：240×208
- **CommanderSkillPanel**（顶部居中）：CanvasLayer@250，~6 槽 × 60px
- **倍速按钮**（左下，layer=50）：position (10, -40)，size 应为 48×30 但实际 90×94
- **aggro_debug_hud**（layer=50）：F1 切换

## 装饰组白名单（validator 已自动过滤）

下列 wrapper 模式 validator 不报 OVERLAP：

- **button_factory 模式**：wrapper Control → ButtonBG(NinePatchRect) + TextureRect + Label + Button + CostLabel
- **frame + content 模式**：wrapper Control → NinePatchRect 背景 + 内容（如 minimap_wrapper、commander skill slot）

判定逻辑：父节点含 Button 子节点 OR 含 NinePatchRect 子节点 → 装饰组，跳过 OVERLAP。

## 添加新 UI 的检查清单

改 `scripts/ui/**` 前：

- [ ] 读父节点 rect（用 F4 Pick 模式或代码里 print）
- [ ] 算目标节点预计 rect（含 anchor 偏移）
- [ ] 算父容器剩余空间（高度/宽度）
- [ ] 跑一遍校验：`godot --headless --script res://addons/ui_safety/runtime/run_bounds_check_cli.gd`
- [ ] 必要时启动 game 按 F3 肉眼验证
