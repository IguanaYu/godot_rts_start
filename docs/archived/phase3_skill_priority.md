# 第三阶段执行计划：技能优先级系统

> 对应整体计划的"第三阶段目标：AI 智能"中的技能优先级部分
> 核心目标：启用 SkillResource.priority 字段，确保高优先级技能优先获得蓝量分配

---

## 一、背景与需求

### 1.1 现状
- `SkillResource` 已有 `priority` 字段，.tres 文件里配好了优先级值：
  - 治疗=70 > 劝化=60 > 嘲讽=50 > 护盾=40 > 闪现=30 > 召唤=20 > 驱散=10 > 隐身=0
- 但这个字段**完全没用上**
- `skill_components` 数组按 .tres 文件中的顺序排列，不按优先级
- `PERIODIC_SCAN` 技能在 `_physics_process` 的 `for comp in skill_components` 循环里按数组顺序触发
- 低优先级技能可能先消耗蓝量，导致高优先级技能（如治疗）无蓝可用

### 1.2 目标
- 启用 `priority` 字段
- 技能组件按优先级降序排列和处理
- 确保高优先级技能优先获得蓝量分配

### 1.3 验收标准
- [ ] `skill_components` 按 priority 降序排列
- [ ] 高优先级技能（如治疗）在有蓝时优先触发
- [ ] 蓝量不足时低优先级技能让路
- [ ] 所有原有技能行为不变

---

## 二、涉及文件

| 操作 | 文件 | 说明 |
|------|------|------|
| **修改** | `scripts/units/unit.gd` | `_setup_skills()` 末尾加排序 |

只改 **1 个文件**，约 5 行新增代码。

---

## 三、详细改动

### 3.1 修改 `_setup_skills()`（约第 1671 行）

在 `skill_components.append(comp)` 循环结束后，添加按 priority 降序排序：

```gdscript
func _setup_skills() -> void:
    if stats_data == null or stats_data.skills.is_empty():
        return
    for skill_res in stats_data.skills:
        if skill_res == null:
            continue
        var comp: Node = _create_skill_component(skill_res)
        if comp == null:
            continue
        comp.skill_resource = skill_res
        comp.name = "Skill_" + skill_res.skill_name
        add_child(comp)
        skill_components.append(comp)
    # Phase 3：按 priority 降序排列（高优先级先处理）
    skill_components.sort_custom(func(a, b):
        return a.skill_resource.priority > b.skill_resource.priority
    )
```

### 3.2 不需要改的地方

- `can_activate()`：已检查蓝量，排序后高优先级先检查
- `PERIODIC_SCAN` 循环（`_physics_process` 第 519 行）：排序后自动按优先级处理
- `ON_ATTACK` 触发点（`_perform_attack` 第 957 行）：排序后自动按优先级处理
- `ON_CHASE` 触发点（`_attack_process` 第 631 行）：排序后自动按优先级处理
- 各 skill_effects 文件：不关心处理顺序

---

## 四、风险与应对

| # | 风险 | 概率 | 影响 | 应对 |
|---|------|------|------|------|
| 1 | 排序 lambda 类型推断失败 | 低 | 编译错误 | 用显式类型 `func(a: Node, b: Node)` |
| 2 | 当前单位都只有 1 个技能，排序无实际效果 | 低 | 无害 | 为未来多技能单位做准备 |

---

## 五、验证方式

1. **编译通过** — `godot --editor --quit` 无错误
2. **功能验证** — Monk 治疗行为不变
3. **回归验证** — 所有原有技能行为不变

---

## 六、实施顺序

```
Step 1: unit.gd _setup_skills() 末尾加排序
Step 2: 启动游戏验证编译和功能
```
