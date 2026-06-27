# Phase 3 续：统一技能激活入口

## Context

Phase 3 的"统一决策循环"和"目标选择策略"已在 commit 4efa8c2 + 14e98f2 完成。但还剩一个架构问题没解决：**激活入口分散**。

当前 5 种技能有 4 条不同的激活路径，大部分绕过基类 `activate()`：

| 技能 | 触发位置 | 激活入口 | 绕过 activate()? |
|------|----------|----------|:---:|
| 护盾/嘲讽/驱散 (PERIODIC_SCAN) | `_skill_ai_tick()` | `activate(target)` | 否 |
| 闪现 (ON_CHASE) | `unit.gd:_attack_process` L664 | `try_blink()` | **是** — 自己管蓝/冷却/文字 |
| 召唤 (ON_ATTACK) | `unit.gd:_perform_attack` L990 | `try_summon()` | **是** — 绕过所有逻辑 |
| 治疗 (自定义 process) | `heal_effect._skill_process()` | 直接 `heal()` + `_show_skill_text()` | **是** |
| 劝化 (自定义 process) | `convert_effect._skill_process()` | `_do_convert()` + `_show_skill_text()` | **是** |

**核心问题**：要加跨切面逻辑（如释放技能扣钱/扣血），要改 5 个地方。而且治疗/劝化/召唤的 `mana_cost` 配了但从没生效——需确认是免费释放还是配置错误。

**已确认**：用户确认治疗/劝化/召唤都免费释放，把 `mana_cost` 设为 0 保持行为不变。

## 目标

1. **统一激活入口** — 所有技能激活经过 `activate()`，跨切面逻辑只写一次
2. **信号扩展点** — `skill_activated` 信号支持多监听者（扣钱/扣血/日志系统各自 connect）
3. `ON_ATTACK`/`ON_CHASE` 仍在事件位置检测，但检测到后调用 `activate()` 而非 `try_*()` 方法
4. heal/convert 保留自定义 `_skill_process()` 做状态管理，但实际效果通过 `activate()` 触发

## 涉及文件

| 操作 | 文件 |
|------|------|
| 修改 | `scripts/skills/skill_component.gd` |
| 修改 | `scripts/units/unit.gd` |
| 修改 | `scripts/skills/skill_effects/blink_effect.gd` |
| 修改 | `scripts/skills/skill_effects/summon_effect.gd` |
| 修改 | `scripts/skills/skill_effects/heal_effect.gd` |
| 修改 | `scripts/skills/skill_effects/convert_effect.gd` |
| 修改 | `resources/skills/heal.tres` (mana_cost=0) |
| 修改 | `resources/skills/convert.tres` (mana_cost=0) |
| 修改 | `resources/skills/summon.tres` (mana_cost=0) |

## 改动方案

### 1. `skill_component.gd` — 新增信号

```gdscript
signal skill_activated(target)  # 技能激活时发出，供 unit 监听做跨切面逻辑
```

`activate()` 中触发信号（在扣蓝/设冷却之后，执行效果之前）：

```gdscript
func activate(target) -> void:
    if not can_activate():
        return
    if target == null or not is_instance_valid(target):
        return
    var u = get_parent()
    if u and "mana" in u and skill_resource.mana_cost > 0.0:
        u.mana = max(0.0, u.mana - skill_resource.mana_cost)
    cooldown_timer = skill_resource.cooldown
    skill_activated.emit(target)   # ← 新增：跨切面信号
    match skill_resource.delivery_type:
        0: _deliver_projectile(target)
        1: _apply_effect(u, u)
        2: _apply_effect(u, target)
    _show_skill_text(skill_resource.skill_name)
```

### 2. `unit.gd` — connect 信号 + 改触发点

#### a) `_setup_skills()` 中 connect（在 `skill_components.append(comp)` 后）

```gdscript
comp.skill_activated.connect(_on_unit_skill_activated)
```

新增空方法（未来扩展扣钱/扣血/日志等）：

```gdscript
func _on_unit_skill_activated(target) -> void:
    # Phase 3：跨切面扩展点，未来在此添加扣钱、扣血、日志等逻辑
    pass
```

#### b) `_attack_process` L664 — ON_CHASE 改用 `activate()`

```gdscript
for comp in skill_components:
    if comp.skill_resource and comp.skill_resource.trigger_condition == 2:  # ON_CHASE
        if comp.can_activate():
            comp.activate(attack_target)
            dist = _get_dist_to_target(attack_target)
            break
```

#### c) `_perform_attack` L990 — ON_ATTACK 改用 `activate()`

```gdscript
for comp in skill_components:
    if comp.skill_resource and comp.skill_resource.trigger_condition == 0:  # ON_ATTACK
        if comp.can_activate():
            comp.activate(attack_target)
            break
```

### 3. 改造技能效果文件

#### a) `blink_effect.gd` — 删 `try_blink()` 和 `_skill_process()` 覆盖，用 `_apply_effect()`

```gdscript
extends "res://scripts/skills/skill_component.gd"
## 闪现：追击时瞬移到目标附近

func _apply_effect(caster, target) -> void:
    if target == null or not is_instance_valid(target):
        return
    var dir: Vector2 = caster.global_position.direction_to(target.global_position)
    if dir.length_squared() < 0.001:
        return
    var blink_dist: float = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 100.0
    caster.global_position += dir * blink_dist
```

> 基类 `_skill_process()` 已处理冷却递减。`activate()` 会扣蓝(10)+设冷却(5s)+显示文字+发信号。

