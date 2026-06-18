# 第二阶段执行计划：技能组件框架

> 对应整体计划的"第二阶段目标：技能框架"
> 核心目标：建立可插拔的技能组件体系，统一管理所有单位技能

---

## 一、需求与验收标准

### 1.1 需求
1. **SkillResource**：用 .tres 文件配置每个技能的数据（冷却、蓝耗、目标类型、交付方式等）
2. **SkillComponent**：运行时组件，挂载到单位上，管理技能的冷却/触发/释放
3. **技能效果迁移**：将 7 个技能从 unit.gd 内嵌逻辑迁移到独立效果文件
4. **蓝条系统**：法师/射手单位有蓝条（HP 条下方显示 MP 条），近战无蓝条
5. **Monk 治疗统一**：移除独立 HEAL 状态机，治疗作为技能纳入框架
6. **移除旧情绪系统**：删除 unit_emotion.gd 及引用

### 1.2 验收标准
- [ ] Stoneguard 被围攻时自动嘲讽，消耗蓝量，进入冷却
- [ ] Blinker 追击时闪现，消耗蓝量
- [ ] Inquisitor 箭矢命中时驱散敌方 buff
- [ ] Necromancer 攻击时概率发射弹道，落地召唤骷髅
- [ ] Enchanter 引导劝化，成功时转化目标
- [ ] Warden 自动给受伤友军加盾（弹道飞过去）
- [ ] Monk 自动治疗最近受伤友军（弹道飞过去），无独立 HEAL 状态
- [ ] Shadowblade 闲置时自动隐身
- [ ] 法师/射手单位 HP 条下方显示蓝色 MP 条
- [ ] 近战单位无 MP 条
- [ ] 所有原有功能正常运作，无新增报错
- [ ] 控制台无 "Emotion" 相关报错

---

## 二、设计总览

### 技能数据流

```
.tres 文件 (SkillResource)        数据层：定义技能参数
       ↓
SkillComponent (Node)             运行时层：管理冷却/触发/释放
       ↓
skill_effects/*.gd                 效果层：实现具体效果逻辑
       ↓
unit.gd + game_spawner.gd          执行层：挂载到场景、发射弹道等
```

### SkillResource 设计

```gdscript
class_name SkillResource extends Resource

enum DeliveryType {
    PROJECTILE,      # 弹道投射：召唤/治疗/劝化/护盾
    INSTANT_SELF,    # 自身即时：隐身
    INSTANT_RANGE,   # 范围即时：嘲讽
}

enum TargetType {
    ENEMY_NEAREST,              # 最近敌人
    ALLY_NEAREST_WOUNDED,       # 最近受伤友军
    SELF,                       # 自身
    CURRENT_ATTACK_TARGET,      # 当前攻击目标
}

enum TriggerCondition {
    ON_ATTACK,          # 每次攻击时触发（召唤、驱散）
    PERIODIC_SCAN,      # 周期性扫描触发（嘲讽、治疗、护盾）
    ON_CHASE,           # 追击时触发（闪现）
    PASSIVE,            # 被动持续效果（隐身）
}

@export var skill_name: String = ""
@export var delivery_type: DeliveryType
@export var target_type: TargetType
@export var trigger_condition: TriggerCondition
@export var cooldown: float = 0.0
@export var mana_cost: float = 0.0
@export var cast_range: float = 0.0
@export var trigger_interval: float = 1.0    # PERIODIC_SCAN 的扫描间隔
@export var priority: int = 0                 # AI决策优先级（数字越大越优先）
@export var effect_scene: PackedScene = null  # 弹道场景（PROJECTILE 时用）
@export var projectile_data: Resource = null  # 弹道数据
```

### SkillComponent 设计

```gdscript
class_name SkillComponent extends Node

var resource: SkillResource      # 绑定的技能数据
var unit: Unit                   # 所属单位
var cooldown_timer: float = 0.0
var trigger_timer: float = 0.0

func can_activate() -> bool      # 检查冷却+蓝量
func find_target() -> Node2D     # 按 TargetType 选目标
func activate(target) -> void    # 释放技能（扣蓝、设CD、触发效果）
func _on_hit(target) -> void     # 弹道命中回调
```

---

## 三、详细改动

### 3.1 新增目录结构

