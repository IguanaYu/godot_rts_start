# PR-T2-3 实施计划：底部横排 UI 条 + 详情面板 L1-L5

- **日期**：2026-08-07（基于深度调研重写），2026-08-07 二次修正（右侧竖排 → 底部横排）
- **阶段**：T2（时代升级 + 科技系统 + UI 改造）
- **状态**：⏳ 待启动
- **预计**：6-7 小时
- **关联**：
  - 总览：[T2_实施路线图.md](T2_实施路线图.md)
  - 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 5 + 6 章 + 2.3.6 节

---

## 一、Context

PR-T2-3 是 T2 阶段**最关键的 UI 改造**：把现有的底部建造面板（QW）改造为**底部横排 UI 条**（星际/魔兽经典布局），中段插入新的详情面板，小地图移到 UI 条最右侧。右上角目标/波次面板不动。

**关键约束**：PR-T2-4（升级系统）的升级按钮要挂在详情面板上，所以 PR-T2-3 必须先完成。详情面板模板要预留"科技区域"插槽。

**前置依赖**：无（PR-T2-1/2 已完成）

**后续依赖**：PR-T2-4（升级按钮挂详情面板）、PR-T2-5（L6-L9 多选场景）

---

## 二、调研结论（深度调研后确认）

### 2.1 现有 UI 结构（必须改的锚点）

| 组件 | 现位置 | 现锚点 | 迁移目标 |
|---|---|---|---|
| **底部建造面板** `panel_wrapper` | 屏幕底部居中 | `anchor_left=0.2, anchor_right=0.8`（宽 60%）| 横向压缩为底部 UI 条左段（宽 ~30%）|
| **目标面板** `objectives_panel` | 右上 | 自建 `CanvasLayer layer=8` + `PRESET_TOP_RIGHT` | **不动**，保持右上角 |
| **小地图** `minimap_wrapper` | 右下 | `PRESET_BOTTOM_RIGHT`（180×180）| 迁入底部 UI 条右段（最右下角）|
| **资源面板** `resource_panel` | 左上 | `PRESET_TOP_LEFT` | 不迁移 |
| **倍速按钮** `_speed_wrapper` | 左下 | 独立 `CanvasLayer layer=50` | 不迁移 |

### 2.2 info_container 现有功能（必须迁出）

