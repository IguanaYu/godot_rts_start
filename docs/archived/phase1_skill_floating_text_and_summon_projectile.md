# 第一阶段执行计划：技能浮动文字 + 召唤弹道

> 对应整体计划的"第一阶段目标：视觉基础"
> 核心目标：解决"看不到技能在放"的问题

---

## 一、需求与验收标准

### 1.1 需求
1. **技能浮动文字**：单位触发任何主动技能时，头顶弹出绿色技能名文字
2. **召唤弹道**：Necromancer 召唤骷髅改为弹道落地生成，不再凭空出现
3. **弹道回调框架**：改造 arrow.gd，支持命中时执行任意自定义回调

### 1.2 验收标准
- [ ] 选定 Necromancer 攻击敌人，触发召唤时：头顶弹出"召唤"→紫色光球飞出→落地生成骷髅
- [ ] 选定 Stoneguard 被围攻：头顶弹出"嘲讽"
- [ ] 选定 Stormcaller 攻击：头顶弹出"连锁闪电"
- [ ] 选定 Salamander 攻击：头顶弹出"锥形攻击"
- [ ] 选定 Blinker 追击敌人：头顶弹出"闪现"
- [ ] 选定 Inquisitor 攻击驱散：头顶弹出"驱散"
- [ ] 选定 Monk 治疗：头顶弹出"治疗"
- [ ] 选定 Enchanter 劝化：头顶弹出"劝化"
- [ ] 选定 Archer 攻击：正常射箭，无绿色文字（不受影响）
- [ ] 所有兵种正常攻击、移动、受击，无新增报错

---

## 二、详细技术方案

### 2.1 新增文件：`scripts/effects/skill_floating_text.gd`

#### 代码
```gdscript
extends Node2D

## 在单位头顶显示技能名浮动文字（绿色）
## 复用 floating_text.gd 的弹出→上飘→淡出动画
static func show(unit: Node2D, skill_name: String) -> void:
    if not is_instance_valid(unit):
        return
    var ft := Node2D.new()
    ft.set_script(preload("res://scripts/effects/floating_text.gd"))
    unit.get_tree().current_scene.add_child(ft)
    ft.setup(skill_name, Color(0.3, 1.0, 0.3), unit.global_position + Vector2(0, -40))
```

#### 说明
- 静态方法，直接 `SkillFloatingText.show(unit, "技能名")` 调用
- 颜色：亮绿色 `#4CFF4C`
- 位置：单位头顶上方 40px
- 复用 `floating_text.gd` 的动画：0.3s 弹入放大 → 上飘 80px → 淡出 → 2s 后自销毁

---

### 2.2 修改文件：`scripts/effects/arrow.gd`

#### 修改点 A：新增字段（第 13 行后）
```gdscript
var hit_callback: Callable = Callable()
```

#### 修改点 B：改写 `_on_hit()`（原第 47-56 行）
```gdscript
func _on_hit() -> void:
    # 如果有自定义回调，优先执行回调并跳过默认伤害逻辑
    if hit_callback.is_valid():
        hit_callback.call()
        queue_free()
        return
    
    # 原伤害逻辑不变
    if hit_target != null and is_instance_valid(hit_target) and not hit_target.is_dead():
        hit_target.take_damage(hit_damage, shooter)
    # 驱散：射击者命中时清除目标增益（Inquisitor）
    if shooter != null and is_instance_valid(shooter) and shooter.has_method("dispel_target"):
        shooter.dispel_target(hit_target)
    if data:
        for effect: Resource in data.effects:
            effect.apply(self, hit_target)
```

#### 边界情况
| 场景 | 行为 |
|------|------|
| hit_callback 未设置（默认 Callable） | `is_valid()` 返回 false，走原逻辑 |
| hit_callback 已设置 | 走回调，不造成伤害 |
| callback 内操作 arrow 自身 | 不允许——callback 返回后立即 queue_free |

---

### 2.3 修改文件：`scripts/systems/game_spawner.gd`

