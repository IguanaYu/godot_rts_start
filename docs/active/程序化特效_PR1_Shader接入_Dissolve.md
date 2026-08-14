# PR-1：Shader 接入 + Dissolve

> **目标**：把 `unit_effects.gdshader` 留好的 5 个未接入 uniform 接到代码，再做 Dissolve shader 接到单位死亡。
>
> **预期收益**：单位受击有白闪、死亡有消散、Boss 紫色发光、狂暴/祝福染色——**性价比最高的一个 PR**，几行代码让现有单位活起来。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案 1.1/1.2](../design/程序化特效落地总方案.md) | [调研报告 1.2](../design/程序化动画与特效调研报告.md)

---

## 1. 现状盘点

### shader 现状（[unit_effects.gdshader](../../shaders/unit_effects.gdshader)）

12 个 uniform，**5 个未接入代码**：

| uniform | 功能 | 接入状态 |
|---|---|---|
| `outline_enabled` / `glow_color` / `glow_width` | 选中描边 | ✅ 已接入 |
| `slow_enabled` / `slow_tint` | 减速冰蓝 | ✅ 已接入 |
| `tint_enabled` / `tint_color` / `tint_amount` | 变体调色 | ✅ 已接入 |
| `hit_flash_enabled` / `hit_flash_color` / `hit_flash_amount` | 受击白闪 | ❌ **未接入** |
| `enraged_enabled` / `enraged_tint` | 狂暴红 | ❌ **未接入** |
| `blessed_enabled` / `blessed_tint` | 祝福金 | ❌ **未接入** |
| `boss_glow_enabled` / `boss_glow_color` / `boss_pulse_speed` | Boss 紫光 | ❌ **未接入** |

### 代码现状

- `unit.gd::_init_outline_materials()`（202 行）已为每单位 `material.duplicate()`——**per-instance 隔离没问题**，不会踩"一个受击全部闪"的坑
- `unit.gd::take_damage()`（1173 行）已有完整的伤害结算链（闪避/反特化/护盾抵扣/吸血/飘字/威胁值），**只缺视觉反馈**
- `unit.gd::die()`（1302 行）当前是 `scale → ZERO + queue_free`，**没有 dissolve**
- 护盾抵扣逻辑：`_shield_hp >= final_amount` 时 `final_amount = 0`——**可以靠这个识别"护盾全吸收"**

### shader 内部覆盖关系（重要）

读 shader 代码发现，fragment 里染色顺序是：
```
slow_tint → tint_color → hit_flash → enraged → blessed → boss_glow → outline
```

**问题**：`hit_flash` 用 `mix(col.rgb, hit_flash_color.rgb, hit_flash_amount=0.85)`，会覆盖前面的 slow/tint。但 `enraged/blessed` 在 `hit_flash` 之后，会反过来覆盖白闪。

**实际效果**：狂暴单位受击时，白闪只持续 0.12 秒就被狂暴 tint 覆盖回红色——视觉上感受不到受击。

---

## 2. 决策点

### 决策点 1：hit_flash 如何与 enraged/blessed 共存？

**方案 A**：调整 shader 顺序，hit_flash 放到最后（覆盖一切）
- ✅ 受击瞬间一定看得到白闪
- ❌ 短暂打断狂暴/祝福的染色感

**方案 B**：hit_flash 触发时短暂禁用 enraged/blessed（GDScript 控制）
- ✅ 视觉清晰
- ❌ 代码复杂，要管多个 uniform 的开关

**方案 C**：hit_flash 用 additive 而非 mix（在现有颜色上加白）
- ✅ 不覆盖原有染色
- ❌ 受击瞬间单位会过曝

**方案 D**：hit_flash 改成"轮廓白闪"而非"整体白闪"（只闪描边）
- ✅ 不影响本体染色
- ❌ 视觉效果弱，像素风小单位看不清

**💡 我的建议**：**方案 A**。受击反馈优先级最高，狂暴/祝福是持续状态、短暂打断不影响。调整 shader 里 `hit_flash` 的位置到 `enraged/blessed` 之后即可。

---

### 决策点 2：Dissolve 是替换 scale-to-zero 还是叠加？

**现状**：`die()` 里 `tween_property(self, "scale", Vector2.ZERO, 0.3)` + `queue_free`

**方案 A**：完全替换，dissolve_amount 0→1 + alpha→0
- ✅ 视觉更现代
- ❌ 失去"缩小"的重量感

