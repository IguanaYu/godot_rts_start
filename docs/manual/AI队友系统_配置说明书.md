# AI 队友系统 — 配置说明书

> 给关卡设计者：本文说明如何在单机关卡中配置 AI 控制的盟军（黄色队友）。
> 适用于场景：联合作战、救援触发、延迟增援、玩家 ping 指挥。

---

## 一、系统总览

AI 队友由 **owner_id = -2** 标识，自动归入 **alliance_id = 0**（玩家阵营），视觉上使用 **黄色**。一旦生成即自动接入玩家阵营的所有系统（unit_spatial_grid 收录、自动攻击、治疗识别、救援上报等），无需额外接线。

### 三种触发方式

| 方式 | 配置位置 | 触发时机 | 适用场景 |
|---|---|---|---|
| **A. 静态盟军** | `map_config.ai_allies` | 关卡开局 | 联合作战 — 玩家与 AI 队友共同推进 |
| **B. 延迟增援** | `capture_point.ally_reinforcement_*` | 玩家占领点后 N 秒 | 中后期援助 — 占领区域召唤援军冲锋 |
| **C. 玩家 ping 指挥** | 无需配置（自动） | 玩家按 Alt+左键/右键 | 玩家主动指挥 AI 队友 |

### 自动行为（所有 AI 队友共用，无需配置）

| 行为 | 触发 | 效果 |
|---|---|---|
| 跟随玩家 | 玩家主力推进 | 自动跟随玩家单位质心（FOLLOW_PLAYER 状态） |
| 自动索敌 | 视野内（280px）出现敌人 | 自动 attack_move 切入战斗 |
| 求救上报 | 受到伤害 | 屏幕文字 + 地图感叹号 + 小地图 ping |
| 求救清除 | 玩家进入求救点 300px 内 | 三种提示自动消失 |

---

## 二、核心概念（必读）

### 三层阵营解耦

| 层 | 字段 | AI 队友的值 | 含义 |
|---|---|---|---|
| **视觉层** | `faction_color` | `YELLOW (4)` | 显示黄色 |
| **控制权层** | `owner_id` | `-2` | 玩家无法框选/控制（combat_controller 拒绝跨 owner） |
| **敌我层** | `alliance_id` | `0` | 自动 team=PLAYER，被加入 `player_units` 组 |

> **重要**：所有节点系统（unit_spatial_grid、_find_closest_enemy_in_range、_alert_nearby_allies、救援上报、增援识别等）都是通过 **team=PLAYER** 自动工作的。配置时不需要手动设置 team。

### 玩家可用的指挥操作

| 操作 | 效果 |
|---|---|
| **Alt + 左键** | 所有 AI 队友强制 attack_move 到该点（红色"攻击此处！" + 红色十字标记） |
| **Alt + 右键** | 所有 AI 队友移动到该点后驻防（蓝色"防御此处！" + 蓝色十字标记） |

普通左键/右键对 AI 队友无影响（玩家无法框选）。

---

## 三、配置方式 A：静态盟军

### 字段位置

[scripts/map_config.gd](../../scripts/map_config.gd) 的 `ai_allies` 字段：

```gdscript
@export var ai_allies: Array[Dictionary] = []
```

### 数据格式（扁平，与 player_units 一致）

每个元素是一个 Dictionary：

```gdscript
{
    "type": int,        # 必填。单位类型：0=士兵, 1=弓兵, 2=枪兵, 3=僧侣
    "pos": Vector2      # 必填。初始位置（世界坐标）
}
```

### 完整示例

在 `.tres` 资源文件中（如 `resources/map1_config.tres`）：

```
[sub_resource type="Resource" id="map1_config"]
...
ai_allies = Array[Dictionary]([{
    "type": 0,
    "pos": Vector2(-100, 200)
}, {
    "type": 0,
    "pos": Vector2(-100, 230)
}, {
    "type": 1,
    "pos": Vector2(-130, 215)
}])
```

或在 Inspector 面板中编辑 MapConfig 资源，找到 `ai_allies` 数组，逐个添加 Dictionary 元素。

### 配置建议

| 关卡类型 | 推荐数量 | 配比 |
|---|---|---|
| 联合作战（玩家+AI vs 1 家敌军） | 5-8 个 | 士兵 60% + 弓兵 30% + 枪兵/僧侣 10% |
| 玩家救援触发 | 2-3 个（放远处） | 全士兵或带 1 个弓兵 |
| 大型会战 | 8-12 个 | 多样化，含 1-2 个僧侣 |