```
scripts/skills/
├── skill_resource.gd           # 技能数据 Resource
├── skill_component.gd          # 技能运行时组件
└── skill_effects/
    ├── taunt_effect.gd         # 嘲讽
    ├── blink_effect.gd         # 闪现
    ├── convert_effect.gd       # 劝化
    ├── shield_effect.gd        # 护盾
    ├── summon_effect.gd        # 召唤（复用已有逻辑）
    ├── heal_effect.gd          # 治疗
    ├── stealth_effect.gd       # 隐身
    └── dispel_effect.gd        # 驱散

resources/skills/               # .tres 技能配置文件
├── taunt.tres
├── blink.tres
├── convert.tres
├── shield.tres
├── summon.tres
├── heal.tres
├── stealth.tres
└── dispel.tres
```

### 3.2 Step 1：SkillResource — 技能数据定义

**新增** `scripts/skills/skill_resource.gd`：

```gdscript
class_name SkillResource
extends Resource

enum DeliveryType {
    PROJECTILE,      # 弹道投射
    INSTANT_SELF,    # 自身即时
    INSTANT_RANGE,   # 范围即时
}

enum TargetType {
    ENEMY_NEAREST,
    ALLY_NEAREST_WOUNDED,
    SELF,
    CURRENT_ATTACK_TARGET,
}

enum TriggerCondition {
    ON_ATTACK,       # 攻击时触发
    PERIODIC_SCAN,   # 周期性扫描
    ON_CHASE,        # 追击时触发
    PASSIVE,         # 被动持续
}

enum SkillCategory {
    ACTIVE,          # 主动技能（消耗蓝+冷却）
    ALTERNATIVE,     # 替代攻击（链式闪电/锥形AoE，不消耗蓝）
    PASSIVE,         # 被动（不消耗蓝，持续生效）
}

@export var skill_name: String = ""
@export var category: SkillCategory = SkillCategory.ACTIVE
@export var delivery_type: DeliveryType = DeliveryType.INSTANT_SELF
@export var target_type: TargetType = TargetType.ENEMY_NEAREST
@export var trigger_condition: TriggerCondition = TriggerCondition.ON_ATTACK
@export var cooldown: float = 0.0
@export var mana_cost: float = 0.0
@export var cast_range: float = 0.0
@export var trigger_interval: float = 1.0
@export var priority: int = 0
@export var effect_scene: PackedScene = null
@export var projectile_data: Resource = null
```

**验证**：编译通过，无报错

### 3.3 Step 2：SkillComponent — 技能运行时

**新增** `scripts/skills/skill_component.gd`：

```gdscript
extends Node
class_name SkillComponent

var skill_resource: SkillResource
var unit: Unit
var cooldown_timer: float = 0.0
var trigger_timer: float = 0.0
var _target: Node2D = null

func _ready() -> void:
    unit = get_parent() as Unit
    if unit == null:
        push_error("SkillComponent must be child of Unit")
        return
    if skill_resource == null:
        push_error("SkillComponent has no skill_resource")
        return

## 能否激活
func can_activate() -> bool:
    if cooldown_timer > 0.0:
        return false
    if unit.mana < skill_resource.mana_cost:
        return false
    return true

## 寻找目标
func find_target():
    var target = null
    match skill_resource.target_type:
        SkillResource.TargetType.ENEMY_NEAREST:
            target = _find_nearest_enemy()
        SkillResource.TargetType.ALLY_NEAREST_WOUNDED:
            target = _find_nearest_wounded_ally()
        SkillResource.TargetType.SELF:
            target = unit
        SkillResource.TargetType.CURRENT_ATTACK_TARGET:
            target = unit.attack_target
    return target

## 释放技能
func activate(target) -> void:
    if not can_activate():
        return
    if target == null or not is_instance_valid(target):
        return
    
    # 扣蓝 + 设冷却
    unit.mana = max(0.0, unit.mana - skill_resource.mana_cost)
    cooldown_timer = skill_resource.cooldown
    
    # 按交付方式执行
    match skill_resource.delivery_type:
        SkillResource.DeliveryType.PROJECTILE:
            _deliver_projectile(target)
        SkillResource.DeliveryType.INSTANT_SELF:
            _apply_effect(unit, unit)
        SkillResource.DeliveryType.INSTANT_RANGE:
            _apply_effect(unit, target)
    
    # 浮动文字
    SkillFloatingText.show(unit, skill_resource.skill_name)

## 弹道交付
func _deliver_projectile(target) -> void:
    var spawner = unit.get_tree().current_scene.get("spawner_module")
    if spawner == null:
        return
    var target_pos := target.global_position if target.has_method("get_global_position") else unit.global_position
    # 创建闭包捕获目标
    var captured_target := target
    var callback := func():
        if not is_instance_valid(unit):
            return
        var final_target := captured_target
        if is_instance_valid(captured_target) and not captured_target.is_dead():
            final_target = captured_target
        _apply_effect(unit, final_target)
    
    spawner.spawn_projectile(
        skill_resource.projectile_data,
        unit.global_position,
        target_pos,
        null, unit, 0,
        skill_resource.effect_scene,
        callback
    )

## 实际效果（由子类重写）
func _apply_effect(caster: Unit, target) -> void:
    pass  # 子类实现
```

