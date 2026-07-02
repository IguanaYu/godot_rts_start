# mini/captain — 开发计划

> **对照**: [mini-captain-玩法设计.md](mini-captain-玩法设计.md) × 现有 RTS 代码库
> **目标**: Demo 第一阶段(技术跑通) → 第二阶段(玩法好玩)
> **分支**: `mini/captain`

---

## 1. 总体结论

现有 RTS 代码库**复用率极高**。核心系统(单位、AI、移动、战斗、据点、胜负、波次、三选一升级、被动技能、召唤物生成)几乎全部可直接复用或轻度改造。

**真正需要新建的只有 4 块**:
1. 单英雄控制层(替代 RTS 框选)
2. 人口系统(现有代码没有)
3. captain 专属升级池(改造现有升级数据)
4. 主动技能 Q+左键释放流程(参考现有指挥官技能)

---

## 2. 直接复用清单(不改代码)

| 系统 | 文件 | 说明 |
|---|---|---|
| 单位基类 | [scripts/units/unit.gd](scripts/units/unit.gd) | 移动(`move_to`)、攻击、状态机(GUARD/ATTACK/MOVE)、生命、伤害结算全有 |
| 导航移动 | NavigationAgent2D(unit.gd:130) | `move_to(target_pos)` 直接可用 |
| 空间网格 | [scripts/core/unit_spatial_grid.gd](scripts/core/unit_spatial_grid.gd) | `UnitGrid.query_neighbors(pos, radius)` 查最近敌人,O(k) |
| 生命组件 | [scripts/core/health_component.gd](scripts/core/health_component.gd) | `take_damage` + `died` 信号 |
| 召唤物生成 | [scripts/systems/game_spawner.gd](scripts/systems/game_spawner.gd) `spawn_summon()`(L454) | 运行时生成召唤兵的工厂方法 |
| 据点 | [scripts/systems_game/capture_point.gd](scripts/systems_game/capture_point.gd) | 占领圈 80px、警戒圈 200px,100% 可用 |
| 建筑系统 | [scripts/buildings/building.gd](scripts/buildings/building.gd) | 受伤/死亡/基地(CASTLE)判定 |
| 胜负条件 | [scripts/victory/](scripts/victory/) 全部 | `VictorySurviveWaves`(守基地N波)、`VictoryHoldPoint`(攻据点)、`VictoryDestroyBase`(推基地)等 |
| 波次管理 | scripts/systems_game/wave_manager.gd | 配合 `VictorySurviveWaves` |
| 难度系统 | [scripts/difficulty.gd](scripts/difficulty.gd) | EASY/NORMAL/HARD 三档,已集成在选关界面 |
| 目标面板 | [scripts/ui/objectives_panel.gd](scripts/ui/objectives_panel.gd) | 自动连接 VictoryCondition 显示目标 |
| 主循环 | [scripts/main.gd](scripts/main.gd) | `_check_victory()` 每帧自动调用,单机下网络自动降级 |
| 被动技能总线 | [scripts/commander/passive_skill_manager.gd](scripts/commander/passive_skill_manager.gd) | 事件驱动,注册 trigger 即可 |
| 技能运行时 | [scripts/skills/skill_component.gd](scripts/skills/skill_component.gd) | `activate()` + `skill_activated` 信号 + 优先级排序 + 冷却 |
| 技能数据 | [scripts/skills/skill_resource.gd](scripts/skills/skill_resource.gd) | TriggerCondition(PERIODIC_SCAN/PASSIVE)、TargetType 已有 |
| 选位置 UI | [scripts/commander_skill/target_preview.gd](scripts/commander_skill/target_preview.gd) | 鼠标跟随预览圈,Q+左键释放可直接用 |
| 落点反馈 | [scripts/commander_skill/area_indicator.gd](scripts/commander_skill/area_indicator.gd) | 技能生效位置视觉反馈 |
| 持续区域 | [scripts/commander_skill/persistent_zone.gd](scripts/commander_skill/persistent_zone.gd) | DOT/HOT 区域,可做光环 |
| 敌方 AI | [scripts/units/enemy_ai.gd](scripts/units/enemy_ai.gd) | PATROL/CHASE/ATTACK/WAVE_ATTACK 状态机 |
| 友军 AI | [scripts/units/ally_ai.gd](scripts/units/ally_ai.gd) | FOLLOW_PLAYER/ATTACK_TARGET,召唤兵可参考 |