**方案 B**：叠加，scale→0.7 + dissolve 0→1 同时进行
- ✅ 既有缩小重量感，又有消散细节
- ❌ dissolve 边缘可能在缩小时看不清

**方案 C**：按死因区分——被普通攻击杀死走 scale-to-zero，被技能/Boss 杀走 dissolve
- ✅ 视觉多样性
- ❌ 复杂，且玩家不一定能区分

**方案 D**：按单位类型区分——普通单位走 scale-to-zero（保留现有），召唤物/Boss 走 dissolve
- ✅ 召唤物"消散"符合设定，Boss "消散"有仪式感
- ✅ 普通单位改动小，性能压力低

**💡 我的建议**：**方案 D**。普通单位保持现有 scale-to-zero（性能友好、视觉一致），召唤物（骷髅）和 Boss（巨魔等）走 dissolve。通过 `unit_stats.gd` 加一个 `dissolve_on_death: bool` 字段控制。

---

### 决策点 3：Dissolve shader 放在哪个文件？

**方案 A**：合并进 `unit_effects.gdshader`（加 3 个 uniform：`dissolve_amount` / `dissolve_noise` / `dissolve_edge_color`）
- ✅ 一个 material 管所有效果，不需要切 material
- ✅ 复用现有 per-instance material 机制
- ❌ shader 文件变大，编译略慢

**方案 B**：新建 `dissolve.gdshader`，死亡时切 material
- ✅ shader 解耦
- ❌ 切 material 有开销，且要管 material 还原（虽然死了不用还原）

**方案 C**：在 `unit_effects.gdshader` 加 dissolve，但只在死亡瞬间才需要 noise texture
- ✅ 平时不传 noise texture，死亡时才 set_shader_parameter
- ✅ 性能友好

**💡 我的建议**：**方案 C**。合并进 `unit_effects.gdshader`，平时 `dissolve_amount = 0` 不显示。noise texture 用 NoiseTexture2D + FastNoiseLite 在编辑器生成一次存成 `.tres`，全局共享。

---

### 决策点 4：Boss 发光怎么识别 Boss 单位？

**方案 A**：在 `unit_stats.gd` 加 `is_boss: bool` 字段，资源文件勾选
- ✅ 数据驱动，清晰
- ❌ 要改所有 Boss 单位的 .tres 文件

**方案 B**：用 HP 阈值判断（比如 HP > 500 视为 Boss）
- ✅ 不改资源
- ❌ 阈值武断，可能误判

**方案 C**：用标签系统（`add_to_group("bosses")`）
- ✅ 灵活
- ❌ 要在场景里手动加 group

**方案 D**：用 stats_data.id 字符串匹配（如 `"troll" / "stoneguard"` 等）
- ✅ 不改资源
- ❌ 硬编码 id 容易漏

**💡 我的建议**：**方案 A**。加 `is_boss` 字段，在 `_init_outline_materials()` 里如果 `stats_data.is_boss == true` 就 set `boss_glow_enabled = true`。改动小、清晰、可扩展（未来还能加 `boss_glow_color_override`）。

---

### 决策点 5：狂暴/祝福什么时候触发？

**现状**：shader 有这两个 uniform，但代码里**没有触发逻辑**。需要先确认这两个状态在 gameplay 里由谁触发。

**方案 A**：作为 buff 系统的一部分（已有 `buffs` 数组？需要确认）
- ✅ 走现有 buff 流程
- ❌ 要读 buff 系统代码

**方案 B**：作为技能效果的一部分（比如指挥官技能"祝福"释放时给友军加 blessed）
- ✅ 走技能系统
- ❌ 要等 PR-6 技能视觉

**方案 C**：PR-1 只接入 hit_flash + boss_glow + dissolve，狂暴/祝福延后到 PR-3/PR-6
- ✅ PR-1 范围可控
- ❌ 留尾巴

**💡 我的建议**：**方案 C**。PR-1 聚焦"立刻见效"的三件事：受击白闪 + Boss 发光 + Dissolve。狂暴/祝福的触发逻辑要和 buff/技能系统一起设计，放到 PR-3（UnitVisualFeedback 里接入持续状态）或 PR-6（技能视觉）。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| hit_flash 与染色共存 | A（hit_flash 放 shader 最后）| 受击反馈优先级最高 |
| Dissolve 替换/叠加 | D（按单位类型区分）| 召唤物/Boss 走 dissolve，普通单位保留 scale-to-zero |
| Dissolve shader 位置 | C（合并进 unit_effects.gdshader）| 复用现有 material 机制 |
| Boss 识别 | A（unit_stats.gd 加 is_boss 字段）| 数据驱动 |
| 狂暴/祝福触发 | C（延后到 PR-3/PR-6）| PR-1 聚焦立刻见效 |