**注意**：SkillComponent 不直接实现效果，而是作为基类。每个技能有自己的子类。

**验证**：编译通过，无报错

### 3.4 Step 3：各个技能效果实现

每个效果一个文件，继承 SkillComponent 并实现 `_apply_effect()`。

#### 3.4a 嘲讽 — `taunt_effect.gd`

```gdscript
extends SkillComponent

func _apply_effect(caster: Unit, target) -> void:
    if target == null or not is_instance_valid(target):
        return
    # 强制目标攻击施法者
    if target.has_method("force_attack_target"):
        target.force_attack_target(caster, skill_resource.cooldown)  # 复用 cooldown 作为持续时间
```

**配置**：`taunt.tres`
- delivery_type: INSTANT_RANGE, target_type: ENEMY_NEAREST
- trigger: PERIODIC_SCAN, trigger_interval: 3.0
- cooldown: 3.0（同时作为嘲讽持续时间）, mana_cost: 15
- cast_range: 150

**迁移来源**：`unit.gd:1714-1752` `_taunt_process()` + `force_attack_target()`

#### 3.4b 闪现 — `blink_effect.gd`

```gdscript
extends SkillComponent

func _apply_effect(caster: Unit, target) -> void:
    if target == null or not is_instance_valid(target):
        return
    var dir := caster.global_position.direction_to(target.global_position)
    var blink_dist := caster.stats_data.blink_range if caster.stats_data else 100.0
    caster.global_position = target.global_position + dir * (-blink_dist * 0.5)
```

**配置**：`blink.tres`
- delivery_type: INSTANT_SELF, target_type: CURRENT_ATTACK_TARGET
- trigger: ON_CHASE, cooldown: 5.0, mana_cost: 10

**迁移来源**：`unit.gd:1692-1703` `_try_blink_toward()`

#### 3.4c 劝化 — `convert_effect.gd`

```gdscript
extends SkillComponent

var _channel_time: float = 0.0
var _channel_target = null

func _apply_effect(caster: Unit, target) -> void:
    # 劝化是引导型，这里只标记目标开始引导
    _channel_target = target
    _channel_time = 0.0

func _process(delta: float) -> void:
    if _channel_target == null or not is_instance_valid(_channel_target):
        _channel_target = null
        _channel_time = 0.0
        return
    # 目标超出范围则放弃
    var dist := unit.global_position.distance_to(_channel_target.global_position)
    if dist > skill_resource.cast_range:
        _channel_target = null
        _channel_time = 0.0
        return
    # 引导累加
    var channel_needed := unit.stats_data.convert_channel_time if unit.stats_data else 3.0
    _channel_time += delta
    if _channel_time >= channel_needed:
        _do_convert(_channel_target)
        _channel_target = null
        _channel_time = 0.0

func _do_convert(target) -> void:
    # 复用 unit.gd 现有 _convert_unit 逻辑
    if unit.has_method("_convert_unit"):
        unit._convert_unit(target)
```

**配置**：`convert.tres`
- delivery_type: PROJECTILE, target_type: ENEMY_NEAREST
- trigger: PERIODIC_SCAN, trigger_interval: 0.5
- mana_cost: 30, cast_range: 200
- effect_scene: 劝化弹道（新建紫色弹道场景）

**迁移来源**：`unit.gd:1781-1856` `_convert_process()` 系列

