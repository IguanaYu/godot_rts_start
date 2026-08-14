# PR-6：指挥官技能视觉升级

> **目标**：8 个指挥官技能从"只有飘字"升级到完整视觉（释放瞬间 + 持续效果）。
>
> **预期收益**：技能释放有"仪式感"，玩家不看 cooldown 条也知道刚发生了什么。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案 2.5](../design/程序化特效落地总方案.md)

---

## 1. 现状盘点

### 8 个技能脚本位置

| 技能 | 脚本 | 现状 |
|---|---|---|
| 嘲讽 | [scripts/skills/skill_effects/taunt_effect.gd](../../scripts/skills/skill_effects/taunt_effect.gd) | 仅飘字 |
| 闪现 | [scripts/skills/skill_effects/blink_effect.gd](../../scripts/skills/skill_effects/blink_effect.gd) | 飘字 + alpha |
| 隐身 | [scripts/skills/skill_effects/stealth_effect.gd](../../scripts/skills/skill_effects/stealth_effect.gd) | 飘字 + alpha |
| 劝化 | [scripts/skills/skill_effects/convert_effect.gd](../../scripts/skills/skill_effects/convert_effect.gd) | 飘字 |
| 护盾 | [scripts/skills/skill_effects/shield_effect.gd](../../scripts/skills/skill_effects/shield_effect.gd) | 飘字 |
| 召唤 | [scripts/skills/skill_effects/summon_effect.gd](../../scripts/skills/skill_effects/summon_effect.gd) | 飘字 + 召唤弹 |
| 治疗 | [scripts/skills/skill_effects/heal_effect.gd](../../scripts/skills/skill_effects/heal_effect.gd) | 飘字 + HealEffect |
| 驱散 | [scripts/skills/skill_effects/dispel_effect.gd](../../scripts/skills/skill_effects/dispel_effect.gd) | 飘字 |

### 可复用辅助工具（commander_skill/ 目录）

- [area_indicator.gd](../../scripts/commander_skill/area_indicator.gd) — 范围指示器
- [circle_renderer.gd](../../scripts/commander_skill/circle_renderer.gd) — 圆环绘制
- [persistent_zone.gd](../../scripts/commander_skill/persistent_zone.gd) — 持续区域
- [target_preview.gd](../../scripts/commander_skill/target_preview.gd) — 目标预览

### 已有特效可复用

- `spawn_effect.tscn` — 出生光柱（召唤可参考）
- `heal_effect.tscn` — 治疗光环
- `outpost_capture_ring.tscn` — 据点环（持续区域可参考）

---

## 2. 决策点

### 决策点 1：技能视觉代码放在哪？

**方案 A**：每个技能的视觉写在自己的 `*_effect.gd` 里
- ✅ 解耦
- ❌ 8 个文件都要改，共性代码重复

**方案 B**：抽一个 `SkillVisualController`（Autoload 或工具类），每个技能调它的 API
- ✅ 共性代码复用（波纹/光柱/环扩散）
- ❌ 多一层抽象

**方案 C**：每个技能视觉独立 `.tscn` 场景，技能脚本调 spawn
- ✅ 可视化编辑
- ❌ 资源管理复杂

**方案 D**：方案 B + 复用 PR-2 粒子池 + PR-5 后处理
- ✅ 共性 + 复用基础设施
- ✅ 工作量最小

**💡 我的建议**：**方案 D**。新增 `SkillVisualController`（Autoload），提供：
- `play_release_ripple(pos, color)` — 释放波纹环
- `play_light_pillar(pos, color, duration)` — 光柱
- `play_charging_circle(pos, color, duration)` — 蓄力环
- `play_screen_impact(pos, strength)` — 屏幕冲击（转发 PR-5）

每个技能脚本调这些 API + 调粒子池。

---

### 决策点 2：嘲讽的范围内视觉怎么做？

**现状**：嘲讽影响周围敌人强制攻击施法者，但范围不可见

**方案 A**：施法者脚下持续画红环（表示影响范围）
- ✅ 持续可见
- ❌ 嘲讽时间短，画完就消失，体验差

