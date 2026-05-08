# 多地图关卡系统实施计划

## Context
当前项目是一个 Godot 4.6 的 2D RTS 游戏，只有单张地图，所有逻辑硬编码在 `main.gd`（847行）中。目标是实现 5 张不同玩法的地图 + 选关界面 + AI 扩展 + 占领点系统。

---

## 实施顺序（按用户优先级）

### 第一阶段：架构重构（前置工作，所有地图依赖）
### 第二阶段：图2 基础进攻
### 第三阶段：图1 闪击战 + 图3 基础防守
### 第四阶段：选关页面
### 第五阶段：图4 复杂防守 + 图5 复杂进攻
### 第六阶段：测试 & 小发布

---

## 第一阶段：架构重构

### 目标
将 `main.gd` 从硬编码单地图改为数据驱动的通用游戏控制器，支持不同地图配置。

### 新建文件

**1. `scripts/map_config.gd`** — 地图配置资源类
```gdscript
class_name MapConfig
extends Resource
```
- `map_name: String`
- `map_bounds: Rect2` — 地图边界
- `nav_bounds: Array[Vector2]` — 导航区域顶点
- `initial_gold: int` — 初始金币
- `camera_start: Vector2` — 相机初始位置
- `player_units: Array[Dictionary]` — {type: int, pos: Vector2}
- `enemy_units: Array[Dictionary]`
- `player_buildings: Array[Dictionary]` — {type: int, grid_pos: Vector2i}
- `enemy_buildings: Array[Dictionary]`
- `environment: Dictionary` — {trees: int, rocks: int, bushes: int, sheep: int}
- `available_items: Array[int]` — 该地图可用的 PlaceMode 列表
- `map_description: String`

**2. `scripts/victory_condition.gd`** — 胜利条件基类
```gdscript
class_name VictoryCondition
extends Node
```
- `signal game_ended(result: String)` — "victory" / "defeat"
- `func check() -> int` — 返回 0=进行中, 1=胜利, 2=失败
- 子类重写 `check()` 实现不同胜利条件

**3. `scripts/wave_manager.gd`** — 波次管理器
```gdscript
class_name WaveManager
extends Node
```
- `@export var waves: Array[Dictionary]` — 每波 {delay: float, units: Array[{type, pos}]}
- `var current_wave: int = -1`
- `signal wave_started(wave_number: int)`
- `signal all_waves_completed`
- 使用 Timer 控制波次间隔
- 调用 game_controller 的公开方法刷兵

**4. `scripts/capture_point.gd`** — 占领点实体
```gdscript
class_name CapturePoint
extends Area2D
```
- `capture_radius: float = 100.0`
- `capture_progress: float = 0.0` (0~100)
- `capturing_team: int = 0` (0=中立, 1=玩家, 2=敌方)
- `captured_by: int = 0` (已完成的占领方)
- `reward_gold: int = 500`
- 视觉：脉冲光圈动画
- `_process` 检测范围内单位，推进占领进度
- `signal captured(team: int)` 占领完成信号

### 修改文件

**5. `scripts/main.gd` 重构**
- 新增变量：`map_config: MapConfig`, `victory_condition: VictoryCondition`
- `_ready()` 改为：加载 map_config → 根据配置生成 UI → 根据配置刷兵 → 设置胜利条件
- `_spawn_initial()` → `_spawn_from_config()` 从 map_config 读取数据
- `_spawn_environment()` → 从 map_config 读取环境配置
- `_create_ui()` → 从 map_config.available_items 生成按钮（而非硬编码 10 个按钮）
- `_check_victory()` → 委托给 `victory_condition.check()`
- `map_bounds` 和 `NAV_BOUNDS` 从 map_config 读取
- `_create_grid()` 的范围从 map_config 读取
- 键盘快捷键（KEY_1~KEY_0）绑定改为动态：根据 available_items 映射
- 新增公开方法供 WaveManager 调用：`spawn_enemy_unit(type, pos)`
- **保持不变**：相机系统、选择系统、放置逻辑、输入处理、导航重建

