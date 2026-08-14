# PR-T2-2 实施计划：T2 内容配置 + 骚扰延续

- **日期**：2026-08-06
- **阶段**：T2（时代升级 + 科技系统 + UI 改造）
- **状态**：✅ 已完成（已合入 master，靶场光环 2026-08-07 补移除）
- **关联**：
  - 总览：[T2_实施路线图.md](T2_实施路线图.md)
  - 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 2.3.3 节（C 模块）+ 2.3.5 节（E 模块）

---

## 一、Context

PR-T2-2 配合 PR-T2-1（时代升级机制）补齐 T2 阶段的"内容"：
1. 调整弓兵 + 靶场 + 兵营的 stats 数值
2. 骚扰波次第 3-4 波加入弓兵（玩家升 T2 后也开始造弓兵应对）

**已做情况**：用户在另一台机器上完成了本 PR，代码尚未同步。本文档作为**验收 + 同步前核对清单**。

**前置依赖**：PR-T2-1（弱）—— 没有 PR-T2-1 也能改 stats 和骚扰波次，但验证"骚扰方+玩家都加入弓兵"的节奏需要时代升级就位。

**后续依赖**：PR-T2-4（升级系统）的弓兵减速箭特色升级需要 PR-T2-2 的弓兵就位。

---

## 二、核心交付

### 2.1 Stats 调整清单

| Stats 文件 | 字段 | 旧值 | 新值 | 设计依据 |
|---|---|---|---|---|
| `resources/stats/archer_stats.tres` | 造价 | 120 | **100** | C 模块拍板 |
| `resources/stats/buildings/archery_stats.tres` | production_cooldown | 30.0 | **20.0** | C 模块拍板 |
| `resources/stats/buildings/archery_stats.tres` | aura_range | 150.0 | **0.0**（移除）| 08-06 修正：靶场不要光环 |
| `resources/stats/buildings/archery_stats.tres` | aura_type | "range_bonus" | **""**（空）| 同上 |
| `resources/stats/buildings/archery_stats.tres` | aura_value | 25.0 | **0.0** | 同上 |
| `resources/stats/buildings/barracks_stats.tres` | production_cooldown | 6.0 | **15.0** | 用户 2026-08-06 拍板 |
| `resources/stats/buildings/farm_stats.tres` | completion_refund | 0 | **100** | T1 残留经济参数（A 模块拍板）|
| `resources/stats/buildings/barracks_stats.tres` | cost_increment | 0 | 计算 300/350/400 递增（每级 +50）| A 模块拍板 |

### 2.2 弓兵属性（确认保持当前值）

| 项 | 值 | 状态 |
|---|---|---|
| HP | 60 | ✅ 与设计一致 |
| DMG | 15 | ✅ 与设计一致 |
| 攻击距离 | 200 | ✅ 与设计一致 |
| 攻击间隔 | 1.2s | ✅ 与设计一致 |
| 移速 | 180 | ✅ 与设计一致 |
| 造价 | 100 金（改后）| ✅ |
| 产能 | 20s（改后）| ✅ |

### 2.3 骚扰波次调整（第 3-4 波加入弓兵）

| 波次 | 时间 | 旧组成 | 新组成 | 总 DPS |
|---|---|---|---|---|
| 第 1 波 | 1:30 警告 / 2:00 出兵 | 3 步兵 | 不变 | 50 |
| 第 2 波 | 3:30 警告 / 4:00 出兵 | 4 步兵 + 1 弓兵 | 不变 | 75 |
| 第 3 波 | 5:30 警告 / 6:00 出兵 | 6 步兵 + 2 弓兵 + 1 精英 | **保持递增**（具体比例实施时算）| 128 |
| 第 4 波 | 7:30 警告 / 8:00 出兵 | 8 步兵 + 3 弓兵 + 2 精英 | **保持递增** | 194 |

⚠️ **第 3-4 波"加入弓兵"的含义**：在 T1 设计基础上微调弓兵数量（而非新增机制）。具体数值实施时按总 DPS 目标（128/194）反推。

### 2.4 骚扰机制保持不变

- WaveManager 调度逻辑不动（沿用 T1 PR-3）
- 攻击目标仍为玩家城堡
- attack-move 路径不变
- 第 5-6 波（如设计延伸到 T2 后期）的具体参数推到 T3 阶段

