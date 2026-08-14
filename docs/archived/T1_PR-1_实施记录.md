# T1 PR-1 实施记录与后续影响

- **日期**：2026-07-31
- **范围**：T1 经济底层 PR-1（阶段 0 + 阶段 1 + 阶段 2.1/2.2 提前）
- **关联**：
  - 实施计划：[T1实施计划.md](T1实施计划.md)
  - 路线图：[T1实施路线图.md](T1实施路线图.md)
  - 改造方案：[T1经济底层改造方案.md](T1经济底层改造方案.md)

本文档记录 PR-1 实施过程中**偏离原计划**或**可能影响后续 PR-2~5** 的调整。后续 PR 实施前必读。

---

## 一、调整清单（10 项）

### 1. BuildingStats 变体 vs 基础版本 -- 加字段时变体也要改

**背景**：test_all 指挥官的 `building_variants[3] = [&"barracks_standard", &"barracks_light", &"barracks_fortified"]`。实际加载的是变体 .tres（如 `barracks_standard_stats.tres`），不是基础版 `barracks_stats.tres`。

**PR-1 踩坑**：反还字段（`completion_refund_unit` / `completion_refund_unit_count`）只加了基础版 `barracks_stats.tres`，3 个变体漏改，导致反还 soldier 不生效。后补改 3 个变体 .tres 才修复。

**后续影响**：
- PR-2~5 如果给建筑加新字段（如队列上限、据点解锁条件），**变体 .tres 也要改**。
- 变体文件清单：`barracks_standard/light/fortified_stats.tres`、`archery_standard/longbow_hall_stats.tres`、`monastery_standard/grand_stats.tres`、`tower_standard/heavy_stats.tres`。
- 代码层可考虑后续加"变体未配字段时回退 parent_id stats"的兜底逻辑，但 PR-1 未做。

---

### 2. Q+1 兵营出兵已从 PR-2 拉到 PR-1

**背景**：原路线图把"移除兵营自动产兵"（阶段 2.1）和"Q+1 改兵营出兵"（阶段 2.2）都放在 PR-2，是一对不能拆的改动。PR-1 提前移除了自动产兵（D2 设计要求），但没补齐 Q+1 手动下单入口，导致断裂状态（兵营不产兵 + 玩家也没法手动下单）。

**PR-1 修复**：把 Q+1 改为"找最近兵营 spawn"拉到 PR-1。实现：
- [main.gd](../../scripts/main.gd) `_find_nearest_barracks(pos)` 找最近已建成兵营
- Q+1 点击后 `barracks._find_valid_spawn_position(16.0)` 找空位 spawn
- 无兵营时 floating_text 提示"无可用兵营"

**后续影响**：
- PR-2 的"队列 UI（5 上限/槽位显示/入队动画）"基于现在的 `_find_nearest_barracks` + `place_player_unit` 实现，**不需要再改放置逻辑**，只需在 place_player_unit 前加入队检查 + 队列 UI。
- 队列满 5 的提示在 PR-2 加，翻译键 `QUEUE_FULL` 已在 PR-1 预备。

---

### 3. 扣金点 main.gd 已改用动态造价

