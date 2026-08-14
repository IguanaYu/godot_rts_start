# T1 PR-4 实施计划

## Context

T1 阶段进入 SH1 据点占领机制——核心战略决策点。PR-1/2/3 完成后，玩家已能在 T1 测试关卡跑通"经济运营 → 防骚扰"循环，但**当前测试地图完全没有 SH1**（PR-3 实施时跳过了据点基础设施）。

PR-4 的目标：① 补完 SH1 基础设施 ② 把 SH1 从"纯战斗目标"升级为"战略决策点"——玩家推下来后能选 1 个特殊建筑作为长期收益。所有玩法决策已在 [T1_实施计划.md](T1_实施计划.md) §5.PR-4 敲定（Q4-1~Q4-10），本计划是它的可执行展开。

**当前 OutpostCommander 状态**（调研发现）：
- 文件：[outpost_commander.gd](scripts/outpost/outpost_commander.gd)
- **敌方专属**：`alliance_id = 1` 固定，无 owner_team / captured 概念
- **领土判定**：`contains_entity()`（[行 695](scripts/outpost/outpost_commander.gd#L695)）距离检测，每帧扫描
- **失败条件**：[行 145-148](scripts/outpost/outpost_commander.gd#L145-L148) 圈内无敌方建筑 → `_despawn()` 自杀
- **无信号**：OutpostCommander 自身没有 signal，但有 `commander_ids` 标签系统（OutpostCommanderManager 维护）
- **可复用**：领土范围检测逻辑（contains_entity）+ 配置字段（territory_radius / aggression 等）

**主要工作**：
0. 补完 SH1 基础设施到测试地图（守军 + 箭塔 + OutpostCommander 节点）
1. 给 OutpostCommander 加 `outpost_captured` 信号 + 占领检测
2. 独立管理"光圈状态机"（不污染 OutpostCommander 敌方逻辑）
3. 新建 ALTAR_ARCHER 建筑类型 + 高级弓箭手单位
4. 扩展 building_placer 支持多源可建区（主基地圆 OR 据点光圈）
5. 新建分裂攻击逻辑

**主要偏离**：
1. OutpostCommander **不改归属**（保持敌方专属），用独立的 `outpost_capture_state.gd` 管理"已占领"状态
2. PR-1 的 `is_in_buildable_area` 当前只看主基地圆，PR-4 需要扩展为多源（含 place_mode 参数）
3. unit.gd 已有 cone_attack / chain_attack 多目标分支，**split_attack 走相同模式**

---

## 0. 实施前已敲定的 4 项调整（用户决策）

| # | 项 | 决策 |
|---|---|---|
| 调整 1 | SH1 基础设施补完 | 照路线图 §3.5 加：1 箭塔 grid(14,7) + 3 步 (720,470/720,530/780,500) + 1 弓 (750,460) + OutpostCommander 节点 |
| 调整 2 | 骚扰路径穿 SH1 | 不动。敌人同阵营 alliance_id=1，ATTACK_MOVE 的 _is_valid_enemy 过滤同阵营，路径穿 SH1 不会自相残杀 |
| 调整 3 | Wave 3 (5:30) timing | 保留 5:30，PR-4 出来实测后如果难度过高再调 |
| 调整 4 | split 优先级 | `if stats_data.split_count > 1: _do_split_attack; elif cone; elif chain; else 单目标` |

---

## 一、决策汇总（已敲定，引自主计划 §5.PR-4）

| # | 项 | 决策 | 来源 |
|---|---|---|---|
| Q4-1 | 占领机制 | 两阶段：① 据点清空检测 → ② 光圈出现 | 已敲定 |
| Q4-2 | 光圈视觉 | 复用 building_placer 的绿色 Line2D 圆环 | 已敲定 |
| Q4-3 | 据点建筑栏 UI | (a) 建造栏顶部新增"据点"分类按钮 | 已敲定 |
| Q4-4 | 分裂攻击 | unit_stats.gd 加 split_count=3 / split_range 字段 | 已敲定 |
| Q4-5 | 祭坛建筑 | 独立 BuildingType.ALTAR_ARCHER 枚举 | 已敲定 |
| Q4-6 | 光圈 vs 可建区 | 两阶段（光圈→特殊建筑→拓展可建区）| 已敲定 |
| Q4-7 | 祭坛产能 | 复用 PR-1 的 `completion_refund_unit` | 已敲定 |
| Q4-8 | 光圈消失条件 | 信号驱动（building_died 触发检查）| 已敲定 |
| Q4-9 | 候选锁定 | OutpostCommander 内存（不持久化）| 已敲定 |
| Q4-10 | A/B/D 占位 | 完全不显示，T1 UI 只有候选 C | 已敲定 |

### 推演决策（实施时按此走，不再问用户）

| # | 项 | 决策 | 理由 |
|---|---|---|---|
| D1 | 光圈状态机独立 | 新建 `outpost_capture_state.gd`（不修改 OutpostCommander 的 alliance_id）| 避免破坏敌方 AI 逻辑 |
| D2 | 占领检测挂载点 | outpost_commander.gd 的 `_on_decision_tick()`（[行 140](scripts/outpost/outpost_commander.gd#L140)）失败检测**前**插入 | 复用现有 buildings/units 扫描结果，零额外性能 |
| D3 | 范围内敌方清空判定 | 复用 `_get_managed_buildings()` + `_get_managed_units()` 返回的数组判空 | 已有方法，不重写 |
| D4 | 光圈节点 | `scenes/effects/outpost_capture_ring.tscn`，根节点 Node2D + `_draw` Line2D 圆环 | 与 building_placer 的 BUILD_RADIUS overlay 同模式 |
| D5 | 高级弓箭手场景 | 复用 archer.tscn，仅 stats 不同（不新建场景）| 最小改动，sprite_scale 通过 stats × variant 三重乘积生效 |
| D6 | ALTAR_ARCHER 产能路径 | 复用 PR-1 的 `_on_building_construction_finished` hook（completion_refund_unit）| 零代码，仅 stats 配置 |
| D7 | 据点建筑栏 toggle | 占领信号触发 → game_ui `_refresh_outpost_category(true)`；失败触发 → `_refresh_outpost_category(false)` | 信号驱动，UI 自动响应 |
| D8 | split 目标选择 | 新增 `_find_n_closest_enemies_in_range(count, range)`，复用 `_find_closest_enemy_in_range` 模式 | 一致风格 |
| D9 | 候选 C 锁定后 UI | 造完祭坛 → 卡片消失 + 分类按钮变灰（"已选 C"）| 视觉反馈"已 commit" |
| D10 | 据点归属归属检测频率 | 信号驱动（建造完成 / 建筑被毁时检查），不轮询 | 性能优于每帧扫描 |

---

## 二、改动文件清单

### 代码层（8 个）

| # | 文件 | 改动要点 |
|---|---|---|
| 1 | [outpost_commander.gd](scripts/outpost/outpost_commander.gd) | 新增 `signal outpost_captured(team)`；`_on_decision_tick()`（[行 140](scripts/outpost/outpost_commander.gd#L140)）失败检测**前**插入占领检测：圈内 buildings.size()==0 && units.size()==0 → emit outpost_captured(0)；新增 `var _captured: bool = false` 防重复 emit |
| 2 | [building.gd](scripts/buildings/building.gd) | enum BuildingType 加 `ALTAR_ARCHER`（值 = 7，接 FARM=6 后）；`_setup_stats()` 加 ALTAR_ARCHER case（grid_size=Vector2i(2,2)，max_hp=200）|
| 3 | [game_data.gd](scripts/systems/game_data.gd) | enum PlaceMode 加 `ALTAR_ARCHER`（值 = 39，接 FARM=38 后）；COSTS 加 `PlaceMode.ALTAR_ARCHER: 350`；MODE_NAMES 加 `PlaceMode.ALTAR_ARCHER: "ENTITY_ALTAR_ARCHER"`；BUILDING_SCENES 加 `BuildingType.ALTAR_ARCHER: "res://scenes/buildings/altar_archer.tscn"`；ALL_ITEMS 暂不加（仅据点分类可见）|
| 4 | [unit.gd](scripts/units/unit.gd) | `_perform_attack()`（[行 1001-1014](scripts/units/unit.gd#L1001-L1014)）投射物分支前加 split 检查：`if stats_data.split_count > 1: _do_split_attack(damage); return`；新增 `_do_split_attack(damage)`：找 N 个最近敌人 + 对每个 `_spawn_arrow(target, damage)`；新增 `_find_n_closest_enemies_in_range(count, range)` 工具函数 |
| 5 | [unit_stats.gd](scripts/stats/unit_stats.gd) | 加 `@export var split_count: int = 1` + `@export var split_range: float = 120.0` |
| 6 | [building_placer.gd](scripts/systems/building_placer.gd) | `is_in_buildable_area(pos, place_mode)` 扩展为多源：① 主基地圆（PR-1）OR ② 已激活据点光圈（造了特殊建筑）OR ③ 占领中据点光圈（仅 ALTAR_ARCHER 可造）；新增 `_captured_outpost_rings: Array` + `_activated_outpost_rings: Array` 状态。**调用点同步改签名**：[行 139 check_build_block](scripts/systems/building_placer.gd#L139) + [行 247 update_preview](scripts/systems/building_placer.gd#L247) |
| 7 | [main.gd](scripts/main.gd) | `_setup_outpost_commanders()` 后 connect `outpost_captured` → 调 `_on_outpost_captured(team, commander_pos, commander_radius)`：实例化 outpost_capture_ring + 通知 building_placer 加 ring + 通知 game_ui 显示据点分类 |
| 8 | [game_ui.gd](scripts/systems/game_ui.gd) | 建造栏顶部加"据点"分类按钮（占领前隐藏）；新增 `_refresh_outpost_category(visible: bool)`；候选 C 卡片（350 金，"生成 1 个高级弓箭手（分裂攻击）"）；点击卡片 → `place_mode_requested.emit(PlaceMode.ALTAR_ARCHER)` |

### 资源层（4 个新建）

| # | 文件 | 内容 |
|---|---|---|
| 9 | `resources/stats/buildings/altar_archer_stats.tres` | id=&"altar_archer"; building_type=7; max_hp=200; build_time=5.0; grid_size=Vector2i(2,2); cost_override=350; completion_refund_unit=&"elite_archer"; completion_refund_unit_count=1 |
| 10 | `scenes/buildings/altar_archer.tscn` | 复制 barracks.tscn 改：building_type=ALTAR_ARCHER，stats=altar_archer_stats.tres；贴图用 monastery 或 archery_range（待选）|
| 11 | `resources/stats/units/elite_archer_stats.tres` | 复制 archer_stats.tres 改：id=&"elite_archer"; max_hp=150; attack_damage=18; attack_range=60; split_count=3; split_range=120; sprite_scale=1.3 |
| 12 | `scenes/effects/outpost_capture_ring.tscn` **(新建)** | 根节点 OutpostCaptureRing（Node2D + _draw Line2D 圆环）；半径默认 200；颜色绿色（复用 building_placer 的 `Color(0, 1, 0, 0.6)`）；可挂 AnimationPlayer 做呼吸效果（可选）|

### 场景层（2 个修改）

| # | 文件 | 改动 |
|---|---|---|
| 13 | [map_t1_economy_test.tscn](scenes/maps/map_t1_economy_test.tscn) | SH1 区域加 OutpostCommander 节点（alliance_id=1, territory_radius=200, aggression=0.4, defensiveness=0.7, enabled_spells=[], enabled_strategies=[]）|
| 13a | [map_t1_economy_test_config.tres](resources/map_t1_economy_test_config.tres) | **补 SH1 守军 + 箭塔**（路线图 §3.5）：箭塔 grid(14,7) + 3 步 (720,470/720,530/780,500) + 1 弓 (750,460)。保留现有 (1100,500) 4 个守军作为敌方城堡守卫 |

### 文案层（1 个）

| # | 文件 | 改动 |
|---|---|---|
| 14 | [translations.csv](locales/translations.csv) | 加 `ENTITY_ALTAR_ARCHER,高级弓箭手祭坛,Archer Altar,アーチャー祭壇` + `OUTPOST_CATEGORY,据点,Outpost,前哨` + `ALTAR_EFFECT_DESC,建造完成生成 1 个高级弓箭手（分裂攻击 3 目标）,...` |

---

## 三、关键实现要点

### A. 占领检测（outpost_commander.gd 扩展）

```gdscript
# 在 _on_decision_tick() 失败检测前插入（约行 145 之前）
# 复用现有扫描结果
var buildings_in_territory = buildings  # _get_managed_buildings() 已返回
var units_in_territory = units           # _get_managed_units() 已返回

if buildings_in_territory.is_empty() and units_in_territory.is_empty():
    if not _captured:
        _captured = true
        outpost_captured.emit(0)  # 0 = 玩家阵营
        print("[OutpostCommander:%s] 据点被玩家占领！" % _uid_str())
    # 不 _despawn()，保留节点用于后续"光圈消失"判定
    return
```

⚠️ **不改 `_despawn()` 行为**：当前圈内无敌方建筑时仍会 `_despawn()`，PR-4 需要保留节点。**实施时要把失败检测的 `_despawn()` 改成"标记废弃"但不删节点**。

### B. 分裂攻击（unit.gd 扩展）

```gdscript
# _perform_attack() 攻击模式分发：split > cone > chain > 单目标
func _perform_attack():
    # ... 现有准备逻辑
    # 调整 4：split 最优先（PR-4 决策）
    if stats_data.split_count > 1:
        _do_split_attack(damage)
        return
    if cone_attack_enabled:        # 原 1010
        _do_cone_attack(damage)
    elif chain_attack_enabled:     # 原 1014
        _do_chain_attack(damage)
    else:                          # 原 1017
        _spawn_arrow(attack_target, damage)

func _do_split_attack(damage: float) -> void:
    var targets := _find_n_closest_enemies_in_range(
        stats_data.split_count, stats_data.split_range)
    if targets.is_empty():
        # fallback：单目标
        if attack_target and is_instance_valid(attack_target):
            _spawn_arrow(attack_target, damage)
        return
    for target in targets:
        _spawn_arrow(target, damage)

func _find_n_closest_enemies_in_range(count: int, range: float) -> Array:
    var enemies := []
    # 复用 _find_closest_enemy_in_range 的扫描逻辑
    for body in $AttackRange.get_overlapping_bodies():
        if not _is_valid_enemy(body): continue
        enemies.append(body)
    # 按距离排序，取前 count 个
    enemies.sort_custom(func(a, b):
        return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
    return enemies.slice(0, count)
```

### C. 光圈两阶段可建区（building_placer.gd 扩展）

```gdscript
# 多源可建区判定
func is_in_buildable_area(pos: Vector2, place_mode: int) -> bool:
    # 源 1：主基地圆（PR-1 已有）
    if _is_in_main_castle_range(pos):
        return true
    # 源 2：已激活据点光圈（造了特殊建筑 → 拓展区）
    for ring in _activated_outpost_rings:
        if pos.distance_to(ring.position) <= ring.radius:
            return true
    # 源 3：占领中据点光圈（仅 ALTAR_ARCHER 可造）
    for ring in _captured_outpost_rings:
        if pos.distance_to(ring.position) <= ring.radius:
            return place_mode == D.PlaceMode.ALTAR_ARCHER
    return false

# main.gd 监听建造完成 → 升级 ring 状态
func _on_building_construction_finished(building):
    # ... PR-1 的反还逻辑
    if building.building_type == D.BuildingType.ALTAR_ARCHER:
        _promote_captured_ring_to_activated(building.position)

func _promote_captured_ring_to_activated(pos: Vector2):
    # 找到 pos 落入的 _captured_outpost_rings，移到 _activated_outpost_rings
    for i in range(_captured_outpost_rings.size()):
        var ring = _captured_outpost_rings[i]
        if pos.distance_to(ring.position) <= ring.radius:
            _captured_outpost_rings.remove_at(i)
            _activated_outpost_rings.append(ring)
            break
```

### D. 祭坛产能（零代码，仅 stats 配置）

PR-1 的 `_on_building_construction_finished` 已经支持 `completion_refund_unit`。祭坛 stats 配置：

```ini
# altar_archer_stats.tres
completion_refund_unit = &"elite_archer"
completion_refund_unit_count = 1
```

PR-1 的 hook 自动 spawn 1 个 elite_archer 在祭坛门口。**PR-4 不用写新代码**。

### E. 光圈视觉（outpost_capture_ring.gd 新建）

```gdscript
extends Node2D
## T1 PR-4: 据点占领光圈（绿色 Line2D 圆环）
## 复用 building_placer 的 BUILD_RADIUS overlay 风格

var radius: float = 200.0
var ring_color: Color = Color(0, 1, 0, 0.6)

func _draw():
    var points := 64
    var prev := Vector2.ZERO
    for i in range(points + 1):
        var angle = i * TAU / points
        var next := Vector2(cos(angle), sin(angle)) * radius
        if i > 0:
            draw_line(prev, next, ring_color, 2.0)
        prev = next
    # 中心半透明填充（可选）
    draw_circle(Vector2.ZERO, radius * 0.95, Color(0, 1, 0, 0.05))
```

---

## 四、验收清单

### 占领机制
- [ ] SH1 守军（3 步 + 1 弓 + 1 塔）全灭后，绿色光圈在 (750, 500) 出现
- [ ] 光圈半径 = 据点领土范围（200 px）
- [ ] 光圈出现**无弹窗、无暂停**
- [ ] 控制台打印 "[OutpostCommander:xxx] 据点被玩家占领！"

### 据点建筑栏
- [ ] 占领前：建造栏顶部无"据点"分类
- [ ] 占领后：建造栏顶部出现"据点"分类按钮
- [ ] 点击"据点"分类 → 显示候选 C 卡片（A/B/D 不显示）
- [ ] 候选 C 卡片显示：名称 + 图标 + 效果"生成 1 个高级弓箭手（分裂攻击）" + 造价 350

### 两阶段可建区
- [ ] 光圈外尝试造祭坛 → 预览变红 + floating_text 提示
- [ ] 光圈内造祭坛 → 扣 350 金，开始建造
- [ ] 光圈内造农场/兵营 → 阻止（光圈仅 ALTAR_ARCHER 可造）
- [ ] 祭坛完成 → 生成 1 个高级弓箭手
- [ ] **此时光圈区域变成永久可建区**（可造农场/兵营等普通建筑）
- [ ] 拓展区造的建筑被打掉，但祭坛还活着 → 拓展区保留
- [ ] 祭坛被打掉 → 已产出的高级弓箭手保留
- [ ] 据点范围内己方建筑全灭 → 光圈永久消失

### 分裂攻击
- [ ] 高级弓箭手攻击时同时射 3 支箭
- [ ] 3 支箭命中 3 个不同目标（如果范围内敌人 ≥ 3）
- [ ] 范围内敌人 < 3 时，命中现有敌人（不浪费箭）
- [ ] 范围内无敌人 → fallback 单目标攻击

### 候选锁定
- [ ] 造完祭坛 → 据点分类按钮变灰（"已选 C"）
- [ ] 重启游戏 → 据点状态重置（不持久化，D9 决策）

---

## 五、已知风险与边界

| # | 风险 | 应对 |
|---|---|---|
| 1 | OutpostCommander 失败检测会 `_despawn()` | 实施时改为"标记废弃"但不删节点，保留用于光圈消失判定 |
| 2 | 多源可建区可能产生边界重叠（主基地圆 + 据点光圈相交）| 第一源命中即返回，不冲突 |
| 3 | 分裂攻击的 target 选择可能击中"路过的中立单位" | `_is_valid_enemy` 严格过滤阵营 |
| 4 | ALTAR_ARCHER 完成反还单位时，可能找不到 elite_archer stats 资源 | 必须先创建 `elite_archer_stats.tres`，否则 ResourceLoader 静默失败 |
| 5 | 据点光圈永久消失后，已激活的拓展区状态 | 设计上应同步消失（光圈消失 = 范围内己方建筑全灭 = 拓展区也空了）|

---

## 六、关联文档

- 主计划：[T1_实施计划.md](T1_实施计划.md) §5.PR-4 / §7.3
- 设计方案：[T1经济底层改造方案.md](T1经济底层改造方案.md) 第十章
- 设计纪要：[2026-07-28_玩法推进纪要.md](../sessions/2026-07-28_玩法推进纪要.md)
- PR-3 实施计划：[T1_PR3_实施计划.md](T1_PR3_实施计划.md)（据点与骚扰独立，可并行）

---

## 七、实施顺序建议

0. **Step 0 SH1 基础设施补完**（用户调整 1）：在 .tres 加 SH1 守军 + 箭塔；在 .tscn 加 OutpostCommander 节点。**先验证：进入 T1 测试关卡，SH1 中心有守军，骚扰路径穿过不交战**
1. **Step 1 数据层**：unit_stats.gd 加 split_count/split_range + building.gd ALTAR_ARCHER 枚举 + game_data.gd PlaceMode/COSTS 等
2. **Step 2 资源层**：新建 altar_archer_stats.tres / elite_archer_stats.tres / altar_archer.tscn
3. **Step 3 占领检测**：outpost_commander.gd 加 outpost_captured 信号 + 检测逻辑
4. **Step 4 光圈视觉**：outpost_capture_ring.tscn + main.gd 信号连接
5. **Step 5 多源可建区**：building_placer.gd 扩展 + 调用点改签名 + main.gd ring 状态管理
6. **Step 6 据点建筑栏 UI**：game_ui.gd 据点分类按钮 + 候选 C 卡片
7. **Step 7 分裂攻击**：unit.gd _do_split_attack + _find_n_closest_enemies_in_range（split 优先级最高）
8. **Step 8 验证**：按第四节验收清单逐项测；**额外测 Wave 3 (5:30) 跟 SH1 推进 timing 是否合理，不合理再调**

预计工时：6-8 小时。