**方案 B**：释放瞬间扩散红波纹 + 被嘲讽敌人头顶感叹号
- ✅ 瞬间 + 标记
- ✅ 玩家看得出谁被嘲讽了
- ❌ 叹号要新增资源或用 _draw

**方案 C**：方案 B + 持续期间被嘲讽敌人红色描边
- ✅ 双重反馈
- ❌ 复用 PR-3 的 outline 系统

**方案 D**：方案 B + 被嘲讽敌人朝施法者有一条红线（复用 aggro_line）
- ✅ 直观"被迫攻击"
- ❌ 改 aggro_line 颜色逻辑

**💡 我的建议**：**方案 B + D**。释放瞬间红波纹（SkillVisualController.play_release_ripple），被嘲讽敌人复用 aggro_line 改红色指向施法者。不画头顶叹号（_draw 太小看不清）。

---

### 决策点 3：闪现的"起点消散 + 终点出现"怎么做？

**现状**：blink_effect.gd 做 alpha 渐变（旧位置消失 + 新位置出现）

**方案 A**：保留现有 alpha + 加 dissolve（PR-1 已有）
- ✅ 复用 PR-1
- ❌ alpha 和 dissolve 视觉重复

**方案 B**：完全替换为 dissolve（去掉 alpha 渐变）
- ✅ 视觉更现代
- ❌ 改动大

**方案 C**：起点 dissolve 消散 + 终点 dissolve 出现，中间 0.1 秒紫色光迹
- ✅ 完整"传送"体验
- ❌ 光迹要新写

**方案 D**：方案 C + 起终点都加紫色波纹环
- ✅ 仪式感
- ✅ 复用 SkillVisualController

**💡 我的建议**：**方案 D**。起点：dissolve 消散 + 紫色波纹。终点：紫色波纹 + dissolve 出现。中间紫色光迹用 beam_effect.gd（已有）改色。

---

### 决策点 4：隐身进入/退出怎么表现？

**现状**：stealth_effect.gd 做 alpha 0→0.5 渐变

**方案 A**：保留现有 alpha + 加横向扭曲（shader 后处理）
- ✅ "光化解构"感
- ❌ 后处理 shader 只作用全屏，不单独作用单位

**方案 B**：单位本身的 shader 加 stealth dissolve（横向条纹消散）
- ✅ 单单位效果
- ❌ unit_effects.gdshader 又加复杂度

**方案 C**：保留现有 alpha + 单位周围一圈紫色波纹消散
- ✅ 简单
- ✅ 复用 SkillVisualController

**方案 D**：方案 C + 进入隐身瞬间施法者轻微 scale 缩小（"消失感"）
- ✅ 双重反馈
- ❌ 改 unit scale

**💡 我的建议**：**方案 C**。隐身进入 = alpha 渐变 + 一圈紫色波纹环。退出 = 反向波纹 + alpha 恢复。不做 shader 扭曲（全屏 shader 作用不到单单位）。

---

### 决策点 5：劝化的引导光柱怎么做？

**现状**：convert_effect.gd 是引导类技能（持续 N 秒后转化）

**方案 A**：施法者到目标之间画持续金色光柱（beam_effect 改色）
- ✅ 直观"引导"
- ❌ 光柱位置随双方移动变化

**方案 B**：目标单位周围金色环慢慢收紧（进度环）
- ✅ 进度可视
- ❌ 环收紧视觉太"陷阱"

**方案 C**：方案 A + 目标头顶进度条
- ✅ 双重反馈
- ❌ 进度条新写

**方案 D**：方案 A + 目标接入 blessed tint（金色）逐渐加深
- ✅ "被感化"的视觉演化
- ✅ 复用 PR-1 shader

**💡 我的建议**：**方案 D**。引导期间施法者→目标金色光柱（复用 beam_effect 改色），目标 blessed_enabled 随着 progress 0→0.4 渐变。成功瞬间 → blessed 完全开启 + 金色环扩散。

---

### 决策点 6：召唤的紫色主题如何区分玩家方蓝色？

**现状**：summon_effect.gd 用 summon_projectile.tscn + 出生光柱（默认蓝色）

