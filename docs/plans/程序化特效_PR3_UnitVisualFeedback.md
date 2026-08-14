# PR-3：UnitVisualFeedback 组件

> **目标**：实现单位视觉反馈组件，接入受击位移、攻击冲量、护盾环、持续状态标记（减速/中毒/护盾/狂暴/祝福）。
>
> **预期收益**：单位战斗有"重量感"，状态可视化，玩家不看 HP 条也能读懂战况。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案 2.1](../design/程序化特效落地总方案.md) | [单位动态设计稿](../design/单位动态与状态视觉设计方案.md)

---

## 1. 现状盘点

### 已有单位视觉（不用改）

- 出生光柱（`spawn_effect.tscn`）
- 死亡缩小（`die()` 里 scale→ZERO）
- 选中描边（`outline_enabled`）
- 减速 tint（`slow_enabled`，但**没有地面环**）
- 伤害飘字（`floating_text.gd`）
- 治疗特效（`heal_effect.tscn`）
- 精英光环（`elite_aura.gd`）
- 连锁闪电/锥形 AoE（`_show_chain_effect` / `_show_cone_effect`）

### 缺失的单位视觉

| 状态 | 缺失内容 |
|---|---|
| 攻击前摇/释放 | 无冲量（剑士/枪兵不前探，弓兵不后坐）|
| 普通受击 | hit_flash 在 PR-1 接入，但**没有受击位移** |
| 护盾承伤 | 无蓝白环区分"没掉血" |
| 减速 | 只有 tint，**没有地面蓝色弧** |
| 中毒 | **完全没有视觉**（只有逻辑层 `_poison_dps`）|
| 护盾存在 | **没有持续视觉**（只有飘字提示）|
| 狂暴 | shader uniform 有，**未接入** |
| 祝福 | shader uniform 有，**未接入** |

### 关键代码位置

- [scripts/units/unit.gd:1173](../../scripts/units/unit.gd) `take_damage()` — 受击入口，护盾抵扣逻辑在这里
- [scripts/units/unit.gd:991](../../scripts/units/unit.gd) `_perform_attack()` — 攻击入口
- [scripts/units/unit.gd:1579](../../scripts/units/unit.gd) `apply_slow()` — 减速入口
- [scripts/units/unit.gd:1585](../../scripts/units/unit.gd) `apply_poison()` — 中毒入口
- [scripts/units/unit.gd:1749](../../scripts/units/unit.gd) `set_shield_hp()` — 护盾入口

### 关键约束（来自单位方案）

> **禁止对 `CharacterBody2D` 本体做攻击或受击缩放/位移**：那会连带碰撞、选择圈、血条和寻路表现。所有冲量只写入 `BodySprite.position` / `BodySprite.scale`。

---

## 2. 决策点

### 决策点 1：冲量用什么实现？

**方案 A**：每次攻击/受击创建 Tween
- ✅ 简单
- ❌ 大量单位同屏时 Tween 爆量

**方案 B**：组件内部插值（_process 里手算）
- ✅ 性能好，无 Tween 开销
- ✅ 多个冲量可叠加（攻击 + 受击同时）
- ❌ 代码量更大

**方案 C**：单 Tween + 重启（每次新冲量 kill 旧 Tween）
- ✅ 简单
- ❌ 攻击 + 受击同时只能保留一个

**方案 D**：分类型多 Tween（一个攻击 Tween，一个受击 Tween）
- ✅ 可叠加
- ❌ Tween 管理复杂

**💡 我的建议**：**方案 B**。组件维护"持续状态 offset/scale"和"短事件 offset/scale"，每帧相加后写入 BodySprite。参考单位方案 "内部合成规则"：

```
最终位置 = base_position + move_settle_offset + attack_offset + hit_offset
最终缩放 = base_scale × idle_scale × attack_scale × hit_scale
```

### 决策点 2：地面环怎么画？

**方案 A**：UnitVisualFeedback._draw() 自己画
- ✅ 节省节点
- ✅ 颜色/形状完全可控
- ❌ _draw 不能动画（要 queue_redraw）

**方案 B**：子节点（Line2D / Polygon2D）画环
- ✅ 可以用 Tween 动画
- ❌ 多状态多子节点，管理麻烦

**方案 C**：用 NinePatchRect / Sprite2D 贴图环
- ✅ 美观
- ❌ 需要贴图资源

**方案 D**：_draw 画 + 每帧 queue_redraw（仅在状态变化或呼吸动画时）
- ✅ 灵活
- ✅ 性能可控（不动画时不 redraw）

**💡 我的建议**：**方案 D**。地面环用 `_draw` 画圆弧/点环，呼吸效果通过 `queue_redraw()`（仅在 active 时每帧 redraw，inactive 时不 redraw）。参考单位方案"性能规则"。

---

### 决策点 3：地面环优先级（多状态同时）

**现状**：单位可能同时有护盾 + 减速 + 中毒 + 祝福

**方案 A**：全部画（最多 4 层）
- ✅ 信息完整
- ❌ 视觉混乱

