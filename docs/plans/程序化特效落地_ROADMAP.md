# 程序化特效落地 ROADMAP

> **目的**：把 [程序化特效落地总方案.md](../design/程序化特效落地总方案.md) 拆成可执行的 PR，每个 PR 都能在测试沙盒里独立验证。
>
> **拆解原则**：基础优先（PR-0→1→2→3...），每个 PR 在沙盒里能立刻看到效果。
>
> **关联文档**：
> - 总方案：[docs/design/程序化特效落地总方案.md](../design/程序化特效落地总方案.md)
> - 调研报告：[docs/design/程序化动画与特效调研报告.md](../design/程序化动画与特效调研报告.md)
> - 单位视觉设计：[docs/design/单位动态与状态视觉设计方案.md](../design/单位动态与状态视觉设计方案.md)
> - 建筑视觉设计：[docs/design/建筑活动视觉设计方案.md](../design/建筑活动视觉设计方案.md)

---

## PR 依赖图

```
PR-0  测试沙盒（极简版）
  ↓
PR-1  Shader 接入 + Dissolve
  ↓
PR-2  粒子对象池 + 配方库
  ↓
PR-3  UnitVisualFeedback 组件
  ↓
PR-4  BuildingActivityVisual 组件
  ↓
PR-5  命中粒子 + 屏幕后处理
  ↓
PR-6  指挥官技能视觉升级
  ↓
PR-7  T3 变体专属视觉（可延后）
```

每个 PR 完成后在沙盒里验证，验证通过再进下一个。

---

## PR-0：测试沙盒场景（极简版）

**目标**：搭一个能 spawn 单位互打、看 HP/伤害飘字的独立场景。后续所有 PR 在这里验证。

### 范围（MVP）

只做四件事：
1. **左面板选单位** → 点击战场 spawn
2. **顶栏时间控制** → 暂停 / 1x / 0.5x / 2x
3. **右面板显示选中单位详情**（复用 `detail_panel.gd`）
4. **重置按钮** → 清空所有 spawn 单位

**不做**：框选、F5 aggro 可视化、快捷键、Debug overlay、无限金币开关。能跳过都跳过。

### 可放置单位清单（初始）

只放最常用的 8 个，足够覆盖后续 PR 验证：

| 单位 | 阵营 | 用途 |
|---|---|---|
| 剑士 | 玩家 | 近战基础 |
| 弓兵 | 玩家 | 远程基础 |
| 枪兵 | 玩家 | 中距 |
| 僧侣 | 玩家 | 治疗 |
| 火焰法师 | 敌方 | 法术攻击（验证元素特效）|
| 巨魔 | 敌方 | Boss 模板（验证 boss_glow）|
| 骷髅 | 召唤物 | 召唤物模板（验证 dissolve）|
| 木桩 HP 500 | 中立 | 静态靶 |

加单位只需要在 `scripts/sandbox/sandbox_config.gd` 里加一行，面板自动生成。

### 场景结构

```
EffectSandbox (Node2D) — scenes/sandbox/effect_sandbox.tscn
├─ Map (TileMap) — 30×30 小地图，复用 map_1 的 tileset
├─ YSort/Units — spawn 的单位加这里
├─ YSort/Targets — 木桩加这里
├─ SandboxController.gd — 主控脚本
└─ SandboxUI (CanvasLayer, layer=10)
    ├─ TopBar — 时间控制 + 重置
    ├─ LeftPanel — 单位按钮列表
    └─ RightPanel — detail_panel 实例
```

### 复用资源

- `scripts/systems/stress_test_spawner.gd` — 借鉴批量 spawn 逻辑
- `scripts/ui/detail_panel.gd` — 选中详情面板，直接复用
- `scripts/effects/floating_text.gd` — 伤害飘字，直接复用
- `scenes/units/unit.tscn` + 所有 `scenes/units/*.tscn` — 单位场景直接用
- 现有 map_1 tileset — 复用地形

### 启动入口

不接入 main.gd 启动流程。在 Godot 编辑器里**直接打开 effect_sandbox.tscn 按 F6 运行**就行。这是开发工具，不是游戏内容。

### 配置说明

`scripts/sandbox/sandbox_config.gd` 维护单位清单：