**方案 A**：召唤弹和出生光柱改成紫色变体
- ✅ 与玩家方蓝色区分
- ❌ 要新建紫色版本资源

**方案 B**：复用现有 spawn_effect + 用 tint（已经有 tint_enabled）
- ✅ 不新建资源
- ❌ tint 不会改光柱颜色（只改单位本体）

**方案 C**：spawn_effect 加 color 参数，紫色调用方传紫色
- ✅ 资源复用 + 参数化
- ❌ 要改 spawn_effect.gd 接口

**方案 D**：方案 C + 骷髅走 dissolve 反向出现（紫黑边缘）
- ✅ 完整召唤体验
- ✅ 复用 PR-1

**💡 我的建议**：**方案 D**。spawn_effect.gd 加 `color: Color` 参数（默认蓝），召唤时传紫色。骷髅出生用 dissolve（PR-1 已加 dissolve_on_death，反向播放做出生）。

---

### 决策点 7：护盾的范围效果如何展示？

**现状**：shield_effect.gd 给范围内友军加 shield_hp

**方案 A**：施法者释放时蓝白环扩散，受影响单位走 PR-3 的护盾环
- ✅ 复用 PR-3
- ✅ 释放瞬间有反馈
- ❌ 范围不可见（不知道影响了谁）

**方案 B**：方案 A + 释放瞬间所有受影响单位同时闪一下蓝白
- ✅ 清晰"被加护盾"
- ❌ 多单位同时闪可能乱

**方案 C**：方案 A + 施法者脚下持续画范围圈（直到护盾结束）
- ✅ 范围可见
- ❌ 持续圈遮挡战场

**💡 我的建议**：**方案 A**。释放瞬间蓝白环扩散，受影响单位走 PR-3 护盾环（已经有持续视觉）。不画范围圈（避免遮挡）。

---

### 决策点 8：治疗的"群体"反馈怎么做？

**现状**：heal_effect.gd + HealEffect 特效，但只对单体

**方案 A**：施法者头顶金色十字光环 + 每个目标单独 HealEffect
- ✅ 复用现有
- ❌ 多目标时全屏 HealEffect 可能乱

**方案 B**：方案 A + 每个目标脚下闪一次金色环
- ✅ 标记"谁被治疗了"
- ❌ 多目标时环乱

**方案 C**：施法者头顶金色十字光环 + 范围内所有目标接入 blessed tint 持续 0.5 秒
- ✅ 整体感强
- ✅ 复用 PR-1 shader

**方案 D**：方案 A + heal_orb 粒子从施法者飘向每个目标
- ✅ "治疗传递"视觉
- ❌ 粒子轨迹复杂

**💡 我的建议**：**方案 A 起步**。施法者头顶十字光环 + 每个目标单独 HealEffect（已有）。如果太乱，迭代为方案 C（blessed tint 替代 HealEffect）。

---

### 决策点 9：驱散的"清除 buff"视觉？

**现状**：dispel_effect.gd 清除目标 buff，但无视觉

**方案 A**：白色清除波纹（从施法者扩散）
- ✅ "净化"感
- ✅ 复用 SkillVisualController

**方案 B**：方案 A + 目标身上所有 buff 视觉瞬间消失（enraged/blessed/poison/slow 全部停）
- ✅ 完整反馈
- ❌ 要联动 PR-3 的 set_* API

**方案 C**：方案 A + 目标单位接入 hit_flash（白色，0.1 秒）
- ✅ "净化闪光"
- ✅ 复用 PR-1

**💡 我的建议**：**方案 B + C**。白色波纹（释放瞬间）+ 目标接入白色 hit_flash + 停所有 buff 视觉（调 unit_visual_feedback 的 set_slow(false) / set_poison(false) / set_enraged(false) 等）。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| 视觉代码位置 | D（SkillVisualController + 粒子池 + 后处理）| 复用基础设施 |
| 嘲讽范围 | B+D（红波纹 + 红色 aggro_line）| 复用现有 |
| 闪现 | D（dissolve + 紫波纹 + 光迹）| 完整体验 |
| 隐身 | C（alpha + 紫波纹）| 不做全屏扭曲 |
| 劝化引导 | D（金光柱 + blessed 渐变）| 进度可视 |
| 召唤主题 | D（spawn_effect 加 color 参数 + dissolve 出现）| 区分玩家方 |
| 护盾范围 | A（释放环 + 走 PR-3）| 复用 |
| 治疗群体 | A（十字光环 + 复用 HealEffect）| 起步简单 |
| 驱散净化 | B+C（白波纹 + hit_flash + 停 buff）| 完整反馈 |