---

## 3. 需要改造的清单

| 系统 | 文件 | 改造内容 |
|---|---|---|
| **三选一升级数据** | [scripts/upgrade/upgrade_data.gd](scripts/upgrade/upgrade_data.gd) | 替换 `CONFIGS` 为 captain 专属升级项(技能解锁/强化/人口/被动等);新增 `EffectType.SKILL_UNLOCK`、`SKILL_UPGRADE` |
| **三选一升级管理** | [scripts/upgrade/upgrade_manager.gd](scripts/upgrade/upgrade_manager.gd) | `_execute_effect()` 加 SKILL_UNLOCK/SKILL_UPGRADE 分支;token 系统改为金币触发(击杀够多金币→升级) |
| **技能数据** | [scripts/skills/skill_resource.gd](scripts/skills/skill_resource.gd) | `TargetType` 新增 `TARGET_POINT`(手动选位置施法);新增 `upgrade_level` 字段支持叠加 |
| **主循环输入** | [scripts/main.gd](scripts/main.gd) L1080-1113 | mini/captain 模式下:左键=英雄移动(非框选)、右键=攻击移动/技能、Q+左键=手动技能、A 键取消 |
| **召唤逻辑** | [scripts/units/unit.gd](scripts/units/unit.gd) `_try_summon_minion()` L1522 | 提取为独立模块,加人口检查、CD、生命周期管理 |

---

## 4. 需要新建的清单

### 4.1 核心新模块(目录:`scripts/mini_captain/`)

| 文件 | 职责 |
|---|---|
| `hero_controller.gd` | **单英雄控制层**。替代 RTS 框选,管理当前英雄单位,左键点击→`hero.move_to()`,右键→攻击移动,Q+左键→手动技能 |
| `population_manager.gd` | **人口系统**。初始 8,满人口禁召,三选一可提升;查询当前人口、注册召唤兵死亡回调 |
| `summon_lifecycle.gd` | **召唤兵生命周期**。持续时间倒计时、到时死亡、受击死亡、人口释放;封装现有 `spawn_summon()` |
| `captain_upgrade_data.gd` | **captain 专属升级池定义**。约 10-15 个升级项,分稀有度,可叠加 |
| `captain_skill_slot.gd` | **技能槽位管理**。6 槽,逐次三选一填入;最多 1 槽可手动;手动槽可切自动/手动 |
| `active_skill_manager.gd` | **主动技能释放流程**。参考 `commander_skill_manager.gd` 的 `start_cast→confirm_cast`,支持 Q+左键选位置 |
| `hero_death_check.gd` | **队长死亡=失败**。继承 VictoryCondition,监听英雄 `died` 信号 |

### 4.2 UI 新建(目录:`scripts/mini_captain/ui/`)

| 文件 | 职责 |
|---|---|
| `skill_bar.gd` | **6 槽技能栏**。显示已获技能图标、冷却、手动槽标记;点击手动槽切换自动/手动 |
| `population_indicator.gd` | **人口显示**。当前/上限,满人口变红 |

### 4.3 场景与配置

| 文件 | 职责 |
|---|---|
| `scenes/maps/mini_captain_demo.tscn` | **demo 关卡场景**。复制 `test_protect_building.tscn` 或 `test_survive_timer.tscn` 改造 |
| `resources/mini_captain_demo_config.tres` | **demo 地图配置**。map_bounds、nav_bounds、initial_gold、difficulty_presets |
| `scenes/mini_captain/hero.tscn` | **英雄场景**。基于现有单位场景,挂 HeroController |
| `resources/captain_upgrades/*.tres` | **升级项资源**。每个三选一选项一个 Resource |

