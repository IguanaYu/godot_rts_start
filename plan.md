# RTS 项目整体代码重构计划

> 2026-05-16 制定的重构计划。上一版（多地图关卡系统）已全部实施完毕。

## Context

项目共有 23 个 GDScript 文件，3717 行代码。核心问题是：
- main.gd（1305行）和 unit.gd（770行）都是"上帝对象"
- 健康系统、影子渲染、动画播放等逻辑在 unit/building/neutral 之间重复实现
- 大量硬编码的数值、路径、颜色散落各处
- 目录结构扁平，30+ 场景文件和 25+ 脚本文件没有分组

重构目标：让每个文件职责清晰、消除重复代码、目录结构合理。

---

## 一、当前项目全貌

### 1.1 文件与代码量

```
文件                     行数    主要问题
─────────────────────────────────────────────────────
main.gd                  1305    上帝对象，10+职责
unit.gd                   770    上帝对象，战斗/移动/动画/血量全混
building.gd               373    塔攻击逻辑混入建筑基类
enemy_ai.gd               179    与unit.gd紧耦合，字符串调用
capture_point.gd          170    奖励逻辑耦合
wave_manager.gd           104    有调试代码
victory_expand_defense.gd  99    重复的清敌检测
sheep.gd                   91    -
level_select.gd            86    关卡数据硬编码
victory_blitz.gd           83    治疗逻辑不该在这
explosion.gd                18    ┐
dust_effect.gd              24    │ 帧动画代码100%重复
heal_effect.gd              25    ┘
click_effect.gd             28    类似的补间动画
floating_text.gd            40    类似的补间动画
arrow.gd                    40    -
jelly_effect.gd             30    静态工具类（做得好）
cursor_manager.gd           41    结构良好
map_config.gd               24    纯数据，结构良好
neutral.gd                  63    影子/精灵代码与unit/building重复
tree.gd                     18    -
victory_condition.gd        15    基类，结构良好
victory_destroy_base.gd     31    简洁清晰
victory_survive_waves.gd    51    有调试代码
pause_input_handler.gd      11    -
─────────────────────────────────────────────────────
总计                      3717
```

### 1.2 当前依赖关系图

```
                    ┌─────────────────────────────────────────┐
                    │              main.gd (1305行)            │
                    │  相机/UI/输入/建筑/经济/战斗/选框/特效   │
                    └──────┬──────────┬──────────┬────────────┘
                           │          │          │
              ┌────────────┘          │          └────────────┐
              ▼                       ▼                       ▼
     ┌────────────────┐    ┌──────────────────┐    ┌──────────────────┐
     │   unit.gd      │    │  building.gd     │    │  wave_manager.gd │
     │   (770行)      │    │  (373行)         │    │   (104行)        │
     │ 战斗/移动/动画  │    │ 建造/塔攻击/血量  │    └──────────────────┘
     │ 血量/治疗/选框  │    └──────────────────┘
     └───┬────────────┘
         │ 父子节点（字符串调用）
         ▼
   ┌───────────────┐
   │  enemy_ai.gd  │
   │  (179行)      │
   └───────────────┘

   胜利条件系统（独立）:            环境系统:
   victory_condition.gd (基类)       neutral.gd (基类)
     ├── victory_blitz.gd            ├── tree.gd
     ├── victory_destroy_base.gd     ├── bush.tscn (无脚本)
     ├── victory_survive_waves.gd    ├── rock.tscn (无脚本)
     └── victory_expand_defense.gd   └── sheep.gd

   特效系统（独立但重复）:
   explosion.gd ─┐
   dust_effect.gd│ 帧动画代码 100% 重复
   heal_effect.gd┘
   click_effect.gd / floating_text.gd / arrow.gd
```

### 1.3 重复代码热力图

```
                    unit.gd    building.gd    neutral.gd
  血量/受伤/死亡     ████░      ████░          ░░░░░
  影子渲染          ████░      ████░          ████░
  精灵定位          ████░      ████░          ████░
  HP条更新          ████░      ████░          ░░░░░

  ████░ = 有实现    ░░░░░ = 无

                    explosion  dust_effect   heal_effect
  帧动画播放        ████░      ████░         ████░
  (完全相同的逻辑)
```

---

## 二、发现的问题（按优先级）

### P0 - 架构性问题

