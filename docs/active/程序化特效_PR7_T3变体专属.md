# PR-7：T3 变体专属视觉（可延后）

> **目标**：10 个 T3 变体的差异化视觉。每个变体在战斗中一眼能认出来。
>
> **状态**：⚠️ **建议延后**。等玩家真正解锁 T3 上手后再做，避免空有视觉没有 gameplay 差异。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案 2.2](../design/程序化特效落地总方案.md)

---

## 1. 现状盘点

### 10 个 T3 变体（玩家方）

| 系 | 变体 | stats_id |
|---|---|---|
| 剑士系 | 狂战士 | berserker |
| 剑士系 | 盾卫 | shieldbearer |
| 剑士系 | 复仇者 | avenger |
| 剑士系 | 决斗者 | duelist |
| 弓兵系 | 神射手 | t3_archer_marksman |
| 弓兵系 | 杀手射手 | t3_archer_slayer |
| 弓兵系 | 减速射手 | t3_archer_slow |
| 枪兵系 | 精英长矛 | t3_lancer_elite |
| 枪兵系 | Boss 杀手 | t3_lancer_bosskiller |
| 僧侣系 | 神圣者 | t3_monk_saint |
| 僧侣系 | 祝福者 | t3_monk_blesser |
| 僧侣系 | 烈焰僧侣 | t3_monk_pyro |

### 现状问题

- T3 变体除了 `display_name`，**没有任何视觉区分**（之前 bug 已修复，但只是修复显示名）
- gameplay 机制：**未知**——需要先核对每个 `t3_*_stats.tres` 看实际有什么字段
- shader 已经有 `enraged_enabled` / `blessed_enabled`，但未接入（PR-1 延后到 PR-3/PR-6）

### 前置依赖

- [ ] PR-1 完成（shader uniform 接入）
- [ ] PR-3 完成（UnitVisualFeedback 组件 + 配置覆盖机制）
- [ ] PR-6 完成（SkillVisualController API）
- [ ] **T3 变体 stats 核对**——确认每个变体的实际 gameplay 机制

---

## 2. 决策点

### 决策点 1：变体差异化通过什么机制实现？

**方案 A**：每个变体改 `unit_stats.gd`（加 `variant_id` / `variant_visual_config` 字段）
- ✅ 数据驱动
- ❌ stats 文件改动大

**方案 B**：每个变体改 `UnitVisualFeedback` 的配置（@export 覆盖）
- ✅ 解耦
- ❌ 配置分散在场景里

**方案 C**：在 UnitVisualFeedback 里维护 `variant_id → config` 映射表
- ✅ 集中管理
- ✅ stats 不动
- ❌ 配置表较大

**方案 D**：方案 C + stats 加 `variant_id` 字段（仅作 key）
- ✅ 数据 + 集中
- ✅ 改动最小

**💡 我的建议**：**方案 D**。`unit_stats.gd` 加 `variant_id: StringName`（仅作 key），UnitVisualFeedback 维护映射表。读 `stats_data.variant_id` 选配置。

---

### 决策点 2：先做哪几个变体？

**方案 A**：10 个全做
- ✅ 完整
- ❌ 工作量大

**方案 B**：先做 4 个最有标志性的（狂战士、神射手、Boss 杀手、烈焰僧侣）
- ✅ 4 系各 1 个代表作
- ✅ 工作量可控

**方案 C**：先做玩家最容易解锁的 3 个（神射手 / 精英长矛 / 祝福者，根据 PR-2 T3 升级 N 选 1）
- ✅ 玩家最先看到
- ❌ 其他变体被冷落

**方案 D**：等玩家解锁 T3 后看哪个变体最受欢迎，再做
- ✅ 用户驱动
- ❌ 等太久

**💡 我的建议**：**方案 B**。先做 4 个代表作验证视觉模板可行性，其他变体按需补。PR-7 本身延后，所以不急。

---

### 决策点 3：变体视觉与战斗可读性如何平衡？

**风险**：10 个变体各搞一套视觉，战场会变花

**方案 A**：每个变体只允许"1 个持续视觉 + 1 个事件视觉"的差异
- ✅ 可控
- ❌ 限制创意

**方案 B**：按兵种系限制颜色谱（剑士系红、弓兵系黄、枪兵系蓝、僧侣系金）
- ✅ 整体协调
- ❌ 变体间不够区分