**⚠️ 注意**：劝化是引导型技能，`_process()` 在 SkillComponent 中持续运行。需要确保 `_process` 不与基类冲突——实际上 SkillComponent 的 `_process` 默认不存在，子类可以自由覆盖。

#### 3.4d 护盾 — `shield_effect.gd`

```gdscript
extends SkillComponent

func _apply_effect(caster: Unit, target) -> void:
    if target == null or not is_instance_valid(target):
        return
    if target.has_method("set_shield_hp"):
        var shield_amt := caster.stats_data.shield_amount if caster.stats_data else 30
        target.set_shield_hp(shield_amt)
```

需要在 unit.gd 新增 `set_shield_hp()` 方法（或直接设置 `_shield_hp` 字段）。

**配置**：`shield.tres`
- delivery_type: PROJECTILE, target_type: ALLY_NEAREST_WOUNDED
- trigger: PERIODIC_SCAN, trigger_interval: 3.0
- mana_cost: 10, cast_range: 200

**迁移来源**：`unit.gd:1862-1865` aura 中的 shield 部分

#### 3.4e 召唤 — `summon_effect.gd`

```gdscript
extends SkillComponent

func _apply_effect(caster: Unit, target) -> void:
    # 直接复用 Phase 1 改造后的 _try_summon_minion
    if caster.has_method("_try_summon_minion"):
        caster._try_summon_minion()
```

**配置**：`summon.tres`
- delivery_type: PROJECTILE, target_type: CURRENT_ATTACK_TARGET
- trigger: ON_ATTACK, cooldown: 0.0, mana_cost: 5
- effect_scene: summon_projectile.tscn

**迁移来源**：`unit.gd:1586-1632` `_try_summon_minion()`（Phase 1 已改造）

#### 3.4f 治疗 — `heal_effect.gd`

```gdscript
extends SkillComponent

func _apply_effect(caster: Unit, target) -> void:
    if target == null or not is_instance_valid(target):
        return
    if target.has_method("heal") or (target.has_method("get_health")):
        var heal_amt := caster.stat_set.get_int("HEAL_AMOUNT") if caster.stat_set else 20
        target.heal(heal_amt)
        # 审判官：治疗时清除友军 debuff
        if caster.stats_data and caster.stats_data.cleanse_on_heal and target.has_method("cleanse_debuffs"):
            target.cleanse_debuffs()
```

**配置**：`heal.tres`
- delivery_type: PROJECTILE, target_type: ALLY_NEAREST_WOUNDED
- trigger: PERIODIC_SCAN, trigger_interval: 0.5
- mana_cost: 5, cast_range: 200
- effect_scene: 治疗弹道（新建绿色光球场景）

**迁移来源**：`unit.gd:775-795` `_heal_process()` + HEAL 状态机

#### 3.4g 隐身 — `stealth_effect.gd`

```gdscript
extends SkillComponent

func _apply_effect(caster: Unit, target) -> void:
    pass  # 隐身是被动持续效果，不需要激活
```

**配置**：`stealth.tres`
- delivery_type: INSTANT_SELF, target_type: SELF
- trigger: PASSIVE, mana_cost: 0

**迁移来源**：`unit.gd:1694-1703` `_stealth_process()`

#### 3.4h 驱散 — `dispel_effect.gd`

```gdscript
extends SkillComponent

func _apply_effect(caster: Unit, target) -> void:
    if target == null or not is_instance_valid(target):
        return
    if target.has_method("clear_buffs"):
        target.clear_buffs()
```

**配置**：`dispel.tres`
- delivery_type: PROJECTILE, target_type: CURRENT_ATTACK_TARGET
- trigger: ON_ATTACK, mana_cost: 0
- effect_scene: 用现有 arrow.tscn（驱散是弓箭命中时触发）

**迁移来源**：arrow.gd 第 58-59 行的驱散逻辑 + `unit.gd:1559-1565` `dispel_target()`

---

### 3.5 Step 4：创建 .tres 技能配置文件

在 `resources/skills/` 下创建 8 个 .tres 文件。每个文件内容类似：

**taunt.tres**：
```
[gd_resource type=Resource script=res://scripts/skills/skill_resource.gd]

[resource]
skill_name = "嘲讽"
category = 0  # ACTIVE
delivery_type = 2  # INSTANT_RANGE
target_type = 0  # ENEMY_NEAREST
trigger_condition = 1  # PERIODIC_SCAN
cooldown = 3.0
mana_cost = 15.0
cast_range = 150.0
trigger_interval = 3.0
priority = 50
```