[game_ui.gd:315-399](scripts/systems/game_ui.gd#L315-L399) 的 `info_container`（TAB_INFO 标签页内容）已经实现：
- 选中建筑：显示 HP 条
- 选中单位：显示数量 + 总 HP 条 + 平均 ATK + 平均 SPD + 分类型明细
- 无选中：隐藏

**迁移策略**：把这整段逻辑迁到新建的 `detail_panel.gd`，底部建造面板的 TAB_INFO 按钮删除（4 tab → 3 tab）。

### 2.3 选中系统数据流（详情面板接入点）

```
玩家点击 → combat_ctrl (combat_controller.gd)
  ├─ selection_changed(units: Array) signal
  └─ building_selected(building) signal
        ↓ main.gd:193-194 连接
  _on_selection_changed(units) → ui_module.update_selection_info(units)
  _on_building_selected(building) → ui_module.update_selection_info([], building)
        ↓ game_ui.gd
  → detail_panel.show_building / show_unit / show_default
```

**接入点**：详情面板监听同样的信号，或直接复用 `update_selection_info()` 入口（推荐后者，最小改动）。

### 2.4 时代升级信号（缺失项！）

**当前状态**：[main.gd](scripts/main.gd) 的 `_start_age_upgrade` / `_cancel_age_upgrade` / `_on_age_upgrade_complete` **没有 emit 任何信号**，只改状态变量。

**详情面板 L5 监听方案**（二选一）：

| 方案 | 实施 | 优点 | 缺点 |
|---|---|---|---|
| **A 轮询**（推荐）| 详情面板 `_process` 读 `main.age_upgrade_target > 0` + `main.age_upgrade_timer / AGE_UPGRADE_TIME[target]` 算进度 | 零改动 main.gd，立即可用 | 每帧查 1 次，性能损耗可忽略 |
| **B 新增信号** | main.gd 加 `signal age_upgrade_started(target)` / `signal age_upgrade_completed(target)` / `signal age_upgrade_cancelled(target)`，三处 emit | 事件驱动，更优雅 | 改 main.gd 3 处 |

**本 PR 走方案 A**（轮询）。方案 B 留到 PR-T2-4 一起加（升级系统也要这些信号）。

### 2.5 城堡头顶位置 + 进度条复用

- **城堡头顶位置**：`main._castle_head_pos()` 返回 `player_castle.global_position + Vector2(0, -60)`
- **城堡缓存**：`main.player_castle` 由 `_cache_player_castle()` 维护
- **产兵进度圆圈**：`building._create_production_circle()` 创建 Node2D 挂 `production_circle.gd` 脚本
- **复用方案**：升级进度条**不复用** production_circle（避免与产兵冲突），新建独立的 `_age_upgrade_bar` 在城堡头顶上方（y=-90，避开产兵圆圈 y=-60）

### 2.6 数据读取 API 速查

| 对象 | 字段 | 读取代码 |
|---|---|---|
| **建筑 HP** | 当前/最大 | `b.health.hp` / `b.health.max_hp`（HealthComponent）|
| **建筑攻击** | DMG/射程/攻速 | `b.attack_damage` / `b.attack_range` / `b.attack_cooldown`（仅 TOWER 非零）|
| **建筑产能** | cooldown | `b.production_cooldown`（BARRACKS=6, ARCHERY=20, CASTLE=10, FARM=10）|
| **建筑产金** | amount | 读 `b.building_stats.gold_production_amount`（CASTLE=50, FARM=20）|
| **建筑在造** | 队列+进度 | `b.get_queue_state()` → `{queue, remaining, total, current}` |
| **建筑队列容量** | max | `b.queue_max`（默认 5）|
| **单位 HP** | 当前/最大 | `u.health.hp` / `u.health.max_hp` |
| **单位 DMG** | 攻击力 | `u.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)` |
| **单位 SPD** | 移速 | `u.stat_set.get_value(StatSetClass.MOVE_SPEED)` |
| **单位射程** | 攻击距离 | `u.stat_set.get_value(StatSetClass.ATTACK_RANGE)` |
| **单位攻速** | 攻击间隔 | `u.stat_set.get_value(StatSetClass.ATTACK_COOLDOWN)` |
| **单兵等级** | 当前/最大 | `u.upgrade_mgr.get_level()` / `u.upgrade_mgr.get_max_level()` |
| **时代** | player_age | `main.player_age`（1/2/3）|

### 2.7 实际数值表（详情面板显示用）

| 对象 | HP | DMG | 射程 | 攻速 | 移速 | 备注 |
|---|---|---|---|---|---|---|
| Castle | 500 | — | — | — | — | 50 金/10s 产金 |
| Barracks | 250 | — | — | — | — | 6s 产能 |
| Archery | 200 | — | — | — | — | 20s 产能，完成反 1 弓兵 |
| Farm | 150 | — | — | — | — | 20 金/10s 产金，完成反 100 金 |
| Tower | 150 | 12 | 150 | 1.5s | — | 仅箭塔有攻击 |
| Soldier | 100 | 10 | 40 | 0.8s | 120 | 单兵升级 HP+10/DMG+2/SPD+5 |
| Archer | 60 | 15 | 200 | 1.2s | 180 | 单兵升级同上 |

---

## 三、核心交付

### 3.1 底部横排 UI 条（星际/魔兽经典布局）

```
┌──────────────────────────────────────────────────────┐
│ 资源(左上)                            ┌────────────┐ │
│                                      │目标 / 波次  │ │ ← 右上角不变
│                                      └────────────┘ │
│                                                     │
│                   [ 游戏世界 ]                       │
│                                                     │
│                                                     │
│ ┌──────────────┐ ┌────────────────┐ ┌────────────┐ │
│ │ QW 建造栏     │ │   详情面板      │ │  小地图     │ │ ← 底部三段横排
│ │ (横向压缩)    │ │  (选中/科技)    │ │            │ │
│ │ 左下 ~30%    │ │  中间 ~40%     │ │  最右 ~20% │ │
│ └──────────────┘ └────────────────┘ └────────────┘ │
└──────────────────────────────────────────────────────┘
```

- **UI 条位置**：屏幕底部，从左到右横排
- **UI 条高度**：屏高 ~22%（@1080p 约 220px，与现 QW 面板高度一致）
- **三段宽度比例**：QW ~30% / 详情 ~40% / 小地图 ~20%（剩 ~10% 为间距+边距）
- **右上角目标/波次面板**：不动

### 3.2 通用详情面板模板

```
┌──────────────────┐
│ {标题}            │ ← 标题区（图标 + 名称 + 数量）
│ ──────            │
│ ▸ 现状            │ ← 现状区（HP/DMG/数量等）
│   {动态内容}      │
│ ▸ 科技 / 升级     │ ← 科技区（PR-T2-4 接入，本 PR 占位）
│   {占位 Label}    │
└──────────────────┘
```

### 3.3 L1-L5 触发情况

| 编号 | 场景 | 详情面板显示 | 触发入口 |
|---|---|---|---|
| **L1** | 默认（启动 / 点空地）| 城堡详情（默认主基地）| `main.player_castle` |
| **L2** | 点单个建筑 | 该建筑详情 | `combat_ctrl.building_selected` 信号 |
| **L3** | 点单个单位 | 该单位详情 | `combat_ctrl.selection_changed` 信号 |
| **L4** | hover QW 图标 | 临时切换显示（移开恢复之前选中）| QW 按钮 `mouse_entered/exited` |
| **L5** | 升级 T2 中 | 城堡头顶进度条 + 详情面板保持城堡 | 轮询 `main.age_upgrade_target > 0` |

### 3.4 各对象详情内容（基础版，不含科技）

#### L1 城堡详情（默认）
```
🏰 城堡 (主基地)
─────────
▸ 现状
  血量: 500/500
  时代: T1
  产能: 50 金 / 10s
▸ 时代升级
  [升级到 T2]  ← 按钮（调用 main._start_age_upgrade()）
  费用 500 金 / 时间 15s
▸ 基础升级
  (T2 升级待接入)  ← PR-T2-4 替换
```

#### L2 单建筑详情
- **兵营**：HP / 在造进度（队列长度 / 当前单位 / 进度条）/ 反还单位（2 soldier）
- **靶场**：HP / 在造进度 / 反还单位（1 archer）
- **农场**：HP / 产能（20 金/10s）/ 完成反还（100 金）
- **箭塔**：HP / DMG / 射程 / 攻速
- **墙**：HP

#### L3 单单位详情
- **步兵**：HP / DMG / 射程 / 攻速 / 移速 / 单兵等级（占位）
- **弓兵**：HP / DMG / 射程 / 攻速 / 移速 / 单兵等级（占位）

---

## 四、改动文件清单

### 新建文件（2 个）

| 文件 | 用途 |
|---|---|
| **`scripts/ui/bottom_ui_bar.gd`** | 底部横排 UI 条容器，管理三段式布局（QW + 详情 + 小地图）|
| **`scripts/ui/detail_panel.gd`** | 详情面板通用模板 + L1-L5 切换逻辑 |

### 修改文件（3 个）

| 文件 | 改动 |
|---|---|
| [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd) | 创建 bottom_ui_bar；QW 建造面板横向压缩嵌入 UI 条左段；移除 info_container + TAB_INFO 按钮（4 tab→3 tab）；迁移小地图创建到 bottom_ui_bar 右段 |
| [scripts/main.gd](scripts/main.gd) | 在 `_input` KEY_U 升级触发时，调用详情面板的 L5 切换（可选，详情面板也可以轮询）|
| [scripts/buildings/building.gd](scripts/buildings/building.gd) | 加 `_age_upgrade_bar` 节点（升级进度条，独立于 `_production_circle`）|

⚠️ **注意**：[scripts/ui/objectives_panel.gd](scripts/ui/objectives_panel.gd) **不改**（右上角目标面板不动）。

---

## 五、实施步骤

### 步骤 1：底部 UI 条容器（1.5h）

**1.1** 新建 [scripts/ui/bottom_ui_bar.gd](scripts/ui/bottom_ui_bar.gd)

```gdscript
extends Control
## T2 PR-3: 底部横排 UI 条 — 三段式（QW 建造栏 + 详情面板 + 小地图）

var detail_panel: Control
var _qw_section: Control
var _detail_section: Control
var _minimap_section: Control
var _minimap_panel: Control


func initialize(main_node: Node2D) -> void:
	# 锚点：屏幕底部全宽，固定高度 ~220px
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_top = -220
	offset_bottom = 0
	offset_left = 0
	offset_right = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 背景（半透明黑底 + 边框）
	var bg := PanelContainer.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.35)
	style.set_corner_radius_all(6)
	style.set_border_width_all(1)
	style.border_color = Color(1, 1, 1, 0.08)
	bg.add_theme_stylebox_override("panel", style)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# 主 HBox（三段横排）
	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 4
	hbox.offset_right = -4
	hbox.offset_top = 4
	hbox.offset_bottom = -4
	hbox.add_theme_constant_override("separation", 4)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(hbox)

	# === 左段 ~30%：QW 建造栏区 ===
	_qw_section = Control.new()
	_qw_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_qw_section.size_flags_stretch_ratio = 0.30
	_qw_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_qw_section)

	# === 中段 ~40%：详情面板 ===
	_detail_section = Control.new()
	_detail_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_section.size_flags_stretch_ratio = 0.40
	_detail_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_detail_section)

	detail_panel = preload("res://scripts/ui/detail_panel.gd").new()
	detail_panel.initialize(main_node)
	_detail_section.add_child(detail_panel)
	detail_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# === 右段 ~20%：小地图区 ===
	_minimap_section = Control.new()
	_minimap_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minimap_section.size_flags_stretch_ratio = 0.20
	_minimap_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_minimap_section)


## QW 建造栏嵌入左段（由 game_ui 调用）
func embed_qw_panel(panel: Control) -> void:
	_qw_section.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## 小地图嵌入右段（由 game_ui 调用）
func embed_minimap(minimap: Control) -> void:
	_minimap_panel = minimap
	_minimap_section.add_child(_minimap_panel)
	_minimap_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)


func get_detail_panel() -> Control:
	return detail_panel


func get_qw_section() -> Control:
	return _qw_section
```

**1.2** 修改 [game_ui.gd](scripts/systems/game_ui.gd) `_create_ui()`：

```gdscript
# === T2 PR-3: 底部横排 UI 条 ===
var bottom_bar := preload("res://scripts/ui/bottom_ui_bar.gd").new()
bottom_bar.name = "BottomUIBar"
bottom_bar.initialize(_main_node)
canvas.add_child(bottom_bar)
_bottom_bar = bottom_bar
```

**1.3** 验收：
- [ ] 屏幕底部出现三段式横排容器（@1080p 高 220px）
- [ ] 三段宽度比例正确（30/40/20）
- [ ] 中段详情面板渲染空白模板

---

### 步骤 2：QW 建造栏嵌入左段（1h）

**2.1** 修改 [game_ui.gd](scripts/systems/game_ui.gd) 中 `panel_wrapper` 的创建。原 `panel_wrapper` 是独立的底部居中面板（`anchor_left=0.2, anchor_right=0.8`），现在改为嵌入 `_bottom_bar` 的左段：

```gdscript
# 原代码：panel_wrapper 直接加到 canvas
# canvas.add_child(panel_wrapper)

# 改为：嵌入底部 UI 条左段
_bottom_bar.embed_qw_panel(panel_wrapper)
```

**2.2** `panel_wrapper` 内部锚点调整：因为 `panel_wrapper` 现在是 `_qw_section` 的子节点（`PRESET_FULL_RECT`），内部的 tab + 图标行 + 时间条布局保持不变，但宽度会变窄（从 60% 屏宽 → 30% 屏宽）。

**2.3** 验收：
- [ ] QW 建造栏在底部 UI 条左段正常显示
- [ ] tab 按钮 + 图标行 + 时间条不溢出（宽度变窄后可能需要调整图标列数）
- [ ] QW 快捷键仍可触发（Q+1/W+1）

---

### 步骤 3：迁移小地图到右段（30min）

**3.1** 修改 [game_ui.gd](scripts/systems/game_ui.gd) `_create_ui()` 中创建 minimap 部分：

```gdscript
# 原代码：minimap 独立挂在 canvas 右下角
# 改为：嵌入底部 UI 条右段
var minimap := Control.new()
minimap.set_script(preload("res://scripts/ui/minimap_panel.gd"))
minimap.name = "MinimapPanel"
_bottom_bar.embed_minimap(minimap)
minimap.initialize(_main_node, _main_node.camera_module, _main_node.map_bounds)
```

**3.2** 更新相机豁免区（底部 UI 条占屏底 ~220px，右侧不再需要豁免）：

```gdscript
# T2 PR-3: 相机豁免区改为底部 UI 条
var vp := _main_node.get_viewport().get_visible_rect().size
if _main_node.camera_module != null:
	_main_node.camera_module.ui_exclusion_rects.append(
		Rect2(0, vp.y - 220, vp.x, 228)
	)
```

**3.3** ping 信号连接保持不变。

**3.4** 验收：
- [ ] 小地图在底部 UI 条右段正常显示
- [ ] ping 标记仍能显示
- [ ] 点击小地图导航仍能用
- [ ] 相机不再移动到底部 UI 条下方

---

### 步骤 4：通用详情面板模板（1h）

**4.1** 新建 [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd)：

```gdscript
extends Control
## T2 PR-3: 详情面板（L1-L5 切换）

const StatSetClass := preload("res://scripts/stats/stat_set.gd")
const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

# 状态机
enum Mode { DEFAULT, BUILDING, UNIT, TEMPORARY }
var _current_mode: int = Mode.DEFAULT
var _permanent_building = null
var _permanent_units: Array = []
var _saved_mode: int = Mode.DEFAULT  # L4 临时切换时保存

# UI 引用
var _main_node: Node2D
var _title_label: Label
var _content_vbox: VBoxContainer
var _tech_vbox: VBoxContainer

# 升级进度轮询
var _age_upgrade_active: bool = false


func initialize(main_node: Node2D) -> void:
	_main_node = main_node
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	show_default()


func _build_ui() -> void:
	# 背景面板
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	style.set_border_width_all(1)
	style.border_color = Color(1, 1, 1, 0.08)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# 标题
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	vbox.add_child(_title_label)

	vbox.add_child(HSeparator.new())

	# 现状区
	var section_label_1 := _make_section_label("现状")
	vbox.add_child(section_label_1)
	_content_vbox = VBoxContainer.new()
	_content_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_content_vbox)

	# 科技区（PR-T2-4 接入，本 PR 占位）
	vbox.add_child(HSeparator.new())
	var section_label_2 := _make_section_label("科技 / 升级")
	vbox.add_child(section_label_2)
	_tech_vbox = VBoxContainer.new()
	_tech_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_tech_vbox)
```

**4.2** 验收：
- [ ] 详情面板在中段渲染空白模板（标题 + 现状区空 + 科技区空）

---

### 步骤 5：L1 默认 + L2 单建筑 + L3 单单位（2h）

**5.1** 实现 L1（默认城堡）、L2（单建筑）、L3（单单位）：

> 详细代码见 [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd) 的 `show_default()` / `show_building(building)` / `show_unit(unit)` 方法。各对象显示内容参考 2.7 节数值表 + 3.4 节内容设计。

**5.2** 改 [game_ui.gd](scripts/systems/game_ui.gd) `update_selection_info()`，把数据传给详情面板：

```gdscript
func update_selection_info(units: Array, building = null) -> void:
	# T2 PR-3: 转发给详情面板
	if _bottom_bar != null:
		var dp = _bottom_bar.get_detail_panel()
		if dp != null:
			if building != null:
				dp.show_building(building)
			elif units.size() == 1:
				dp.show_unit(units[0])
			elif units.is_empty():
				dp.show_default()
			# 多选情况留 PR-T2-5 处理
```

**5.3** 验收：
- [ ] L1 启动时详情面板显示城堡（HP/时代/产能/升级按钮）
- [ ] L2 点地图建筑 → 详情切换（兵营显示在造进度、靶场显示反还、农场显示产能、箭塔显示攻击）
- [ ] L3 点单位 → 详情切换（步兵/弓兵显示 HP/DMG/射程/攻速/移速）
- [ ] 点空地 → 回 L1 城堡
- [ ] 升级按钮扣 500 金触发时代升级

---

### 步骤 6：L4 hover QW 图标临时切换（1h）

**6.1** 在 `detail_panel.gd` 加 L4 状态管理：

```gdscript
## L4: hover QW 图标 → 临时切换
func show_temporary_mode(mode: int) -> void:
	_saved_mode = _current_mode
	_clear_content()
	_clear_tech()
	var name_str: String = tr(D.MODE_NAMES.get(mode, "?"))
	_title_label.text = name_str + "（预览）"
	var cost: int = D.COSTS.get(mode, 0)
	_add_info_line("造价: %d 金" % cost, Color(0.6, 0.6, 0.6))
	if D.is_unit_mode(mode):
		_add_info_line("类型: 单位", Color(0.6, 0.6, 0.6))
	else:
		_add_info_line("类型: 建筑", Color(0.6, 0.6, 0.6))


## L4: 鼠标移开 → 恢复之前选中
func restore_previous() -> void:
	match _saved_mode:
		Mode.DEFAULT: show_default()
		Mode.BUILDING: show_building(_permanent_building)
		Mode.UNIT:
			if _permanent_units.size() > 0:
				show_unit(_permanent_units[0])
			else:
				show_default()
```

**6.2** 修改 [game_ui.gd](scripts/systems/game_ui.gd) `_on_icon_hover` / `_on_icon_unhover`，加详情面板临时切换调用。

**6.3** 验收：
- [ ] 鼠标移到 QW 图标 → 详情面板临时切换为"预览"
- [ ] 移开 → 恢复之前选中
- [ ] tooltip 仍正常显示（造价 + 快捷键）

---

### 步骤 7：L5 升级时城堡头顶进度条 + 详情保持（30min）

**7.1** 在 `detail_panel.gd` 的 `_process` 加升级轮询：

```gdscript
func _process(_delta: float) -> void:
	var upgrading: bool = _main_node.age_upgrade_target > 0
	if upgrading != _age_upgrade_active:
		_age_upgrade_active = upgrading
		if upgrading:
			# 升级启动 → 强制切到城堡
			if _current_mode == Mode.UNIT:
				show_default()
			elif _current_mode == Mode.BUILDING and _permanent_building != _main_node.player_castle:
				show_default()
		else:
			# 升级完成/取消 → 刷新城堡数据
			if _current_mode == Mode.DEFAULT:
				show_default()
```

**7.2** 在 [building.gd](scripts/buildings/building.gd) 加 `_age_upgrade_bar` 节点（仅城堡），在 y=-90 创建进度条（避开产兵圆圈 y=-60）。

**7.3** 在 [main.gd](scripts/main.gd) 升级倒计时处加进度条更新。

**7.4** 验收：
- [ ] 点升级按钮 → 城堡头顶出现进度条（独立于产兵圆圈）
- [ ] 详情面板保持显示城堡
- [ ] 升级完成 → 进度条消失，详情面板显示 T2 城堡
- [ ] 升级取消 → 进度条消失，详情面板仍显示城堡（T1）

---

### 步骤 8：清理底部建造面板旧结构（30min）

**8.1** 删除底部建造面板的 TAB_INFO 按钮和 info_container：
- 删除 info_tab 按钮创建
- 删除 info_container 整段创建
- tab_buttons 数组从 4 个变 3 个（unit / building / outpost）
- `_switch_tab` 切换逻辑去掉 tab_index==2 分支
- outpost tab 的 index 从 3 改成 2

**8.2** 删除 `_update_info_panel()` 和 `_tracked_units` / `_tracked_building` 等相关变量（已迁到 detail_panel.gd）。

**8.3** 验收：
- [ ] 底部建造面板只有 3 个 tab（单位/建筑/据点）
- [ ] 不再有 TAB_INFO 按钮
- [ ] 选中单位/建筑不再触发底部面板切换（详情在中段）

---

### 步骤 9：分辨率适配测试（30min）

切换 1920 / 1600 / 1280 分辨率测试：
- [ ] 底部 UI 条高度固定 ~220px，全宽拉伸
- [ ] 三段比例保持（30/40/20）
- [ ] QW 建造栏图标在窄屏下不溢出
- [ ] 详情面板内容不溢出
- [ ] 小地图在窄屏下可读

---

## 六、风险与注意事项

### 6.1 高风险
- **QW 建造栏横向压缩后图标布局**：现 QW 面板宽 60% 屏宽（~1152px @1920），压缩到 30%（~576px）后图标行可能放不下原来的列数。需要调整图标排列（减列数或缩图标）
- **1280 分辨率下三段过窄**：1280 下 QW 段仅 384px、详情段 512px、小地图 256px。小地图最小尺寸 172×172 可读，但接近极限

### 6.2 中风险
- **L4 hover 实现细节**：现有 QW 按钮在 `_add_icon_button()` 创建，已连 `mouse_entered/exited`。注意 button_factory.gd 的封装不要破坏
- **L5 升级时强制切到城堡**：用户选中其他单位时启动升级，是否强制切到城堡？计划**不强制**——只在用户当前选中是城堡或空地时切换；选了其他单位时维持，避免打断操作

### 6.3 注意事项
- **不要复用 `_production_circle`**：城堡头顶升级进度条要新建独立节点（`_age_upgrade_bar`），避免与产兵进度冲突（产兵 y=-60，升级 y=-90）
- **预留科技区插槽**：详情面板的科技区是独立 VBoxContainer，PR-T2-4 会往里面塞升级按钮。本 PR 用占位 Label 标记位置
- **目标面板不动**：右上角目标/波次面板保持原样（独立 CanvasLayer + PRESET_TOP_RIGHT），本 PR 不改 objectives_panel.gd
- **节点命名**：新建节点用清晰名字（`BottomUIBar` / `DetailPanel` / `QWSection` 等），避免 get_children() 遍历找节点时误匹配

---

## 七、验收清单

### 7.1 底部横排 UI 条布局
- [ ] 屏幕底部有三段式横排 UI 条（高 ~220px）
- [ ] 三段比例：QW ~30% / 详情 ~40% / 小地图 ~20%
- [ ] 1920 分辨率下三段宽度正常
- [ ] 1280 分辨率下不溢出/不变形

### 7.2 QW 建造栏压缩
- [ ] QW 建造栏在左段正常显示
- [ ] tab + 图标行 + 时间条不溢出
- [ ] QW 快捷键仍可触发（Q+1/W+1）
- [ ] QW 4 tab 减为 3 tab（移除 INFO）

### 7.3 小地图迁移
- [ ] 小地图在右段正常显示
- [ ] 标记、点击导航、ping 等行为不变
- [ ] 相机豁免区更新到底部 UI 条

### 7.4 右上角不变
- [ ] 目标/波次面板仍在右上角
- [ ] 波次倒计时、目标条件等内容完整
- [ ] 折叠按钮仍可点击

### 7.5 详情面板 L1-L5
- [ ] L1：启动时显示城堡详情（HP/时代/产能/升级按钮占位）
- [ ] L2：点建筑 → 显示该建筑详情（按类型显示不同字段）
- [ ] L3：点单位 → 显示该单位详情（HP/DMG/射程/攻速/移速）
- [ ] L4：hover QW 图标 → 临时切换预览，移开恢复
- [ ] L5：升级 T2 时 → 城堡头顶进度条 + 详情面板保持城堡
- [ ] 点空地 → 回 L1

### 7.6 详情面板模板
- [ ] 标题区显示图标 + 名称
- [ ] 现状区按对象类型动态填充
- [ ] 科技区有占位 Label（"T2 全局升级待接入"）
- [ ] 城堡详情有"升级到 T2"按钮（调用 main._start_age_upgrade）

### 7.7 不破坏现有功能
- [ ] 资源面板（左上）正常
- [ ] 倍速按钮（左下）正常
- [ ] 暂停菜单（ESC）正常
- [ ] SH1 据点占领后 outpost tab 仍显示
- [ ] 灰色锁（T1 时靶场/弓兵灰显）仍生效

---

## 八、关联文档

- 总览：[T2_实施路线图.md](T2_实施路线图.md)
- 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 5 + 6 章 + 2.3.6 节
- 前置：[T2_PR-1_实施计划.md](T2_PR-1_实施计划.md)（时代升级状态供详情面板读）
- 后续：[T2_PR-4_实施计划.md](T2_PR-4_实施计划.md)（升级按钮挂详情面板科技区）
- 后续：[T2_PR-5_实施计划.md](T2_PR-5_实施计划.md)（L6-L9 多选场景接入详情面板）