**方案 C**：方案 A + 复用 PR-3 的状态环（护盾/中毒等通用），变体只加"标志性视觉"
- ✅ 通用状态不被覆盖
- ✅ 变体差异化聚焦

**方案 D**：不限制，让每个变体最大化差异
- ✅ 鲜明
- ❌ 战场混乱

**💡 我的建议**：**方案 C**。每个变体定义"标志性视觉"（1-2 个），通用状态（中毒/护盾）走 PR-3 不变。

---

### 决策点 4：变体专属接入哪个事件？

**现状**：每个变体的 gameplay 触发时机未知

**需要先确认的**（前置任务）：
- 狂战士：HP < 50% 时是否真的有"攻击速度/伤害加成"？
- 盾卫：是否真的有"举盾防御"姿态？
- 复仇者：HP < 30% 时是否有加成？
- 决斗者：1v1 时是否有加成？
- 神射手：蓄力时间是否更长？
- 杀手射手：对英雄/Boss 是否有标记机制？
- 减速射手：命中是否附加减速？
- 精英长矛：对 Boss 是否有标记？
- Boss 杀手：是否有穿甲机制？
- 神圣者：治疗是否真的群体？
- 祝福者：buff 是否给周围友军？
- 烈焰僧侣：是否真的有火焰攻击？

**💡 我的建议**：**PR-7 启动前先做"变体 stats 核对"**——读所有 `t3_*_stats.tres`，整理一份"变体 → 实际 gameplay 机制 → 视觉建议"对照表。**没有 gameplay 支撑的视觉差异不做**。

---

### 决策点 5：变体的颜色策略？

**方案 A**：每个变体一个专属颜色（12 个变体 12 种色）
- ✅ 鲜明
- ❌ 色彩爆炸

**方案 B**：按兵种系分（剑士红、弓兵黄、枪兵蓝、僧侣金）
- ✅ 协调
- ❌ 变体间区分不够

**方案 C**：通用色 + 1 个标志性 accent 色
- ✅ 平衡
- ✅ 通用 tint 保持，变体加 accent

**方案 D**：不变颜色，用形状/动画区分（环的形状、粒子轨迹）
- ✅ 色彩干净
- ❌ 形状在小单位上看不清

**💡 我的建议**：**方案 C**。变体保留兵种系通用 tint，加 1 个标志性 accent（比如狂战士 = 红色描边脉动、神射手 = 金色聚能环）。accent 走 PR-3 的配置覆盖。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| 差异化机制 | D（stats 加 variant_id + 映射表）| 数据驱动 + 集中 |
| 优先做哪些 | B（4 个代表作）| 验证模板 |
| 可读性 | C（每变体 1-2 个标志性视觉）| 通用状态不被覆盖 |
| 接入事件 | 前置：核对 stats | 没机制不做视觉 |
| 颜色策略 | C（通用 tint + accent）| 平衡 |

---

## 4. 4 个代表作的具体方案（待 stats 核对后调整）

### 狂战士（剑士系）

**前提**：stats 有"HP < 50% 攻击加成"机制

**视觉差异化**：
- HP < 50% 时接入 `enraged_enabled`（PR-1 shader）+ 红色描边脉动
- 攻击冲量幅度 +50%（PR-3 配置覆盖：attack_lunge_px = 5 而非默认 3）
- 攻击命中时多一次小幅度前冲（叠加在通用前冲上）

**接入点**：
- [unit.gd](../../scripts/units/unit.gd) 每帧检查 HP ratio，触发 `set_enraged(active)`
- UnitVisualFeedback 配置覆盖

---

### 神射手（弓兵系）

**前提**：stats 有"蓄力时间更长 / 远程加成"

**视觉差异化**：
- 攻击前摇加长 → 蓄力期间脚下金色聚能环（play_charging_circle）
- 箭矢带加强 trail（arrow_trail shader 调宽 + 金色）
- 攻击释放时金色波纹环

**接入点**：
- `_perform_attack()` 前摇期间调 SkillVisualController
- arrow_trail material 覆盖

---

### Boss 杀手（枪兵系）

**前提**：stats 有"对 Boss 加成 / 穿甲"

**视觉差异化**：
- 锁定 Boss 时脚下金色目标环（区别于普通选中的白色）
- 攻击命中时加"贯穿冲击线"（从命中点向攻击反方向画 0.1 秒线）
- 命中粒子用 hit_spark 加量版