**blink.tres**：
```
[gd_resource]
skill_name = "闪现"
category = 0
delivery_type = 1  # INSTANT_SELF
target_type = 3  # CURRENT_ATTACK_TARGET
trigger_condition = 2  # ON_CHASE
cooldown = 5.0
mana_cost = 10.0
priority = 30
```

其他 .tres 文件同理，按各技能配置参数。

---

### 3.6 Step 5：修改 UnitStats — 新增技能和蓝字段

**修改** `scripts/stats/unit_stats.gd`，在文件末尾新增（第 106 行后）：

```gdscript
# --- 技能系统（Phase 2） ---
@export var skills: Array[Resource] = []        # SkillResource 数组
@export var mana_type: int = 0                  # 0=NONE, 1=MAGE, 2=ARCHER
@export var max_mana: float = 0.0               # 最大蓝量
@export var mana_regen: float = 0.0             # 每秒回蓝
```

**现有 .tres 文件修改**：
- Necromancer → mana_type=1(MAGE), max_mana=100, mana_regen=2, skills=[summon.tres]
- Stoneguard → mana_type=1(MAGE), max_mana=80, mana_regen=1.5, skills=[taunt.tres]
- Blinker → mana_type=2(ARCHER), max_mana=60, mana_regen=2, skills=[blink.tres]
- Enchanter → mana_type=1(MAGE), max_mana=120, mana_regen=1, skills=[convert.tres]
- Warden → mana_type=1(MAGE), max_mana=100, mana_regen=2, skills=[shield.tres]
- Monk → mana_type=1(MAGE), max_mana=80, mana_regen=3, skills=[heal.tres]
- Shadowblade → mana_type=2(ARCHER), max_mana=50, mana_regen=1, skills=[stealth.tres]
- Inquisitor → mana_type=2(ARCHER), max_mana=60, mana_regen=2, skills=[dispel.tres]
- Stormcaller → mana_type=1(MAGE), max_mana=100, mana_regen=2, skills=[]（链式闪电是替代攻击，先不动）
- Salamander → mana_type=1(MAGE), max_mana=80, mana_regen=1.5, skills=[]（锥形AoE同理）

---

### 3.7 Step 6：修改 unit.gd — 集成技能框架

#### 6a：新增变量（第 60 行附近）

```gdscript
# 技能系统（Phase 2）
var mana: float = 0.0
var max_mana: float = 0.0
var mana_regen: float = 0.0
var _skill_components: Array[SkillComponent] = []
```

替换掉 `# Monk 治疗系统` 相关变量（第 76-78 行）：
```gdscript
# 移除 heal_target, _is_healing（由技能组件接管）
```

#### 6b：修改 _setup_stats()（第 221 行）

在 `_setup_stats()` 末尾新增：
```gdscript
# Phase 2：技能系统初始化
if stats_data:
    max_mana = stats_data.max_mana
    mana_regen = stats_data.mana_regen
    mana = max_mana  # 开局满蓝
    # 创建技能组件
    _setup_skills()
```

#### 6c：新增 _setup_skills() 方法

```gdscript
## 根据 stats_data.skills 创建 SkillComponent 子节点
func _setup_skills() -> void:
    if stats_data == null or stats_data.skills.is_empty():
        return
    for skill_res in stats_data.skills:
        if skill_res == null:
            continue
        var comp: SkillComponent
        match skill_res.skill_name:
            "嘲讽": comp = load("res://scripts/skills/skill_effects/taunt_effect.gd").new()
            "闪现": comp = load("res://scripts/skills/skill_effects/blink_effect.gd").new()
            "劝化": comp = load("res://scripts/skills/skill_effects/convert_effect.gd").new()
            "护盾": comp = load("res://scripts/skills/skill_effects/shield_effect.gd").new()
            "召唤": comp = load("res://scripts/skills/skill_effects/summon_effect.gd").new()
            "治疗": comp = load("res://scripts/skills/skill_effects/heal_effect.gd").new()
            "隐身": comp = load("res://scripts/skills/skill_effects/stealth_effect.gd").new()
            "驱散": comp = load("res://scripts/skills/skill_effects/dispel_effect.gd").new()
            _:
                comp = SkillComponent.new()
        comp.skill_resource = skill_res
        comp.name = "Skill_" + skill_res.skill_name
        add_child(comp)
        _skill_components.append(comp)
```

