# 代码审查报告

> 审查日期：2026-05-08
> 项目：godot_rts_start（Godot 4.6 RTS 游戏原型）
> 审查范围：scripts/ 目录下全部 GDScript 文件

---

## 一、项目概况

### 文件清单

| 文件 | 行数 | 职责 |
|------|------|------|
| main.gd | 847 | 主控：相机、选择、放置、UI、胜利判定 |
| unit.gd | 496 | 单位：移动、战斗、动画、状态机 |
| building.gd | 374 | 建筑：建造、箭塔攻击、受伤 |
| enemy_ai.gd | 138 | 敌方AI：巡逻、追击、攻击 |
| arrow.gd | 41 | 箭矢抛物线弹道 |
| neutral.gd | 64 | 中立物体基类（树、石） |
| sheep.gd | 92 | 羊的AI行为 |
| jelly_effect.gd | 31 | 果冻弹性特效工具类 |

### 架构亮点

- **模块清晰**：Unit / Building / EnemyAI 各有独立脚本，职责边界清楚
- **状态机设计**：Unit 有 `IDLE / MOVE / ATTACK_MOVE / ATTACK / DEAD` 五态，覆盖 RTS 核心操作
- **编辑器工具支持**：`@tool` + `_refresh_editor()` 方便在编辑器中预览
- **导航动态重建**：建筑放置/销毁后自动更新 NavigationMesh，路径不会穿墙

---

## 二、问题清单

### P0 — 性能（每帧全量 group 遍历）

多个位置在 `_process` / `_physics_process` 中每帧调用 `get_nodes_in_group()` 遍历所有单位/建筑做距离检测：

| 文件 | 行号 | 描述 |
|------|------|------|
| unit.gd | 360-375 | `_attack_move_process` 每帧遍历所有敌方单位+建筑找最近目标 |
| unit.gd | 430-436 | `_alert_enemy_response` 受击时遍历所有敌方单位广播报警 |
| building.gd | 259-268 | 箭塔 `_tower_process` 每帧遍历所有敌方单位找目标 |
| building.gd | 309-315 | 建筑受击时遍历所有敌方单位报警 |
| enemy_ai.gd | 102-119 | AI `_scan_for_targets` 每帧扫描所有玩家单位+建筑 |
| main.gd | 575-588 | `_check_victory` 每帧遍历所有建筑判断胜负 |

**影响**：单位/建筑数量增长后，O(n*m) 遍历叠加会导致帧率明显下降。

**建议**：
- 用 `Area2D` + `body_entered` / `body_exited` 信号做范围检测
- 给扫描加冷却时间（每 0.2-0.5 秒扫一次，不必每帧都扫）
- 用 `PhysicsDirectSpaceState2D.intersect_point()` 做空间查询
- `_check_victory` 改为事件驱动：只在建筑 `died` 信号触发时检查

---

### P0 — 资源加载（箭矢每次射出都 load）

| 文件 | 行号 | 问题 |
|------|------|------|
| unit.gd | 403 | `load("res://scenes/arrow.tscn")` 每次射箭都重新加载 |
| building.gd | 287 | 同上，箭塔射箭每次都 load |
| building.gd | 321 | 爆炸特效 `load("res://scenes/explosion.tscn")` 每次死亡都重新加载 |

**建议**：改为 `const` 预加载：
```gdscript
const ArrowScene := preload("res://scenes/arrow.tscn")
const ExplosionScene := preload("res://scenes/explosion.tscn")
```

---

### P1 — 代码重复

#### 2.1 阴影生成（3处重复）

`neutral.gd:37-49`、`unit.gd:174-186`、`building.gd:165-178` 三处几乎一样的 `_rebuild_shadow()`：逐像素画椭圆阴影。

**建议**：抽取为共享工具类：
```gdscript
# shadow_util.gd
class_name ShadowUtil
static func create_ellipse_shadow(parent: Node, width: int, height: int, alpha: float, offset: Vector2) -> Sprite2D
```

#### 2.2 箭矢生成（2处重复）

`unit.gd:402-409` 和 `building.gd:285-293` 的 `_spawn_arrow` 逻辑几乎一致。

**建议**：抽取到 arrow.gd 作为 static 工厂方法：
```gdscript
static func spawn(from: Vector2, target, damage: int, shooter) -> Node2D
```