| # | 问题 | 涉及文件 | 影响 |
|---|------|---------|------|
| 1 | main.gd 是上帝对象（1305行，10+职责） | main.gd | 改任何功能都要动这个文件 |
| 2 | unit.gd 是上帝对象（770行，6+职责） | unit.gd | 战斗/动画/血量/移动全混 |
| 3 | 建筑塔攻击逻辑混入建筑基类 | building.gd | 不需要攻击的建筑也带攻击代码 |
| 4 | 血量系统在 unit/building 重复实现 | unit.gd, building.gd | 改一处忘一处 |
| 5 | 影子/精灵代码在三个文件重复 | unit.gd, building.gd, neutral.gd | 同上 |

### P1 - 代码质量问题

| # | 问题 | 涉及文件 | 影响 |
|---|------|---------|------|
| 6 | 特效帧动画代码重复3次 | explosion/dust/heal_effect.gd | 每次改动画逻辑要改3处 |
| 7 | enemy_ai.gd 用字符串调用unit方法 | enemy_ai.gd | 重构unit时AI会静默崩溃 |
| 8 | 硬编码数值散落各处 | 几乎所有文件 | 调平衡需要翻遍代码 |
| 9 | 硬编码场景路径 | main.gd, unit.gd, building.gd | 移动文件后路径全断 |
| 10 | 胜利条件中有治疗逻辑和重复的清敌检测 | victory_blitz.gd, victory_expand_defense.gd | 职责不清 |

### P2 - 目录结构问题

| # | 问题 | 影响 |
|---|------|------|
| 11 | scenes/ 30个文件平铺在根目录 | 难以快速定位 |
| 12 | scripts/ 25个文件平铺在根目录 | 同上 |
| 13 | 关卡数据硬编码在 level_select.gd | 改关卡要改代码 |

### 做得好的地方（保留不动）

- assets/ 按类型分子目录
- 胜利条件继承体系（VictoryCondition基类）
- 地图配置用 Resource（.tres）
- 单位/建筑用场景继承
- jelly_effect.gd 作为静态工具类
- cursor_manager.gd 职责单一
- map_config.gd 纯数据容器

---

## 三、重构方案

### 3.1 新目录结构

```
rts-base/
├── project.godot
├── scenes/
│   ├── main.tscn
│   ├── level_select.tscn
│   ├── maps/
│   │   └── map_1~4.tscn
│   ├── units/                           ← 新分组
│   │   ├── unit.tscn
│   │   ├── soldier.tscn
│   │   ├── archer.tscn
│   │   ├── lancer.tscn
│   │   └── monk.tscn
│   ├── buildings/                       ← 新分组
│   │   ├── building.tscn
│   │   ├── castle.tscn
│   │   ├── barracks.tscn
│   │   ├── tower.tscn
│   │   ├── wall.tscn
│   │   ├── monastery.tscn
│   │   └── archery_building.tscn
│   ├── effects/                         ← 新分组
│   │   ├── arrow.tscn
│   │   ├── attack_click_effect.tscn
│   │   ├── move_click_effect.tscn
│   │   ├── dust_effect.tscn
│   │   ├── explosion.tscn
│   │   └── heal_effect.tscn
│   └── environment/                     ← 新分组
│       ├── neutral.tscn
│       ├── tree.tscn
│       ├── bush.tscn
│       ├── rock.tscn
│       └── sheep.tscn
│
├── scripts/
│   ├── main.gd                          ← 瘦身至 ~200行
│   ├── core/                            ← 新分组：共享基础
│   │   ├── game_entity.gd               ← 新建：血量/受伤/死亡的基类
│   │   ├── shadow_renderer.gd           ← 新建：提取影子渲染
│   │   └── frame_animated_effect.gd     ← 新建：帧动画特效基类
│   ├── systems/                         ← 新分组：从main拆出的Manager
│   │   ├── camera_manager.gd
│   │   ├── selection_manager.gd
│   │   ├── building_manager.gd
│   │   ├── combat_manager.gd
│   │   ├── economy_manager.gd
│   │   ├── effects_manager.gd
│   │   └── input_handler.gd
│   ├── units/                           ← 新分组
│   │   ├── unit.gd                      ← 瘦身：移除重复代码
│   │   └── enemy_ai.gd
│   ├── buildings/                       ← 新分组
│   │   └── building.gd                  ← 塔攻击逻辑拆出
│   ├── victory/                         ← 新分组
│   │   ├── victory_condition.gd
│   │   ├── victory_blitz.gd
│   │   ├── victory_destroy_base.gd
│   │   ├── victory_survive_waves.gd
│   │   └── victory_expand_defense.gd
│   ├── effects/                         ← 新分组
│   │   ├── click_effect.gd
│   │   ├── dust_effect.gd              ← 继承帧动画基类
│   │   ├── explosion.gd                ← 继承帧动画基类
│   │   ├── heal_effect.gd              ← 继承帧动画基类
│   │   ├── floating_text.gd
│   │   ├── jelly_effect.gd
│   │   └── arrow.gd
│   ├── environment/                     ← 新分组
│   │   ├── neutral.gd
│   │   ├── tree.gd
│   │   └── sheep.gd
│   ├── systems_game/                    ← 新分组：游戏内系统
│   │   ├── capture_point.gd
│   │   └── wave_manager.gd
│   └── ui/                              ← 新分组
│       ├── cursor_manager.gd
│       ├── pause_input_handler.gd
│       └── level_select.gd
│
├── resources/
│   ├── map1~4_config.tres
│   └── level_data.tres                  ← 新建：关卡数据从代码中提取
│
└── assets/                              ← 不动（结构已经很好）
```