#### 6d：修改 _physics_process()（第 493 行）

在状态机分发前（第 550 行，`match state` 之前），新增技能 AI 循环：

```gdscript
# Phase 2：技能系统——冷却递减 + 蓝量恢复
for comp in _skill_components:
    if comp.cooldown_timer > 0.0:
        comp.cooldown_timer = max(0.0, comp.cooldown_timer - delta)
    if comp.skill_resource and comp.skill_resource.trigger_condition == SkillResource.TriggerCondition.PERIODIC_SCAN:
        comp.trigger_timer += delta
        if comp.trigger_timer >= comp.skill_resource.trigger_interval:
            comp.trigger_timer = 0.0
            if comp.can_activate():
                var target := comp.find_target()
                if target != null:
                    comp.activate(target)

# 蓝量恢复
if max_mana > 0.0 and mana < max_mana:
    mana = min(max_mana, mana + mana_regen * delta)
```

**⚠️ 移除以下旧 process 调用**（第 519-530 行）：
```gdscript
# 移除：
# _taunt_process(delta)        # 由技能组件接管
# _convert_process(delta)      # 由技能组件接管
# _stealth_process(delta)      # 由技能组件接管
# 保留：
# _aura_process(delta)          # 光环系统暂不移除
# _blink_timer 冷却递减         # 由技能组件接管

# 同时移除 _blink_timer 和 _taunt_expire_timer 的递减
```

#### 6e：修改状态机分发（第 551 行）

```gdscript
match state:
    UnitState.GUARD:
        _guard_process(delta)
    UnitState.HOLD_POSITION:
        _hold_position_process(delta)
    UnitState.MOVE:
        _move_process()
    UnitState.ATTACK_MOVE:
        _attack_move_process(delta)
    UnitState.ATTACK:
        _attack_process(delta)
    # UnitState.HEAL:            # 移除 HEAL 状态
    #     _heal_process(delta)
```

#### 6f：修改 _guard_process()（第 821 行）

移除 Monk 的特殊治疗逻辑，改为统一扫描敌人：
```gdscript
func _guard_process(delta: float) -> void:
    # Monk 不再有特殊治疗逻辑——由技能组件处理
    if _should_scan_this_frame():
        _cached_scan_enemy = _find_closest_enemy_in_range(attack_move_scan_range)
    var closest = _cached_scan_enemy if _is_target_alive(_cached_scan_enemy) else null
    if closest != null:
        attack_target = closest
        attack_command_source = CommandSource.AUTO
        nav_agent.target_position = _get_building_nav_target(closest)
        state = UnitState.ATTACK
        hold_position_mode = false
```

#### 6g：修改 _attack_move_process()（第 684 行）

移除 Monk 特殊治疗：
```gdscript
func _attack_move_process(delta: float) -> void:
    # Monk 不再特殊处理——技能组件会处理治疗
    if _should_scan_this_frame():
        _cached_scan_enemy = _find_closest_enemy_in_range(attack_move_scan_range)
    ...
```

#### 6h：修改 _attack_process()（第 615 行）

Monk 的治疗逻辑由技能组件接管，Monk 仍然不执行普通攻击：
```gdscript
func _attack_process(delta: float) -> void:
    if unit_type == UnitType.MONK:
        return  # Monk 不攻击（保持不变）
    ...
```

#### 6i：新增 _skill_ai_on_attack()

在 `_perform_attack()` 末尾（第 1029 行 `_try_summon_minion()` 后）调用：
```gdscript
# Phase 2：触发 ON_ATTACK 技能
for comp in _skill_components:
    if comp.skill_resource and comp.skill_resource.trigger_condition == SkillResource.TriggerCondition.ON_ATTACK:
        if comp.can_activate():
            var target := comp.find_target()
            if target != null:
                comp.activate(target)
```

#### 6j：新增 _skill_ai_on_chase()

