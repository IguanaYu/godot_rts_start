# 第三阶段执行计划：统一 AI 决策循环

> 对应整体计划的"第三阶段目标：AI 智能"中的统一决策循环部分
> 核心目标：把分散的技能触发点收拢到统一决策循环，按优先级"技能 > 攻击 > 待机"

---

## 一、背景与需求

### 1.1 现状：技能触发点分散在 4 个地方

当前技能触发逻辑散落在 `unit.gd` 各处，没有统一决策入口：

| 触发条件 | 当前位置 | 触发方式 | 问题 |
|----------|----------|----------|------|
| PERIODIC_SCAN | `_physics_process` 第 519 行 `for comp in skill_components` 循环 | 每个组件独立 `_skill_process()` 自己决定何时触发 | 各自为政，不协调 |
| ON_CHASE | `_attack_process` 第 631 行 | `for comp` 遍历找 trigger_condition==2 的组件 | 硬编码在攻击逻辑中间 |
| ON_ATTACK | `_perform_attack` 第 957 行 | `for comp` 遍历找 trigger_condition==0 的组件 | 硬编码在攻击逻辑末尾 |
| PASSIVE | `_skill_process` 里（隐身组件自己处理） | 组件自己跑 | 没问题，被动不需要统一 |

**核心问题**：没有"先检查高优先级技能，再决定是否攻击"的统一逻辑。虽然 Phase 3.1 做了优先级排序，但只是数组排序，没有真正的决策循环——`PERIODIC_SCAN` 技能各自独立触发，不会因为"治疗更重要"而抑制"护盾"的触发。

### 1.2 目标

收拢 `PERIODIC_SCAN` 技能的触发逻辑到统一决策方法 `_skill_ai_tick(delta)`：
- 按 priority 降序遍历技能组件
- 每个组件检查 `can_activate()` + `find_target()`
- 第一个能激活的技能就触发，本轮不再检查其他技能（避免同帧多技能抢蓝）
- `ON_ATTACK` / `ON_CHASE` 保持原位（它们是事件驱动，不该收拢到周期循环里）

### 1.3 验收标准
- [ ] `PERIODIC_SCAN` 技能通过统一 `_skill_ai_tick()` 触发，不再各自独立触发
- [ ] 同一帧只触发一个技能（高优先级先检查，触发后跳过低优先级）
- [ ] `ON_ATTACK` / `ON_CHASE` / `PASSIVE` 触发方式不变
- [ ] 所有原有技能行为不变
- [ ] 治疗优先级最高时，蓝量优先分配给治疗

---

## 二、涉及文件

| 操作 | 文件 | 说明 |
|------|------|------|
| **修改** | `scripts/units/unit.gd` | 新增 `_skill_ai_tick()`，替换原 `for comp` 循环 |
| **修改** | `scripts/skills/skill_component.gd` | `_skill_process()` 只做冷却递减，不再自己触发 PERIODIC_SCAN |

只改 **2 个文件**。

---

## 三、详细改动

### 3.1 SkillComponent — `_skill_process()` 只做冷却递减