```gdscript
const SPAWNABLE_UNITS := [
    { "scene": preload("res://scenes/units/soldier.tscn"), "name": "剑士", "faction": "player" },
    { "scene": preload("res://scenes/units/archer.tscn"), "name": "弓兵", "faction": "player" },
    # ... 加一行就出一个按钮
]
```

---

## PR-1：Shader 接入 + Dissolve

**目标**：把 5 个未接入的 shader uniform 接上代码，再做 Dissolve shader 接到单位死亡。

### 范围

1. **接入 5 个 uniform**：
   - `hit_flash_enabled` / `hit_flash_amount` / `hit_flash_color` → 接到 `unit.gd::take_damage()`，Tween 0 → 0.85 → 0，0.12 秒
   - `enraged_enabled` / `enraged_tint` → 接到狂暴 buff 系统
   - `blessed_enabled` / `blessed_tint` → 接到祝福 buff 系统
   - `boss_glow_enabled` / `boss_glow_color` / `boss_pulse_speed` → 接到 Boss 单位（巨魔等）

2. **Dissolve shader**：
   - 在 `shaders/unit_effects.gdshader` 里加 `dissolve_amount` + `dissolve_noise` + `dissolve_edge_color` uniform（不新建 shader 文件）
   - `unit.gd::die()` 里叠加 dissolve：scale-to-zero 保留 + 同时 dissolve_amount 0→1，0.4 秒

### 验证（沙盒）

- spawn 5 剑士 vs 5 火法师 → 剑士受击时有白闪
- spawn 巨魔 → 紫色脉动发光
- spawn 骷髅 → 死亡时 dissolve 消散（紫黑边缘）

### 关键文件

- [shaders/unit_effects.gdshader](../../shaders/unit_effects.gdshader)
- [scripts/units/unit.gd](../../scripts/units/unit.gd) (`take_damage` / `die` / `_init_outline_materials`)
- [scripts/stats/unit_stats.gd](../../scripts/stats/unit_stats.gd) — 可能要加 `is_boss` / `hit_flash_color_override` 字段

---

## PR-2：粒子对象池 + 配方库

**目标**：建 ParticlePool Autoload + 6 种基础配方 .tscn，替换现有 instantiate() 调用。

### 范围

1. **ParticlePool Autoload**（`scripts/effects/particle_pool.gd`）：
   - `prewarm(scene, count, key)` / `spawn(key, pos)` / `_return_to_pool()`
   - `main.gd::_ready()` 启动时预热所有配方各 20-30 个

2. **6 种基础配方**（`scenes/effects/particles/*.tscn`）：
   | 配方 | 用途 |
   |---|---|
   | dust.tscn | 落地/施工 |
   | hit_spark.tscn | 近战命中 |
   | debris.tscn | 建筑/城墙摧毁 |
   | energy_fog.tscn | 召唤/Buff |
   | heal_orb.tscn | 治疗光斑 |
   | blood_mist.tscn | 单位受击/死亡 |

3. **替换现有 instantiate()**：
   - `scripts/effects/dust_effect.gd` 触发处改用 ParticlePool
   - `scripts/effects/heal_effect.gd` 触发处改用 ParticlePool
   - 其他已有粒子场景按需迁移

### 验证（沙盒）

- spawn 50 剑士 vs 50 敌方 → 大量命中/死亡时不卡顿（profile FPS）
- 观察是否出现 `push_warning("Particle pool empty: ...")` 日志，按需调大预热数量

### 关键文件

- 新增 `scripts/effects/particle_pool.gd`
- 新增 `scenes/effects/particles/*.tscn`
- [scripts/main.gd](../../scripts/main.gd) (`_ready` 预热)
- [project.godot](../../project.godot) — Autoload 注册

---

## PR-3：UnitVisualFeedback 组件

**目标**：实现单位视觉反馈组件，接入受击位移、攻击冲量、护盾环、持续状态标记。

### 范围

按 [单位动态与状态视觉设计方案.md](../design/单位动态与状态视觉设计方案.md) 实现：

1. **新组件** `scripts/effects/unit_visual_feedback.gd`：
   - `configure(body, material, unit_type, seed)`
   - `play_attack(aim_dir, is_ranged)` / `play_hit(from_dir, shield_absorbed)` / `play_heal()`
   - `set_slow(active)` / `set_poison(active)` / `set_shield(active, ratio)`
   - `_draw()` 画地面环（护盾/减速弧/中毒点）