---

## 4. 接入点 / 涉及文件

### 修改文件

| 文件 | 改动 |
|---|---|
| [shaders/unit_effects.gdshader](../../shaders/unit_effects.gdshader) | 1. 调整 fragment 里 hit_flash 顺序到 enraged/blessed 之后<br>2. 加 3 个 uniform：`dissolve_amount` / `dissolve_noise` / `dissolve_edge_color`<br>3. 加 dissolve 逻辑（discard + 边缘发光）|
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`take_damage`) | 加 hit_flash 触发：Tween `hit_flash_amount` 0→0.85→0，0.12 秒 |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`die`) | 如果 `stats_data.dissolve_on_death`：走 dissolve 逻辑 |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`_init_outline_materials`) | 如果 `stats_data.is_boss`：set `boss_glow_enabled = true` |
| [scripts/stats/unit_stats.gd](../../scripts/stats/unit_stats.gd) | 加 `is_boss: bool` + `dissolve_on_death: bool` + `hit_flash_color_override: Color` 字段 |

### 新增文件

```
assets/effects/dissolve_noise.tres    # NoiseTexture2D + FastNoiseLite 配置
```

### 修改 .tres 资源

- `resources/stats/troll_stats.tres`（巨魔）：`is_boss = true`
- `resources/stats/skeleton_stats.tres`（骷髅）：`dissolve_on_death = true`
- 其他 Boss/召唤物按需补

---

## 5. 验证标准（沙盒）

PR-1 完成后，在 PR-0 沙盒里：

- [ ] spawn 5 剑士 vs 5 火法师 → 剑士**受击时有明显白闪**（0.12 秒）
- [ ] spawn 巨魔 → 看到紫色**呼吸发光**（脉动）
- [ ] spawn 骷髅 → 死亡时**dissolve 消散**（紫黑边缘 + 0.4 秒）
- [ ] spawn 剑士 → 死亡时保留现有**缩小到 0**（行为不变）
- [ ] 狂暴单位（如果有）受击时，白闪能盖住狂暴红 tint
- [ ] 同屏 20 单位互打，受击白闪不卡顿（profile FPS）

---

## 6. 配置说明

### 让某个单位变成 Boss

在对应 `.tres` 文件里勾选 `is_boss = true`：

```
# resources/stats/troll_stats.tres
is_boss = true
```

Boss 会自动有紫色呼吸发光。如果想要不同颜色（比如死灵法师用绿色），在 stats 加 `boss_glow_color_override: Color`，在 `_init_outline_materials()` 里读这个字段。

### 让某个单位死亡时 dissolve

```
# resources/stats/skeleton_stats.tres
dissolve_on_death = true
```

### 自定义受击闪白颜色

默认白色。某个单位想要特殊颜色（比如烈焰僧侣受击闪红）：

```
# resources/stats/t3_monk_pyro_stats.tres
hit_flash_color_override = Color(1.0, 0.3, 0.0, 1.0)
```

---

## 7. 已知风险

| 风险 | 缓解 |
|---|---|
| hit_flash 触发时多个 Tween 竞争 | 用 meta 标记 Tween（参考 `jelly_effect.gd` 的 `_jelly_tween` 模式），新触发改写旧的 |
| dissolve 噪声纹理在不同分辨率下效果不一致 | 用 NoiseTexture2D 的 `seamless = true` + 固定 size |
| Boss 发光的 9 次采样和 outline 的 9 次采样叠加（18 次）性能 | 像素风单位贴图小，采样开销可控；如真卡可优化为 4 次采样 |
| `is_boss` 单位同时有 outline（被选中）时双层发光 | shader 里 outline 和 boss_glow 用同一个 outer 采样结果，不重复计算（需要重构 shader）|

---

## 8. 后续衔接

- **PR-3**：接入狂暴/祝福染色（作为 UnitVisualFeedback 的持续状态管理）
- **PR-6**：指挥官技能"祝福"释放时给友军加 `blessed_enabled`
- **PR-7**：T3 变体（如狂战士）接入 `enraged_enabled` 作为变体专属视觉
