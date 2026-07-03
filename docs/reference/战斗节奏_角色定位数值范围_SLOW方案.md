# 战斗节奏 — 角色定位数值范围（SLOW 方案）

> 基于 [RTS战斗节奏设计_从10秒TTK反推数值.md](RTS战斗节奏设计_从10秒TTK反推数值.md) 的方法论
> 应用于当前项目实际公式（百分比减伤），结合已确认的 SLOW 倍率
> 倍率定义：[balance_scheme.gd](../../scripts/autoload/balance_scheme.gd) `Scheme.SLOW`

---

## 0. 锚点：SLOW 方案

| 倍率 | 值 |
|------|---|
| HP × | **1.3** |
| DMG × | **0.9**（取整） |
| CD × | **1.05** |

**衍生系数：**
- DPS 倍率 = 0.9 / 1.05 = **0.857**
- 自打 TTK 倍率 = 1.3 / 0.857 = **1.517**

**基准 soldier（base 100/10/0.8）：**
| HP | DMG | CD | DPS | 自打 TTK |
|----|-----|----|-----|---------|
| 130 | 9 | 0.84 | 10.7 | **12.0s** |

---

## 1. 核心公式

```
effective_HP   = base_HP × 1.3
effective_DMG  = int(base_DMG × 0.9)        # Godot int() 截断
effective_CD   = base_CD × 1.05
effective_DPS  = effective_DMG / effective_CD
自打_TTK       = effective_HP / effective_DPS
             = base_HP × 1.517 / (base_DMG / base_CD)
```

**反推 base 值（设计新单位时套用）：**
```
base_HP  = 目标_TTK × base_DPS / 1.517
base_DMG = effective_DPS × base_CD / 0.857
```

---

## 2. 角色定位维度对比

| 维度 | 肉盾 | 近战输出 | 远程输出 | 刺客 | 法师 | 辅助 | 攻城 |
|------|------|---------|---------|------|------|------|------|
| **HP** | 极高 | 中 | 低 | 低 | 中 | 中 | 中高 |
| **DMG** | 低 | 中 | 中高 | 极高 | 极高 | 极低 | 极高 |
| **CD** | 长 | 中 | 中 | 中短 | 极长 | 中 | 极长 |
| **DPS** | 低 | 中 | 中高 | 极高 | 中 | 极低 | 高 |
| **Range** | 近战 | 近战 | 远程 | 近/中 | 远程 | 远程 | 超远程 |
| **Move** | 慢 | 中 | 中 | 快 | 中 | 中 | 极慢 |

---

## 3. 各角色 base 值范围（设计新单位时直接套用）

> 下面给出 **base 值**（写入 .tres 的原始数值），并列出应用 SLOW 后的实际值。

### 3.1 近战标准（基准，soldier-like）
| 字段 | base 范围 | SLOW 实际 | 说明 |
|------|----------|----------|------|
| max_hp | 95-110 | **124-143** | 锚点 100 |
| attack_damage | 9-11 | **8-9** | 锚点 10 |
| attack_cooldown | 0.75-0.9 | **0.79-0.95** | 锚点 0.8 |
| attack_range | 30-50 | — | 近战距离 |
| **DPS** | 10-14 | **9-11** | — |
| **自打 TTK** | — | **11-13s** | 玩家实测甜点 |

### 3.2 远程标准（archer-like）
| 字段 | base 范围 | SLOW 实际 | 说明 |
|------|----------|----------|------|
| max_hp | 55-75 | **72-98** | 比近战脆 25-40% |
| attack_damage | 12-18 | **11-16** | 单发高 |
| attack_cooldown | 1.1-1.4 | **1.16-1.47** | 慢射速换射程 |
| attack_range | 180-220 | — | 风筝空间 |
| **DPS** | 9-15 | **7.5-13** | 略低于近战（射程补偿） |
| **自打 TTK** | — | **6-10s** | 被切近战就死 |

### 3.3 肉盾（tank / defensive front）
| 字段 | base 范围 | SLOW 实际 | 说明 |
|------|----------|----------|------|
| max_hp | 200-300 | **260-390** | 2-3x soldier |
| attack_damage | 5-8 | **4-7** | 配合低 DPS |
| attack_cooldown | 1.0-1.3 | **1.05-1.37** | 慢攻击 |
| attack_range | 20-30 | — | 必须近战吸仇 |
| damage_reduction | 0.15-0.30 | — | 关键减伤字段 |
| **DPS** | 4-8 | **3-6.5** | 最低 |
| **自打 TTK** | — | **40-90s** | 极难单独击杀 |

> 肉盾的价值不在 DPS，而在拉仇恨/卡位/拖延时间。给 `damage_reduction` 比堆 HP 更高效（百分比公式递减收益但叠加效果显著）。

### 3.4 刺客 / 突袭（assassin / skirmisher）
| 字段 | base 范围 | SLOW 实际 | 说明 |
|------|----------|----------|------|
| max_hp | 60-85 | **78-111** | 比 soldier 低 20-35% |
| attack_damage | 16-25 | **14-22** | 单发爆发 |
| attack_cooldown | 0.85-1.1 | **0.89-1.16** | — |
| attack_range | 25-150 | — | 近战或短远程 |
| move_speed | 1.3-1.6x soldier | — | 高机动 |
| **DPS** | 14-26 | **12-23** | 最高的可持续输出 |
| **自打 TTK** | — | **3.5-7s** | 谁先手谁赢 |