### 3.2 重构后的依赖关系图

```
                      ┌──────────────┐
                      │   main.gd    │
                      │  (~200行)    │
                      │  初始化+协调  │
                      └──────┬───────┘
                             │ 创建/持有引用
           ┌─────────┬───────┼───────┬──────────┐
           ▼         ▼       ▼       ▼          ▼
     ┌──────────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐
     │camera_mgr│ │build.│ │combat│ │select│ │economy   │
     │ ~150行   │ │mgr   │ │mgr   │ │mgr   │ │  ~80行   │
     └──────────┘ │~250行│ │~120行│ │~100行│ └──────────┘
                  └──────┘ └──────┘ └──────┘
     ┌──────────┐ ┌───────────┐
     │input_    │ │effects_   │
     │handler   │ │manager    │
     │ ~150行   │ │  ~50行    │
     └──────────┘ └───────────┘


  ┌──────────────────────────────────────────────────┐
  │              共享基础层 (scripts/core/)            │
  │                                                    │
  │  game_entity.gd         影子/精灵共用接口          │
  │  (血量/受伤/死亡)                                    │
  │       ▲              ▲           ▲                 │
  │       │              │           │                 │
  │  ┌────┴────┐   ┌─────┴────┐  ┌──┴──────┐         │
  │  │ unit.gd │   │building.gd│  │neutral.gd│         │
  │  (~500行) │   │(~300行)   │  │ (~30行)  │         │
  │  移动+战斗 │   │建造+塔攻击│  │ 环境基类 │         │
  │  +AI接口  │   │          │  │         │         │
  │  └────┬────┘   └──────────┘  └─────────┘         │
  │       │                                            │
  │  ┌────┴────┐                                      │
  │  │enemy_ai │  ← 通过类型化接口调用，不用字符串     │
  │  └─────────┘                                      │
  └──────────────────────────────────────────────────┘


  ┌──────────────────────────────────────────────────┐
  │              帧动画特效 (scripts/effects/)         │
  │                                                    │
  │  frame_animated_effect.gd (基类，消除3处重复)       │
  │       ▲              ▲           ▲                 │
  │  explosion.gd   dust_effect.gd  heal_effect.gd    │
  │  (各~10行)      (各~10行)       (各~10行)         │
  └──────────────────────────────────────────────────┘
```

### 3.3 具体重构项

#### A. 新建共享基类（消除重复代码）

**A1. game_entity.gd — 血量/受伤/死亡基类**
```
来源：unit.gd 和 building.gd 中重复的血量逻辑
功能：
  - hp / max_hp 变量
  - take_damage(amount, attacker)
  - die()
  - is_dead()
  - _update_hp_bar()
  - signal died(entity)
继承者：unit.gd, building.gd
```

**A2. shadow_renderer.gd — 影子渲染（或混入 game_entity）**
```
来源：unit.gd, building.gd, neutral.gd 中重复的影子代码
功能：
  - _rebuild_shadow()  生成椭圆阴影
  - _apply_sprite_position()  精灵定位
```

**A3. frame_animated_effect.gd — 帧动画特效基类**
```
来源：explosion.gd, dust_effect.gd, heal_effect.gd 中100%重复的帧动画代码
功能：
  - _frame, _total_frames, _fps, _timer
  - _ready() 初始化总帧数
  - _process(delta) 推进帧，播完自动销毁
继承者：explosion.gd, dust_effect.gd, heal_effect.gd
每个子类只需 ~5-10 行（设置纹理和FPS）
```

#### B. main.gd 拆分（7个Manager）