#### 修改点：`spawn_projectile()` 签名（第 504 行）

**原签名**：
```gdscript
func spawn_projectile(data: Resource, from: Vector2, to: Vector2, target, shooter, damage: int, custom_arrow: PackedScene = null) -> void:
```

**改为**：
```gdscript
func spawn_projectile(data: Resource, from: Vector2, to: Vector2, target, shooter, damage: int, custom_arrow: PackedScene = null, hit_callback: Callable = Callable()) -> void:
```

#### 修改点：arrow 赋值后追加（第 525 行后）
```gdscript
arrow.hit_callback = hit_callback
```

#### 现有调用检查（确保零影响）
在 `game_spawner.gd` 内搜索所有 `spawn_projectile(` 的调用：
- 第 504 行：定义本身
- 搜索全文件确认有无其他调用——只在 `unit.gd:_spawn_arrow`（第 1130 行）被调用
- 该调用传 7 个参数，不传 hit_callback → 默认空 Callable → 零影响

---

### 2.4 新增文件：`scenes/effects/summon_projectile.tscn`

```
[gd_scene load_steps=2 format=3 uid="uid://summonproj001"]

[ext_resource type="Script" path="res://scripts/effects/arrow.gd" id="arrow_script"]

[node name="SummonProjectile" type="Node2D"]
script = ExtResource("arrow_script")

[node name="SummonSprite" type="ColorRect" parent="."]
offset_left = -8.0
offset_top = -8.0
offset_right = 8.0
offset_bottom = 8.0
color = Color(0.7, 0.2, 0.8, 0.9)
```

视觉：16×16 紫色方形光球，后续可替换为骷髅头/灵魂球精灵纹理

**注意**：`arrow.tscn` 的 Sprite 节点名为 `ArrowSprite`，这里改为 `SummonSprite` 以避免混淆。arrow.gd 中通过 `$ArrowSprite` 引用该节点，但 summon 场景的子节点名不同——需要检查 arrow.gd 是否硬编码了节点名。

检查 arrow.gd 第 15 行：
```gdscript
@onready var sprite: ColorRect = $ArrowSprite
```

**→ 这里硬编码了 `$ArrowSprite`**。所以 summon 场景中**必须**保持子节点名为 `ArrowSprite`，否则会 null 报错。

**修正后的 summon_projectile.tscn**：
```
[gd_scene load_steps=2 format=3 uid="uid://summonproj001"]

[ext_resource type="Script" path="res://scripts/effects/arrow.gd" id="arrow_script"]

[node name="SummonProjectile" type="Node2D"]
script = ExtResource("arrow_script")

[node name="ArrowSprite" type="ColorRect" parent="."]
offset_left = -8.0
offset_top = -8.0
offset_right = 8.0
offset_bottom = 8.0
color = Color(0.7, 0.2, 0.8, 0.9)
```

---

### 2.5 修改文件：`scripts/units/unit.gd`

#### 修改点 A：文件顶部新增常量（第 12 行 `UnitEffectsShader` 后面）
```gdscript
const SkillFloatingText := preload("res://scripts/effects/skill_floating_text.gd")
```

#### 修改点 B：改造 `_try_summon_minion()`（原第 1579-1611 行）

**原代码**：
```gdscript
func _try_summon_minion() -> void:
    if stats_data == null or stats_data.summon_max <= 0:
        return
    if randf() > stats_data.summon_chance:
        return
    _prune_dead_minions()
    if _summoned_minions.size() >= stats_data.summon_max:
        return
    var spawner = get_tree().current_scene.get("spawner_module")
    if spawner == null:
        return
    var minion = spawner.spawn_summon(
        stats_data.summon_type,
        stats_data.summon_stats_id,
        global_position,
        team
    )
    if minion == null:
        return
    minion.connect("died", Callable(self, "_on_minion_died"))
    _summoned_minions.append(minion)
    if stats_data.summon_lifetime > 0.0:
        var tw := create_tween()
        tw.tween_interval(stats_data.summon_lifetime)
        tw.tween_callback(func():
            if is_instance_valid(minion) and not minion.is_dead():
                minion.die()
        )
```

