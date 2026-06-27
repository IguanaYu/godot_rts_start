# 第三阶段执行计划：敌方 Leash 拉兵系统

> 对应整体计划的"第三阶段目标：AI 智能"中的 Leash 部分
> 核心目标：给敌方 AI 添加追击距离限制，允许玩家通过操作技巧拉兵

---

## 一、背景与需求

### 1.1 现状
- 敌方 AI 有 `patrol_center` 和 `patrol_radius`（巡逻范围），但**追击时没有距离限制**
- 敌人一旦进入 CHASE 状态会追到天涯海角
- 玩家无法通过操作技巧"拉兵"，只能硬碰硬
- 缺乏 RTS 经典微操空间（SC2/War3/Dota2 的 leash 机制）

### 1.2 目标
- 给每个敌人添加 `leash_range`（最大追击距离）
- 追击/攻击中持续检查距 `patrol_center` 的距离
- 超出 leash 后放弃追击，走回巡逻区域
- 保持敌人 AI 其他行为不变

### 1.3 验收标准
- [ ] 敌人在 patrol_center 附近正常巡逻
- [ ] 进入攻击范围内 → 进入 CHASE → ATTACK（和之前一样）
- [ ] 追击超出 leash_range（距 patrol_center）→ 放弃追击，走回巡逻区
- [ ] 攻击中超出 leash_range → 放弃攻击，走回巡逻区
- [ ] 走回巡逻区后恢复巡逻
- [ ] 被攻击时（on_attacked）不受 leash 影响——除非已经超出 leash
- [ ] 玩家可以故意站在 leash 边界勾引少数敌人出来

---

## 二、设计决策（已确认）

| 项目 | 决定 |
|------|------|
| `leash_range` 默认值 | **400** |
| 超出后行为 | **走回 patrol_center**，恢复巡逻 |
| 预警视觉反馈 | **不需要** |
| 检查时机 | **追击 + 攻击中都检查** |

---

## 三、涉及文件

| 操作 | 文件 | 说明 |
|------|------|------|
| **修改** | `scripts/units/enemy_ai.gd` | 添加 leash_range 字段 + 追击/攻击中距离检查 + 超限回巡逻 |

只改 **1 个文件**，约 15-20 行新增代码。

---

## 四、详细改动

### 4.1 新增字段

