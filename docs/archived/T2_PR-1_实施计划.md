# T2 PR-1 实施计划

## Context

T1 阶段已完成（PR-1~4 实施 + PR-5 验证）。T2 阶段开始，**PR-1 是 T2 的地基**——时代升级机制 + T1 经济参数同步 + T2 解锁内容数值微调。PR-2（兵种全局升级）/PR-3（详情面板 UI）/PR-4（骚扰第 5-6 波）都依赖 PR-1 完成的"player_age + available_items 联动"基础设施。

PR-1 完成后玩家可以：
- 在 T1 测试地图按 **U 键**触发时代升级（500 金 / 15s / 完成后无反还）
- 升级完成后建造栏自动解锁**靶场 + 弓兵**
- 升级中可再按 U 取消，全额退款
- 靶场完成时反 1 弓兵（复用 PR-1 的 completion_refund_unit 机制）
- 农场完成时反 100 金
- 兵营造价递增（300/350/400...）

所有玩法决策已在 [T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) A+B+C 模块拍板，本计划是它的可执行展开。

**主要工作**：
1. T1 经济参数同步（农场反还、兵营造价递增——纯 stats 改动）
2. 城堡时代升级机制（扣金 + 倒计时 + 解锁 + 可取消——main.gd 新增逻辑）
3. 时代状态机 + available_items 联动（建造栏刷新）
4. 弓兵/靶场数值微调（C 模块拍板值）
5. 临时快捷键 U 触发升级（PR-3 做详情面板时迁移）