**改为**：
```gdscript
func _try_summon_minion() -> void:
    if stats_data == null or stats_data.summon_max <= 0:
        return
    if randf() > stats_data.summon_chance:
        return
    _prune_dead_minions()
    if _summoned_minions.size() >= stats_data.summon_max:
        return
    
    var spawner = get_tree().current_scene.get("spawner_module")
    if spawner == null:
        return
    
    # 确定弹道目标位置：当前攻击目标的位置
    var target_pos: Vector2
    if attack_target and is_instance_valid(attack_target):
        target_pos = attack_target.global_position
    else:
        # 无目标时在自身附近随机位置召唤
        target_pos = global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60))
    
    const SummonProjectileScene := preload("res://scenes/effects/summon_projectile.tscn")
    var callback := func():
        if not is_instance_valid(self):
            return  # 召唤者已死亡，不生成
        # 获取最终生成位置（目标可能已移动）
        var final_pos := target_pos
        if attack_target and is_instance_valid(attack_target) and not attack_target.is_dead():
            final_pos = attack_target.global_position
        var minion = spawner.spawn_summon(
            stats_data.summon_type,
            stats_data.summon_stats_id,
            final_pos,
            team
        )
        if minion == null:
            return
        minion.connect("died", Callable(self, "_on_minion_died"))
        _summoned_minions.append(minion)
        if stats_data.summon_lifetime > 0.0:
            var tw := create_tween()
            tw.tween_interval(stats_data.summon_lifetime)
            tw.tween_callback(func():
                if is_instance_valid(minion) and not minion.is_dead():
                    minion.die()
            )
        # 浮动文字：召唤成功
        SkillFloatingText.show(self, "召唤")
    
    # 发射弹道
    spawner.spawn_projectile(null, global_position, target_pos, null, self, 0, SummonProjectileScene, callback)
```

**⚠️ 重要**：`spawn_projectile` 传递 `damage=0`、`target=null`，箭矢命中不造成任何伤害。

#### 修改点 C：嘲讽触发点加浮动文字（第 1734 行）

原代码第 1734 行：
```gdscript
u.force_attack_target(self, dur)
```

改为：
```gdscript
u.force_attack_target(self, dur)
SkillFloatingText.show(self, "嘲讽")
```

**注意**：嘲讽每 `taunt_pulse_interval`（Stoneguard 默认为 3 秒）脉冲一次，每次脉冲时显示"嘲讽"。频率可控，不会刷屏。

#### 修改点 D：闪现触发点加浮动文字（第 1701 行附近）

```gdscript
global_position = target_node.global_position + dir * (-stats_data.blink_range * 0.5)
_blink_timer = stats_data.blink_cooldown
SkillFloatingText.show(self, "闪现")
```

插入点在闪现成功后（设置位置和冷却后）。

#### 修改点 E：链式闪电触发点加浮动文字（第 1062 行）

```gdscript
best.take_damage(current_dmg, self)
chained.append(best)
chain_points.append(best.global_position)
current_target = best
# 只在首次命中时显示文字（后续弹跳不重复显示）
if i == 0:
    SkillFloatingText.show(self, "连锁闪电")
```

#### 修改点 F：锥形攻击触发点加浮动文字（第 1088 行）

```gdscript
u.take_damage(damage, self)
# 锥形攻击：只在有目标命中时显示
if not _showed_cone_text:
    SkillFloatingText.show(self, "锥形攻击")
    _showed_cone_text = true
```

需要新增变量 `var _showed_cone_text: bool = false`，在 `_perform_attack()` 开头重置。

实际上更简单的做法是在 `_do_cone_attack()` 函数末尾、`_show_cone_effect()` 之前加：
```gdscript
SkillFloatingText.show(self, "锥形攻击")
```

因为锥形攻击总是由 `_perform_attack` 触发，每次攻击显示一次即可。不需要计数。

#### 修改点 G：驱散触发点加浮动文字