### 重要约束

- **单机模式独占**：`ai_allies` 在多人模式下被自动跳过（main.gd 检测 `RelayManager.is_online` 后跳过 `_spawn_ai_allies()`）。多人关卡配置了也无效。
- **位置避开障碍**：盟军生成位置应在导航网格内（地图 NavPoly 范围），否则会卡在生成点。
- **避免重叠玩家**：盟军生成位置距离玩家初始单位建议 ≥100px，避免开局视觉混乱。

---

## 四、配置方式 B：延迟增援

### 字段位置

[scripts/systems_game/capture_point.gd](../../scripts/systems_game/capture_point.gd) 的两个字段：

```gdscript
@export var ally_reinforcement_delay: float = 0.0       # 延迟秒数，0 = 无增援
@export var ally_reinforcement_groups: Array = []        # 波次配置
```

### 触发流程

```
玩家占领 capture_point (capture_progress ≥ 100%)
  ↓
main.gd._on_capture_point_captured() 触发
  ↓
显示屏幕文字 "增援即将到达！"（ALLY_REINFORCEMENT_INCOMING）
  ↓
启动 timer（ally_reinforcement_delay 秒）
  ↓
timer 结束 → game_spawner.spawn_ally_wave(groups, capture_point_pos, nearest_enemy_pos)
  ↓
在 capture_point 位置生成盟军单位
  ↓
盟军立即 attack_move 到最近的敌方单位/建筑（FORCE_ATTACK 状态）
```

### 数据格式

`ally_reinforcement_groups` 是一个 Array，每个元素是 Dictionary：

```gdscript
{
    "type": int,    # 必填。单位类型：0=士兵, 1=弓兵, 2=枪兵, 3=僧侣
    "count": int    # 必填。数量
}
```

### 完整示例（场景文件 .tscn）

```
[node name="CapturePoint1" type="Area2D" parent="."]
position = Vector2(600, 200)
script = ExtResource("capture_point")
can_enemy_capture = false
reward_gold = 200
reward_soldiers = 3
ally_reinforcement_delay = 15.0
ally_reinforcement_groups = Array[Dictionary]([{"type": 0, "count": 3}, {"type": 1, "count": 2}])
```

效果：玩家占领此点后 15 秒，在 (600, 200) 生成 3 个士兵 + 2 个弓兵，自动冲锋攻击最近敌人。

### 配置建议

| 关卡阶段 | 推荐延迟 | 推荐数量 |
|---|---|---|
| 第 1 个占领点 | 15-20s | 3-5 个 |
| 中期占领点 | 10-15s | 5-8 个 |
| 后期占领点（boss 前） | 5-10s | 8-12 个 |

> **关键经验**：不要把增援放在玩家会立即触发胜利的最后一个占领点上 — 玩家会看不到增援到达。把增援放在玩家还要继续推进的早期/中期占领点上。

### 关键约束

- **生成位置 = capture_point.global_position**：盟军会在占领点的位置生成。如果该点附近有敌方单位，盟军生成后会立即与敌人交战。
- **目标位置自动计算**：main.gd 的 `_find_nearest_enemy_pos()` 会找最近的敌方建筑/单位作为增援目标，无需手动配置。
- **多人模式跳过**：与静态盟军一样，`_on_capture_point_captured` 在多人模式下直接 return。

---

## 五、自动机制（无需配置）

### 救援触发

AI 队友受到攻击时**自动**触发，由 [scripts/units/unit.gd](../../scripts/units/unit.gd) 的 `take_damage()` 上报：

```gdscript
if owner_id == -2 and attacker != null:
    AllyDistressSignal.report(global_position, self)
```

### 救援 UI（三合一，自动显示）

| 提示类型 | 触发 | 持续 |
|---|---|---|
| 屏幕浮动文字 | 黄色"友军求救！" | ~3s 自动消失 |
| 地图感叹号 | 黄色"!"在求救位置闪烁 | 直到求救清除 |
| 小地图脉动圆点 | 黄色脉冲点 | 直到求救清除 |

### 区域去重

`AllyDistressSignal` autoload 内置：
- **AREA_CD = 10s**：同一位置 10 秒内只报一次（避免刷屏）
- **AREA_RADIUS = 200px**：判定"同一位置"的半径
- **RESCUE_RADIUS = 300px**：玩家进入此距离视为已救援