在 `_attack_process()` 中闪现触发位置（第 637-638 行）改为调用技能组件：
```gdscript
# 原代码：
# if stats_data and stats_data.blink_range > 0.0 and _blink_timer <= 0.0:
#     _try_blink_toward(attack_target)

# 改为：
for comp in _skill_components:
    if comp.skill_resource and comp.skill_resource.trigger_condition == SkillResource.TriggerCondition.ON_CHASE:
        if comp.can_activate():
            var target := comp.find_target()
            if target != null:
                comp.activate(target)
                break  # 一次追击只触发一个闪现技能
```

#### 6k：保留 _try_summon_minion() 但改为走技能组件

`_try_summon_minion()` 保持不变（Phase 1 已改造），但 `_perform_attack()` 中通过 ON_ATTACK 技能来调用它。

或者保持原有 `_try_summon_minion()` 调用不变，同时 ON_ATTACK 触发的召唤技能组件也调用它——这样不会重复，因为 `_try_summon_minion()` 内部有概率和上限检查。

实际上更清晰的做法是：`_perform_attack()` 末尾的 ON_ATTACK 循环会触发召唤技能组件，所以原有的 `_try_summon_minion()` 调用可以移除，由技能组件接管。

---

### 3.8 Step 7：移除旧代码

#### 移除的方法
| 方法 | 原因 |
|------|------|
| `_taunt_process()` | 由 taunt_effect.gd 接管 |
| `_convert_process()` | 由 convert_effect.gd 接管 |
| `_convert_unit()` | 由 convert_effect.gd 接管（或保留供 convert_effect 调用） |
| `_find_convert_target()` | 由 SkillComponent.find_target() 接管 |
| `_stealth_process()` | 由 stealth_effect.gd 接管 |
| `_try_blink_toward()` | 由 blink_effect.gd 接管 |
| `_heal_process()` | 由 heal_effect.gd 接管 |
| `force_attack_target()` | **保留**（嘲讽效果需要调用） |
| `is_taunted()` | **保留**（供 AI 决策参考） |
| `dispel_target()` | **保留**（arrow 回调中仍可能直接调用） |
| `clear_buffs()` | **保留**（驱散效果需要调用） |
| `cleanse_debuffs()` | **保留**（治疗效果需要调用） |

#### 移除的变量
| 变量 | 原因 |
|------|------|
| `heal_target` | 由技能组件管理 |
| `_is_healing` | 不再需要 |
| `_blink_timer` | 由技能组件管理冷却 |
| `_taunt_pulse_timer` | 由技能组件管理 |
| `_taunt_expire_timer` | **保留**（被嘲讽状态需要） |
| `_convert_target` | 由 convert_effect.gd 管理 |
| `_convert_channel` | 由 convert_effect.gd 管理 |
| `_convert_aura_timer` | 由 convert_effect.gd 管理 |
| `_stealth_reveal_timer` | **保留**（隐身显形逻辑需要） |

#### 移除情绪系统
- 删除 `scripts/systems_game/unit_emotion.gd`
- 删除 `enemy_ai.gd` 中引用 emotion 的代码（第 40-43 行）

---

### 3.9 Step 8：蓝条 UI

#### 修改 health 显示

当前 HP 条在 `unit.gd` 中通过 `hp_bar: ProgressBar` 管理。需要在下方面加 MP 条。

**新增** `scripts/ui/mana_bar.gd`：
```gdscript
extends ProgressBar

func _ready() -> void:
    # 设置为细蓝条
    custom_minimum_size = Vector2(0, 4)
    # 颜色在场景中设置
```

**修改单位场景**：在每个单位的 .tscn 中添加 MP 条（HP 条下方）。
或者更简单：在 unit.gd 中用代码创建。

在 `_ready()` 中新增：
```gdscript
# Phase 2：蓝条
if max_mana > 0.0:
    _mana_bar = ProgressBar.new()
    _mana_bar.custom_minimum_size = Vector2(0, 4)
    _mana_bar.max_value = max_mana
    _mana_bar.value = mana
    _mana_bar.position = Vector2(-20, 30)  # HP 条下方
    _mana_bar.size = Vector2(40, 4)
    add_child(_mana_bar)
```

在 `_physics_process()` 末尾更新：
```gdscript
if _mana_bar and max_mana > 0.0:
    _mana_bar.value = mana
    _mana_bar.max_value = max_mana
    _mana_bar.modulate = Color(0.3, 0.5, 1.0, 0.8)  # 蓝色
```

---

### 3.10 Step 9：新建弹道场景