**方案 B**：按优先级只画一层（参考单位方案：护盾 > 中毒 > 减速 > 增益）
- ✅ 清晰
- ❌ 信息丢失

**方案 C**：分两层画（内环 + 外环），每层按优先级取一个
- ✅ 平衡
- ✅ 可读

**方案 D**：护盾走外环（大半径），中毒/减速走内环（小半径），buff 走 tint（不画环）
- ✅ 信息分离
- ✅ 视觉层次清晰

**💡 我的建议**：**方案 D**。护盾 = 外环（半径 22）、中毒/减速 = 内环（半径 16）、狂暴/祝福 = tint（PR-1 已接入 shader）。这样最多画 2 个环 + tint，视觉不混乱。

---

### 决策点 4：攻击冲量方向怎么算？

**现状**：`_perform_attack()` 里有 `attack_target`，可以拿到方向

**方案 A**：朝目标方向前探
- ✅ 自然
- ❌ 远程单位（弓兵）前探会很怪

**方案 B**：近战朝目标前探，远程朝目标反方向后坐
- ✅ 符合直觉（近战扑、弓兵反作用力）
- ❌ 需要区分 is_ranged

**方案 C**：所有单位都朝目标方向前探，远程前探量小（1px）
- ✅ 简单
- ❌ 远程视觉不对

**方案 D**：按 unit_type 配置（剑士 3px 前探、枪兵 4px 前探、弓兵 2px 后坐、僧侣缩放脉冲）
- ✅ 兵种差异化
- ❌ 配置表更复杂

**💡 我的建议**：**方案 D**。按 unit_type 配置，参考单位方案"兵种动作配置"表：

| 兵种 | 前探 | 后坐 | 备注 |
|---|---|---|---|
| SOLDIER | 3px | - | 朝目标 |
| ARCHER | - | 2px | 朝反方向 |
| LANCER | 4px | - | 朝目标 |
| MONK | - | - | scale 脉冲（蓄力→释放）|

---

### 决策点 5：受击位移方向怎么算？

**现状**：`take_damage(amount, attacker)` 有 attacker 参数

**方案 A**：朝 attacker→self 反方向偏移（被打退）
- ✅ 符合物理
- ❌ 没有 attacker 时（比如掉血光环）没方向

**方案 B**：朝 unit 面朝方向反方向偏移
- ✅ 总有方向
- ❌ 不符合物理

**方案 C**：有 attacker 走方案 A，无 attacker 走"向上小跳"（通用反馈）
- ✅ 兜底
- ✅ 符合直觉

**💡 我的建议**：**方案 C**。优先用 attacker 方向，无 attacker 时走"向上 2px + scale 压扁"的通用反馈。

---

### 决策点 6：护盾承伤怎么识别？

**现状**：`take_damage()` 里 `_shield_hp >= final_amount` 时 `final_amount = 0`

**方案 A**：在 take_damage 里加一个 `shield_absorbed: bool` 局部变量，传给 UnitVisualFeedback
- ✅ 清晰
- ❌ 要改 take_damage 签名

**方案 B**：组件自己比较"shield_hp before/after"
- ✅ 不改签名
- ❌ 组件要缓存上一帧 shield_hp

**方案 C**：在 take_damage 内部直接调组件 API，区分调用
- ✅ 直接
- ❌ take_damage 耦合组件

**💡 我的建议**：**方案 C**。take_damage 内部判断护盾是否全吸收，分别调用 `play_hit(from_dir, false)` 或 `play_hit(from_dir, true)`。take_damage 已经知道护盾状态，没必要让组件再猜。

---

### 决策点 7：狂暴/祝福何时触发？

**现状**：shader 有 uniform，但代码没触发逻辑

**方案 A**：作为 buff 系统的一部分，buff 添加/移除时调组件 set_enraged/set_blessed
- ✅ 走现有系统
- ❌ 要确认 buff 系统是否存在/如何工作

**方案 B**：PR-3 只做基础设施（API 提供），实际触发留给 PR-6 技能视觉
- ✅ PR-3 范围可控
- ❌ 接口可能设计错

**方案 C**：先 hardcode 一个测试触发点（比如 HP < 50% 触发狂暴），验证视觉
- ✅ 快速验证
- ❌ hardcode 代码要删

**💡 我的建议**：**方案 B**。PR-3 提供 `set_enraged(active)` / `set_blessed(active)` API，但不写触发逻辑。PR-6 接入实际技能/buff 触发。这样接口设计可以先出来，PR-6 不会卡。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| 冲量实现 | B（_process 内部插值）| 性能 + 可叠加 |
| 地面环画法 | D（_draw + 按需 redraw）| 灵活 + 性能可控 |
| 状态环优先级 | D（护盾外环/中毒内环/buff 走 tint）| 视觉层次清晰 |
| 攻击冲量方向 | D（按 unit_type 配置）| 兵种差异化 |
| 受击位移方向 | C（attacker 方向 + 无 attacker 兜底）| 物理正确 + 兜底 |
| 护盾承伤识别 | C（take_damage 内部分流调用）| 直接清晰 |
| 狂暴/祝福触发 | B（PR-3 只做 API，PR-6 接入）| 范围可控 |