### 3.5 法师 / 爆发（caster / nuker）
| 字段 | base 范围 | SLOW 实际 | 说明 |
|------|----------|----------|------|
| max_hp | 75-105 | **98-137** | 中下血量 |
| attack_damage | 22-40 | **20-36** | 大爆发 |
| attack_cooldown | 2.0-3.2 | **2.1-3.36** | 长CD换 burst |
| attack_range | 200-260 | — | 远程 |
| max_mana | 50-120 | — | 蓝量限制 |
| **DPS（含CD）** | 8-18 | **6-15** | 蓝打空后断档 |
| **自打 TTK（满蓝）** | — | **7-15s** | — |

> 法师设计的关键是 **burst/sustain 二选一**：burst 法师 CD 长 DMG 高，sustain 法师 CD 短 DMG 低。

### 3.6 辅助 / 治疗（support / healer）
| 字段 | base 范围 | SLOW 实际 | 说明 |
|------|----------|----------|------|
| max_hp | 85-115 | **111-150** | 中等生存 |
| attack_damage | 3-8 | **3-7** | 几乎不打人 |
| attack_cooldown | 1.0-1.5 | **1.05-1.58** | — |
| attack_range | 140-200 | — | 站后排 |
| heal_amount | 8-18 | — | 治疗量 |
| heal_cooldown | 1.5-2.5 | — | — |
| heal_range | 150-220 | — | — |
| **DPS** | 2-7 | **2-6** | 最低 |
| **自打 TTK** | — | **18-50s** | 难杀但不致命 |

### 3.7 攻城（siege / anti-building）
| 字段 | base 范围 | SLOW 实际 | 说明 |
|------|----------|----------|------|
| max_hp | 180-260 | **234-338** | 中高血 |
| attack_damage | 35-70 | **32-63** | 极高 |
| attack_cooldown | 2.4-4.0 | **2.52-4.2** | 极慢 |
| attack_range | 240-340 | — | 超远 |
| bonus_vs（建筑） | 2.0-3.0x | — | 秒建筑 |
| move_speed | 0.6-0.8x soldier | — | 极慢 |
| **DPS（vs 单位）** | 11-26 | **8-22** | — |
| **DPS（vs 建筑）** | 22-78 | **16-66** | — |
| **自打 TTK** | — | **12-25s** | 怕被近战切 |

---

## 4. 设计规律总结

### 4.1 推荐 TTK 范围（按定位排序）

| 定位 | 推荐自打 TTK | 与 soldier 比 | 设计意图 |
|------|-------------|--------------|---------|
| 刺客 | 3-7s | 0.25-0.6x | 高风险高回报 |
| 远程输出 | 6-10s | 0.5-0.85x | 站位错了就死 |
| 法师（满蓝） | 7-15s | 0.6-1.25x | burst 窗口 |
| **近战标准** | **11-13s** | **1.0x（锚点）** | **基准节奏** |
| 攻城 | 12-25s | 1.0-2.1x | 怕近战 |
| 辅助 | 18-50s | 1.5-4x | 几乎不打架 |
| 肉盾 | 40-90s | 3.3-7.5x | 拖时间 |

### 4.2 5 个常见反模式（设计时避开）

| 反模式 | 现象 | 修正方向 |
|--------|------|---------|
| **超厚肉盾高 DPS** | HP 300+ 且 DMG 15+ | 二者必舍一，肉盾就是低 DPS |
| **远程+高血+高伤** | archer HP 100+ DMG 15+ | 远程优势必须用脆性补偿 |
| **刺客无缺陷** | HP 100 + DMG 20 + 速度 1.5x | 刺客必须脆，否则无解 |
| **法师无蓝限** | DMG 30 + CD 1.0 | burst 必须配长 CD 或蓝限 |
| **辅助能打** | DMG 12+ + 治疗 | 辅助的代价就是输出 |

### 4.3 推导示例

**例 1：设计一个 TTK=8s 的远程法师，DMG=20，CD=2.0**
```
effective_DPS = 20 × 0.9 / (2.0 × 1.05) = 8.57
required_effective_HP = 8 × 8.57 = 68.6
base_HP = 68.6 / 1.3 = 52.7 → 取 50
```
→ 写入 .tres：HP=50, DMG=20, CD=2.0

**例 2：设计一个 TTK=50s 的肉盾，DMG=6，CD=1.2，reduction=0.20**
```
effective_DPS = 6 × 0.9 / (1.2 × 1.05) = 4.29
required_effective_HP = 50 × 4.29 = 214.3
base_HP_no_armor = 214.3 / 1.3 = 164.8
考虑 reduction=0.20 后 effective_HP 实际翻倍：base_HP ≈ 165 / 0.8 ≈ 82?
```
> **注意**：百分比减伤公式下，effective_HP = HP / (1 - reduction)。reduction=0.2 → 有效血量 ×1.25。所以实际 base_HP = 165 / 1.25 = **132**。