**接入点**：
- `_perform_attack()` 检测目标 is_boss，触发目标环
- take_damage 在 attacker 是 Boss 杀手时调特殊命中视觉

---

### 烈焰僧侣（僧侣系）

**前提**：stats 有"火焰攻击"

**视觉差异化**：
- 攻击加火焰 trail（每个动作留 0.2 秒尾迹粒子）
- 命中时火焰爆裂粒子（橙红 + 黄）
- 本体脚下淡橙色能量雾环（持续）

**接入点**：
- UnitVisualFeedback 配置覆盖（持续状态）
- `_perform_attack()` 触发火焰 trail

---

## 5. 接入点 / 涉及文件

### 修改文件

| 文件 | 改动 |
|---|---|
| [scripts/stats/unit_stats.gd](../../scripts/stats/unit_stats.gd) | 加 `variant_id: StringName` 字段 |
| `resources/stats/t3_*_stats.tres`（12 个）| 填 variant_id |
| [scripts/effects/unit_visual_feedback.gd](../../scripts/effects/unit_visual_feedback.gd) | 加 `variant_id → config` 映射表 + 应用逻辑 |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) | HP 阈值/锁定 Boss 等触发点 |

### 前置任务（PR-7 启动前必做）

读所有 `resources/stats/t3_*_stats.tres`，整理对照表：

| 变体 | 实际 gameplay 机制 | 视觉建议是否做 |
|---|---|---|
| 狂战士 | ??? | ??? |
| 神射手 | ??? | ??? |
| ... | ... | ... |

---

## 6. 验证标准（沙盒）

- [ ] 沙盒 spawn 每个变体，看视觉差异
- [ ] 狂战士 HP < 50% → 红描边 + 红色 enraged tint
- [ ] 神射手攻击 → 蓄力环 + 金色箭矢 trail
- [ ] Boss 杀手锁定巨魔 → 金色目标环
- [ ] 烈焰僧侣攻击 → 火焰 trail
- [ ] 通用状态（中毒/护盾）依然能看清，不被变体视觉遮盖
- [ ] 同屏 5 种不同变体战斗，玩家能一眼区分

---

## 7. 配置说明

### variant_id 映射表（UnitVisualFeedback 顶部）

```gdscript
const VARIANT_CONFIGS := {
    &"berserker": {
        "enrage_on_low_hp": true,
        "enrage_threshold": 0.5,
        "attack_lunge_override": 5.0,
    },
    &"marksman": {
        "charging_circle": true,
        "arrow_trail_color": Color(1.0, 0.84, 0.0),
    },
    &"bosskiller": {
        "target_boss_ring": true,
        "pierce_line_on_hit": true,
    },
    &"pyro_monk": {
        "flame_trail": true,
        "hit_particle_override": "flame_burst",
    },
    # ... 其他变体
}
```

### 添加新变体视觉

1. 在 `resources/stats/` 对应 .tres 设 `variant_id`
2. 在 UnitVisualFeedback 的 VARIANT_CONFIGS 加配置
3. 实现配置对应的视觉逻辑
4. 沙盒验证

---

## 8. 已知风险

| 风险 | 缓解 |
|---|---|
| 变体 stats 没 gameplay 机制支持，视觉做了也没触发 | **前置任务必做**：先核对 stats |
| 同屏多变体视觉混乱 | 限制每变体 1-2 个标志性视觉 |
| 变体视觉与 PR-3 通用状态冲突 | 通用状态优先（中毒/护盾），变体视觉退让 |
| 变体配色与敌方阵营色（红）冲突 | 变体 accent 避开纯红，用橙/金/紫 |
| PR-7 延后期间变体 gameplay 调整 | 视觉配置走 variant_id，stats 改了不影响视觉代码 |

---

## 9. 何时启动 PR-7

建议触发条件（任一）：
1. 玩家正式解锁 T3 并使用过变体
2. 有玩家反馈"变体分不清"
3. 游戏接近发布，需要视觉差异化作为卖点

**不建议**在 PR-1~6 还没完成时就启动 PR-7（依赖太多）。

---

## 10. 后续衔接

- **PR-1**：依赖 shader uniform 接入（enraged/blessed）
- **PR-3**：依赖 UnitVisualFeedback 的配置覆盖机制
- **PR-6**：依赖 SkillVisualController（神射手聚能环、烈焰僧侣火焰 trail 等）
- **未来**：敌方单位模板（总方案第 3 章）可以复用 PR-7 的"标志性视觉"思路