---

## 4. 接入点 / 涉及文件

### 新增文件

```
scripts/skills/skill_visual_controller.gd    # Autoload 单例（或 skill_effects 模块）
```

### 修改文件

| 文件 | 改动 |
|---|---|
| [project.godot](../../project.godot) | 注册 SkillVisualController Autoload（如果走 Autoload）|
| [scripts/skills/skill_effects/taunt_effect.gd](../../scripts/skills/skill_effects/taunt_effect.gd) | 释放调 `play_release_ripple(pos, RED)`，被嘲讽敌人走红色 aggro_line |
| [scripts/skills/skill_effects/blink_effect.gd](../../scripts/skills/skill_effects/blink_effect.gd) | 起点终点调 dissolve（PR-1）+ play_release_ripple(PURPLE) + beam_effect 紫色光迹 |
| [scripts/skills/skill_effects/stealth_effect.gd](../../scripts/skills/skill_effects/stealth_effect.gd) | 进入/退出调 play_release_ripple(PURPLE) |
| [scripts/skills/skill_effects/convert_effect.gd](../../scripts/skills/skill_effects/convert_effect.gd) | 引导期间 beam_effect 金色 + 目标 blessed_amount 按 progress 渐变 |
| [scripts/skills/skill_effects/shield_effect.gd](../../scripts/skills/skill_effects/shield_effect.gd) | 释放调 play_release_ripple(BLUE_WHITE) + 受影响单位走 PR-3 护盾环 |
| [scripts/skills/skill_effects/summon_effect.gd](../../scripts/skills/skill_effects/summon_effect.gd) | spawn_effect 传紫色 color + 骷髅 dissolve 反向出现 |
| [scripts/skills/skill_effects/heal_effect.gd](../../scripts/skills/skill_effects/heal_effect.gd) | 施法者头顶 play_light_pillar(GOLD, cross_shape) + 每个目标 HealEffect |
| [scripts/skills/skill_effects/dispel_effect.gd](../../scripts/skills/skill_effects/dispel_effect.gd) | 释放 play_release_ripple(WHITE) + 目标 hit_flash + 停所有 buff 视觉 |
| [scripts/effects/spawn_effect.gd](../../scripts/effects/spawn_effect.gd) | 加 `color: Color` 参数（默认蓝）|

---

## 5. SkillVisualController API 设计

```gdscript
class_name SkillVisualController
extends Node2D

# 释放波纹环（地面 _draw，0.3 秒扩散消失）
func play_release_ripple(world_pos: Vector2, color: Color, max_radius: float = 80.0) -> void

# 光柱（持续 N 秒，可指定形状 circle / cross / pillar）
func play_light_pillar(world_pos: Vector2, color: Color, duration: float, shape: String = "pillar") -> void

# 蓄力环（持续到 finish 调用，进度 0-1）
func play_charging_circle(world_pos: Vector2, color: Color) -> ChargingCircleHandle

# 屏幕冲击（转发 PR-5 PostProcessController）
func play_screen_impact(world_pos: Vector2, strength: float = 5.0) -> void
```

---

## 6. 8 技能视觉规范表