---

## 4. 接入点 / 涉及文件

### 新增文件

```
scripts/effects/unit_visual_feedback.gd    # 新组件
```

### 修改文件

| 文件 | 改动 |
|---|---|
| [scenes/units/unit.tscn](../../scenes/units/unit.tscn) | 加 UnitVisualFeedback 子节点 |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`_ready`) | 调用 `unit_visual_feedback.configure(body_sprite, material, unit_type, seed)` |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`_physics_process`) | 传 `velocity` + `is_running` 给组件 |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`_perform_attack`) | 调用 `play_attack(aim_direction, is_ranged)` |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`take_damage`) | 护盾分流后调 `play_hit(from_direction, shield_absorbed)` |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`apply_slow` / 减速到期) | 调 `set_slow(active)` |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`apply_poison` / 中毒到期) | 调 `set_poison(active)` |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`set_shield_hp`) | 调 `set_shield(active, ratio)` |
| [scripts/units/unit.gd](../../scripts/units/unit.gd) (`die`) | 调 `stop_all()` |

---

## 5. 组件接口设计

```gdscript
class_name UnitVisualFeedback
extends Node2D

# === 配置 ===
func configure(body: Sprite2D, material: ShaderMaterial, unit_type: int, seed: int) -> void

# === 持续状态 ===
func set_motion(velocity: Vector2, is_running: bool) -> void
func set_slow(active: bool) -> void
func set_poison(active: bool) -> void
func set_shield(active: bool, ratio: float = 1.0) -> void
func set_enraged(active: bool) -> void       # PR-6 接入
func set_blessed(active: bool) -> void       # PR-6 接入

# === 短事件 ===
func play_spawn() -> void
func play_attack(aim_direction: Vector2, is_ranged: bool) -> void
func play_hit(from_direction: Vector2, shield_absorbed: bool) -> void
func play_heal() -> void

# === 控制 ===
func stop_all() -> void
```

### 内部状态合成

```gdscript
# 每帧 _process 里合成最终 transform
var final_pos := base_position + move_settle + attack_offset + hit_offset
var final_scale := base_scale * idle_scale * attack_scale * hit_scale
body_sprite.position = final_pos
body_sprite.scale = final_scale

# _draw 画地面环（按需 queue_redraw）
```

---

## 6. 验证标准（沙盒）

- [ ] spawn 5 剑士 vs 5 敌方 → 剑士**攻击时有前探冲量**（3px，0.1 秒）
- [ ] 弓兵攻击时**有后坐**（2px）
- [ ] 剑士**受击时白闪 + 朝被打方向偏移 2px**（PR-1 的 hit_flash + PR-3 的位移）
- [ ] 僧侣治疗时**身体向上提 2px**
- [ ] 给单位加护盾 → 脚下**蓝白外环呼吸**（1.2 秒一次）
- [ ] 护盾承伤时 → **不闪白，画蓝白内环扩散**
- [ ] 减速单位脚下有**蓝色弧**
- [ ] 中毒单位脚下有**3 个绿色点环**
- [ ] 同屏 20 单位战斗，无 Tween 爆量，FPS 稳定
- [ ] 单位死亡后所有表现停止（stop_all）

---

## 7. 配置说明

### Inspector 可调参数（特殊单位覆盖用）

```
attack_lunge_px：        近战前探距离，默认按 unit_type
ranged_recoil_px：       远程后坐距离，默认按 unit_type
hit_push_px：            受击位移，默认 2
body_pulse_strength：    攻击/治疗缩放，0.005 ~ 0.02
status_ring_enabled：    是否显示地面状态环（默认 true）
status_ring_radius：     默认 16-22
```

普通单位不需要在 Inspector 配置，按 unit_type 自动选默认值。只有特殊单位（Boss / 召唤物）才覆盖。

---

## 8. 已知风险

| 风险 | 缓解 |
|---|---|
| BodySprite 初始 position/scale 被 _process 覆盖 | configure() 里缓存 base 值；其他系统不要直接改 BodySprite.position |
| 单位移动时冲量叠加导致视觉漂移 | move_settle 只在"刚停止"时触发一次，不是持续 |
| 多个受击同时触发（AOE） | hit_offset 用最新值覆盖（不累加）|
| 状态环 _draw 性能（50 单位 × 2 环）| inactive 状态不 redraw；可加"远离镜头时关闭" |
| 狂暴/祝福 tint 与 hit_flash 冲突 | PR-1 已调整 shader 顺序（hit_flash 最后）|
| `set_shield(active, ratio)` 频繁调用 | 内部判断 active 变化时才重画 |

---

## 9. 后续衔接

- **PR-1**：依赖 hit_flash 已接入（受击白闪）
- **PR-2**：依赖粒子池（hit_spark / heal_orb 走池）
- **PR-6**：技能"祝福"释放时调 `set_blessed(true)`
- **PR-7**：T3 变体（如狂战士）通过覆盖配置实现差异化视觉