搜索 `dispel_target` 调用位置。arrow.gd 中第 51-52 行是驱散逻辑：
```gdscript
if shooter != null and is_instance_valid(shooter) and shooter.has_method("dispel_target"):
    shooter.dispel_target(hit_target)
```

驱散是在箭矢命中时由 arrow 触发的，这里 arrow 不知道 shooter 是否实际执行了驱散。应该在 `unit.gd` 的 `dispel_target()` 函数中加。

`dispel_target()` 函数位置（第 1559-1565 行）：
```gdscript
func dispel_target(target) -> void:
    if target == null or not is_instance_valid(target):
        return
    if target.has_method("clear_buffs"):
        target.clear_buffs()
    # 这里加浮动文字（箭头命中且目标有 buff 时触发）
    SkillFloatingText.show(self, "驱散")
```

但驱散的实际效果是"目标有 buff 才生效"，即使目标没有 buff 也会显示文字。更好的做法是在 `clear_buffs()` 实际清除了 buff 时显示。不过 `clear_buffs()` 是目标的方法。

简化做法：在 `dispel_target()` 中无条件显示"驱散"。作为测试用浮动文字，这是可以接受的——玩家看到文字就知道 Inquisitor 的箭命中了。

#### 修改点 H：劝化触发点加浮动文字

`_convert_unit()` 函数（第 1805-1833 行）成功转化后，在末尾加：
```gdscript
SkillFloatingText.show(self, "劝化")
```

#### 修改点 I：治疗触发点加浮动文字

`_heal_process()` 中，在 `health.heal()` 调用后加。定位到第 774-793 行的治疗逻辑：

```gdscript
# 在 health.heal() 之后加
SkillFloatingText.show(self, "治疗")
```

---

## 三、实施步骤

### Step 1：新建 skill_floating_text.gd
- **操作**：创建 `scripts/effects/skill_floating_text.gd`
- **验证**：无（仅定义，尚无不调用）

### Step 2：修改 arrow.gd — 新增 hit_callback
- **操作**：添加 `var hit_callback: Callable = Callable()` 字段，改写 `_on_hit()`
- **验证**：运行游戏，Archer 正常射箭、命中、造成伤害

### Step 3：修改 game_spawner.gd — spawn_projectile 新增参数
- **操作**：修改函数签名，添加 `arrow.hit_callback = hit_callback`
- **验证**：运行游戏，Archer 正常射箭（零影响）

### Step 4：新建 summon_projectile.tscn
- **操作**：创建场景，子节点名必须为 `ArrowSprite`（arrow.gd 硬编码）
- **验证**：无（尚未引用）

### Step 5：修改 unit.gd — 改造 _try_summon_minion
- **操作**：改为发射弹道 + callback 生成
- **验证**：选 Necromancer 攻击敌人，观察紫色光球飞行+落地生成骷髅

### Step 6：修改 unit.gd — 各处加浮动文字
- **操作**：7 处插入 `SkillFloatingText.show()`
- **验证**：逐个兵种测试每个技能的文字显示

### Step 7：全面回归验证
- **操作**：运行游戏，所有兵种攻击/移动/受击正常

---

## 四、风险与应对

| # | 风险 | 概率 | 影响 | 应对 |
|---|------|------|------|------|
| 1 | summon_projectile 子节点名 `ArrowSprite` 与 arrow.gd 硬编码不匹配 | 中 | 弹道场景报 null 错误 | 已发现，确认保持同名即可 |
| 2 | 弹道 callback 内 `self` 无效（召唤者已死亡） | 低 | 不生成召唤物，无报错 | 已加 `is_instance_valid(self)` 守卫 |
| 3 | 弹道飞行期间目标死亡，召唤物生成在尸体位置 | 中 | 视觉略怪但可接受 | 标记为合理行为（从尸体召唤） |
| 4 | 嘲讽每 3 秒脉冲显示"嘲讽"文字，高频刷屏 | 中 | 玩家视觉干扰 | floating_text 2s 自销毁，3s 间隔基本不堆叠 |
| 5 | 链式闪电首次命中显示文字，后续弹跳不显示 | 低 | 信息缺失 | 故意设计——一次攻击只显示一次 |
| 6 | 治疗每帧都可能触发，文字堆叠 | 中 | 视觉干扰 | 需确认 `_heal_process` 有冷却控制（`heal_cooldown`），不会每帧触发 |
| 7 | 驱散即使目标无 buff 也显示文字 | 低 | 信息不准确 | 测试用功能，可接受 |