### 关键修改点（main.gd 具体行号）

| 区域 | 行号 | 改动 |
|------|------|------|
| 地图常量 | 6-7 | 改为从 map_config 读取 |
| UI按钮数据 | 135-146 | 改为从 map_config.available_items 动态生成 |
| _ready | 70-83 | 重写为配置驱动 |
| _spawn_initial | 200-241 | 替换为 _spawn_from_config() |
| _spawn_environment | 244-301 | 替换为配置驱动 |
| _check_victory | 569-594 | 委托给 victory_condition.check() |
| _create_grid | 86-116 | 范围从 map_config 读取 |
| 快捷键绑定 | 643-662 | 动态映射 |
| 键盘数据 | 10-21 | 保持 COSTS，available_items 从 config 过滤 |

---

## 第二阶段：图2 — 基础进攻

### 玩法
玩家建造基地、训练军队，直接推掉敌方城堡获胜。

### 新建文件

**1. `scripts/victory_destroy_base.gd`** — 摧毁基地胜利条件
```gdscript
class_name VictoryDestroyBase
extends VictoryCondition
```
- `check()`: 玩家城堡被毁 → 失败；敌方城堡被毁 → 胜利
- 本质上就是当前 `_check_victory()` 的逻辑提取

**2. `resources/map2_config.tres`** — 图2 配置
- 玩家：城堡(1,2)、兵营(5,3)、3士兵+2弓箭手
- 敌方：城堡(12,2)、兵营(10,3)、箭塔(15,4)、城墙、3士兵+2弓箭手
- 金币：10000，所有建筑/单位可用
- 即当前硬编码的地图数据

**3. `scenes/maps/map_2.tscn`** — 图2 场景
- 复制 main.tscn 的节点结构（Ground, NavigationRegion2D, Camera2D, PlayerUnits, EnemyUnits, Buildings 等）
- 根节点脚本不变（main.gd）
- 添加 VictoryDestroyBase 子节点
- 设置 map_config 指向 map2_config.tres

### AI（图2）
- 敌方 AI 使用现有 enemy_ai.gd 的 PATROL/CHASE/ATTACK 即可
- 初始敌方单位自带巡逻 AI，玩家推过去时自动应战

---

## 第三阶段：图1 闪击战 + 图3 基础防守

### 图1：闪击战

**新建文件：**

**`scripts/victory_blitz.gd`** — 据点推进胜利条件
- 3 个据点坐标（@export）
- 玩家单位到达据点范围 → 占领（停留3秒）
- 必须按顺序占领（据点1→2→3）
- 3个据点全占 → 胜利
- 玩家城堡被毁 → 失败

**`resources/map1_config.tres`** — 图1 配置
- 地图：线性狭长（横向），3个据点均匀分布
- 玩家：左侧出生，只有初始部队 + 少量金币买兵（**无建造**）
- 敌方：每个据点有守军（2-4个单位），据点3有堡垒
- available_items：仅 SOLDIER, ARCHER, LANCER（无任何建筑）
- initial_gold：2000（仅够补充兵力）

**`scenes/maps/map_1.tscn`** — 图1 场景
- 添加 VictoryBlitz 子节点
- 3 个 CapturePoint 子节点标记据点位置

**AI（图1）：**
- 敌方守军在据点附近巡逻（patrol_radius 小）
- 检测到玩家靠近即 chase + attack
- 用现有 enemy_ai.gd 即可，调整巡逻中心和半径

### 图3：基础防守

**新建文件：**

**`scripts/victory_survive_waves.gd`** — 生存波次胜利条件
- `@export var waves_to_survive: int = 3`
- WaveManager 所有波次完成 + 所有敌方单位死亡 → 胜利
- 玩家城堡被毁 → 失败
- `check()` 中检查 WaveManager 状态

