# rts_base 自动化测试方法论

最后更新：2026-07-08

---

## 一、整体架构

**不使用外部测试框架**（GUT、GdUnit4 等），因为项目大量使用 `preload` + duck typing，与框架的类型推断、mock 机制不兼容。

**三层测试结构**：

| 层 | 用途 | 示例 | 耗时 | headless支持 |
|----|------|------|------|-------------|
| L1 纯逻辑 | 测纯函数、状态机、math | can_cast、能量回复计算 | <1s | ✅ |
| L2 场景集成 | 测真实节点交互、战斗、寻路 | 士兵进攻兵营 | ~10s | ✅ |
| L3 输入模拟 | 测键盘/鼠标 → 游戏全链路 | 按A键攻击移动 | 可变 | ❌ 需要渲染 |

---

## 二、文件结构

```
scripts/test/
├── assertions.gd                 # 断言工具库（PASS/FAIL输出）
├── test_runner.gd                # 测试运行器（CLI入口）
├── mock_spawner.gd               # 生成器桩（duck-typed）
├── commander_skill/              # 指挥官技能测试目录
│   └── test_can_cast.gd          # L1: can_cast 逻辑
└── combat/                       # 战斗系统测试目录
    ├── test_attack_building.gd   # L2: 士兵进攻兵营
    └── setup_combat.gd           # 战斗场景初始化脚本

scenes/test/
├── test_runner.tscn              # 运行器根场景（带Camera2D）
└── test_combat_scene.tscn        # 战斗测试专用场景（寻路、容器）
```

---

## 三、怎么写新测试

### 模板（L1 纯逻辑）

```gdscript
extends RefCounted

const Thing := preload("res://scripts/xxxx/thing.gd")

func run(a: RefCounted, _runner: Node) -> void:
    print("[测试: 什么东西]")
    _test_case_1(a)
    _test_case_2(a)

func _test_case_1(a: RefCounted) -> void:
    var obj = Node.new()
    obj.set_script(load("res://scripts/xxxx/thing.gd"))
    obj.initialize(...)
    
    var result = obj.some_method()
    a.assert_eq(result, expected, "方法返回正确")
    
    obj.queue_free()
```

### 模板（L2 场景集成）

```gdscript
extends RefCounted

const TestScene := preload("res://scenes/test/xxx_scene.tscn")
var scene: Node2D

func run(a: RefCounted, runner: Node) -> void:
    print("[测试: 什么场景]")
    
    # 1. 加载场景
    scene = TestScene.instantiate()
    runner.add_child(scene)
    await runner.get_tree().process_frame
    
    # 2. 生成测试数据
    var unit = scene.spawn_unit(...)
    var target = scene.spawn_target(...)
    
    # 3. 截图证据
    await _take_screenshot(runner, "xxx_01_setup")
    
    # 4. 执行操作
    unit.command_xxx(target)
    
    # 5. 等待 + 截图
    await runner.get_tree().create_timer(1.0).timeout
    await _take_screenshot(runner, "xxx_02_action")
    
    # 6. 断言
    a.assert_eq(target.health.hp, 0, "目标被摧毁")
    
    # 7. 清理
    scene.queue_free()

func _take_screenshot(runner, name):
    await runner.get_tree().process_frame
    var img = runner.get_viewport().get_texture().get_image()
    img.save_png("user://test_screenshots/" + name + ".png")
    print("  [截图] " + name)
```

### 注册到运行器

在 `scripts/test/test_runner.gd` 的 `_SUITES` 字典加一行：

```gdscript
const _SUITES := {
    "commander_skill.can_cast": "res://scripts/test/commander_skill/test_can_cast.gd",
    "combat.attack_building": "res://scripts/test/combat/test_attack_building.gd",
    "你的模块.测试名": "res://scripts/test/你的模块/xxx.gd",  # ← 加这里
}
```

---

## 四、运行方式

### 命令行