2. **接入 unit.gd**：
   - `_ready()` 配置组件
   - `_physics_process()` 传 velocity / is_running
   - `_perform_attack()` → `play_attack()`
   - `take_damage()` 区分普通命中 / 护盾命中 → `play_hit()`
   - `apply_slow()` / `apply_poison()` / `set_shield_hp()` → 对应 set_*()

3. **挂到 unit.tscn** 作为子节点

### 验证（沙盒）

- 选中单位能看到脚下护盾环
- 攻击有前探/后坐冲量
- 普通命中 = 白闪 + 位移；护盾命中 = 蓝白环（不闪白）
- 减速单位脚下有蓝色弧，中毒有绿色点环

### 关键文件

- 新增 `scripts/effects/unit_visual_feedback.gd`
- [scenes/units/unit.tscn](../../scenes/units/unit.tscn)
- [scripts/units/unit.gd](../../scripts/units/unit.gd)

---

## PR-4：BuildingActivityVisual 组件

**目标**：实现建筑活动视觉组件，接入 9 种建筑。

### 范围

按 [建筑活动视觉设计方案.md](../design/建筑活动视觉设计方案.md) 实现：

1. **新组件** `scripts/effects/building_activity_visual.gd`：
   - `configure(building_type, body, seed)`
   - `set_production(active, ratio)` / `play_order_received()` / `play_production_completed()`
   - `set_construction(active, ratio)` / `play_construction_completed()`
   - `play_resource_tick()` / `set_age_upgrade(active, ratio)` / `play_age_upgrade_completed()`
   - `play_hit(from_direction)` / `stop_all()`

2. **接入 building.gd**：
   - `_production_process()` → `set_production()`
   - `queue_unit()` 成功后 → `play_order_received()`
   - `_spawn_next_unit()` 完成 → `play_production_completed()`
   - `_produce_gold()` → `play_resource_tick()`
   - `start_construction()` / `_finish_construction()`
   - `set_age_upgrade_progress()`
   - `take_damage()` / `die()`

3. **挂到 building.tscn** 作为子节点

4. **建筑专属配置**：
   - 兵营：脉冲 1.5% + 门口尘土
   - 靶场：脉冲 1.0% + 弱尘土
   - 修道院：白蓝细环（不脉冲）
   - 城堡：产金 + 升级双环
   - 箭塔：开火轻微 jelly（保留现有）
   - 城墙：受击震动（不 scale）
   - 农场：产金小金环
   - 学院：研究时金环
   - 祭坛：占领大金光柱

### 验证（沙盒）

沙盒需要扩展加建筑 spawn 面板（如果 PR-0 没做）。或者在正式游戏里验证：
- 选个兵营让它生产 → 看门口尘土 + 微震
- 让城堡升时代 → 看金环转动 + 完成双环扩散
- 让敌方攻击玩家建筑 → 看受击震动 + 碎片粒子

### 关键文件

- 新增 `scripts/effects/building_activity_visual.gd`
- [scenes/buildings/building.tscn](../../scenes/buildings/building.tscn)
- [scripts/buildings/building.gd](../../scripts/buildings/building.gd)

---

## PR-5：命中粒子 + 屏幕后处理

**目标**：让战斗有冲击感。命中粒子落地 + 大招/爆炸有屏幕级冲击波和色差。

### 范围

1. **命中粒子配方落地**：
   - 近战命中 → `hit_spark` 配方（PR-2 已建，这里接到 `take_damage()`）
   - 远程命中 → `dust` 弱版
   - Boss/暴击 → 加量版

2. **屏幕后处理 shader**：
   - 新建 `shaders/post_process.gdshader`（冲击波 + 色差二合一）
   - 新建 `scripts/effects/post_process_controller.gd` Autoload
   - CanvasLayer (layer=100) + ColorRect + ShaderMaterial
   - API: `shake_screen(strength, dur)` / `chromatic_aberration(strength, dur)` / `shockwave(center, radius, dur)`

3. **接入触发点**：
   - 单位命中 → 小 hit_spark（不加后处理，太频繁）
   - 建筑爆炸 → screen shake + shockwave
   - 指挥官技能释放 → chromatic_aberration + shockwave（PR-6 接入）
   - Boss 死亡 → 大 screen shake + chromatic_aberration

### 验证（沙盒）