在 [enemy_ai.gd:10](scripts/units/enemy_ai.gd#L10) `vision_range` 后新增：

```gdscript
@export var leash_range: float = 400.0      # 最大追击距离（距 patrol_center）
```

### 4.2 新增辅助方法

```gdscript
## 是否超出追击距离（用 distance_squared 避免开平方）
func _is_beyond_leash() -> bool:
    return unit.global_position.distance_squared_to(patrol_center) > leash_range * leash_range

## 放弃追击，回到巡逻
func _break_leash() -> void:
    chase_target = null
    ai_state = AIState.PATROL
    _pick_new_patrol_point()
```

**说明**：
- 用 `distance_squared_to` 避免开平方，比 `distance_to` 性能更好
- `_break_leash()` 只设 `chase_target=null` 和状态，不设 `unit.attack_target=null`——因为 enemy_ai._physics_process 第 40-43 行已经会在 `attack_target` 为 null 时切 `unit.state = GUARD`
- 设置 `ai_state = PATROL` + `_pick_new_patrol_point()` 让敌人走回巡逻区域

### 4.3 修改 `_chase_process()`（第 94 行）

在目标无效检查之后、移动/攻击之前，插入 leash 检查：

```gdscript
func _chase_process() -> void:
    if _is_target_invalid():
        chase_target = null
        if previous_state == AIState.WAVE_ATTACK:
            ai_state = AIState.WAVE_ATTACK
            unit.attack_move_to(wave_target)
        else:
            ai_state = AIState.PATROL
            _pick_new_patrol_point()
        return

    # Phase 3：超出追击距离则放弃
    if _is_beyond_leash():
        _break_leash()
        return

    var dist: float = unit.global_position.distance_to(chase_target.global_position)
    var atk_range: float = unit.get_effective_attack_range()
    if dist <= atk_range:
        ai_state = AIState.ATTACK
        unit.command_attack(chase_target)
    else:
        unit.move_to(chase_target.global_position)
```

### 4.4 修改 `_attack_process()`（第 114 行）

在目标无效检查之后、当前目标检查之前，插入 leash 检查：

```gdscript
func _attack_process() -> void:
    if _is_target_invalid():
        chase_target = null
        if previous_state == AIState.WAVE_ATTACK:
            ai_state = AIState.WAVE_ATTACK
            unit.attack_move_to(wave_target)
        else:
            ai_state = AIState.PATROL
            _pick_new_patrol_point()
        return

    # Phase 3：超出追击距离则放弃
    if _is_beyond_leash():
        _break_leash()
        return

    var current_target = unit.attack_target
    if current_target != chase_target:
        unit.command_attack(chase_target)
```

---

## 五、执行流程追踪

验证 leash 在攻击中的工作情况：

```
Frame 1（leash 超出在 _attack_process 中检测到）：
  → _is_beyond_leash() 返回 true
  → _break_leash()：chase_target=null, ai_state=PATROL
  → 函数 return

Frame 2（enemy_ai._physics_process）：
  → unit.state == ATTACK（之前攻击中）
  → 进入 _attack_process → _is_target_invalid() 返回 true（chase_target==null）
  → 设置 unit.state = GUARD（第 43 行）
  → ai_state = PATROL

Frame 3（enemy_ai._physics_process）：
  → unit.state == GUARD，无早期返回
  → ai_state == PATROL → _patrol_process()
  → unit.move_to(patrol_target) → unit.state = MOVE

Frame 4+：
  → unit.state == MOVE，AI 不干预
  → unit._move_process() 处理导航
  → 到达后 unit.state = GUARD
  → _patrol_process() 继续正常巡逻
```

---

## 六、风险与应对

| # | 风险 | 概率 | 影响 | 应对 |
|---|------|------|------|------|
| 1 | leash 太短，敌人一追就回头 | 低 | 敌人攻击性太弱 | 默认 400 适中，可调参数 |
| 2 | leash 太长，等于没有限制 | 低 | 拉兵无效 | 默认 400 适中，用户可自行调整 |
| 3 | 走回巡逻区途中重新发现敌人 | 中 | 敌人"反复横跳" | 这是预期行为——玩家需要让目标退出敌人视野 |
| 4 | WAVE_ATTACK 模式下的 leash | 低 | 波次进攻被 leash 打断 | WAVE_ATTACK 不走 _chase_process/_attack_process，不受影响 |
| 5 | 和现有 patrol 逻辑冲突 | 低 | patrol 不正常 | leash 只在 CHASE/ATTACK 状态下检查，不影响巡逻 |

---

## 七、验证方式

### 功能验证

1. **正常巡逻不受影响**：
   - 在敌人巡逻区外观察 → 敌人正常巡逻，不会追击

2. **正常追击**：
   - 进入敌人 vision_range → 敌人进入 CHASE → 追到面前 → ATTACK
   - 如果目标在 leash 范围内，和之前行为完全一样

3. **拉兵测试（核心验证）**：
   - 站在敌人 patrol_center 的 leash 边界外（约 400 距离）
   - 进入 vision_range → 敌人追过来
   - 向后跑 → 敌人追到 leash 边界 → 放弃追击，走回巡逻区
   - **预期结果**：敌人追到 400 距离时回头

4. **攻击中拉兵**：
   - 进入敌人 patrol_center 的 leash 边界内 → 敌人攻击
   - 向后跑但保持在 leash 内 → 敌人继续追
   - 跑出 leash → 敌人放弃攻击，走回巡逻区

5. **波次攻击不受影响**：
   - 触发 WAVE_ATTACK → 敌人攻击移动到目标位置
   - 即使距离很远，也不会被 leash 打断

### 回归验证
1. 所有敌方单位正常巡逻/追击/攻击
2. 玩家正常操作不受影响
3. 无新增报错或警告

---

## 八、实施顺序

```
Step 1: enemy_ai.gd 新增 leash_range 字段 + _is_beyond_leash() + _break_leash()
Step 2: enemy_ai.gd 修改 _chase_process() — 插入 leash 检查
Step 3: enemy_ai.gd 修改 _attack_process() — 插入 leash 检查
Step 4: 功能验证（特别是拉兵测试）
Step 5: 回归验证
```