---

## 三、改动文件清单（推测，待同步核对）

| 文件 | 改动 |
|---|---|
| `resources/stats/archer_stats.tres` | 造价字段（如果在 .tres 里；否则在 game_data.gd 的 COSTS 数组）|
| `resources/stats/buildings/archery_stats.tres` | production_cooldown + 移除 aura 三字段 |
| `resources/stats/buildings/barracks_stats.tres` | production_cooldown + cost_increment |
| `resources/stats/buildings/farm_stats.tres` | completion_refund |
| `scripts/systems/game_data.gd` | COSTS 数组（如弓兵造价在代码里）|
| `scripts/systems_game/wave_manager.gd` 或场景配置 | 第 3-4 波 groups 数组微调 |
| `scenes/maps/map_t1_economy_test.tscn` | 骚扰波次配置（如写在场景里）|

---

## 四、验收点（同步后核对）

### 4.1 弓兵数值
- [ ] 弓兵 stats：HP 60 / DMG 15 / 射程 200 / 攻速 1.2s / 移速 180
- [ ] 弓兵造价显示 100 金（建造栏 + 实际扣金）
- [ ] 靶场造弓兵 20s/个（玩家视野内能看到 20s 进度）

### 4.2 靶场属性
- [ ] 靶场 HP 200 / 造价 250 金 / 建造 5s
- [ ] 靶场**没有**射程光环（附近单位射程不变）
- [ ] 靶场被攻击时 HP 正常下降

### 4.3 兵营属性
- [ ] 兵营 production_cooldown = 15s/兵
- [ ] 兵营递增造价：300 → 350 → 400（依次建 3 个兵营测试）
- [ ] 兵营完成仍反 2 个 soldier（沿用 T1）

### 4.4 农场属性
- [ ] 农场 completion_refund = 100 金（完成时反 100）
- [ ] 农场仍每 10s 产 20 金（沿用 T1）

### 4.5 骚扰波次
- [ ] 第 3 波（5:30 警告 / 6:00 出兵）含弓兵，组成混合部队
- [ ] 第 4 波（7:30 警告 / 8:00 出兵）含更多弓兵
- [ ] 骚扰方弓兵 attack-move 到玩家城堡
- [ ] 骚扰方弓兵在射程内主动攻击玩家单位
- [ ] 总 DPS 符合设计目标（128 / 194，容差 ±20%）

### 4.6 T2 阶段节奏验证
- [ ] 玩家在 3:00 左右升 T2 后，5:30 第 3 波到达时有 1-2 弓兵应对
- [ ] 玩家 4:00+ 升 T2 时，骚扰压力大但仍可守
- [ ] 没出现"骚扰方有弓兵、玩家完全没弓兵"的不对称局面（玩家有反制空间）

---

## 五、风险与注意事项

### 5.1 同步前必做
- 在另一机器跑一遍验收点
- 特别核对"靶场移除光环"是否彻底（aura_range=0 + aura_type="" + aura_value=0）
- 确认 barracks 产能 15s 是否合理（旧值 6s 实际是 T1 PR-2 后的值，玩家可能已适应）

### 5.2 已知坑
- **archer 造价位置**：可能在 `archer_stats.tres` 的 `cost_override`，或在 `game_data.gd` 的 `COSTS` 数组。同步后查清，避免漏改
- **barracks cost_increment**：现有 barracks_stats.tres 没看到 cost_increment 字段（仅在 farm_stats.tres 有）。可能要在 building_stats.gd 加这个字段
- **骚扰波次配置位置**：可能在场景 .tscn 的 WaveManager 节点里，也可能在 wave_manager.gd 的硬编码。同步后查清

### 5.3 设计延伸（T3 阶段处理）
- 第 5-6 波的具体参数（DPS、单位组成）
- T3 阶段骚扰方加入精英单位（如修道院单位）
- 这些不在 PR-T2-2 范围

---

## 六、关联文档

- 总览：[T2_实施路线图.md](T2_实施路线图.md)
- 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 2.3.3 + 2.3.5 节
- 前置：[T2_PR-1_实施计划.md](T2_PR-1_实施计划.md)
- 后续：[T2_PR-4_实施计划.md](T2_PR-4_实施计划.md)（弓兵特色升级依赖本 PR）