---

## 五、代码改动汇总（diff 风格）

### arrow.gd
```
+ var hit_callback: Callable = Callable()
  
  func _on_hit() -> void:
+     if hit_callback.is_valid():
+         hit_callback.call()
+         queue_free()
+         return
      if hit_target != null ...
```

### game_spawner.gd:504
```
- func spawn_projectile(data, from, to, target, shooter, damage, custom_arrow = null):
+ func spawn_projectile(data, from, to, target, shooter, damage, custom_arrow = null, hit_callback = Callable()):
  ...
+ arrow.hit_callback = hit_callback
```

### unit.gd
```
+ const SkillFloatingText := preload("res://scripts/effects/skill_floating_text.gd")

  _try_summon_minion():
-     spawner.spawn_summon(...)
+     # 发射弹道
+     spawner.spawn_projectile(null, pos, target_pos, null, self, 0, SummonScene, callback)
+     # callback 内 spawner.spawn_summon(...) + SkillFloatingText.show(self, "召唤")

  _taunt_process():
      u.force_attack_target(self, dur)
+     SkillFloatingText.show(self, "嘲讽")

  _try_blink_toward():
      global_position = ...
      _blink_timer = ...
+     SkillFloatingText.show(self, "闪现")

  _do_chain_attack():
      best.take_damage(...)
+     if i == 0: SkillFloatingText.show(self, "连锁闪电")

  _do_cone_attack():
      u.take_damage(damage, self)
+ SkillFloatingText.show(self, "锥形攻击")

  dispel_target():
      target.clear_buffs()
+     SkillFloatingText.show(self, "驱散")

  _convert_unit():
      ...
+     SkillFloatingText.show(self, "劝化")

  _heal_process():
      health.heal(...)
+     SkillFloatingText.show(self, "治疗")
```

---

## 六、验证脚本

启动 Godot 引擎运行游戏后：

```
1. 打开调试控制台（F8）
2. 在地图上放置 Necromancer + 一个敌方单位
3. 选中 Necromancer，右键攻击敌方单位
   → 观察：每次攻击时，紫色光球从 Necromancer 飞出
   → 观察：光球命中目标位置后，骷髅生成
   → 观察：Necromancer 头顶弹出绿色"召唤"文字
4. 放置 Stoneguard，让多个敌人围攻
   → 观察：Stoneguard 头顶弹出绿色"嘲讽"文字
5. 放置 Stormcaller + 多个敌人
   → 观察：链式闪电命中时弹出"连锁闪电"
6. 放置 Salamander + 敌人
   → 观察：锥形攻击时弹出"锥形攻击"
7. 放置 Blinker，攻击远处敌人
   → 观察：追击时闪现，弹出"闪现"
8. 放置 Inquisitor + 有 buff 的敌人
   → 观察：箭矢命中时弹出"驱散"
9. 放置 Monk + 受伤友军
   → 观察：治疗时弹出"治疗"
10. 放置 Archer + 敌人
    → 确认：正常射箭，无绿色文字
11. 检查 Godot 输出面板
    → 确认：无新增错误/警告
```

---

## 七、回滚方案

如果某一步出问题需要回滚：

| 步骤 | 回滚方式 |
|------|---------|
| Step 1-2 | 删除/恢复文件即可 |
| Step 3 | git checkout game_spawner.gd |
| Step 4 | 删除 summon_projectile.tscn |
| Step 5 | git checkout unit.gd |
| Step 6 | 逐一删除插入的 SkillFloatingText.show() 行 |
