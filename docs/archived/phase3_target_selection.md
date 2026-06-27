# 第三阶段执行计划：目标选择策略完善

> 对应整体计划的"第三阶段目标：AI 智能"中的目标选择部分
> 核心目标：完善 SkillComponent 的目标搜索逻辑，让 AI 更聪明地选择目标

---

## 一、背景与需求

### 1.1 现状问题

当前 `SkillComponent` 的目标搜索有 4 个问题：

#### 问题 1：不用 UnitGrid 空间分区，性能差
- [skill_component.gd:184](scripts/skills/skill_component.gd#L184) `_get_all_units()` 遍历 `player_units` + `enemy_units` 分组的**所有单位**
- `unit.gd` 里的搜索全部用 `UnitGrid.query_neighbors()` 空间分区，只查附近单位
- 技能组件每 0.5s 扫描一次，大量单位时性能差

#### 问题 2：治疗不优先最危急的目标
- [skill_component.gd:162](scripts/skills/skill_component.gd#L162) `_find_nearest_wounded_ally()` 只选**最近的**受伤友军
- 但最近的友军可能只掉了 1 血，而远处有个友军剩 1 血濒死
- 应该优先治疗血量百分比最低的友军（同等危急程度下再选最近的）

#### 问题 3：嘲讽目标选择不够智能
- 嘲讽（[taunt_effect.gd](scripts/skills/skill_effects/taunt_effect.gd)）：用 `ENEMY_NEAREST` 选最近敌人
- 但嘲讽应该选**正在攻击友军的敌人**，而不是随便最近的敌人

#### 问题 4：护盾目标选择不够智能
- 护盾（[shield_effect.gd](scripts/skills/skill_effects/shield_effect.gd)）：用 `ALLY_NEAREST_WOUNDED` 选最近受伤友军
- 但护盾应该优先给**血量最低的友军**

### 1.2 目标
- 用 `UnitGrid.query_neighbors()` 替代全量遍历
- 治疗优先选血量百分比最低的友军
- 嘲讽优先选正在攻击友军的敌人
- 护盾优先选血量百分比最低的友军

### 1.3 验收标准
- [ ] 技能目标搜索用 UnitGrid，不再遍历全量单位
- [ ] Monk 治疗优先选血量百分比最低的友军（而非最近的）
- [ ] Stoneguard 嘲讽优先选正在攻击友军的敌人
- [ ] Warden 护盾优先选血量最低的友军
- [ ] 所有原有技能行为不退化

---

## 二、涉及文件

| 操作 | 文件 | 说明 |
|------|------|------|
| **修改** | `scripts/skills/skill_resource.gd` | 新增 `TargetType` 枚举值 |
| **修改** | `scripts/skills/skill_component.gd` | 用 UnitGrid 重写搜索 + 血量百分比优先 + 新目标类型 |
| **修改** | `resources/skills/taunt.tres` | target_type 改为 ENEMY_ATTACKING_ALLY |
| **修改** | `resources/skills/shield.tres` | target_type 改为 ALLY_LOWEST_HP |
| **修改** | `resources/skills/heal.tres` | target_type 改为 ALLY_LOWEST_HP |

UnitGrid 是全局 autoload（`project.godot` 第 28 行注册），可直接用 `UnitGrid.query_neighbors(pos, radius)`。

---

## 三、详细改动

### 3.1 SkillResource 新增 TargetType

在 [skill_resource.gd:12](scripts/skills/skill_resource.gd#L12) 的 `TargetType` 枚举新增：

```gdscript
enum TargetType {
    ENEMY_NEAREST,
    ALLY_NEAREST_WOUNDED,
    SELF,
    CURRENT_ATTACK_TARGET,
    ENEMY_ATTACKING_ALLY,    # 新增：正在攻击友军的敌人（嘲讽用）
    ALLY_LOWEST_HP,           # 新增：血量百分比最低的友军（治疗/护盾用）
}
```

### 3.2 SkillComponent — 用 UnitGrid 重写搜索

**a) `_get_all_units()` 改为 `_query_nearby_units(search_range)`，直接用 UnitGrid：**

```gdscript
func _query_nearby_units(search_range: float) -> Array:
    var u = get_parent()
    if u == null:
        return []
    return UnitGrid.query_neighbors(u.global_position, search_range)
```

**b) `find_target()` 的 match 新增 2 个分支（第 32 行）：**
```gdscript
match skill_resource.target_type:
    0:  return _find_nearest_enemy()
    1:  return _find_nearest_wounded_ally()
    2:  return get_parent()
    3:  var u = get_parent(); return u.attack_target if u and "attack_target" in u else null
    4:  return _find_enemy_attacking_ally()   # 新增
    5:  return _find_nearest_wounded_ally()    # 新增（复用，已改为血量百分比优先）
```

**c) `_find_nearest_enemy()` 改用 `_query_nearby_units()`：**
```gdscript
func _find_nearest_enemy():
    var u = get_parent()
    if u == null:
        return null
    var search_range = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 300.0
    var best = null
    var best_dist = search_range
    for unit in _query_nearby_units(search_range):
        if not is_instance_valid(unit) or unit == u:
            continue
        if "is_dead" in unit and unit.is_dead():
            continue
        if "team" in unit and unit.team == u.team:
            continue
        if "is_stealthed" in unit and unit.has_method("is_stealthed") and unit.is_stealthed():
            continue
        var d = u.global_position.distance_to(unit.global_position)
        if d <= best_dist:
            best_dist = d
            best = unit
    return best
```