- spawn 50 单位互打 → 命中有粒子但不卡
- 杀死巨魔 → 屏幕震动 + 色差
- 加个 debug 按钮触发 shockwave（PR-0 沙盒可顺手加）

### 关键文件

- 新增 `shaders/post_process.gdshader`
- 新增 `scripts/effects/post_process_controller.gd`
- [scripts/units/unit.gd](../../scripts/units/unit.gd) (`take_damage` 加 hit_spark)
- [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`die` 加 screen shake)

---

## PR-6：指挥官技能视觉升级

**目标**：8 个指挥官技能从"只有飘字"升级到有完整视觉。

### 范围（8 个技能）

按 [总方案 2.5](../design/程序化特效落地总方案.md#25-玩家指挥官技能8-个) 逐个做：

| 技能 | 释放瞬间 | 持续效果 |
|---|---|---|
| 嘲讽 | 红色波纹环扩散 | 被嘲讽敌人头顶感叹号 |
| 闪现 | 起点 dissolve 消散 | 紫色光迹 |
| 隐身 | dissolve + 横向扭曲 | （无持续）|
| 劝化 | 金色光柱引导 | 引导期间持续光柱 |
| 护盾 | 蓝白环扩散 | 走 PR-3 的护盾环 |
| 召唤 | 紫色光柱 + energy_fog | 骷髅出生 dissolve 反向 |
| 治疗 | 金色十字光环 | heal_orb 粒子 |
| 驱散 | 白色清除波纹 | （无持续）|

### 验证（沙盒）

沙盒需要扩展加技能释放按钮（PR-0 没做的话），或者在正式游戏里验证：
- 释放每个技能 → 看释放瞬间 + 持续效果是否到位
- 用 PR-5 的后处理给释放瞬间加冲击

### 关键文件

- [scripts/skills/*.gd](../../scripts/) — 各技能脚本
- [scripts/effects/unit_visual_feedback.gd](../../effects/) — PR-3 的组件复用

---

## PR-7：T3 变体专属视觉（可延后）

**目标**：10 个 T3 变体的差异化视觉。**建议等玩家真正解锁 T3 后再做**，避免空有视觉没有 gameplay 差异。

### 范围

按 [总方案 2.2](../design/程序化特效落地总方案.md#22-t3-变体专属视觉) 逐个做。需要先核对 `resources/stats/t3_*_stats.tres` 里每个变体的实际 gameplay 机制，再决定视觉。

10 个变体分 4 系：
- 剑士系（狂战士 / 盾卫 / 复仇者 / 决斗者）
- 弓兵系（神射手 / 杀手射手 / 减速射手）
- 枪兵系（精英长矛 / Boss 杀手）
- 僧侣系（神圣者 / 祝福者 / 烈焰僧侣）

### 验证

在沙盒里 spawn 每个变体 + 对应敌人，看视觉差异。

---

## 配置说明

### Autoload 注册

PR-2 完成后 `project.godot` 加：
```
[autoload]
ParticlePool="*res://scripts/effects/particle_pool.gd"
```

PR-5 完成后加：
```
PostProcessController="*res://scripts/effects/post_process_controller.gd"
```

### 沙盒启动方式

Godot 编辑器 → 打开 `scenes/sandbox/effect_sandbox.tscn` → F6 运行。

不接入 main.gd 启动流程，是开发工具不是游戏内容。

### 单位 stats 字段扩展（PR-1 可能需要）

`scripts/stats/unit_stats.gd` 加：
```gdscript
@export var is_boss: bool = false           # 触发 boss_glow
@export var hit_flash_color: Color = Color.WHITE  # 单位专属受击色
```

### T3 变体 stats 复核（PR-7 前置）

PR-7 启动前先核对 `resources/stats/t3_*_stats.tres` 10 个文件，整理一份"变体 → gameplay 机制 → 视觉建议"对照表，避免做了视觉但没有机制支持。

---

## 整体节奏建议

- **PR-0** 1 个对话聊实施细节（沙盒布局/交互/复用）
- **PR-1 到 PR-5** 每个独立聊 + 独立验证
- **PR-6 / PR-7** 可以并行，互不依赖
- 每个 PR 完成后更新 [TODO.md](../../TODO.md) 关联状态

完成 PR-5 后，项目的"程序化特效地基"就完整了，PR-6/7 是锦上添花。
