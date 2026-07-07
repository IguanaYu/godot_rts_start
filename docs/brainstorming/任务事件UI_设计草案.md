# 任务事件 UI — 设计草案

> 状态：brainstorming（核心方向待对齐）
>
> 配套文档：
> - 跨游戏调研：[任务事件UI_跨游戏调研.md](../reference/research/任务事件UI_跨游戏调研.md)

---

## 1. 目标

把当前散落在 17+ 个 VictoryCondition 子类里的"任务文字 / 进度 / 标记"逻辑收敛成一套**统一格式**，让：

- **任务面板（objectives_panel.gd）** 不再每条目标都渲染成 `Label + Label`，能根据数据自带类型动态选择渲染器（进度条 / 倒计时 / 计数 / HP 条）
- **任务事件提示** 独立成一套信号系统，接到/完成/失败任务时屏幕中央有动画 + 音效，而不是只能靠面板刷新
- **任务描述格式** 统一：动词开头 + 对象 + 数量/时限，不再出现 `"Kill: " + target_category` 这种硬拼字符串，也不再在翻译 key 里塞 `%d/%d`

---

## 2. 现状问题

### 2.1 目标产出格式不一致

每个 VictoryCondition 子类自己拼 `get_objectives()` 的字典：

| 子类 | 当前做法 | 问题 |
|---|---|---|
| [victory_assassinate.gd:94-98](../../scripts/victory/victory_assassinate.gd#L94-L98) | `text = "Kill: " + target_category` | 英文硬拼，没走翻译 |
| [victory_kill_count.gd:95-99](../../scripts/victory/victory_kill_count.gd#L95-L99) | `text = tr(description_key)`，但翻译 key `OBJ_KILL_COUNT` 自带 `%d/%d` | 描述文字和进度信息混在一起 |
| [victory_hold_point.gd:48-61](../../scripts/victory/victory_hold_point.gd#L48-L61) | 进度是 `"Hold: 60s remaining"` 整句 | 想把"倒计时"换成进度条就得改源码 |
| [victory_protect_building.gd:117-127](../../scripts/victory/victory_protect_building.gd#L117-L127) | 进度是 `"Time: 60s"` | 跟 hold_point 又是两种格式 |
| [victory_multi_stage.gd:104-146](../../scripts/victory/victory_multi_stage.gd#L104-L146) | 用 `"  " + text` 做缩进 | 靠空格控制视觉层级 |
| [victory_destroy_buildings.gd:115-119](../../scripts/victory/victory_destroy_buildings.gd#L115-L119) | `text = "Destroy: " + type_name`（type_name 写死 "Tower"） | 又一个硬拼 |

### 2.2 没有"任务事件"这一层

现在只有 `objective_updated` 信号告诉 UI"刷新一下"。SC2/WC3 都有的：

- 接到新任务时的 cinematic 提示
- 任务完成的恭喜提示 + 奖励列表
- 任务失败的红色警告
- 多阶段切换时的过渡动画

本项目都缺失。多阶段切换只是静默改 `process_mode` + 刷新面板。

### 2.3 任务面板渲染能力弱

[objectives_panel.gd:182-206](../../scripts/ui/objectives_panel.gd#L182-L206) 渲染循环只能产出 `Label + Label`，没法：

- 显示横向进度条
- 显示 HP 条（保护目标的当前 HP）
- 显示圆形倒计时
- 显示单位图标 + 计数 `[☠ x3]`
- 显示完成/失败的状态徽章

任何一类想加都得在 panel 里写特殊分支。

### 2.4 翻译 key 格式混杂

[locales/translations.csv:209-315](../../locales/translations.csv#L209-L315) 里 OBJ_* 一段：

```
OBJ_VIP_SURVIVAL,Protect the VIP,...           # 纯描述
OBJ_KILL_COUNT,Kill enemies: %d/%d,...          # 描述+进度
OBJ_TIME_REMAINING,Time: %s,...                 # 纯进度前缀
OBJ_HOLD_REMAINING,Hold: %ds remaining,...      # 又一种进度格式
OBJ_STAGE,Stage %d: %s,...                      # 阶段标题
OBJ_COMPLETED,Completed,...                     # 状态文案
```

没有"哪种 key 该带占位符"的约定。

---

## 3. 设计提案

### 3.1 统一任务数据模型（ObjectiveData）

把 `get_objectives()` 返回的字典升级成强类型资源：

```gdscript
# scripts/objectives/objective_data.gd
class_name ObjectiveData
extends Resource

enum State { LOCKED, ACTIVE, COMPLETED, FAILED }
enum Kind { PRIMARY, SECONDARY, BONUS }    # 主线/支线/奖励
enum ProgressFormat {
    NONE,                  # 无进度（纯描述）
    COUNT,                 # 12/30
    FRACTION_BAR,          # 横向进度条
    TIMER_COUNTDOWN,       # 03:25 倒计时（圆形或文字）
    HP_BAR,                # HP 条（保护目标）
    ICON_COUNT,            # [☠ x3] 图标计数
    CHECKLIST,             # 多个 ✓/✗ 子项
}

@export var id: StringName                  # 唯一标识，便于事件系统定位
@export var title_key: String               # 翻译 key：短标题
@export var desc_key: String                # 翻译 key：完整描述
@export var state: State = State.ACTIVE
@export var kind: Kind = Kind.PRIMARY
@export var progress_format: ProgressFormat = ProgressFormat.NONE

# 进度数据（按 format 解释）
@export var current_value: float = 0.0
@export var target_value: float = 0.0
@export var icon_type: int = -1             # ICON_COUNT 用的图标枚举（复用 ObjectiveMarker.MarkerType）
@export var checklist_items: Array[Dictionary] = []  # CHECKLIST 用：[{text, checked}, ...]

# 关联的世界标记
@export var marker_id: StringName = &""     # 关联到 objective_markers 里的某个标记
```

**关键约束**：

- `title_key` / `desc_key` 必须是**纯描述翻译 key**，**不允许带 `%d`/`%s` 占位符**。占位符一律在进度字段里。
- 进度信息永远走 `current_value/target_value`，由前端按 `progress_format` 渲染。
- `id` 用于事件系统精确指派（"只刷新这个目标"、"标记这个目标完成"）。

### 3.2 任务描述统一格式

参考 SC2/WC3 的动词 + 对象 + 数量/时限模板：

| 任务类型 | 描述模板（中文示例） | 翻译 key 写法 |
|---|---|---|
| 摧毁 | "摧毁敌方 3 座兵营" | `OBJ_DESTROY_BARACKS`（不带数字） |
| 击杀 | "消灭敌方英雄单位" | `OBJ_KILL_HERO` |
| 保护 | "保护中央箭塔" | `OBJ_PROTECT_TOWER` |
| 占领 | "占领并坚守北据点" | `OBJ_HOLD_NORTH` |
| 收集 | "积累金币" | `OBJ_ACCUMULATE_GOLD` |
| 护送 | "护送 VIP 到达目的地" | `OBJ_ESCORT_VIP` |
| 生存 | "在敌方进攻中存活" | `OBJ_SURVIVE_WAVES` |

**描述文字只承担"做什么"，数字走 progress 字段**。例：

```gdscript
# 之前
return [{
    "text": tr("OBJ_KILL_COUNT"),  # "Kill enemies: %d/%d"
    "progress": "%d/%d" % [_killed, _total],
    "state": 0
}]

# 之后
var data := ObjectiveData.new()
data.title_key = "OBJ_KILL_TARGETS"
data.desc_key = "OBJ_KILL_TARGETS_DESC"     # "Eliminate the priority targets"
data.progress_format = ObjectiveData.ProgressFormat.COUNT
data.current_value = _killed
data.target_value = _total
return [data]
```

### 3.3 动态组件库

任务面板按 `progress_format` 在工厂里选渲染器。下表是 v1 要支持的组件清单：

| 组件 | ProgressFormat | 视觉示例 | 适用任务 |
|---|---|---|---|
| 纯文字 | NONE | `保护中央箭塔` | 保护类、VIP 存活 |
| 计数文字 | COUNT | `12/30` | 击杀计数、收集金币 |
| 横向进度条 | FRACTION_BAR | `[████░░░░] 50%` | 收集神器、领地积分 |
| 倒计时文字 | TIMER_COUNTDOWN | `02:35` | 限时生存、坚守计时 |
| HP 条 | HP_BAR | `[████░░] 75/100` | 保护建筑、Boss 战 |
| 图标计数 | ICON_COUNT | `[☠ ×3]` | 刺杀多目标、多建筑 |
| 复选清单 | CHECKLIST | `✓ 北据点`<br>`✓ 中据点`<br>`☐ 南据点` | 多阶段据点、多目标刺杀 |

**渲染工厂**（伪代码）：

```gdscript
# scripts/ui/objective_row_factory.gd
func create_row(data: ObjectiveData) -> Control:
    var row := preload("res://scenes/ui/objective_row.tscn").instantiate()
    row.setup_title(tr(data.title_key))
    row.setup_state_badge(data.state)           # ACTIVE/COMPLETED/FAILED 徽章
    row.setup_kind_icon(data.kind)              # PRIMARY 金/SECONDARY 银/BONUS 紫
    match data.progress_format:
        ObjectiveData.ProgressFormat.NONE:
            pass                                # 不渲染进度区
        ObjectiveData.ProgressFormat.COUNT:
            row.setup_count(int(data.current_value), int(data.target_value))
        ObjectiveData.ProgressFormat.TIMER_COUNTDOWN:
            row.setup_countdown(data.current_value)  # 剩余秒数
        ObjectiveData.ProgressFormat.HP_BAR:
            row.setup_hp_bar(data.current_value, data.target_value)
        # ...
    return row
```

每个 setup_xxx 内部管理自己的更新逻辑（倒计时自己 tick，HP 条监听目标信号），不污染外部。

### 3.4 任务事件提示系统（MissionEventBus）

独立于任务面板的瞬时通知系统：

```gdscript
# scripts/systems/mission_event_bus.gd
class_name MissionEventBus
extends Node

enum EventType {
    OBJECTIVE_RECEIVED,    # 接到新任务
    OBJECTIVE_UPDATED,     # 进度变化（仅大幅变化才提示）
    OBJECTIVE_COMPLETED,   # 完成
    OBJECTIVE_FAILED,      # 失败
    STAGE_ADVANCED,        # 多阶段切换
    MISSION_START,         # 任务开场
    MISSION_END,           # 任务结束（胜利/失败）
}

signal event_emitted(event: Dictionary)
# event = { "type": EventType, "objective_id": StringName, "title_key": String,
#           "payload": Dictionary (奖励列表/旧阶段/新阶段/失败原因 等) }
```

**消费方**：

1. **Toast UI**（屏幕中央/上方）：cinematic 动画 + 音效
2. **任务面板**：监听 OBJECTIVE_COMPLETED 给对应行打勾，监听 STAGE_ADVANCED 切换显示
3. **小地图**：监听 OBJECTIVE_RECEIVED 给目标点加脉冲

**事件触发示例**：

```gdscript
# 多阶段切换时
mission_event_bus.emit({
    "type": MissionEventBus.EventType.STAGE_ADVANCED,
    "objective_id": &"main_quest",
    "title_key": "OBJ_STAGE_2",
    "payload": { "old_stage": 0, "new_stage": 1, "total_stages": 3 }
})
```

**Toast 行为**（参考调研 §2.1-2.2）：

| 事件类型 | 颜色 | 停留 | 音效 | 堆叠 |
|---|---|---|---|---|
| OBJECTIVE_RECEIVED | 金黄 | 3.5s | 钟声 | 最多 2 条 |
| OBJECTIVE_COMPLETED | 翠绿 | 2.5s | 短号角 | 最多 3 条 |
| OBJECTIVE_FAILED | 暗红 | 4.0s | 警报 | 不堆叠（替换） |
| STAGE_ADVANCED | 蓝白 | 3.0s | 转场音 | 不堆叠 |
| MISSION_END | 全屏 | 手动关闭 | 胜利/失败主题曲 | 单条 |

### 3.5 任务面板 UI 重构

[objectives_panel.gd](../../scripts/ui/objectives_panel.gd) 保持当前位置（右上角）+ 折叠按钮，重构成：

```
┌─ Info ──────────────────────[▼]─┐
│                                 │
│  MAIN QUEST                     │  ← Kind.PRIMARY 区
│  ☐ 摧毁敌方 3 座兵营    [2/3]    │     完成行划线灰化
│  ☐ 保护中央箭塔       ████░ 75% │
│                                 │
│  ─────────────────              │
│                                 │
│  SECONDARY          [2 active]  │  ← Kind.SECONDARY 折叠组
│  > 消灭隐藏 Boss                │     默认折叠，按钮展开
│                                 │
│  ─────────────────              │
│                                 │
│  WAVES                          │  ← 原波次区保持
│  Wave 2/5   [████░░] 18s        │
│                                 │
└─────────────────────────────────┘
```

**关键变化**：

- 不再 `Label + Label`，每行是 `ObjectiveRow` 复合控件（按 §3.3 工厂产出）
- 主线/支线分区，支线默认折叠（调研 §2.2-3）
- 已完成行**划线 + 灰化**，不删除（调研 §2.1-5）
- 状态徽章独立显示（`☐` 进行中 / `✓` 完成 / `✗` 失败）

### 3.6 任务标记（世界 + 小地图）联动

当前 [objective_marker.gd](../../scripts/effects/objective_marker.gd) 已经有 7 种图标 × 3 等级。问题是它跟任务面板/事件系统没绑定——是各 VictoryCondition 自己 `_add_marker` 加的。

设计：让 ObjectiveData 自带 `marker_id`，事件系统监听状态变化：

- `OBJECTIVE_RECEIVED` → 自动创建对应世界标记 + 小地图脉冲
- `OBJECTIVE_COMPLETED` → 标记淡出（已有 `dismiss()`）
- `OBJECTIVE_FAILED` → 标记变红闪烁（已有 `set_danger(true)`）

这样 VictoryCondition 子类只需在数据里声明 `marker_id` 与图标类型，不用自己 `_add_marker`。

---

## 4. 实施路径

按"先抽象、再迁移、最后加新功能"分 4 阶段：

### 阶段 1：抽象层（不改现有子类）
- [ ] 新建 `ObjectiveData` 资源
- [ ] 新建 `ObjectiveRow` 场景（标题 + 状态徽章 + 进度区）
- [ ] 新建 `objective_row_factory.gd`
- [ ] 在 `VictoryCondition` 基类加 `get_objective_data() -> Array[ObjectiveData]`，默认实现把旧 `get_objectives()` 字典转换成 `ObjectiveData`（兼容层）

### 阶段 2：迁移现有子类
- [ ] 每个子类（assassinate / kill_count / destroy_buildings / protect_building / hold_point / multi_stage / composite 等）实现 `get_objective_data()`，删掉硬拼字符串
- [ ] 翻译表整理：拆分描述 key（不带占位符）和进度格式
- [ ] `objectives_panel.gd` 切换到调用 `get_objective_data()` + 工厂渲染

### 阶段 3：任务事件系统
- [ ] 新建 `MissionEventBus` autoload
- [ ] 关键节点（VictoryMultiStage 切阶段、VictoryCondition 完成、VictoryComposite 子条件状态变化）发事件
- [ ] 新建 Toast UI 场景（屏幕中央偏上，cinematic 动画）
- [ ] 接入音效系统

### 阶段 4：增强（可选）
- [ ] Bonus 目标折叠组
- [ ] 小地图任务脉冲
- [ ] 屏外目标方向箭头（参考调研 §2.2-8）
- [ ] Scout Report 开场卡片（参考 AoE4）
- [ ] 任务完成度评分（参考 8-Bit Armies 1-3 星）

---

## 5. 待决策问题

实现前需要拍板的设计选择，按优先级排：

### Q1：ObjectiveData 用 Resource 还是 Dictionary？

- **Resource**：类型安全，编辑器里能 `@export`，但每条目标要 `.new()` + 字段赋值，代码量略多
- **Dictionary**：跟现有 `get_objectives()` 兼容，但失去类型检查

**推荐**：Resource。代价是迁移工作量，但长期收益（编辑器可见、强类型）值得。

### Q2：是否一次性迁移所有 17 个子类？

- 一次性：UI 立刻一致，但 PR 巨大、回归风险高
- 渐进式：基类加兼容层，新数据模型和旧字典并存，按子类逐个迁移

**推荐**：渐进式。基类 `get_objective_data()` 默认实现做转换，旧子类不重写也能跑。优先迁移出现频率最高的（destroy_base / survive_waves / hold_point / multi_stage）。

### Q3：任务事件 Toast 的位置？

- 屏幕中央偏上（WC3 cinematic 风格）：醒目，但战斗时挡 HUD
- 屏幕上方居中横向 banner（SC2 风格）：占顶部，需确保不挡资源栏
- 右上角任务面板内联高亮（无独立 toast）：最不打扰，但缺戏剧性

**推荐**：屏幕中央偏上，停留 ≤ 3.5s，自动淡出。仅"接到新任务"和"任务完成"用中央 toast；进度小更新走面板内联高亮。

### Q4：多阶段任务（MultiStage）的展示粒度？

- 只显示当前阶段（沉浸更好，但易迷失）
- 当前阶段高亮 + 未来阶段灰显（剧透风险，但目标更清晰）

**推荐**：当前阶段高亮 + 未来阶段灰显标题（不显示具体目标），调研 §2.1-7 提到 SC2 直接替换文字会迷茫。

### Q5：Bonus 目标的视觉区分？

调研显示主/次目标必须用图标 + 颜色双重区分（§2.1-2）。

- **方案 A**：图标（主线 ★ / 支线 ◆ / 奖励 ✦）+ 颜色（金/银/紫）
- **方案 B**：缩进 + 颜色（金/银/灰）

**推荐**：方案 A。已有 `ObjectiveMarker` 7 种图标可复用。

### Q6：任务面板默认展开还是折叠？

- 任务数 ≤ 3 自动展开
- 任务数 ≥ 4 主线展开 + 支线折叠

**推荐**：阈值 3。

### Q7：音效资源从哪来？

任务事件三态（接到/完成/失败）各需一个音效。当前项目音效库情况未知，可能需要：

- 用免费音效库（freesound.org / opengameart.org）
- 程序化合成（Godot AudioStreamGenerator）
- 暂时用 placeholder 不放音效，先把 UI 跑通

**推荐**：v1 先不放音效，UI 跑通后再补。

### Q8：是否需要 Scout Report 开场卡片？

AOE4 的开场侦察报告对剧情任务很有用，但对本项目（目前以战斗节奏为主）可能过重。

**推荐**：先不做。等剧情任务多了再考虑。

---

## 6. 风险与避坑（待要点拆文档详述）

- **回归风险**：17 个子类逐个迁移，每次都要在测试场景里验证面板正确刷新
- **翻译表迁移**：拆分描述 key 时要保留旧 key 兼容（或一次性删除，看是否还有外部引用）
- **资源管理**：ObjectiveData 是 Resource，要注意 `duplicate()` vs 共享引用——多阶段任务切换时不能误改到模板
- **性能**：每帧重建 N 行 ObjectiveRow 在大量目标时可能卡，考虑 dirty flag + 增量更新

---

## 7. 后续

- 设计对齐后，要点拆文档放在 [docs/reference/design/任务事件UI_设计要点与避坑指南.md](../reference/design/任务事件UI_设计要点与避坑指南.md)
- 实施从阶段 1 开始，每阶段独立 PR