| 技能 | 释放瞬间 | 持续效果 | 复用资源 |
|---|---|---|---|
| **嘲讽** | 红波纹环扩散 | 被嘲讽敌人红色 aggro_line | area_indicator, aggro_line |
| **闪现** | 紫 dissolve 消散 + 紫波纹 | 紫色 beam 光迹 | PR-1 dissolve, beam_effect |
| **隐身** | 紫波纹环 + alpha 渐变 | 半透明 | play_release_ripple |
| **劝化** | （无）| 金 beam 光柱 + 目标 blessed 渐变 | beam_effect, PR-1 blessed |
| **护盾** | 蓝白波纹环 | PR-3 护盾环（受影响单位）| play_release_ripple, PR-3 |
| **召唤** | 紫光柱（spawn_effect 改色）| 骷髅 dissolve 反向出现 | spawn_effect, PR-1 dissolve |
| **治疗** | 金十字光环 + heal_orb 粒子 | 每个目标 HealEffect | play_light_pillar, heal_effect.tscn |
| **驱散** | 白波纹 + 目标 hit_flash | 停所有 buff 视觉 | play_release_ripple, PR-1 hit_flash, PR-3 set_* |

---

## 7. 验证标准（沙盒）

PR-0 沙盒需要扩展加技能释放按钮：

- [ ] 沙盒左面板加"技能"tab（8 个按钮）
- [ ] 点击"嘲讽" → 施法者脚下红波纹 + 周围敌人朝施法者拉红线
- [ ] 点击"闪现" + 点击目标点 → 起点消散 + 终点出现 + 紫光迹
- [ ] 点击"隐身" → 单位半透明 + 紫波纹
- [ ] 点击"劝化" + 点目标 → 金色光柱连接 + 目标渐变金 tint
- [ ] 点击"护盾" → 蓝白波纹 + 周围友军脚下蓝白环
- [ ] 点击"召唤" → 紫光柱 + 骷髅 dissolve 出现
- [ ] 点击"治疗" → 金十字 + 范围内友军 HealEffect
- [ ] 点击"驱散" → 白波纹 + 目标白闪 + buff 视觉消失
- [ ] 释放任意技能时触发 `PostProcessController.shake_screen(strength=5)`

---

## 8. 配置说明

### 技能颜色常量

在 `skill_visual_controller.gd` 顶部：

```gdscript
const COLOR_TAUNT := Color(1.0, 0.2, 0.2)        # 红
const COLOR_BLINK := Color(0.6, 0.2, 0.9)        # 紫
const COLOR_STEALTH := Color(0.6, 0.2, 0.9)      # 紫
const COLOR_CONVERT := Color(1.0, 0.84, 0.25)    # 金
const COLOR_SHIELD := Color(0.5, 0.8, 1.0)       # 蓝白
const COLOR_SUMMON := Color(0.6, 0.2, 0.9)       # 紫
const COLOR_HEAL := Color(1.0, 0.84, 0.25)       # 金
const COLOR_DISPEL := Color(1.0, 1.0, 1.0)       # 白
```

### 加新技能视觉

1. 在 `skill_visual_controller.gd` 加 API（如果现有 API 不够）
2. 在对应 `*_effect.gd` 调用 API
3. 沙盒加按钮验证

---

## 9. 已知风险

| 风险 | 缓解 |
|---|---|
| 8 个技能同时改，bug 多 | 按技能逐个迁移（先嘲讽 → 闪现 → ...）|
| SkillVisualController 是 Autoload 还是模块 | 建议先做普通 Node2D 工具类，挂 main.gd；如果切场景丢状态再升 Autoload |
| 劝化的 beam_effect 跟随移动单位 | beam 每帧 update 两端位置（已有逻辑可能支持）|
| 召唤骷髅的 dissolve 反向和死亡 dissolve 共享 shader | 用 `dissolve_amount` 1→0（出生）vs 0→1（死亡），方向不同 |
| 驱散停 buff 视觉但 buff 还在（比如减速时间没到）| 这是 bug——驱散应该既停视觉也停 buff 逻辑，需要在 dispel_effect.gd 里联动 |
| 沙盒技能释放按钮需要"施法者"概念 | 沙盒里"最近选中的友军单位"作为施法者 |

---

## 10. 后续衔接

- **PR-1**：依赖 hit_flash + dissolve + blessed/enraged 接入
- **PR-3**：依赖 UnitVisualFeedback 的护盾环、set_enraged、set_blessed API
- **PR-5**：依赖 PostProcessController.shake_screen
- **PR-7**：T3 变体（如神圣者）的治疗视觉可以走 PR-6 的 play_light_pillar