**d) `_find_nearest_wounded_ally()` 改为血量百分比优先：**
```gdscript
## 找受伤友军：优先血量百分比最低的，同百分比选最近的
func _find_nearest_wounded_ally():
    var u = get_parent()
    if u == null:
        return null
    var search_range = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 300.0
    var best = null
    var best_hp_ratio = 1.0  # 血量百分比，越低越优先
    var best_dist = search_range
    for unit in _query_nearby_units(search_range):
        if not is_instance_valid(unit) or unit == u:
            continue
        if "is_dead" in unit and unit.is_dead():
            continue
        if "team" in unit and unit.team != u.team:
            continue
        if "health" not in unit or unit.health == null:
            continue
        if unit.health.hp >= unit.health.max_hp:
            continue
        var hp_ratio = float(unit.health.hp) / float(unit.health.max_hp)
        var d = u.global_position.distance_to(unit.global_position)
        # 血量百分比更低，或同百分比但更近
        if hp_ratio < best_hp_ratio or (hp_ratio == best_hp_ratio and d < best_dist):
            best_hp_ratio = hp_ratio
            best_dist = d
            best = unit
    return best
```

**e) 新增 `_find_enemy_attacking_ally()`（嘲讽用）：**
```gdscript
## 找正在攻击友军的敌人（嘲讽优先目标）
func _find_enemy_attacking_ally():
    var u = get_parent()
    if u == null:
        return null
    var search_range = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 300.0
    var best = null
    var best_dist = search_range
    for unit in _query_nearby_units(search_range):
        if not is_instance_valid(unit) or unit == u:
            continue
        if "is_dead" in unit and unit.is_dead():
            continue
        if "team" in unit and unit.team == u.team:
            continue
        if "is_stealthed" in unit and unit.has_method("is_stealthed") and unit.is_stealthed():
            continue
        # 检查这个敌人是否正在攻击友军
        if "attack_target" not in unit or unit.attack_target == null:
            continue
        if not is_instance_valid(unit.attack_target):
            continue
        if "team" in unit.attack_target and unit.attack_target.team != u.team:
            continue  # 它在攻击敌人，不是友军
        var d = u.global_position.distance_to(unit.global_position)
        if d <= best_dist:
            best_dist = d
            best = unit
    # 没找到正在攻击友军的敌人，fallback 到最近敌人
    if best == null:
        return _find_nearest_enemy()
    return best
```

### 3.3 修改 3 个 .tres 文件

| 文件 | target_type 旧值 | 新值 | 说明 |
|------|------------------|------|------|
| `resources/skills/taunt.tres` | 0 (ENEMY_NEAREST) | 4 (ENEMY_ATTACKING_ALLY) | 优先嘲讽正在攻击友军的敌人 |
| `resources/skills/shield.tres` | 1 (ALLY_NEAREST_WOUNDED) | 5 (ALLY_LOWEST_HP) | 优先给血量最低的友军加盾 |
| `resources/skills/heal.tres` | 1 (ALLY_NEAREST_WOUNDED) | 5 (ALLY_LOWEST_HP) | 优先治疗血量最低的友军 |

### 3.4 不需要改的地方

- `taunt_effect.gd` / `shield_effect.gd` / `heal_effect.gd` 的 `_apply_effect` 和 `_skill_process` — 调用 `find_target()` 或 `activate()`，基类逻辑改了自动生效
- `convert_effect.gd` — 有自己的 `_find_convert_target()`，暂不动
- `blink_effect.gd` / `summon_effect.gd` / `dispel_effect.gd` / `stealth_effect.gd` — 不用 find_target

---

## 四、风险与应对

| # | 风险 | 概率 | 影响 | 应对 |
|---|------|------|------|------|
| 1 | UnitGrid 访问方式 | 低 | 编译错误 | UnitGrid 是 autoload，直接全局用 |
| 2 | 血量百分比优先导致 Monk 来回跑 | 中 | 治疗效率下降 | 同百分比时选最近的，避免远距离来回 |
| 3 | 嘲讽找不到正在攻击友军的敌人 | 低 | 嘲讽不触发 | fallback 到最近敌人 |
| 4 | 类型推断失败 | 低 | 编译错误 | 用显式 float 类型 |
| 5 | convert_effect 有自己的 _find_convert_target | 低 | 重复逻辑 | 暂不改 convert，它已有独立逻辑 |

---

## 五、验证方式

### 功能验证
1. **治疗优先级** — Monk 附近有 2 个受伤友军：一个近的掉了 1 血，一个远的剩 10% 血。Monk 应优先跑向远的那个濒死友军。
2. **嘲讽优先级** — Stoneguard 附近有 2 个敌人：一个在打友军，一个闲逛。Stoneguard 应优先嘲讽正在攻击友军的那个。
3. **护盾优先级** — Warden 附近有 2 个受伤友军：一个满血附近掉了一点，一个濒死。Warden 应优先给濒死的加盾。
4. **fallback 正常** — 嘲讽附近没有正在攻击友军的敌人时，嘲讽最近敌人（不沉默）。

### 回归验证
1. 所有原有技能行为不退化
2. 无新增报错
3. 性能：用 UnitGrid 后大量单位时不再卡顿

---

## 六、实施顺序

```
Step 1: skill_resource.gd 新增 2 个 TargetType 枚举值
Step 2: skill_component.gd 重写搜索逻辑（UnitGrid + 血量百分比优先 + 新目标类型）
Step 3: 修改 3 个 .tres 文件的 target_type
Step 4: 启动游戏验证
```