### 玩家 ping 指挥

无需配置。玩家按 Alt+左键/右键时，main.gd 拦截鼠标事件，调用 `AllyCommander` autoload 广播给所有 owner_id=-2 单位。

### 视觉反馈

ping 位置显示一个**扩散十字标记**（红色=攻击，蓝色=防御），1.2 秒自动淡出。

---

## 六、外部接口

### 在脚本中生成 AI 队友

```gdscript
# 单个静态盟军（初始预置）
spawner_module.spawn_ally_unit_initial(unit_type, position)

# 批量增援波次（占领点/事件触发）
spawner_module.spawn_ally_wave(groups, spawn_center, target_pos)
# 例：spawner_module.spawn_ally_wave([{"type":0,"count":3}], Vector2(600,200), Vector2(1500,200))
```

### 在脚本中下达指挥

```gdscript
# 所有 AI 队友 attack_move 到此点
AllyCommander.issue_attack_order(world_pos)

# 所有 AI 队友 move 到此点后驻防
AllyCommander.issue_defend_order(world_pos)
```

### 查询求救信号

```gdscript
# 获取当前所有活跃求救位置（供小地图/UI 使用）
var positions: Array = AllyDistressSignal.get_active_positions()
```

### 盟军 AI 状态（高级）

`ally_ai.gd` 的状态机：

| 状态 | 触发 | 行为 |
|---|---|---|
| `FOLLOW_PLAYER` | 默认；无外部触发 | 跟随玩家主力质心 |
| `ATTACK_TARGET` | 视野/受击发现敌人 | `unit.command_attack(target)` |
| `FORCE_ATTACK` | 玩家 ping 攻击点 / 增援波次 | 强制 `attack_move` 到 ping 位置 |
| `FORCE_DEFEND` | 玩家 ping 防御点 | `move` 到 ping 位置后驻防 |

---

## 七、设计建议

### 关卡设计模式

#### 模式 1：开局联合作战

```
玩家(5 个单位) + AI 队友(5 个单位，左侧 100px 外) vs 敌军
```
配置：`map_config.ai_allies` 添加 5 个单位，位置在玩家初始单位的左侧/上方。

#### 模式 2：救援关卡

```
玩家(强) vs 敌军
AI 队友(2 个，放在敌军深处) → 玩家推进到他们位置时，他们正在被攻击
```
配置：`ai_allies` 添加 2 个单位，位置在地图中央或敌军前线。救援 UI 自动触发。

#### 模式 3：分阶段援助

```
玩家 vs 敌军
占领点 1 → 15s 后召唤 3+2 增援
占领点 2 → 20s 后召唤 5+3 增援
占领点 3（终局）→ 无增援（避免胜利前触发）
```
配置：在前 1-2 个 capture_point 上配置 `ally_reinforcement_*`。

#### 模式 4：玩家主动指挥

```
玩家 → Alt+左键 → AI 队友冲锋
```
无需配置。AI 队友存在即可被指挥。

### 平衡性建议

- **AI 队友不消耗玩家金币/人口**：他们不是玩家资产，独立运作。
- **AI 队友不自己造兵**：纯战斗单位，靠预置 + 增援补充（设计决策）。
- **AI 队友死亡不掉玩家评分**：玩家损失单位计数（`_units_lost`）只统计 owner_id=1 的玩家单位。
- **AI 队友获得升级**：`spawn_ally_unit_initial` 会调用 `_upgrade_manager.apply_all_stat_upgrades_to_unit()`，玩家升级同样惠及盟军。

### 视觉/UX 提示

- **黄色一致性**：所有 AI 队友统一黄色，与多人模式的玩家2 颜色一致（视觉上玩家容易理解"友军"概念）。
- **求救显著**：三合一 UI 让玩家无法错过救援信号。
- **指挥反馈**：ping 时屏幕文字 + 十字标记 + 队友立即行动，反馈链路完整。

---

## 八、常见问题排查

### Q1：AI 队友没生成？
- **检查**：`map_config.ai_allies` 是否非空
- **检查**：是否在多人模式（`RelayManager.is_online = true` 会跳过）
- **检查**：场景是否预置了 PlayerUnits 子节点 — main.gd 会在预置/非预置两种分支都调用 `_spawn_ai_allies()`

### Q2：AI 队友卡住不动？
- **检查位置**：生成位置是否在 NavPoly 范围内（不在导航网格内会无法移动）
- **检查障碍**：生成位置是否被建筑/单位阻挡