| Manager | 提取的函数 | 预估行数 |
|---------|-----------|---------|
| camera_manager | _process_camera, _clamp_camera, _get_base_position, _jump_to_base | ~150 |
| building_manager | _place_building, _on_building_died, _rebuild_nav, grid_*, _create_grid, _enter_place_mode, _update_preview, _do_place | ~250 |
| combat_manager | _do_attack_move, _find_enemy_at, _stop_selected, _hold_position, _right_click | ~120 |
| selection_manager | _selection_released, _deselect_all, _get_selection_rect, _formation_offset | ~100 |
| economy_manager | add_gold, _update_gold_display, _update_button_affordability, COSTS | ~80 |
| effects_manager | _spawn_click_effect, _spawn_dust_effect, show_floating_text, spawn_enemy_wave/unit | ~50 |
| input_handler | _input中的路由分发 | ~150 |

重构后 main.gd (~200行)：只做初始化各Manager + 游戏流程控制

#### C. unit.gd 优化

```
当前：770行，战斗/移动/动画/血量/治疗/选框全混
目标：~500行，去掉重复代码后更清晰

具体改动：
1. 血量/受伤/死亡 → 继承 game_entity.gd（删 ~60行）
2. 影子/精灵定位 → 继承共享代码（删 ~40行）
3. 硬编码数值 → 提取为常量或导出变量
4. _physics_process 中的视觉更新 → 拆为独立函数
```

#### D. building.gd 优化

```
当前：373行，塔攻击逻辑混入建筑基类
目标：~300行

具体改动：
1. 血量/受伤/死亡 → 继承 game_entity.gd（删 ~30行）
2. 影子/精灵定位 → 继承共享代码（删 ~40行）
3. 塔攻击逻辑（_tower_process, _spawn_arrow）考虑拆为 TowerBehaviour 组件
   或者保持 if building_type == TOWER 的守卫（更简单，暂不拆）
4. 硬编码数值 → 常量或导出变量
```

#### E. enemy_ai.gd 解耦

```
当前：通过 unit.get("state") / unit.call("move_to") 字符串调用
目标：通过类型化引用直接调用

具体改动：
1. var unit: Unit = get_parent()  (类型化，不是 get_parent() as CharacterBody2D)
2. unit.move_to()  (直接调用，不用 call())
3. unit.state = Unit.UnitState.GUARD  (直接赋值，不用 set())
```

#### F. 其他小改动

```
- victory_blitz.gd: 移除治疗逻辑（或通过信号委托）
- level_select.gd: 关卡数据提取到 level_data.tres
- wave_manager.gd: 移除调试代码
- victory_survive_waves.gd: 移除调试代码
- 所有文件: 硬编码场景路径 → 用常量集中管理
```

---

## 四、执行计划

### 阶段 0: 准备
- 运行游戏确认当前可正常工作

### 阶段 1: 目录重组（只移动文件 + 修路径）
1. 创建 scenes/ 子目录: units/, buildings/, effects/, environment/
2. 移动 .tscn 文件
3. 全局搜索替换场景路径引用（preload/load 中的 "res://scenes/xxx.tscn" → "res://scenes/xxx/xxx.tscn"）
4. 运行验证 → 提交

### 阶段 2: 建立共享基类
1. 新建 scripts/core/frame_animated_effect.gd
2. 改 explosion/dust/heal_effect 继承它
3. 新建 scripts/core/game_entity.gd（血量基类）
4. 改 unit.gd 和 building.gd 继承它
5. 提取影子/精灵公共代码
6. 运行验证 → 提交

### 阶段 3: 拆分 main.gd
3a. 提取 camera_manager（最独立）
3b. 提取 effects_manager
3c. 提取 economy_manager
3d. 提取 building_manager
3e. 提取 selection_manager
3f. 提取 combat_manager
3g. 提取 input_handler
每步：提取 → 验证 → 提交

### 阶段 4: scripts/ 目录分组
1. 创建 scripts/ 子目录
2. 移动 .gd 文件
3. 更新 class_name / preload 路径
4. 运行验证 → 提交

### 阶段 5: 清理与优化
1. enemy_ai.gd 类型化解耦
2. 硬编码数值提取为常量
3. 移除调试代码
4. 关卡数据提取到 Resource
5. 运行验证 → 最终提交

---

## 五、验证方式

每个阶段完成后：
1. 运行 Godot 项目，无报错
2. 完整玩一局：选关 → 生产单位 → 放建筑 → 战斗 → 胜利/失败
3. 重点验证当前阶段涉及的系统
4. git commit