**背景**：PR-1 实现了 `building_placer.get_current_cost(mode)`（按农场数 ×cost_increment 递增），但扣金点 [main.gd:1271](../../scripts/main.gd#L1271) 原来用静态 `D.COSTS.get(place_mode, 0)`，导致实际扣金没递增。

**PR-1 修复**：扣金改用 `building_placer.get_current_cost(place_mode)`。

**后续影响**：
- PR-2 的"建造栏动态造价实时刷新"（阶段 2.4）只需改 game_ui 的按钮 label/角标显示，**扣金逻辑已就位**。
- game_ui 的 tooltip 和 affordability 已在 PR-1 改用 `get_current_cost`，按钮 label 角标显示推 PR-2。

---

### 4. 生产圆圈对 BARRACKS/MONASTERY/ARCHERY 不显示

**背景**：PR-1 移除了 `_spawn_produced_unit()` 调用（D2），但 [building.gd:_create_production_circle](../../scripts/buildings/building.gd#L667) 对 BARRACKS 仍创建生产圆圈（production_cooldown=25>0），圆圈每 25s 转满但什么都不做，给用户"还在自动生产"的错觉。

**PR-1 修复**：`_create_production_circle` 开头对 `BARRACKS / MONASTERY / ARCHERY` 直接 return。CASTLE/FARM 产金圆圈保留。

**后续影响**：
- PR-2 如果要做队列进度显示，**需要重新启用圆圈**（改 `_create_production_circle` 的 match 分支，让 BARRACKS 在有队列时显示）或新建队列 UI。
- production_cooldown 字段仍在 stats 里（barracks=25），PR-2 可复用做队列生产间隔。

---

### 5. `_is_position_clear` 加了单位检查

**背景**：PR-1 反还 2 个 soldier 时，`_find_valid_spawn_position` 每次都返回底部中央（第一个候选），2 个 soldier spawn 在同一位置 -> 物理引擎弹开 -> 弹进兵营里。

**PR-1 修复**：[building.gd:_is_position_clear](../../scripts/buildings/building.gd#L352) 不仅检查建筑，还检查 player_units + enemy_units 组内的单位（最小间距 `unit_radius * 2.5 = 40px`）。

**后续影响**：
- 所有 spawn 都会避开已有单位，避免重叠。
- 性能：spawn 时遍历所有单位，但不是每帧调用，可接受。
- PR-3 骚扰波次 spawn 也会受益（骚扰单位不重叠）。
- 如果后续有"密集阵型 spawn"需求（如召唤骷髅），可能需要调小间距或绕过此检查。

---

### 6. `place_player_unit` 加了逃生检查

**背景**：原 `_spawn_produced_unit`（建筑自动产兵）有逃生机制：spawn 后若在建筑内，调 `_start_escape()`。但 `place_player_unit`（面板造兵）没有。PR-1 把 Q+1 改为兵营旁 spawn 后，需要逃生兜底。

**PR-1 修复**：[game_spawner.gd:place_player_unit](../../scripts/systems/game_spawner.gd#L335) add_child 后加 `_is_inside_any_building` 检查 + `_start_escape()`。

**后续影响**：
- 所有面板造兵（Q+1/Q+2 等）都会触发逃生。
- PR-2 队列出兵也走 place_player_unit，自动受益。
- 如果后续单位类型没有 `_start_escape` 方法（如攻城武器），has_method 检查会跳过，不会报错。

---

### 7. 手写 .tscn 的 UID 教训

**背景**：手写 `map_t1_economy_test.tscn` 时，main_script 的 ext_resource UID 写成了 `uid://cmp1bdjkabfkb`（实际是 capture_point.gd 的 UID），导致 Godot 加载了 capture_point.gd（extends Area2D）挂到 Node2D 根节点 -> "Script inherits from Area2D" 错误 -> 场景实例化中断 -> 卡 60%。

**根因**：Godot 信任 UID 优先于 path。UID 在缓存里命中了（哪怕命中到错的文件），就按 UID 加载，path 不作为兜底。

**PR-1 修复**：UID 改成 main.gd 的真实 UID `uid://cg2igjmusi0dq`。

**后续影响**：
- 后续新建 .tscn 时，**ext_resource 的 UID 必须与目标 .uid 文件一致**。
- 验证方法：`cat scripts/xxx.gd.uid` 看权威 UID。
- 更安全的做法：写新场景时不在 ext_resource 里写 UID，只写 path，让 Godot 首次 import 时自己补 UID（会有一条 warning 但功能不受影响）。
- 已写入 memory：[feedback_tscn_uid_mismatch.md](../../C:/Users/haoyu/.claude/projects/f--godot-game-rts-base-rts-base/memory/feedback_tscn_uid_mismatch.md)。

---

### 8. `commander_context._fallback_basic_building_id` 加了 FARM case

**背景**：`get_default_building_stats_id(building_type, alliance_id)` 先查指挥官变体，没有就回退到 `_fallback_basic_building_id`。FARM 没有变体（test_all 的 building_variants 不含 key 6），走回退。原回退 match 没有 case 6，返回 `&""`，导致 `BuildingStatsRegistry.has_id(&"")` 为 false，building_stats 为 null，所有 stats 字段不生效。

**PR-1 修复**：[commander_context.gd:_fallback_basic_building_id](../../scripts/commander/commander_context.gd#L80) 加 `6: return &"farm"`。

**后续影响**：
- 后续新增建筑类型（如 PR-4 的据点祭坛 altar_archer）**要在这里加 case**，否则 stats 加载失败。
- 如果新建筑有变体，还要在指挥官 profile 的 building_variants 里加。

---

### 9. temp_flag 机制

**背景**：T1 测试入口需要强制 loadout=[FARM,TOWER,BARRACKS,SOLDIER,ARCHER] + 指挥官=test_all，绕过玩家 save 的 loadout 和指挥官选择。但又不应该持久化（只对本局生效）。

**PR-1 实现**：[save_manager.gd](../../scripts/systems/save_manager.gd) 加 `_temp_flags: Dictionary` + `set_temp_flag` / `get_temp_flag` / `has_temp_flag` / `clear_temp_flags`。session 级，不持久化。
- main_menu 的 T1 按钮 set temp_flag
- main.gd `_resolve_loadout` 检查 `skip_loadout_screen` 强制 loadout
- main.gd Step 7 检查 `force_commander` 强制指挥官
- main.gd init 末尾 `clear_temp_flags()` 清理

**后续影响**：
- 后续其他测试入口（如 PR-3 骚扰测试、PR-4 据点测试）可复用此机制。
- temp_flag 是 session 级，重启游戏后消失，符合"测试入口不污染正常存档"的需求。

---

### 10. player_castle 缓存 + show_build_range 设置

**背景**：6 格圆形可建区需要玩家主基地位置作为圆心。建造范围显示开关需要持久化。

**PR-1 实现**：
- main.gd 加 `var player_castle: Node = null` 字段
- init 末尾 `_cache_player_castle()` 遍历 player_buildings 组找 CASTLE
- [building_placer.gd:is_in_buildable_area](../../scripts/systems/building_placer.gd#L112) 读 `main_node.player_castle.global_position` 判定距离
- show_build_range 持久化到 settings.cfg，main.gd Step 5 读入 `building_placer.show_build_range`
- 建造模式下 show_build_range=true 时画绿色圆环（Line2D 64 点近似圆）

**后续影响**：
- 如果后续主基地会移动/被摧毁/重建，**需要更新 player_castle 缓存**（目前 T1 不涉及，主基地是静态的）。
- PR-4 据点占领后扩展可建区，需要扩展 `is_in_buildable_area` 逻辑（据点光圈内也可建）。
- show_build_range 圆环目前只在建造模式显示，PR-2 可考虑常驻显示（类似 PVZ 种植区）。

---

## 二、PR-1 完成的功能验收清单

| 验收项 | 状态 |
|---|---|
| T1 测试入口直达（绕过指挥官/编制界面）| ✅ |
| 开局 400 金 | ✅ |
| 主基地每 10s +50 金（floating_text 显示 +50）| ✅ |
| 农场造价递增 100/250/400/550/700 | ✅ |
| 农场建造 20s 完成，每 10s +20 金 | ✅ |
| 兵营完成反还 2 个 soldier（不卡墙/不重叠）| ✅ |
| 兵营无生产圆圈转动 | ✅ |
| Q+1 在最近兵营旁 spawn（不卡墙/不重叠）| ✅ |
| 无兵营时 Q+1 提示"无可用兵营" | ✅ |
| 6 格圆形可建区（主基地 384px 内）| ✅ |
| 建造范围外预览变红 | ✅ |
| 设置菜单"显示建造范围"开关 + 绿色圆环 | ✅ |
| test_all 指挥官（无 economy_boost）| ✅ |

---

## 三、仍推 PR-2 的功能

| 功能 | 原路线图归属 | PR-1 状态 |
|---|---|---|
| 兵营队列 UI（5 上限/槽位显示/入队动画）| 阶段 2.3 | 推 PR-2 |
| 队列满 5 提示 | 阶段 2.3 | 推 PR-2（翻译键 QUEUE_FULL 已预备）|
| 建造栏按钮 label 动态造价角标 | 阶段 2.4 | 推 PR-2（扣金已动态，只差显示）|
| 农场上限 5 灰显 | 阶段 1.5 | 推 PR-2 |
| 没农场时兵营灰显 | 阶段 1.5 | 推 PR-2（翻译键 NEED_FARM 已预备）|
| 兵营队列进度显示 | 阶段 2.3 | 推 PR-2（生产圆圈已禁用，需重新启用或新建 UI）|

---

## 四、改动文件清单（PR-1 完整）

### 修改的文件（18 个）

| 文件 | 改动摘要 |
|---|---|
| [scripts/systems/save_manager.gd](../../scripts/systems/save_manager.gd) | +temp_flag 机制 |
| [scripts/stats/building_stats.gd](../../scripts/stats/building_stats.gd) | +5 T1 字段（cost_increment/gold_production_amount/completion_refund*）|
| [scripts/systems/game_data.gd](../../scripts/systems/game_data.gd) | PlaceMode.FARM + COSTS/MODE_NAMES/ICON_TEXTURES/DISPLAY_ORDER/ALL_ITEMS 等 |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) | BuildingType.FARM / _produce_gold 读 stats / 移除自动产兵 / 反还 hook / FARM 产金 / FARM 贴图 / _is_position_clear 加单位检查 / _create_production_circle 禁用 BARRACKS |
| [scripts/systems/building_placer.gd](../../scripts/systems/building_placer.gd) | +get_current_cost / +is_in_buildable_area / +show_build_range 圆环 |
| [scripts/ui/main_menu.gd](../../scripts/ui/main_menu.gd) | +T1 按钮 + 显示建造范围 CheckButton |
| [scripts/main.gd](../../scripts/main.gd) | +player_castle / temp_flag 检查 / 扣金用 get_current_cost / Q+1 改最近兵营 spawn / +_find_nearest_barracks / +_cache_player_castle |
| [scripts/systems/game_ui.gd](../../scripts/systems/game_ui.gd) | tooltip + affordability 用动态造价 |
| [scripts/systems/game_spawner.gd](../../scripts/systems/game_spawner.gd) | place_player_unit 加逃生检查 |
| [scripts/commander/commander_context.gd](../../scripts/commander/commander_context.gd) | +FARM 兜底 stats_id |
| [scripts/stats/building_stats_registry.gd](../../scripts/stats/building_stats_registry.gd) | +get_by_type 方法 |
| [resources/stats/buildings/barracks_stats.tres](../../resources/stats/buildings/barracks_stats.tres) | +反还字段 |
| [resources/stats/buildings/barracks_standard_stats.tres](../../resources/stats/buildings/barracks_standard_stats.tres) | +反还字段 |
| [resources/stats/buildings/barracks_light_stats.tres](../../resources/stats/buildings/barracks_light_stats.tres) | +反还字段 |
| [resources/stats/buildings/barracks_fortified_stats.tres](../../resources/stats/buildings/barracks_fortified_stats.tres) | +反还字段 |
| [resources/stats/buildings/castle_stats.tres](../../resources/stats/buildings/castle_stats.tres) | +gold_production_amount=50 |
| [locales/translations.csv](../../locales/translations.csv) | +9 翻译键（ENTITY_FARM/UI_T1_TEST/UI_SHOW_BUILD_RANGE/NO_BARRACKS/QUEUE_FULL/OUT_OF_RANGE/NEED_FARM）|
| [docs/active/T1实施计划.md](T1实施计划.md) | D1-D17 决策更新 + 路径修正 |

### 新建的文件（4 个）

| 文件 | 说明 |
|---|---|
| [resources/stats/buildings/farm_stats.tres](../../resources/stats/buildings/farm_stats.tres) | 农场属性（HP 150 / 产金 20 / 递增 150 / 建造 20s）|
| [scenes/buildings/farm.tscn](../../scenes/buildings/farm.tscn) | 农场场景（继承 building.tscn，building_type=6）|
| [resources/map_t1_economy_test_config.tres](../../resources/map_t1_economy_test_config.tres) | T1 测试地图配置（400 金 / SLOW / 城堡在 (3,8)）|
| [scenes/maps/map_t1_economy_test.tscn](../../scenes/maps/map_t1_economy_test.tscn) | T1 测试地图场景（Node2D + main.gd + map_config）|