当前 [skill_component.gd:78](scripts/skills/skill_component.gd#L78) 的 `_skill_process()` 包含 PERIODIC_SCAN 触发逻辑。改为**只做冷却递减**，触发逻辑移到 unit.gd 的统一决策循环：

```gdscript
## 每帧处理（由 unit.gd 的 _physics_process 调用）
## 只做冷却递减，PERIODIC_SCAN 触发由 unit.gd _skill_ai_tick() 统一处理
func _skill_process(delta: float) -> void:
    if cooldown_timer > 0.0:
        cooldown_timer = max(0.0, cooldown_timer - delta)
```

**注意**：`heal_effect.gd` 和 `convert_effect.gd` 覆盖了 `_skill_process()`，它们有自己的引导/移动逻辑。这两个保持不变——它们不只是"触发技能"，还有持续的状态管理（引导计时、移动追目标）。统一决策循环只管"是否触发新一次"，不管"已触发后的持续逻辑"。

### 3.2 Unit.gd — 新增 `_skill_ai_tick(delta)`

在 `_physics_process` 中替换原来的 `for comp in skill_components: comp._skill_process(delta)`：

```gdscript
# Phase 2：技能组件处理（冷却递减 + PERIODIC_SCAN/PASSIVE 触发）
for comp in skill_components:
    comp._skill_process(delta)
```

改为：

```gdscript
# Phase 3：技能组件冷却递减（所有组件每帧执行）
for comp in skill_components:
    comp._skill_process(delta)
# Phase 3：统一 AI 决策循环（PERIODIC_SCAN 技能按优先级触发）
_skill_ai_tick(delta)
```

新增方法（放在 `_physics_process` 附近）：

```gdscript
## Phase 3：统一技能 AI 决策循环
## 按 priority 降序遍历 PERIODIC_SCAN 技能，第一个能激活的就触发
## 同帧只触发一个技能，避免低优先级技能抢蓝
func _skill_ai_tick(delta: float) -> void:
    for comp in skill_components:
        if comp.skill_resource == null:
            continue
        # 只处理 PERIODIC_SCAN 触发条件
        if comp.skill_resource.trigger_condition != 1:  # PERIODIC_SCAN
            continue
        # trigger_interval 节流
        comp.trigger_timer += delta
        if comp.trigger_timer < comp.skill_resource.trigger_interval:
            continue
        comp.trigger_timer = 0.0
        # 检查能否激活 + 有无目标
        if not comp.can_activate():
            continue
        var target = comp.find_target()
        if target == null:
            continue
        # 触发！本轮不再检查其他技能
        comp.activate(target)
        break
```

### 3.3 不需要改的地方

- `ON_CHASE` 触发（`_attack_process` 第 631 行）— 事件驱动，保持原位
- `ON_ATTACK` 触发（`_perform_attack` 第 957 行）— 事件驱动，保持原位
- `heal_effect.gd` / `convert_effect.gd` 的 `_skill_process()` 覆盖 — 它们有持续状态管理，不受影响
- `stealth_effect.gd` 的 `_skill_process()` — PASSIVE 类型，自己做视觉效果，不受影响

---

## 四、关键设计决策

### 为什么 ON_ATTACK / ON_CHASE 不收拢？

它们是**事件驱动**的——只有在攻击命中 / 追击距离过远时才该触发。如果放进周期循环里，每帧都检查会造成：
- 召唤技能每帧尝试召唤（虽然内部有概率限制，但浪费 CPU）
- 闪现每帧尝试闪现（虽然内部有冷却，但逻辑不清晰）

事件驱动的触发点应该留在事件发生的地方。

### 为什么 heal_effect / convert_effect 不受影响？

它们的 `_skill_process()` 不只是"触发技能"，还有持续逻辑：
- `heal_effect`：持续追踪治疗目标，移动靠近，到达后治疗
- `convert_effect`：引导计时累加，引导完成后转化

统一决策循环只管"是否开始新一次触发"，这些持续逻辑在组件内部完成，不受影响。

但有个问题：`heal_effect` 覆盖了 `_skill_process()`，它的触发逻辑（`find_target()` + `activate()`）在覆盖方法里，不走基类的 PERIODIC_SCAN 逻辑。所以 `_skill_ai_tick()` 不会触发治疗技能——治疗技能自己在 `_skill_process()` 里触发。

**解决方案**：`_skill_ai_tick()` 里跳过有自己 `_skill_process()` 覆盖的组件。用 `has_method` 检查——但 GDScript 的方法覆盖检测不方便。更简单的方案：在 SkillResource 加一个 `custom_process: bool` 标记，或者直接让 `_skill_ai_tick` 只处理"没有覆盖 `_skill_process` 的 PERIODIC_SCAN 组件"。

实际上最简单：**让 heal_effect 和 convert_effect 的 `_skill_process` 不要自己做触发，把触发逻辑也交给 `_skill_ai_tick`，只保留持续状态管理**。但这改动较大，风险高。

**折中方案（推荐）**：`_skill_ai_tick()` 里用 `comp.get_script().get_source_code()` 检查是否覆盖了 `_skill_process`——太 hacky。

**最终方案**：在 SkillComponent 基类加一个 `uses_custom_process: bool = false` 标记，heal_effect 和 convert_effect 在 `_ready()` 里设为 true。`_skill_ai_tick()` 跳过这些组件。

---

## 五、风险与应对

| # | 风险 | 概率 | 影响 | 应对 |
|---|------|------|------|------|
| 1 | heal/convert 不走统一循环 | 中 | 它们独立触发，不参与优先级竞争 | 加 `uses_custom_process` 标记，`_skill_ai_tick` 跳过 |
| 2 | 同帧只触发一个技能导致护盾延迟 | 低 | 护盾等低优先级技能偶尔晚一帧 | 可接受，优先保证治疗蓝量 |
| 3 | trigger_timer 逻辑从组件移到 unit 后计数不准 | 低 | 触发频率变化 | `_skill_ai_tick` 里操作 `comp.trigger_timer`，保持一致 |

---

## 六、验证方式

### 功能验证
1. **治疗优先** — Monk 有蓝时，治疗技能优先触发（不被其他技能抢蓝）
2. **嘲讽正常** — Stoneguard 周期性嘲讽周围敌人
3. **护盾正常** — Warden 周期性给友军加盾
4. **召唤/闪现不变** — 攻击时召唤、追击时闪现行为不变（事件驱动）
5. **劝化不变** — Enchanter 引导转化行为不变（自定义 process）

### 回归验证
1. 所有原有技能行为不退化
2. 无新增报错

---

## 七、实施顺序

```
Step 1: skill_component.gd — _skill_process() 改为只做冷却递减
Step 2: skill_component.gd — 新增 uses_custom_process 标记
Step 3: heal_effect.gd / convert_effect.gd — _ready() 设 uses_custom_process = true
Step 4: unit.gd — 新增 _skill_ai_tick()，替换 _physics_process 中的触发逻辑
Step 5: 启动游戏验证
```