---

## 5. 建筑 HP 与 siege 节奏

建筑 base HP 硬编码在 [building.gd:142 _setup_stats](../../scripts/buildings/building.gd#L142)，按 `BuildingType` 分配。SLOW 方案下额外应用 **2.0x 倍率**（通过 `BalanceScheme.get_building_hp_mult()`，在 `_apply_commander_building_stats` 的 3 个 `health.setup()` 路径都乘进去）。

### 5.1 各建筑实际 HP

| 建筑 | base HP | SLOW 实际 (×2.0) | grid | 备注 |
|------|---------|-----------------|------|------|
| Wall（墙） | 300 | **600** | 1×1 | 阻挡 + 吸伤害 |
| Tower（箭塔） | 150 | **300** | 1×1 | 远程防御 |
| Castle（城堡） | 500 | **1000** | 3×3 | 主基地，光环 +10% 防御 |
| Barracks（兵营） | 250 | **500** | 2×2 | 产 soldier，光环 +15% 近战 |
| Monastery（修道院） | 400 | **800** | 2×2 | 产 monk，光环 +2 regen |
| Archery（靶场） | 200 | **400** | 2×2 | 产 archer，光环 +25 range |

### 5.2 Siege 时间估算（5 个 SLOW soldier 集火，DPS 合计 ≈ 53.5）

| 建筑 | 实际 HP | 5 soldier 集火 | 3 soldier 集火 | 1 soldier 独斗 |
|------|---------|---------------|---------------|---------------|
| Wall | 600 | 11s | 19s | 56s |
| Tower | 300 | 6s | 9s | 28s |
| Archery | 400 | 7s | 12s | 37s |
| Barracks | 500 | 9s | 16s | 47s |
| Monastery | 800 | 15s | 25s | 75s |
| Castle | 1000 | **19s** | 31s | 93s |

### 5.3 推荐拉锯战时长（按战斗规模）

| 攻方规模 | 推荐 castle siege 时长 | 设计意图 |
|---------|----------------------|---------|
| 3-5 单位（小股骚扰） | 25-40s | 防守方有时间赶回救 |
| 8-12 单位（主力推进） | 15-25s | 拉锯但不会僵持 |
| 15+ 单位（决战） | 8-15s | 多线集火秒掉 |

SLOW 当前的 castle × 5 soldier = 19s 落在中间区间，符合"主力推进拉锯"目标。

### 5.4 设计新建筑时的建议

| 字段 | 推荐范围 | 说明 |
|------|---------|------|
| base max_hp | 200-600 | < 200 太脆（一波单兵秒掉），> 600 太冗长 |
| grid_size | 1×1 / 2×2 / 3×3 | 决定占地和受击面积 |
| aura_range | 100-250 | 防御光环覆盖范围 |
| aura_value | 0.1-0.3 (百分比值) 或 1-3 (固定值) | 不要叠加超过 0.5（玩家难感知减伤） |
| production_cooldown | 20-40s | 短于此会刷兵太快，长于此玩家忘掉 |

### 5.5 反模式（设计时避开）

- **超厚墙体无覆盖**：Wall HP=600 但没建筑在后面 → 玩家绕过即可，浪费数值
- **箭塔太脆**：Tower HP < 200 → 一波小队冲掉，没威慑力
- **Castle 难以接近**：周围全是 Wall + Tower → 攻方进不去，变成消极僵持
- **光环叠加过量**：多个 buildings 光环堆 +50% 防御 → 守方无敌

---

## 6. 与其他系统的联动

### 6.1 升级系统（UpgradeMgr）
- `upgrade_hp_per_level` / `upgrade_damage_per_level` 是在 **SLOW 倍率之后** 应用的（通过 `add_modifier` 顺序）
- 因此升级收益不受 SLOW 影响，玩家依然能感受到"升级 = 变强"

### 6.2 cost / supply（game_data.gd COSTS）
- 当前 COSTS 是硬编码的，不随 scheme 变化
- 设计新单位时：性价比 = DPS × HP / cost，建议保持在 0.8-1.2x soldier 范围

### 6.3 bonus_vs_unit_types（克制）
- 克制倍率 (`bonus_vs_multiplier`) 在 damage 计算时直接相乘
- 推荐 1.5x（强克制）或 0.75x（被克制），即 2x 强弱差

---

## 7. 添加新单位的 checklist

- [ ] 确定定位（参考第 2 节）
- [ ] 选 base_HP / base_DMG / base_CD，使应用 SLOW 后自打 TTK 落在第 4.1 节推荐范围
- [ ] 远程单位必须 base_HP ≤ 0.75 × soldier
- [ ] 肉盾必须 DPS ≤ 0.6 × soldier
- [ ] 法师必须 CD ≥ 1.5 × soldier 或有 mana 限制
- [ ] 设置 `damage_reduction`（百分比，0.0-0.5）
- [ ] 在 [test_balance_slow.tscn](../../scenes/maps/test_balance_slow.tscn) 上 A/B 测试，主观确认节奏