### 4.4 选关联动

| 文件 | 改动 |
|---|---|
| [scripts/ui/level_select.gd](scripts/ui/level_select.gd) | `test_levels` 数组(L176)加 mini_captain_demo 条目 |

---

## 5. Demo 第一阶段:技术跑通

**目标**:验证核心机制能跑起来,不追求好玩。

### 任务列表

| # | 任务 | 依赖 | 复用/新建 |
|---|---|---|---|
| 1.1 | 创建 `scripts/mini_captain/` 目录结构 | - | 新建 |
| 1.2 | 新建 `hero_controller.gd`:左键点击→`hero.move_to()`,英雄自动 GUARD 索敌攻击 | unit.gd `move_to` | 新建 |
| 1.3 | 改 `main.gd` 输入:mini/captain 模式下左键调 `hero_controller.move_to()` 而非 `combat_controller.start_selection()` | hero_controller | 改造 |
| 1.4 | 新建 `hero.tscn`:基于现有单位,设为 player 方,挂 HeroController | hero_controller | 新建 |
| 1.5 | 新建 `population_manager.gd`:初始 8,`can_summon()`/`add()`/`remove()` | - | 新建 |
| 1.6 | 新建 `summon_lifecycle.gd`:封装 `spawn_summon()`,加持续时间+死亡回调+人口释放 | game_spawner.spawn_summon | 新建 |
| 1.7 | 做一个最简召唤技能(测试用):CD 5秒,召唤 1 个近战兵,持续 10 秒 | summon_lifecycle | 新建 |
| 1.8 | 新建 `mini_captain_demo.tscn`:小地图、玩家城堡、英雄出生点、几个杂兵敌人 | 复制 test_* 场景 | 新建 |
| 1.9 | 新建 `mini_captain_demo_config.tres`:地图配置 | 复制现有 .tres | 新建 |
| 1.10 | 在 `level_select.gd` 加选关条目 | level_select | 改造 |
| 1.11 | 跑起来验证:点击移动、自动攻击、召唤兵生成+到期死亡、人口限制生效 | 全部 | 测试 |

### 第一阶段交付物
- 能从选关界面进入 mini_captain_demo 关卡
- 鼠标点击移动英雄
- 英雄自动攻击附近敌人
- 按键召唤一个小兵,小兵自动攻击、到期死亡
- 人口满时无法召唤

---

## 6. Demo 第二阶段:玩法好玩

**目标**:验证 survivors-like 割草 + 召唤组合 + 三选一成长的爽感。

### 任务列表

| # | 任务 | 依赖 | 复用/新建 |
|---|---|---|---|
| 2.1 | 新建 `captain_upgrade_data.gd`:定义 10-15 个升级项(新召唤技能/强化/人口/被动/经济) | upgrade_data 模式 | 新建 |
| 2.2 | 改 `upgrade_manager.gd`:支持 SKILL_UNLOCK/SKILL_UPGRADE 效果类型;金币触发升级(而非 token) | upgrade_manager | 改造 |
| 2.3 | 复用 `upgrade_panel.gd` 三选一 UI:接入 captain 升级池 | upgrade_panel | 复用 |
| 2.4 | 新建 `captain_skill_slot.gd`:6 槽管理,逐次三选一填入,最多 1 手动槽 | - | 新建 |
| 2.5 | 新建 `skill_bar.gd`:6 槽技能栏 UI,显示图标/冷却/手动标记 | - | 新建 |
| 2.6 | 实现 2-3 个召唤兵技能:阵地召唤(3法师)、天降召唤(5火焰兵)、瞬发伴随(小骷髅式) | summon_lifecycle | 新建 |
| 2.7 | 实现 1-2 个被动触发技能:每5秒三连射击命中召唤1小兵 | skill_component + passive_skill_manager | 复用+新建 |
| 2.8 | 新建 `active_skill_manager.gd`:Q+左键释放流程,参考 commander_skill_manager | target_preview | 新建 |
| 2.9 | 实现队长主动技能:基础"大范围狂暴"+技能"指定点召唤法师群"组合 | active_skill_manager | 新建 |
| 2.10 | 改 `skill_resource.gd`:加 TARGET_POINT TargetType、upgrade_level 字段 | skill_resource | 改造 |
| 2.11 | 新建 `hero_death_check.gd`:队长死亡=失败,继承 VictoryCondition | VictoryCondition 基类 | 新建 |
| 2.12 | 配置 demo 关卡:VictorySurviveWaves(守 5 波)+ WaveManager + 杂兵波次 + 1 种精英 | 复用 | 配置 |
| 2.13 | 新建 `population_indicator.gd`:人口显示 UI | population_manager | 新建 |
| 2.14 | 跑起来验证:5-10 分钟单局、三选一成长爽感、召唤爆兵手感、精英威胁、胜负完整 | 全部 | 测试 |