#### 治疗弹道 `scenes/effects/heal_projectile.tscn`
基于 `arrow.tscn`，绿色光球：
```
[node name="ArrowSprite" type="ColorRect" parent="."]
color = Color(0.2, 0.9, 0.3, 0.9)
```

#### 护盾弹道 `scenes/effects/shield_projectile.tscn`
基于 `arrow.tscn`，蓝色光球：
```
[node name="ArrowSprite" type="ColorRect" parent="."]
color = Color(0.2, 0.5, 1.0, 0.9)
```

#### 劝化弹道 `scenes/effects/convert_projectile.tscn`
基于 `arrow.tscn`，金色光球：
```
[node name="ArrowSprite" type="ColorRect" parent="."]
color = Color(1.0, 0.8, 0.2, 0.9)
```

---

## 四、实施步骤

```
Step 1: skill_resource.gd 新建
Step 2: skill_component.gd 新建
Step 3: 8 个 skill_effects/*.gd 新建
Step 4: 8 个 .tres 配置文件创建
Step 5: unit_stats.gd 新增字段
Step 6: 修改现有 .tres 文件（加技能/蓝条字段）
Step 7: unit.gd 集成技能框架（大改）
Step 8: 移除旧代码
Step 9: 蓝条 UI
Step 10: 新建弹道场景（治疗/护盾/劝化）
Step 11: 全面回归验证
```

---

## 五、风险与应对

| # | 风险 | 概率 | 影响 | 应对 |
|---|------|------|------|------|
| 1 | unit.gd 大改引入回归 bug | 高 | 单位无法攻击/移动 | 每改完一个函数立即运行测试；用 git 分步提交 |
| 2 | HEAL 状态移除后 Monk 发呆 | 中 | Monk 不治疗 | heal_effect 的 PERIODIC_SCAN 必须正常工作 |
| 3 | 移除旧 process 后某些技能不触发 | 中 | 技能沉默 | 逐技能验证，对照验收清单 |
| 4 | 蓝条 UI 和 HP 条位置冲突 | 低 | 显示重叠 | 调整 MP 条 position.y 偏移量 |
| 5 | 多个技能组件同时触发（如嘲讽+护盾） | 低 | 蓝量竞争 | 按 priority 排序，蓝不足时跳过低优先级 |
| 6 | 劝化引导期间 _process 冲突 | 中 | 劝化失败 | convert_effect 单独测试引导流程 |
| 7 | 隐身技能 PASSIVE 类型不触发 | 中 | 隐身不工作 | PASSIVE 类型在 _physics_process 中无条件执行 |

---

## 六、验证方式

### 逐技能验证
```
1. 选定 Stoneguard → 被围攻 → 头顶"嘲讽"+ 敌人强制攻击 Stoneguard
2. 选定 Blinker → 攻击远处敌人 → 闪现到目标附近 + 蓝量减少
3. 选定 Enchanter → 靠近敌人 → 引导 → 金色光球 → 目标转化
4. 选定 Warden → 友军受伤 → 蓝色光球 → 友军获得护盾
5. 选定 Necromancer → 攻击敌人 → 紫色光球 → 落地出骷髅
6. 选定 Monk → 友军受伤 → 绿色光球 → 友军回血
7. 选定 Shadowblade → 闲置 → 半透明（隐身）
8. 选定 Inquisitor → 攻击有 buff 的敌人 → 箭矢命中 → buff 被清除
```

### 蓝条验证
```
1. 选定 Necromancer → 攻击 → 蓝量减少 → 回蓝
2. 选定 Soldier（近战）→ 无蓝条显示
3. 选定 Archer → 无蓝条（无技能的射手）
```

### 回归验证
```
1. 所有兵种正常攻击/移动/受击/死亡
2. 指挥官技能正常释放
3. 敌方 AI 正常巡逻/追击
4. 建筑正常运作
5. 无 Emotion 相关报错
```

---

## 七、回滚方案

| 情况 | 操作 |
|------|------|
| 某个技能不工作 | 回退该技能的 .tres 和 effect 文件，恢复旧 process |
| Monk 发呆 | 临时恢复 HEAL 状态，推迟迁移 |
| 蓝条显示异常 | 回退蓝条 UI 代码，蓝条逻辑保留（只是不显示） |
| 全面崩溃 | git checkout unit.gd + unit_stats.gd，恢复旧版本 |