**主要偏离**（相对 T2 设计文档）：
1. **兵营产能保留 6s**（[barracks_stats.tres:18](../../resources/stats/buildings/barracks_stats.tres#L18) 实际值）。文档 [L82](T2阶段设计_科技与UI.md#L82) 写"25s → 15s"是误读——25s 是 [building.gd:169](../../scripts/buildings/building.gd#L169) 的 fallback 默认值，被 stats 的 6.0 覆盖了。当前实际 6s/兵比文档目标 15s 还快，不改。
2. **T2 升级完成后无反还**（用户 2026-08-05 决策）。取代文档 [L92](T2阶段设计_科技与UI.md#L92) 原"反还 300 金"。
3. **靶场完成反 1 弓兵**（用户 2026-08-05 新增）。取代"靠 T2 反还 300 金启动弓兵"的设计。

---

## 一、决策汇总

### 1.1 用户拍板的 3 项调整（2026-08-05 对话）

| # | 项 | 决策 |
|---|---|---|
| 调整 1 | 兵营产能 | **保留 6s/兵**（不改代码，更新 T2 文档）|
| 调整 2 | 时代升级 UI（PR-1 临时）| **键盘快捷键 U**（选中城堡不是必须——时代升级是全局机制，player_castle 已缓存）|
| 调整 3 | 升级中取消退款 | **全额退款 500 金** |

### 1.2 T2 设计文档已拍板的核心决策

| # | 项 | 决策 | 来源 |
|---|---|---|---|
| Q1 | T1→T2 升级费用 | 500 金 | A/B 模块 |
| Q2 | T1→T2 升级时间 | 15s | B 模块 |
| Q3 | 升级完成后反还 | **无反还**（用户调整） | 本对话 |
| Q4 | 升级中城堡状态 | 完全正常（产金照常） | B 模块 |
| Q5 | 升级失败条件 | 城堡被摧毁 = 游戏失败 | B 模块 |
| Q6 | T2 解锁建筑 | 靶场 ARCHERY_RANGE | C 模块 |
| Q7 | T2 解锁单位 | 弓兵 ARCHER | C 模块 |
| Q8 | 弓兵造价 | 120 → 100 | C 模块 |
| Q9 | 弓兵产能 | 30s → 20s | C 模块 |
| Q10 | 靶场完成反还 | **反 1 弓兵**（用户新增） | 本对话 |
| Q11 | 靶场 HP/造价/建造 | 200 / 250 金 / 5s（保留） | C 模块 |
| Q12 | 农场完成反还 | 100 金 | A 模块 |
| Q13 | 兵营造价递增 | cost_increment=50（300/350/400/450...）| A 模块 |

### 1.3 推演决策（实施时按此走，不再问用户）

| # | 项 | 决策 | 理由 |
|---|---|---|---|
| D1 | 时代状态存储 | `main.gd` 加 `var player_age: int = 1` | main 已有 player_castle / gold 等全局状态，最简单 |
| D2 | 时代升级逻辑挂载 | `main.gd` 加 4 个方法：`_start_age_upgrade` / `_cancel_age_upgrade` / `_on_age_upgrade_complete` / `_unlock_age_items` | 不新建单例，避免 autoload 改动；时代升级是全局机制 |
| D3 | 升级参数存储 | `main.gd` 加常量 `AGE_UPGRADE_COST = {2: 500}` + `AGE_UPGRADE_TIME = {2: 15.0}` | T1→T2 只有一组参数，硬编码最简单；T3 阶段再加 |
| D4 | 升级倒计时 | `main.gd` 加 `var age_upgrade_timer: float` + `var age_upgrade_target: int`；在 `_process` 里递减 | 升级状态存 main 而非城堡实例——城堡可能被毁，状态不能丢 |
| D5 | 触发前置检查 | ① `age_upgrade_target == 0`（不在升级中）② `player_age + 1 in AGE_UPGRADE_COST`（有下一时代）③ `gold >= cost` | 不检查城堡存在——player_castle 已缓存，城堡被毁时游戏已失败 |
| D6 | available_items 联动 | `_unlock_age_items(age)` 往 `map_config.available_items` 追加 ARCHERY_RANGE + ARCHER | 复用现有数据流，game_ui 已从 map_config 读 |
| D7 | 建造栏刷新 | `game_ui.gd` 新增 `refresh_build_buttons()` 方法——销毁旧建造栏 + 重新调用 `_create_build_panel()` | 升级只发生 1-2 次/局，重建闪烁可接受；比追加按钮简单 |
| D8 | 快捷键挂载 | `main.gd _input()` 加 `KEY_U` 分支：升级中按 U = 取消；否则 = 启动升级 | 复用现有按键处理（[行 1168-1316](../../scripts/main.gd#L1168-L1316)）|
| D9 | 视觉反馈 | floating_text 提示（开始/取消/完成）+ 升级中城堡头顶飘字"T2 升级中: 12s"（每 3s 刷一次）| 最小改动；PR-3 详情面板再升级为正式进度条 |
| D10 | 城堡死亡时清理 | `_check_victory()` 检测玩家城堡死亡时强制 `age_upgrade_target = 0` | 避免悬空状态 |
| D11 | 弓兵 stats | 改 [game_data.gd:27](../../scripts/systems/game_data.gd#L27) `COSTS[ARCHER]` 120→100 | 数据驱动 |
| D12 | 靶场反弓兵 | 改 [archery_stats.tres](../../resources/stats/buildings/archery_stats.tres) 加 `completion_refund_unit=&"archer"` + `count=1` | 复用 [building.gd:902-917](../../scripts/buildings/building.gd#L902-L917) `_spawn_completion_refund_units()`，零代码 |
| D13 | 农场反还金币 | 改 [farm_stats.tres:28](../../resources/stats/buildings/farm_stats.tres#L28) `completion_refund` 0→100 | 复用现有 completion_refund 字段（[building.gd](../../scripts/buildings/building.gd) 反还金币逻辑已有）|
| D14 | 兵营造价递增 | 改 [barracks_stats.tres:26](../../resources/stats/buildings/barracks_stats.tres#L26) `cost_increment` 0→50 | 复用 PR-1 已有动态造价机制 |

---

## 二、改动文件清单

### 代码层（2 个）

| # | 文件 | 改动要点 |
|---|---|---|
| 1 | [scripts/main.gd](../../scripts/main.gd) | 加 `player_age` / `age_upgrade_timer` / `age_upgrade_target` 变量；加 `AGE_UPGRADE_COST` / `AGE_UPGRADE_TIME` 常量；加 `_start_age_upgrade` / `_cancel_age_upgrade` / `_on_age_upgrade_complete` / `_unlock_age_items` 方法；`_input` 加 `KEY_U` 分支；`_process` 加倒计时递减；`_check_victory` 加城堡死亡清理 |
| 2 | [scripts/systems/game_ui.gd](../../scripts/systems/game_ui.gd) | 抽取 `_create_build_panel()` 方法（从 `_create_ui` 里拆出建造栏创建逻辑）；新增 `refresh_build_buttons()`——销毁旧建造栏 + 重建 |
| 3 | [scripts/systems/game_data.gd](../../scripts/systems/game_data.gd) | `COSTS[PlaceMode.ARCHER]` 120 → 100 |

### 数据层（3 个 .tres）

| # | 文件 | 改动 |
|---|---|---|
| 1 | [resources/stats/buildings/farm_stats.tres](../../resources/stats/buildings/farm_stats.tres) | `completion_refund: 0 → 100` |
| 2 | [resources/stats/buildings/barracks_stats.tres](../../resources/stats/buildings/barracks_stats.tres) | `cost_increment: 0 → 50` |
| 3 | [resources/stats/buildings/archery_stats.tres](../../resources/stats/buildings/archery_stats.tres) | `production_cooldown: 30.0 → 20.0`；**新增** `completion_refund_unit = &"archer"`；**新增** `completion_refund_unit_count = 1` |

### 不需要新建的场景/脚本

- ❌ 不新建 `age_upgrade_manager.gd`（逻辑放 main.gd）
- ❌ 不改 `building_stats.gd`（不加时代升级字段——升级参数硬编码在 main.gd 常量）
- ❌ 不新建时代升级 UI 场景（用 floating_text，PR-3 再做正式 UI）

---

## 三、实施步骤

### 阶段 1：T1 经济参数同步（30 分钟）

**1.1** 改 [farm_stats.tres:28](../../resources/stats/buildings/farm_stats.tres#L28)
- `completion_refund = 100`

**1.2** 改 [barracks_stats.tres:26](../../resources/stats/buildings/barracks_stats.tres#L26)
- `cost_increment = 50`

**1.3** 验证（T1 测试地图）
- [ ] 造农场完成 → +100 金
- [ ] 第 1 个兵营 300 金，第 2 个 350，第 3 个 400

### 阶段 2：弓兵/靶场数值（30 分钟）

**2.1** 改 [game_data.gd:27](../../scripts/systems/game_data.gd#L27)
- `PlaceMode.ARCHER: 100`

**2.2** 改 [archery_stats.tres](../../resources/stats/buildings/archery_stats.tres)
- `production_cooldown = 20.0`
- 新增 `completion_refund_unit = &"archer"`
- 新增 `completion_refund_unit_count = 1`

**2.3** 验证
- [ ] 弓兵造价显示 100
- [ ] 靶场产能 20s
- [ ] 靶场完成时反 1 弓兵

### 阶段 3：时代升级核心机制（2-3 小时）

**3.1** main.gd 加状态变量（class 顶部，gold 附近）
```gdscript
var player_age: int = 1
var age_upgrade_timer: float = 0.0
var age_upgrade_target: int = 0
const AGE_UPGRADE_COST := {2: 500}
const AGE_UPGRADE_TIME := {2: 15.0}
```

**3.2** main.gd 加 _start_age_upgrade()
```gdscript
func _start_age_upgrade() -> void:
    if age_upgrade_target > 0:
        return  # 已在升级中，由 _input 走取消分支
    var target := player_age + 1
    if target not in AGE_UPGRADE_COST:
        return
    var cost: int = AGE_UPGRADE_COST[target]
    if gold < cost:
        _floating_text_at_screen("金币不足（需要 %d）" % cost)
        return
    gold -= cost
    age_upgrade_target = target
    age_upgrade_timer = AGE_UPGRADE_TIME[target]
    _floating_text_at_screen("开始升级到 T%d（%ds）" % [target, int(age_upgrade_timer)])
```

**3.3** main.gd 加 _cancel_age_upgrade()
```gdscript
func _cancel_age_upgrade() -> void:
    if age_upgrade_target == 0:
        return
    var cost: int = AGE_UPGRADE_COST[age_upgrade_target]
    gold += cost
    var cancelled_target := age_upgrade_target
    age_upgrade_target = 0
    age_upgrade_timer = 0.0
    _floating_text_at_screen("升级已取消，退回 %d 金" % cost)
```

**3.4** main.gd _process 加倒计时（在现有 _process 末尾或 gold 处理附近）
```gdscript
if age_upgrade_target > 0:
    age_upgrade_timer -= delta
    # 每 3s 飘字提示进度
    if int(age_upgrade_timer) % 3 == 0 and _last_upgrade_tick != int(age_upgrade_timer):
        _floating_text_at_screen("T%d 升级中: %ds" % [age_upgrade_target, int(age_upgrade_timer)])
        _last_upgrade_tick = int(age_upgrade_timer)
    if age_upgrade_timer <= 0:
        _on_age_upgrade_complete()
```

**3.5** main.gd 加 _on_age_upgrade_complete() + _unlock_age_items()
```gdscript
func _on_age_upgrade_complete() -> void:
    var completed := age_upgrade_target
    player_age = completed
    age_upgrade_target = 0
    age_upgrade_timer = 0.0
    _unlock_age_items(completed)
    _floating_text_at_screen("升级到 T%d 完成！" % completed)

func _unlock_age_items(age: int) -> void:
    var to_unlock: Array[int] = []
    if age >= 2:
        to_unlock = [D.PlaceMode.ARCHERY_RANGE, D.PlaceMode.ARCHER]
    for mode in to_unlock:
        if int(mode) not in map_config.available_items:
            map_config.available_items.append(int(mode))
    game_ui.refresh_build_buttons()
```

**3.6** main.gd _input 加 KEY_U（在 [行 1168-1316](../../scripts/main.gd#L1168-L1316) 的按键处理里）
```gdscript
if event.pressed and event.keycode == KEY_U:
    if age_upgrade_target > 0:
        _cancel_age_upgrade()
    else:
        _start_age_upgrade()
    get_viewport().set_input_as_handled()
    return
```

**3.7** main.gd _check_victory 加城堡死亡清理（[行 1109-1135](../../scripts/main.gd#L1109-L1135)）
```gdscript
# 在检测到玩家城堡死亡时（_on_game_ended("defeat") 调用前）
age_upgrade_target = 0
age_upgrade_timer = 0.0
```

### 阶段 4：建造栏刷新（1 小时）

**4.1** game_ui.gd 抽取 _create_build_panel()
- 把 `_create_ui()` 里建造栏创建部分（[行 239](../../scripts/systems/game_ui.gd#L239) 起 `panel_wrapper` 到建造按钮生成结束）抽取成独立方法
- 保存 `panel_wrapper` 引用为成员变量 `_build_panel_wrapper`

**4.2** game_ui.gd 加 refresh_build_buttons()
```gdscript
func refresh_build_buttons() -> void:
    if _build_panel_wrapper == null or not is_instance_valid(_build_panel_wrapper):
        return
    # 销毁旧建造栏内容
    for child in _build_panel_wrapper.get_children():
        child.queue_free()
    # 重建
    _create_build_panel()
```

**4.3** 验证
- [ ] 时代升级前建造栏只有 FARM/TOWER/BARRACKS/SOLDIER/ARCHER（或玩家编制）
- [ ] 升级完成后建造栏多出 ARCHERY_RANGE
- [ ] ARCHER 如果原本就在编制里（T1 测试地图默认有），不需要新增

### 阶段 5：回归 + 验证（30 分钟）

按第四节验收清单逐项验证。

---

## 四、验收清单

### 4.1 T1 经济参数同步
- [ ] 农场完成时反 100 金（floating_text 提示）
- [ ] 第 1 个兵营造价 300 金
- [ ] 第 2 个兵营造价 350 金
- [ ] 第 3 个兵营造价 400 金
- [ ] 步兵造价 50 金（已改，回归）
- [ ] 兵营产能 6s/兵（保留，无回归）

### 4.2 时代升级机制
- [ ] 开局 `player_age = 1`
- [ ] 金币 < 500 时按 U → floating_text "金币不足"
- [ ] 金币 ≥ 500 时按 U → 扣 500 金 + floating_text "开始升级到 T2"
- [ ] 升级中每 3s 看到 floating_text 进度提示
- [ ] 升级中按 U → 取消 + 退回 500 金 + floating_text "升级已取消"
- [ ] 升级中城堡每 10s 仍产 50 金（产金照常）
- [ ] 15s 后升级完成 + floating_text "升级到 T2 完成"
- [ ] 升级完成后 `player_age = 2`
- [ ] 城堡被毁时升级状态被清理（age_upgrade_target = 0）

### 4.3 available_items 联动
- [ ] 升级前建造栏**没有**靶场图标
- [ ] 升级完成后建造栏**出现**靶场图标
- [ ] 升级完成后按 W+4（ARCHERY_RANGE 快捷键）→ 可建造靶场
- [ ] 靶场造价 250 金

### 4.4 T2 解锁内容数值
- [ ] 弓兵造价 100 金
- [ ] 靶场产能 20s/弓兵
- [ ] 靶场建造完成时反 1 弓兵（在靶场门口生成）
- [ ] 靶场 HP 200 / 建造时间 5s

### 4.5 回归（不破坏 T1）
- [ ] T1 测试地图可正常进入
- [ ] T1 前 4 波骚扰仍正常触发
- [ ] SH1 据点仍可占领
- [ ] 兵营队列 UI（PR-2）仍正常
- [ ] 农场上限 5 仍生效

---

## 五、风险

| 风险 | 概率 | 应对 |
|---|---|---|
| `refresh_build_buttons` 重建破坏建造栏交互状态（如当前选中模式） | 中 | 实施时记录当前 place_mode，重建后恢复；或重建时重置为 NONE |
| KEY_U 与现有快捷键冲突 | 低 | 实施前 grep `KEY_U` 确认未占用 |
| `map_config.available_items` 是 Array[int] 强类型 | 中 | 追加时用 `int(mode)` 转换（参考 [main.gd:1573](../../scripts/main.gd#L1573) `_apply_loadout_filter`）|
| 升级中存档/读档（如果游戏支持）| 低 | T1 阶段无存档，T2 PR-1 不处理 |
| floating_text 提示位置不佳 | 低 | 用现有 `_floating_text_at_screen` 或 objectives_panel，实施时调 |

---

## 六、用户配置说明

**玩家怎么触发时代升级**：
1. 攒够 500 金
2. 按 **U 键** → 扣 500 金，开始 15s 倒计时
3. 升级中想取消 → 再按一次 U → 退回 500 金
4. 15s 后自动完成 → 建造栏多出靶场图标，可造弓兵

**关卡设计者怎么配置时代升级参数**：
- 当前硬编码在 [main.gd](../../scripts/main.gd) 的 `AGE_UPGRADE_COST` / `AGE_UPGRADE_TIME` 常量
- T3 阶段加 T2→T3 时：往这两个字典追加 `{3: 金币}` / `{3: 时间}`
- T2 解锁内容在 `_unlock_age_items(age)` 方法里配置

**关卡设计者怎么配置建筑反还**：
- 农场反金币：改 [farm_stats.tres](../../resources/stats/buildings/farm_stats.tres) `completion_refund`
- 兵营反单位：改 [barracks_stats.tres](../../resources/stats/buildings/barracks_stats.tres) `completion_refund_unit` + `count`
- 靶场反单位：改 [archery_stats.tres](../../resources/stats/buildings/archery_stats.tres) `completion_refund_unit` + `count`

---

## 七、关联文档

- [T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) — 主设计（A+B+C 模块，本 PR 实施）
- [T1_PR-4_实施计划.md](T1_PR-4_实施计划.md) — 实施计划格式参考
- [T1_PR-1_实施记录.md](T1_PR-1_实施记录.md) — completion_refund / cost_increment 字段来源
- [T1实施路线图.md](T1实施路线图.md) — T1 完成情况

---

## 八、PR-1 之后的依赖

PR-1 完成后解锁的后续 PR：

| PR | 依赖 PR-1 的什么 | 阻塞原因 |
|---|---|---|
| PR-2（兵种全局升级）| `player_age` 状态（科技树按时代解锁）| D 模块数值未定 |
| PR-3（详情面板 UI）| `player_age` + 时代升级方法（迁到详情面板按钮）| F 模块交互细节待聊 |
| PR-4（骚扰第 5-6 波 + T2 单位实战）| `player_age` 状态（T2 单位参与骚扰）| E 模块未设计 |
| PR-5（T2 测试地图 + 验证）| 所有前序 PR | — |