### 第二阶段交付物
- 5-10 分钟完整单局
- 击杀→金币→三选一升级循环
- 6 槽技能逐渐填满,自动释放
- Q+左键手动释放狂暴+召唤组合
- 杂兵割草 + 精英威胁
- 守基地 5 波 或 攻下 1 据点 的完整胜负

---

## 7. 不在 Demo 范围(后续扩展)

- 多指挥官系统(不同基础效果/专属技能)
- V 键指挥召唤兵
- 大增幅节点(事件驱动 vs 周期驱动)
- 多关卡
- 多难度调优
- Boss
- UI/HUD 精美化
- 网络联机(单机 demo 不需要)

---

## 8. 关键复用路径速查

| 需求 | 看哪个文件 |
|---|---|
| 鼠标点击移动单位 | [unit.gd:1288](scripts/units/unit.gd#L1288) `move_to()` |
| 自动攻击最近敌人 | [unit.gd:742](scripts/units/unit.gd#L742) `_find_closest_enemy_in_range()` + GUARD 状态 L790 |
| 运行时生成召唤兵 | [game_spawner.gd:454](scripts/systems/game_spawner.gd#L454) `spawn_summon()` |
| 查询附近单位 | [unit_spatial_grid.gd:44](scripts/core/unit_spatial_grid.gd#L44) `query_neighbors()` |
| 三选一抽卡逻辑 | [upgrade_manager.gd:52](scripts/upgrade/upgrade_manager.gd#L52) `get_random_choices()` |
| 三选一 UI | [upgrade_panel.gd:149](scripts/upgrade/upgrade_panel.gd#L149) `show_selection()` |
| 选位置释放预览 | [target_preview.gd](scripts/commander_skill/target_preview.gd) |
| 释放流程三阶段 | [commander_skill_manager.gd:55](scripts/commander_skill/commander_skill_manager.gd#L55) `start_cast→confirm_cast` |
| 被动技能事件总线 | [passive_skill_manager.gd:45](scripts/commander/passive_skill_manager.gd#L45) `register()` |
| 守基地 N 波胜负 | [victory_survive_waves.gd](scripts/victory/victory_survive_waves.gd) |
| 攻据点胜负 | [victory_hold_point.gd](scripts/victory/victory_hold_point.gd) + [capture_point.gd](scripts/systems_game/capture_point.gd) |
| 单位死亡信号 | [unit.gd:166](scripts/units/unit.gd#L166) `died(unit)` 信号 |
| 建筑死亡信号 | [building.gd:90](scripts/buildings/building.gd#L90) `died(building)` 信号 |
| 现有召唤效果 | [summon_effect.gd](scripts/skills/skill_effects/summon_effect.gd) + [unit.gd:1522](scripts/units/unit.gd#L1522) `_try_summon_minion()` |