#### b) `summon_effect.gd` — 删 `try_summon()` 和 `_skill_process()` 覆盖，用 `_apply_effect()`

```gdscript
extends "res://scripts/skills/skill_component.gd"
## 召唤：攻击命中时召唤骷髅

func _apply_effect(caster, target) -> void:
    if caster.has_method("_try_summon_minion"):
        caster._try_summon_minion()
```

> mana_cost 设为 0，不扣蓝。`activate()` 会设冷却(0)+显示文字+发信号。

#### c) `heal_effect.gd` — 治疗逻辑移到 `_apply_effect()`，通过 `activate()` 触发

`_skill_process()` 中距离够时改为调用 `activate(_heal_target)`，移除直接 `heal()` + `_show_skill_text()`：

```gdscript
    if dist <= heal_range:
        activate(_heal_target)  # ← 统一入口：扣蓝(0)+冷却+治疗+文字+信号
```

新增 `_apply_effect()`：

```gdscript
func _apply_effect(caster, target) -> void:
    if target == null or not is_instance_valid(target):
        return
    var heal_amt := 8
    if caster.stats_data and caster.stats_data.heal_amount > 0:
        heal_amt = caster.stats_data.heal_amount
    if target.has_method("heal"):
        target.heal(heal_amt)
    elif target.health:
        target.health.heal(heal_amt)
    if caster.stats_data and caster.stats_data.cleanse_on_heal and target.has_method("cleanse_debuffs"):
        target.cleanse_debuffs()
```

> heal 的冷却： Monk stats_data.heal_cooldown=1.0 与 heal.tres cooldown=1.0 一致，`activate()` 设 `cooldown_timer = skill_resource.cooldown = 1.0`，行为不变。移除 `_skill_process()` 末尾的 `cooldown_timer = heal_cd` 和 `_show_skill_text()`。

#### d) `convert_effect.gd` — 转化逻辑调用 `activate()`

`_skill_process()` 中引导完成后，先保存 target 再调用 `activate()`，最后清空状态：

```gdscript
    if _channel_time >= channel_needed:
        var saved_target = _channel_target   # ← 保存引用
        _do_convert(u, saved_target)
        activate(saved_target)                # ← 统一入口：扣蓝(0)+冷却(0)+文字+信号
        _channel_target = null
        _channel_time = 0.0
```

`_do_convert()` 中移除 `_show_skill_text()`（`activate()` 会显示）。

> convert.tres cooldown=0.0，`activate()` 设 `cooldown_timer = 0`，无冷却（保持现状）。

### 4. 修改 3 个 .tres 的 mana_cost = 0

| 文件 | 当前 mana_cost | 新值 |
|------|:---:|:---:|
| `resources/skills/heal.tres` | 5.0 | 0.0 |
| `resources/skills/convert.tres` | 30.0 | 0.0 |
| `resources/skills/summon.tres` | 5.0 | 0.0 |

> 闪现保持 mana_cost=10.0（原本就扣蓝，行为不变）。

### 5. blink.tres delivery_type 改为 2 (INSTANT_RANGE)

blink 原 delivery_type=1 (INSTANT_SELF)，`activate()` 会调 `_apply_effect(u, u)`，但闪现需要敌人位置算方向。改为 2 (INSTANT_RANGE)，`activate()` 调 `_apply_effect(u, target)` 传入敌人。

## 关键设计决策

### 为什么用信号而不是虚方法？

`skill_activated` 信号支持：
- **多监听者** — 扣钱系统 + 日志系统 + 成就系统可同时 connect
- **动态增减** — 运行时 connect/disconnect，不需改代码重新部署
- **解耦** — SkillComponent 只发信号，不关心谁监听

未来加"扣钱"逻辑：只改 unit.gd 的 `_on_unit_skill_activated`。加"扣血"：再 connect 一个新方法。都不动 SkillComponent 基类。

### 为什么 heal/convert 保留自定义 `_skill_process()`？

它们有持续状态管理（追踪目标、移动、引导计时），这些逻辑必须在每帧执行。但"实际触发效果"的那一刻（治疗命中、引导完成）改为调用 `activate()`，这样扣蓝/冷却/文字/信号都统一了。

`uses_custom_process = true` 让 `_skill_ai_tick()` 跳过它们（已实现），避免双重触发。

## 风险与应对

| # | 风险 | 概率 | 影响 | 应对 |
|---|------|------|------|------|
| 1 | heal/convert/summon 走 activate() 后行为变化 | 低 | mana_cost 已设为 0，不扣蓝 | 已确认三个 .tres 的 mana_cost 改为 0 |
| 2 | heal 冷却来源从 stats_data 改为 skill_resource | 无 | 无影响 | Monk 的 heal_cooldown=1.0 与 heal.tres cooldown=1.0 一致 |
| 3 | convert activate() 顺序问题 | 中 | target 在 _do_convert 后被清空 | 实现时在清空 _channel_target 前保存引用 |
| 4 | blink delivery_type 需改为 INSTANT_RANGE | 低 | 否则 _apply_effect 收到 (caster, caster) | blink.tres delivery_type 改为 2 |

## 验证结果

- **编译通过** — `godot --editor --quit` 无 SCRIPT ERROR
- **游戏运行正常** — 启动到关闭 exit code 0，FPS 稳定 60，无运行时崩溃
- **战斗正常** — 单位数量变化（召唤/死亡正常），导航网格正常重建