#### 2.3 grid_size 查找（2处重复）

`main.gd:338-350` 和 `main.gd:530-544` 两处 switch 做 `PlaceMode → grid_size` 映射。

**建议**：用字典统一管理：
```gdscript
const GRID_SIZES := {
    PlaceMode.WALL: Vector2i(1, 1),
    PlaceMode.TOWER: Vector2i(1, 1),
    PlaceMode.CASTLE: Vector2i(3, 3),
    ...
}
```

#### 2.4 单位放置流程（4处重复）

`main.gd:693-735` 四种单位类型的放置代码只差 UnitType 参数。

**建议**：提取 `_place_unit(type, pos)` 辅助函数。

---

### P1 — 类型安全（enemy_ai.gd 大量字符串调用）

`enemy_ai.gd` 中频繁使用 `unit.get("state")`、`unit.call("move_to", ...)` 等字符串方式访问：

- 第 24 行：`unit.get("state") == UnitScript.UnitState.DEAD`
- 第 28 行：`unit.get("state") == UnitScript.UnitState.ATTACK`
- 第 37-41 行：多个 `unit.get("state")` 检查
- 第 64 行：`unit.call("move_to", patrol_target)`
- 第 74 行：`unit.get("attack_range")`
- 第 77 行：`unit.call("command_attack", chase_target)`

**问题**：类型不安全、性能差（每次都要字符串查找）、重构时容易遗漏。

**建议**：用强类型引用直接调用：
```gdscript
var unit: Unit = get_parent()
if unit.state == Unit.UnitState.DEAD:
    return
unit.move_to(patrol_target)
```

---

### P2 — main.gd 过于臃肿（847行）

main.gd 承担了过多职责：相机控制、UI创建、建筑放置、单位创建、选择系统、输入处理、胜利判定、网格系统、环境生成。

**建议拆分方向**：
- `CameraController` — 相机移动/缩放/拖拽/边界约束
- `SelectionManager` — 框选/点击选择/取消选择
- `PlacementManager` — 建筑放置/预览/网格管理
- `GameUI` — UI创建、金币显示、按钮状态更新

---

### P2 — 缺少对象池

箭矢（arrow）和爆炸特效（explosion）频繁 `instantiate()` + `queue_free()`，产生 GC 压力。

**建议**：实现简单的对象池，预创建一批实例复用。当单位/战斗规模增大时效果明显。

---

### P2 — 导航重建频率过高

`main.gd:378-401` 每次放置或移除建筑都全量重建 NavigationMesh。快速连续放置多面墙会触发多次完整烘焙。

**建议**：加 debounce 机制，短时间内连续操作只重建一次：
```gdscript
var _nav_rebuild_pending: bool = false
func _schedule_nav_rebuild() -> void:
    if _nav_rebuild_pending:
        return
    _nav_rebuild_pending = true
    await get_tree().create_timer(0.1).timeout
    _rebuild_navigation()
    _nav_rebuild_pending = false
```

---

## 三、优化优先级

| 优先级 | 问题 | 影响 | 工作量 |
|--------|------|------|--------|
| **P0** | 每帧全量 group 遍历 | 单位多了卡顿 | 中 |
| **P0** | 箭矢/特效每次 load 不用 preload | 资源浪费 | 小 |
| **P1** | 重复代码（阴影/箭矢/grid_size/单位放置） | 维护成本高 | 小 |
| **P1** | AI 的 get/set 字符串调用 | 类型安全+性能 | 小 |
| **P2** | main.gd 拆分 | 可维护性 | 大 |
| **P2** | 对象池 | GC 压力 | 中 |
| **P2** | 导航重建 debounce | 边缘场景 | 小 |

---

## 四、其他小问题

1. **attack_target 类型不明确**：`unit.gd` 和 `building.gd` 中 `attack_target` 声明为无类型变量，实际可能是 Unit 或 Building，建议声明为更明确的类型或添加注释说明。
2. **攻击移动时 scan_range 硬编码**：`unit.gd:45` 的 `attack_move_scan_range = 300.0` 应考虑放到单位属性中，不同兵种可有不同扫描范围。
3. **shadow_offset_y 不统一**：Unit 的 shadow_offset_y 默认为 0，但建筑也是 0，考虑到 sprite_lift 的存在，阴影可能需要对应偏移。