**`resources/map3_config.tres`** — 图3 配置
- 玩家：中央偏左，已有完整防线（城堡+兵营+箭塔+城墙），初始较多军队
- 敌方：无初始单位，无建筑（靠波次生成）
- 金币：15000（用于防御建设）
- available_items：所有防御建筑 + 士兵/弓箭手/枪兵

**`scenes/maps/map_3.tscn`** — 图3 场景
- 添加 WaveManager 子节点（3波配置）
- 添加 VictorySurviveWaves 子节点

**波次设计：**
- 第1波（30秒后）：3士兵+2弓箭手，从右侧进攻
- 第2波（第1波清完后60秒）：5士兵+3弓箭手+1枪兵，从右侧进攻
- 第3波（第2波清完后90秒）：8士兵+4弓箭手+2枪兵，从右+上两路进攻

**AI（图3）：**
- 波次生成的敌方单位使用 `start_wave_attack(player_base_pos)` 直接进攻
- 扩展 enemy_ai.gd：新增 `WAVE_ATTACK` 状态
  - 单位朝目标移动
  - 路上遇到敌方单位 → 切换 CHASE/ATTACK
  - 击杀后继续朝目标前进
  - 不返回 PATROL

---

## 第四阶段：选关页面

### 新建文件

**`scenes/level_select.tscn`** — 选关界面
- Control 根节点
- 标题 "Select Level"
- 5 个地图按钮/卡片（显示地图名称+描述）
- 暂时全部解锁（无锁定逻辑）

**`scripts/level_select.gd`** — 选关逻辑
- 5 个按钮分别跳转到对应地图场景
- `get_tree().change_scene_to_file()` 切换
- Esc 键返回或退出

**修改 `project.godot`**：主场景改为 `res://scenes/level_select.tscn`

---

## 第五阶段：图4 + 图5

### 图4：复杂防守（主动清野扩张）

**新建文件：**

**`scripts/victory_expand_defense.gd`** — 扩张防守胜利条件
- 必须占领所有中立据点 + 存活 N 波
- 占领据点给奖励（金币、解锁新兵种）
- 玩家城堡被毁 → 失败

**`resources/map4_config.tres`** — 大地图，中立营地分散各处
- 玩家：中央，初始基地
- 中立营地：4-5个，各有守军
- 敌方：地图边缘，定时波次进攻
- 金币：8000

**`scenes/maps/map_4.tscn`** — 图4 场景
- CapturePointManager + WaveManager + VictoryExpandDefense
- 5 个 CapturePoint 分布地图各处

**AI（图4）：**
- 敌方巡逻：部分单位在营地周围巡逻
- 波次进攻：每60-90秒一波，进攻玩家基地或已占领据点
- 需要 enemy_ai.gd 的 WAVE_ATTACK 状态

### 图5：复杂进攻

**新建文件：**

**`scripts/victory_outpost_sequential.gd`** — 前哨→主基地胜利条件
- 2-3个敌方前哨必须先被摧毁
- 前哨全灭后，敌方主基地才可被攻击（之前无敌）
- 或者：占领所有据点也算胜利
- 玩家城堡被毁 → 失败

**`resources/map5_config.tres`** — 大地图，敌方有多重防线
- 玩家：左下角，完整基地
- 敌方：2个前哨（各有守军+建筑），1个主基地
- 中立据点：2-3个可占领
- 金币：10000

**`scenes/maps/map_5.tscn`** — 图5 场景
- CapturePointManager + WaveManager + VictoryOutpostSequential

**AI（图5）：**
- 前哨守军巡逻
- 主基地定时派援军到前哨
- 玩家占领中立据点时，敌方可能派兵抢回

---

## enemy_ai.gd 扩展

在现有 3 个状态基础上新增：