```bash
# 跑所有测试
"E:\godot\Godot_v4.6.1-stable_win64.exe" --path "F:\godot_game\rts_base\rts-base" "res://scenes/test/test_runner.tscn"

# 只跑特定模块（字符串包含匹配）
"E:\godot\Godot_v4.6.1-stable_win64.exe" --path "F:\godot_game\rts_base\rts-base" "res://scenes/test/test_runner.tscn" -- combat
"E:\godot\Godot_v4.6.1-stable_win64.exe" --path "F:\godot_game\rts_base\rts-base" "res://scenes/test/test_runner.tscn" -- commander
```

### 输出解读

```
=== rts_base 测试运行器 ===
截图目录: C:/Users/.../test_screenshots/

[ combat.attack_building ]
  PASS: 敌方建筑生成成功
  PASS: 5个士兵生成成功
  FAIL: 建筑初始HP > 0 -- expected true, got false
  -> 3 通过, 1 失败

=== 汇总 ===
测试数: 4 | 通过: 3 | 失败: 1
RESULT: 发现失败
```

**退出码**：0=全过，1=有失败 → 可用于 CI。

---

## 五、截图证据机制

每张截图的**文件名就是执行阶段**，便于定位问题：

```
combat_01_units_spawned.png    # 初始状态
combat_02_attack_ordered.png   # 下达命令后
combat_03_combat_progress.png  # 战斗中
combat_04_building_destroyed.png  # 结束状态
```

**截图目录**：`C:\Users\haoyu\AppData\Roaming\Godot\app_userdata\rts_base\test_screenshots\`

> 💡 打开 Windows 资源管理器直接粘这个路径就能进。

---

## 六、关键最佳实践

### 1. 优先用现有场景 preload，不要 class_name

项目里的脚本都是 `preload` + `set_script()` 模式，测试也保持一致：

```gdscript
# ✅ 正确
var unit = load("res://scenes/units/soldier.tscn").instantiate()
unit.alliance_id = 0

# ❌ 不要（框架不兼容）
var unit = Unit.new()
```

### 2. 参考 stress_test_spawner.gd 的创建模式

`scripts/systems/stress_test_spawner.gd` 是项目里最干净的"如何在非游戏主流程下生成单位"的参考，写测试时优先抄它的模式。

### 3. 单位创建的 5 步标准流程

```gdscript
1. instantiate() 场景
2. 设置 alliance_id（setter 会自动同步 team）
3. 设置 faction_color、position
4. add_child() 到容器节点（⚠️ 必须，否则 _ready 不跑）
5. add_to_group("player_units")（⚠️ 必须，否则寻路、攻击找不到目标）
```

### 4. 等待 _ready 完成

`add_child()` 后必须 `await get_tree().process_frame` 至少一次，否则 `health`、`stat_set` 等都是 null，调用方法会 crash。

### 5. 不要用 Engine.is_editor_hint() 分支

测试是在游戏运行模式下执行的，不是编辑器模式。

---

## 七、现有测试清单

| 测试名 | 层 | 内容 |
|--------|----|------|
| `commander_skill.can_cast` | L1 | 7 个断言：技能可用性、冷却、能量/金币不足、零耗能等 |
| `combat.attack_building` | L2 | 5 个断言 + 4 张截图：5个士兵进攻兵营，验证兵营被摧毁、士兵存活 |

---

## 八、下一步建议扩展方向

按优先级：

1. **`commander_skill.effects`** - 验证 orbital_strike 能正确造成范围伤害
2. **`combat.attack_unit`** - 士兵攻击敌方士兵（不是建筑）
3. **`combat.pathfinding`** - 单位寻路能绕过障碍物
4. **`unit.ai_behavior`** - 敌方单位看到玩家会自动追击
5. **`input.combat_shortcuts`** - 模拟按 A 键 + 鼠标点击，验证进入攻击移动模式（L3）

---

## 九、开发者工作流

写完一个功能后 → 写一个对应测试 → 跑 `-- 模块名` 验证 → 看截图检查视觉表现 → 提交。

这个流程的优势：
- **可复现**：任何时候跑都得到一样的结果
- **有证据**：截图记录了每个阶段，出问题能快速定位
- **低成本**：不需要手动操作游戏，命令行一键跑
- **可扩展**：加新测试只需要一个新的 `.gd` 文件 + 一行注册