### Q3：增援没出现？
- **检查 capture_point 配置**：`ally_reinforcement_delay > 0` 且 `ally_reinforcement_groups` 非空
- **检查胜利条件**：占领最后一个点立即触发胜利的话，玩家看不到增援 — 把增援移到早期占领点
- **检查多人模式**：多人模式下增援自动跳过

### Q4：ping 指挥没反应？
- **检查 AI 队友是否存在**：无 AI 队友时 main.gd 直接 return（避免无意义提示）
- **检查多人模式**：多人模式下 ping 指挥自动跳过

### Q5：玩家无法框选 AI 队友？
- **这是预期行为**：owner_id=-2 让 combat_controller 拒绝跨 owner 控制。玩家只能通过 ping 指挥。

### Q6：救援 UI 刷屏？
- **检查区域 CD**：默认 10 秒，可在 [ally_distress_signal.gd](../../scripts/systems_game/ally_distress_signal.gd) 调整 `AREA_CD` 和 `AREA_RADIUS`

---

## 九、关键文件

| 文件 | 作用 |
|---|---|
| [scripts/units/ally_ai.gd](../../scripts/units/ally_ai.gd) | AI 队友战术状态机（4 状态：FOLLOW_PLAYER / ATTACK_TARGET / FORCE_ATTACK / FORCE_DEFEND） |
| [scripts/systems_game/ally_commander.gd](../../scripts/systems_game/ally_commander.gd) | 战略层调度 + ping 指挥（autoload 单例） |
| [scripts/systems_game/ally_distress_signal.gd](../../scripts/systems_game/ally_distress_signal.gd) | 求救信号黑板（autoload 单例，区域 CD 去重） |
| [scripts/ui/ally_distress_marker.gd](../../scripts/ui/ally_distress_marker.gd) | 求救感叹号 UI（黄色"!"闪烁） |
| [scripts/systems_game/capture_point.gd](../../scripts/systems_game/capture_point.gd) | 占领点（含 ally_reinforcement_delay/groups 字段） |
| [scripts/systems/game_spawner.gd](../../scripts/systems/game_spawner.gd) | 单位生成（`spawn_ally_unit_initial` / `spawn_ally_wave`） |
| [scripts/map_config.gd](../../scripts/map_config.gd) | 地图配置（`ai_allies` 字段） |
| [scripts/main.gd](../../scripts/main.gd) | 主控制器（拦截 Alt+左键/右键、连接占领点信号、求救 UI） |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) | 单位基类（take_damage 上报 owner_id=-2 求救） |
| [scripts/ui/minimap_panel.gd](../../scripts/ui/minimap_panel.gd) | 小地图（脉动 ping 显示） |
| [project.godot](../../project.godot) | autoload 注册（`AllyCommander` / `AllyDistressSignal`） |

---

## 十、快速模板

### 模板 A：联合作战关卡

**map_config.tres**：
```
ai_allies = Array[Dictionary]([{"type":0,"pos":Vector2(-100,170)},{"type":0,"pos":Vector2(-100,200)},{"type":0,"pos":Vector2(-100,230)},{"type":1,"pos":Vector2(-130,185)},{"type":1,"pos":Vector2(-130,215)}])
```

### 模板 B：占领点带增援

**map_xxx.tscn**（CapturePoint 节点）：
```
[node name="CapturePoint1" type="Area2D" parent="."]
position = Vector2(600, 200)
script = ExtResource("capture_point")
can_enemy_capture = false
ally_reinforcement_delay = 15.0
ally_reinforcement_groups = Array[Dictionary]([{"type": 0, "count": 3}, {"type": 1, "count": 2}])
```

### 模板 C：救援关卡（敌人深处放弱小盟军）

**map_config.tres**：
```
ai_allies = Array[Dictionary]([{"type":0,"pos":Vector2(900,180)},{"type":1,"pos":Vector2(900,220)}])
```

放在敌军前线，玩家推进到他们时他们正在被攻击 → 救援 UI 自动触发。

---

## 附录：单位类型 ID 速查

| ID | 类型 | 说明 |
|---|---|---|
| 0 | 士兵 (SOLDIER) | 近战，肉盾 |
| 1 | 弓兵 (ARCHER) | 远程，输出 |
| 2 | 枪兵 (LANCER) | 近战，反骑 |
| 3 | 僧侣 (MONK) | 治疗，辅助 |