```
enum AIState { PATROL, CHASE, ATTACK, WAVE_ATTACK }

var wave_target: Vector2 = Vector2.ZERO
var chase_range: float = 300.0  # 波次行军中追敌范围

func start_wave_attack(target: Vector2):
    wave_target = target
    ai_state = AIState.WAVE_ATTACK
    unit.call("attack_move_to", target)

# WAVE_ATTACK 状态逻辑：
# - 朝 wave_target 移动
# - 遇敌（chase_range 内）→ 切 CHASE
# - 击杀后 → 回到 WAVE_ATTACK 继续前进
# - 到达目标 → 切 PATROL（以目标为中心巡逻）
```

---

## capture_point.gd 实现

### 灵活奖励系统
占领点设计为通用场景，支持灵活配置不同奖励类型：

```
class_name CapturePoint
extends Area2D

# 奖励类型枚举
enum RewardType { GOLD, UNITS, CUSTOM }
@export var reward_type: RewardType = RewardType.GOLD
@export var reward_gold: int = 500
@export var reward_units: Array[Dictionary] = []  # [{type: UnitType.SOLDIER, count: 2}]
@export var reward_custom: String = ""  # 预留未来扩展

# 触发方式
@export var trigger_on_start: bool = true  # 地图开始时可见
@export var trigger_on_kill_all: bool = false  # 消灭附近敌军后刷新
@export var trigger_on_destroy_building: NodePath = ""  # 摧毁指定建筑后刷新
```

### 视觉表现
- Area2D + CollisionShape2D (CircleShape2D, radius=100)
- 未激活时隐藏，触发条件满足后出现光圈
- 光圈：脉冲动画，占领中进度环
- _process: 检测 overlapping_bodies，统计各阵营单位数量
- 占领进度：优势方每秒+20，另一方减少
- 满值时触发 `captured(team)` 信号

### 奖励发放
- 金币：通知 game_controller.add_gold(amount)
- 单位：通知 game_controller 在占领点附近生成指定单位
- 信号：`signal reward_granted(reward_data: Dictionary)` 预留扩展

### 触发场景
1. **图1/图2**：据点一开始就存在，玩家踩上去读条占领
2. **图4/图5**：消灭中立营地守军 → 刷新光圈 → 踩上去占领 → 给金币+兵
3. **未来扩展**：摧毁敌方建筑后刷新光圈，占领给特殊奖励

---

## 验证计划

1. **重构后**：确保原有地图（图2）功能与重构前完全一致 — 选择、建造、战斗、胜利条件
2. **图2**：完整游玩一局 — 造兵→推家→胜利/失败
3. **图1**：3个据点依次推进，验证占领机制和AI防守
4. **图3**：3波防守，验证波次生成和AI进攻
5. **选关页面**：5个按钮正确跳转，Esc 返回
6. **图4/5**：完整游玩验证占领+波次+AI巡逻
7. **回归测试**：每张地图独立运行无报错，R键重启正常

---

## 文件清单总览

### 新建文件（约 15 个）
| 文件 | 说明 |
|------|------|
| `scripts/map_config.gd` | 地图配置资源类 |
| `scripts/victory_condition.gd` | 胜利条件基类 |
| `scripts/wave_manager.gd` | 波次管理器 |
| `scripts/capture_point.gd` | 占领点实体 |
| `scripts/victory_destroy_base.gd` | 图2 摧毁基地 |
| `scripts/victory_blitz.gd` | 图1 闪击据点 |
| `scripts/victory_survive_waves.gd` | 图3 生存波次 |
| `scripts/victory_expand_defense.gd` | 图4 扩张防守 |
| `scripts/victory_outpost_sequential.gd` | 图5 前哨推进 |
| `scenes/level_select.tscn` + `scripts/level_select.gd` | 选关页面 |
| `scenes/maps/map_1.tscn` ~ `map_5.tscn` | 5张地图场景 |
| `resources/map1_config.tres` ~ `map5_config.tres` | 5份地图配置 |

### 修改文件（约 3 个）
| 文件 | 说明 |
|------|------|
| `scripts/main.gd` | 重构为数据驱动的游戏控制器 |
| `scripts/enemy_ai.gd` | 新增 WAVE_ATTACK 状态 |
| `project.godot` | 主场景改为选关页面 |
