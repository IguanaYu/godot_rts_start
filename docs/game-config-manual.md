# Godot RTS 游戏配置手册

本文档涵盖游戏中所有可配置的项目，包括单位属性、建筑属性、关卡布局、波次系统、胜利条件等。分为两部分：

- **代码配置**：需要修改 `.gd` 脚本文件中的数值
- **编辑器配置**：通过 Godot 编辑器 Inspector 面板或场景树修改

---

## 目录

1. [单位属性配置](#一单位属性配置)
2. [建筑属性配置](#二建筑属性配置)
3. [关卡 MapConfig 资源配置](#三关卡-mapconfig-资源配置)
4. [地图场景结构配置](#四地图场景结构配置)
5. [波次系统配置](#五波次系统配置)
6. [胜利条件配置](#六胜利条件配置)
7. [占领点 CapturePoint 配置](#七占领点-capturepoint-配置)
8. [敌人 AI 配置](#八敌人-ai-配置)
9. [全局常量配置](#九全局常量配置)
10. [选关界面配置](#十选关界面配置)
11. [新建完整关卡教程](#十一新建完整关卡教程)

---

## 一、单位属性配置

### 1.1 数值属性（代码配置）

**文件位置**：`scripts/unit.gd` → `_setup_stats()` 方法（第 94-124 行）

| 属性 | Soldier | Archer | Lancer | Monk |
|------|---------|--------|--------|------|
| max_hp | 100 | 60 | 180 | 50 |
| attack_damage | 10 | 15 | 12 | 0 |
| attack_range | 40.0 | 200.0 | 45.0 | 0.0 |
| attack_cooldown | 0.8s | 1.2s | 1.0s | 999.0s |
| move_speed | 120.0 | 80.0 | 70.0 | 90.0 |
| **Monk 专属** | | | | |
| heal_range | - | - | - | 120.0 |
| heal_amount | - | - | - | 8 |
| heal_cooldown | - | - | - | 1.0s |
| heal_scan_range | - | - | - | 250.0 |

**如何修改**：在 `_setup_stats()` 中找到对应的 `UnitType` 分支，修改数值即可。

```gdscript
# 示例：修改 Soldier 的血量和攻击力
UnitType.SOLDIER:
    max_hp = 100        # ← 改这里
    attack_damage = 10  # ← 改这里
    attack_range = 40.0
    attack_cooldown = 0.8
    move_speed = 120.0
```

### 1.2 费用配置（代码配置）

**文件位置**：`scripts/game_data.gd` → `COSTS` 字典（第 12-23 行）

| 单位 | PlaceMode 枚举值 | 费用 |
|------|-----------------|------|
| Soldier | SOLDIER = 5 | 100 |
| Archer | ARCHER = 6 | 120 |
| Lancer | LANCER = 9 | 150 |
| Monk | MONK_UNIT = 10 | 80 |

**如何修改**：在 `COSTS` 字典中修改对应枚举的数值。

### 1.3 显示名称（代码配置）

**文件位置**：`scripts/game_data.gd` → `MODE_NAMES` 字典（第 26-37 行）

修改游戏中 UI 按钮上显示的名称。

### 1.4 视觉参数（编辑器配置）

在场景编辑器中选中一个单位实例（如 `scenes/soldier.tscn`），Inspector 面板会显示以下 `@export` 参数：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| unit_type | SOLDIER | 单位类型枚举 |
| team | PLAYER | 阵营 (PLAYER/ENEMY) |
| sprite_lift | 20.0 | 精灵向上偏移量 |
| shadow_width | 28 | 脚底阴影宽度 |
| shadow_height | 12 | 脚底阴影高度 |
| shadow_alpha | 0.4 | 阴影透明度 |
| shadow_offset_x | 0.0 | 阴影水平偏移 |
| shadow_offset_y | 0.0 | 阴影垂直偏移 |
| sprite_scale_x | 0.3 | 精灵水平缩放 |
| sprite_scale_y | 0.3 | 精灵垂直缩放 |
| sprite_offset_x | 0.0 | 精灵水平偏移 |
| sprite_offset_y | 0.0 | 精灵垂直偏移 |

### 1.5 单位类型枚举对照表

| 枚举值 | UnitType | 用途 |
|--------|----------|------|
| 0 | SOLDIER | 近战士兵 |
| 1 | ARCHER | 弓箭手（远程，射箭） |
| 2 | LANCER | 枪兵（高血量近战） |
| 3 | MONK | 僧侣（治疗友军，不攻击） |

---

## 二、建筑属性配置

### 2.1 数值属性（代码配置）

**文件位置**：`scripts/building.gd` → `_setup_stats()` 方法（第 68-88 行）

| 属性 | Wall | Tower | Castle | Barracks | Monastery | Archery |
|------|------|-------|--------|----------|-----------|---------|
| max_hp | 300 | 150 | 500 | 250 | 400 | 200 |
| grid_size | 1x1 | 1x1 | 3x3 | 2x2 | 2x2 | 2x2 |
| **Tower 专属** | | | | | | |
| attack_damage | - | 12.0 | - | - | - | - |
| attack_range | - | 150.0 | - | - | - | - |
| attack_cooldown | - | 1.5s | - | - | - | - |

**建造时间**：`building.gd` 第 40 行 `build_time = 5.0`（所有建筑统一 5 秒）

**如何修改**：在 `_setup_stats()` 中找到对应的 `BuildingType` 分支，修改数值。

### 2.2 费用配置（代码配置）

**文件位置**：`scripts/game_data.gd` → `COSTS` 字典（第 12-23 行）

| 建筑 | PlaceMode 枚举值 | 费用 |
|------|-----------------|------|
| Wall | WALL = 1 | 50 |
| Tower | TOWER = 2 | 150 |
| Castle | CASTLE = 4 | 500 |
| Barracks | BARRACKS = 5 | 300 |
| Monastery | MONASTERY = 7 | 350 |
| Archery Range | ARCHERY_RANGE = 8 | 250 |

### 2.3 网格尺寸（代码配置）

**文件位置**：`scripts/game_data.gd` → `BUILDING_GRID_SIZES` 字典（第 60-67 行）

| 建筑 | 占用格子 |
|------|---------|
| Wall | 1 x 1 |
| Tower | 1 x 1 |
| Castle | 3 x 3 |
| Barracks | 2 x 2 |
| Monastery | 2 x 2 |
| Archery | 2 x 2 |

每格 = 64 像素（`GRID_SIZE = 64`）

### 2.4 视觉参数（编辑器配置）

在场景编辑器中选中建筑实例，Inspector 面板显示的 `@export` 参数：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| building_type | WALL | 建筑类型枚举 |
| team | PLAYER | 阵营 (PLAYER/ENEMY) |
| shadow_scale_x | 0.85 | 阴影水平缩放比例 |
| shadow_scale_y | 0.45 | 阴影垂直缩放比例 |
| shadow_alpha | 0.35 | 阴影透明度 |
| shadow_offset_x | 0.0 | 阴影水平偏移 |
| shadow_offset_y | 0.0 | 阴影垂直偏移 |
| sprite_scale_x | 0.4 | 精灵水平缩放 |
| sprite_scale_y | 0.4 | 精灵垂直缩放 |
| sprite_lift_ratio | 0.15 | 精灵上移比例 |
| sprite_offset_x | 0.0 | 精灵水平偏移 |
| sprite_offset_y | 0.0 | 精灵垂直偏移 |

### 2.5 建筑类型枚举对照表

| 枚举值 | BuildingType | 说明 |
|--------|-------------|------|
| 0 | WALL | 城墙，基础防御 |
| 1 | TOWER | 箭塔，自动攻击敌人 |
| 2 | CASTLE | 城堡，胜利条件建筑 |
| 3 | BARRACKS | 兵营 |
| 4 | MONASTERY | 寺院 |
| 5 | ARCHERY | 射箭场 |

---

## 三、关卡 MapConfig 资源配置

### 3.1 概述

每个关卡对应一个 `.tres` 资源文件，通过 Godot 编辑器 Inspector 面板直接编辑。

**资源文件位置**：`resources/map*_config.tres`
**脚本定义**：`scripts/map_config.gd`

### 3.2 配置字段详解

在 Godot 编辑器中双击 `.tres` 文件，Inspector 面板显示所有字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| **map_name** | String | 地图名称，如 "Blitz" |
| **map_bounds** | Rect2 | 地图边界，格式 Rect2(x, y, width, height)。影响摄像机移动范围和环境生成区域 |
| **nav_bounds** | Array[Vector2] | 导航区域多边形顶点，定义单位可移动区域 |
| **initial_gold** | int | 玩家初始金币 |
| **camera_start** | Vector2 | 摄像机初始位置 |
| **player_units** | Array[Dictionary] | 玩家初始单位列表 |
| **player_buildings** | Array[Dictionary] | 玩家初始建筑列表 |
| **enemy_units** | Array[Dictionary] | 敌方初始单位列表 |
| **enemy_buildings** | Array[Dictionary] | 敌方初始建筑列表 |
| **environment** | Dictionary | 装饰物数量 |
| **available_items** | Array[int] | 本关可用的物品列表 |
| **map_description** | String | 地图描述文字 |

### 3.3 单位数据格式

`player_units` / `enemy_units` 中每个元素的格式：

```json
{
    "type": 0,        // UnitType 枚举：0=Soldier, 1=Archer, 2=Lancer, 3=Monk
    "pos": Vector2(x, y)  // 世界坐标位置（像素）
}
```

**在编辑器中操作**：点击数组旁边的 `+` 号添加元素，在 Inspector 中编辑 `type` 和 `pos` 字段。

### 3.4 建筑数据格式

`player_buildings` / `enemy_buildings` 中每个元素的格式：

```json
{
    "type": 2,              // BuildingType 枚举：0=Wall, 1=Tower, 2=Castle, 3=Barracks, 4=Monastery, 5=Archery
    "grid_pos": Vector2i(x, y)  // 网格坐标（每格64像素）
}
```

> **注意**：建筑使用网格坐标而非世界坐标。世界坐标 = 网格坐标 x 64。

### 3.5 环境配置

`environment` 字段是一个 Dictionary，包含以下键：

| 键 | 默认值 | 说明 |
|----|--------|------|
| trees | 15 | 树木数量 |
| rocks | 10 | 岩石数量 |
| bushes | 12 | 灌木数量 |
| sheep | 5 | 绵羊数量 |

装饰物在地图边界内随机放置（避开边缘 100px）。

### 3.6 可用物品配置

`available_items` 是一个 PlaceMode 枚举值数组，决定玩家在该关卡可以建造/训练什么。

| PlaceMode 枚举 | 值 | 对应物品 |
|----------------|-----|---------|
| NONE | 0 | （无） |
| WALL | 1 | 城墙 $50 |
| TOWER | 2 | 箭塔 $150 |
| CASTLE | 4 | 城堡 $500 |
| BARRACKS | 5 | 兵营 $300 |
| SOLDIER | 6 | 士兵 $100 |
| ARCHER | 7 | 弓箭手 $120 |
| MONASTERY | 8 | 寺院 $350 |
| ARCHERY_RANGE | 9 | 射箭场 $250 |
| LANCER | 10 | 枪兵 $150 |
| MONK_UNIT | 11 | 僧侣 $80 |

> **快捷键**：可用物品按顺序绑定到键盘 1-0，所以最多 10 个。

### 3.7 现有关卡配置对比

| 配置项 | Map 1 (Blitz) | Map 2 (Basic Attack) | Map 3 (Tower Defense) | Map 4 (Expand & Defend) |
|--------|--------------|---------------------|----------------------|------------------------|
| initial_gold | 0 | 10000 | 6000 | 8000 |
| map_bounds | -100,-100,2200,600 | -500,-500,2000,1700 | -500,-500,2000,1700 | -500,-500,2500,2200 |
| player_units | 3 Soldier + 2 Archer | 3 Soldier + 2 Archer | 3 Soldier + 2 Archer | 3 Soldier + 2 Archer |
| player_buildings | 无 | Castle + Barracks | Castle + Barracks + Archery + Tower | Castle + Barracks |
| enemy_units | 7 Soldier + 4 Archer | 3 Soldier + 2 Archer | 无 | 14 单位混合 |
| enemy_buildings | 1 Tower + 2 Wall | Castle + Barracks + Tower + 2 Wall | 无 | 4 Tower |
| environment | 6树/4石/3灌/0羊 | 15树/10石/12灌/5羊 | 10树/8石/6灌/3羊 | 20树/12石/15灌/6羊 |
| available_items | 空（无建造） | 全部 10 种 | Tower,Soldier,Archery,ArcheryRange,Lancer | 7 种 |
| 胜利条件 | Blitz | DestroyBase | SurviveWaves | ExpandDefense |
| 波次 | 无 | 无 | 3 波 | 有 |

---

## 四、地图场景结构配置

### 4.1 场景文件

**位置**：`scenes/maps/map_*.tscn`

### 4.2 必需节点结构

在 Godot 编辑器中创建/编辑地图场景时，必须包含以下节点层次：

```
MapX (Node2D)                  ← 挂载脚本: scripts/main.gd
├── map_config: MapConfig      ← Inspector 中引用对应的 .tres 资源
├── Ground (ColorRect)         ← 地面背景色和大小
├── NavigationRegion2D         ← 导航网格
├── Camera2D                   ← 摄像机
├── PlayerUnits (Node2D)       ← 玩家单位容器（运行时自动填充）
├── EnemyUnits (Node2D)        ← 敌方单位容器（运行时自动填充）
├── Buildings (Node2D)         ← 建筑容器（运行时自动填充）
├── SelectionBox (ColorRect)   ← 框选矩形
├── PreviewRect (ColorRect)    ← 建筑放置预览
├── ResultLabel (Label)        ← 胜利/失败文字
├── AttackMoveIndicator (Label)← 攻击移动提示
├── WaveManager (Node)         ← [可选] 波次管理器
├── VictoryXxx (Node)          ← 胜利条件节点（必需）
└── CapturePoint (Area2D)      ← [可选] 占领点
```

### 4.3 根节点配置

选中根节点，在 Inspector 中设置：
- **Script**: `scripts/main.gd`
- **Map Config**: 拖入对应的 `.tres` 资源文件

### 4.4 Ground 节点配置

设置 ColorRect 的偏移和颜色，与 `map_bounds` 对应：
- `offset_left/top/right/bottom`: 对应 map_bounds 的范围
- `color`: 地面颜色（各关卡可以用不同颜色）

### 4.5 NavigationRegion2D 配置

双击 NavigationRegion2D 节点，使用多边形编辑工具绘制导航区域。顶点应与 MapConfig 中的 `nav_bounds` 对应。

也可以在 Inspector 中直接编辑 `NavigationPolygon` 的顶点属性。

### 4.6 SelectionBox / PreviewRect 配置

这两个 ColorRect 保持默认即可，运行时由代码控制：
- `visible`: false
- `mouse_filter`: Ignore (2)
- `color`: 框选用蓝色半透明，预览用绿色/红色半透明

---

## 五、波次系统配置

### 5.1 WaveManager 节点

**脚本**：`scripts/wave_manager.gd`

在地图场景中添加一个 `Node` 类型的子节点，挂载 `wave_manager.gd` 脚本。

### 5.2 Inspector 可配置项

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| **clear_then_next** | bool | false | true = 清完当前波所有敌人后才开始下一波倒计时 |
| **waves** | Array[Dictionary] | [] | 波次数据数组 |

### 5.3 单个波次数据格式

在 Inspector 中点击 `waves` 数组的 `+` 号添加波次，每个波次是以下结构的 Dictionary：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| **delay** | float | 是 | 波次开始前的倒计时（秒） |
| **post_clear_delay** | float | 否 | 清完波后的等待时间（秒），配合 `clear_then_next` 使用 |
| **wave_attack** | bool | 否 | true = 单位会主动向目标位置发起攻击移动 |
| **wave_target** | Vector2 | 否 | 攻击目标位置（通常设为玩家基地） |
| **units** | Array[Dictionary] | 是 | 本波敌人列表 |

### 5.4 波次中的单位格式

`units` 数组中每个元素：

```json
{
    "type": 0,            // UnitType 枚举
    "pos": Vector2(x, y)  // 生成位置（世界坐标）
}
```

### 5.5 当前波次配置示例（Map 3）

| 波次 | delay | post_clear_delay | wave_attack | 单位组成 |
|------|-------|-----------------|-------------|---------|
| 第 1 波 | 30s | 60s | true | 3 Soldier + 2 Archer |
| 第 2 波 | 60s | 60s | true | 5 Soldier + 3 Archer + 1 Lancer |
| 第 3 波 | 90s | 0s | true | 8 Soldier + 4 Archer + 2 Lancer |

所有波的 `wave_target` = `Vector2(200, 350)`（玩家基地方向）

### 5.6 波次工作流程

1. 游戏开始 → WaveManager 调用 `start_waves()`
2. 读取第 1 波的 `delay` → 开始倒计时
3. 倒计时结束 → 生成该波所有单位
4. 如果 `clear_then_next = true`：
   - 等待所有敌方单位被消灭
   - 读取当前波的 `post_clear_delay` 作为下一波的等待时间
   - 开始下一波倒计时
5. 如果 `clear_then_next = false`：
   - 直接按下一波的 `delay` 开始倒计时
6. 所有波次完成 → 发出 `all_waves_completed` 信号

---

## 六、胜利条件配置

### 6.1 概述

每个地图场景必须包含一个挂载了胜利条件脚本的子节点。游戏主循环通过 `VictoryCondition.check()` 方法返回值判断胜负：
- `0` = 进行中
- `1` = 胜利
- `2` = 失败

### 6.2 VictoryDestroyBase — 摧毁基地

**脚本**：`scripts/victory_destroy_base.gd`

**适用**：标准对战关卡（如 Map 2）

**规则**：
- 玩家城堡被摧毁 = 失败
- 敌方城堡被摧毁 = 胜利

**编辑器配置**：无需额外配置，无 `@export` 参数。只需添加为根节点的子节点并挂载脚本。

### 6.3 VictorySurviveWaves — 存活波次

**脚本**：`scripts/victory_survive_waves.gd`

**适用**：塔防关卡（如 Map 3）

**规则**：
- 玩家城堡被摧毁 = 失败
- 所有波次完成 + 所有敌人消灭 = 胜利

**Inspector 配置**：

| 参数 | 类型 | 说明 |
|------|------|------|
| wave_manager_path | NodePath | 指向场景中的 WaveManager 节点，如 `../WaveManager` |

### 6.4 VictoryBlitz — 闪电战

**脚本**：`scripts/victory_blitz.gd`

**适用**：无基地的突击关卡（如 Map 1）

**规则**：
- 所有玩家单位死亡 = 失败
- 占领所有据点 = 胜利（占领据点后回复 50% HP）

**Inspector 配置**：

| 参数 | 类型 | 说明 |
|------|------|------|
| capture_points | Array[NodePath] | 所有关键占领点的路径列表 |
| activation_radius | float | 据点周围多少像素内没有敌人时才激活据点（默认 200） |

> 据点按顺序激活：只有当前目标据点周围的敌人被清除后，据点才会变为可占领状态。

### 6.5 VictoryExpandDefense — 扩张防守

**脚本**：`scripts/victory_expand_defense.gd`

**适用**：混合关卡（如 Map 4）

**规则**：
- 玩家城堡被摧毁 = 失败
- 占领所有据点 + 所有波次完成 + 所有敌人消灭 = 胜利

**Inspector 配置**：

| 参数 | 类型 | 说明 |
|------|------|------|
| wave_manager_path | NodePath | 指向 WaveManager 节点 |
| capture_points | Array[NodePath] | 所有关键占领点的路径列表 |
| activation_radius | float | 据点激活半径（默认 250） |

> 与 Blitz 不同，ExpandDefense 的所有据点可以同时激活（不需要按顺序）。

---

## 七、占领点 CapturePoint 配置

### 7.1 节点类型

在地图场景中添加 `Area2D` 类型的子节点，挂载 `scripts/capture_point.gd` 脚本。

**脚本**：`scripts/capture_point.gd`

### 7.2 Inspector 配置

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| **capture_radius** | float | 100.0 | 占领检测范围（像素），单位需在此范围内 |
| **capture_speed** | float | 20.0 | 占领进度速度（进度/秒），从 0 到 100 |
| **reward_type** | RewardType | GOLD | 占领奖励类型 |
| **reward_gold** | int | 500 | 奖励金币数量（GOLD 类型时） |
| **reward_units** | Array[Dictionary] | [] | 奖励单位列表（UNITS 类型时） |
| **reward_custom** | String | "" | 自定义奖励（CUSTOM 类型，暂未实现） |
| **trigger_on_start** | bool | true | 开局时是否自动激活 |
| **trigger_on_kill_all** | bool | false | 击杀全部敌人后是否激活 |
| **trigger_on_destroy_building** | NodePath | "" | 摧毁指定建筑后激活 |

### 7.3 奖励类型枚举

| 枚举值 | RewardType | 说明 |
|--------|-----------|------|
| 0 | GOLD | 给玩家金币 |
| 1 | UNITS | 在占领点附近生成单位 |
| 2 | CUSTOM | 自定义（预留接口） |

### 7.4 reward_units 数据格式

```json
[
    { "type": 0, "count": 3 },   // 3 个 Soldier
    { "type": 1, "count": 2 }    // 2 个 Archer
]
```

### 7.5 占领机制

- 占领范围内**己方单位数 > 敌方单位数**时，占领进度增加
- 占领范围内**敌方单位数 > 己方单位数**时，占领进度减少（1.5x 速度）
- 进度从 0 增长到 100 即完成占领
- 敌方单位也可以占领（会抢夺控制权）

---

## 八、敌人 AI 配置

### 8.1 EnemyAI 脚本

**脚本**：`scripts/enemy_ai.gd`

敌方 AI 自动挂载在敌方单位上（由 `game_spawner.gd` 创建敌方单位时自动添加）。不需要手动在编辑器中配置。

### 8.2 Inspector 可配置项

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| **patrol_radius** | float | 150.0 | 巡逻半径（围绕出生点随机移动的范围） |
| **vision_range** | float | 250.0 | 视野范围（发现玩家单位/建筑的距离） |

### 8.3 AI 状态机

| 状态 | 说明 |
|------|------|
| PATROL | 在出生点附近巡逻，等待发现目标 |
| CHASE | 发现敌人后追击 |
| ATTACK | 进入攻击范围后攻击 |
| WAVE_ATTACK | 波次攻击模式，向目标位置攻击移动 |

### 8.4 AI 行为规则

- 巡逻时发现视野内的玩家单位或建筑 → 切换到 CHASE
- 进入攻击范围 → 切换到 ATTACK
- 目标死亡 → 恢复 PATROL 或继续 WAVE_ATTACK
- 被攻击时 → 立即反击并通知 400 范围内的友军

---

## 九、全局常量配置

### 9.1 GameData 文件

**文件位置**：`scripts/game_data.gd`

| 常量 | 值 | 说明 |
|------|-----|------|
| **GRID_SIZE** | 64 | 建筑放置网格大小（像素） |
| **CAMERA_SPEED** | 600.0 | 摄像机移动速度 |
| **EDGE_MARGIN** | 30.0 | 边缘滚动触发距离 |
| **ZOOM_STEP** | 0.15 | 每次滚轮缩放步进 |
| **MIN_ZOOM** | 0.4 | 最小缩放（最远） |
| **MAX_ZOOM** | 2.0 | 最大缩放（最近） |
| **DEFAULT_TREES** | 15 | 环境默认树木数 |
| **DEFAULT_ROCKS** | 10 | 环境默认岩石数 |
| **DEFAULT_BUSHES** | 12 | 环境默认灌木数 |
| **DEFAULT_SHEEP** | 5 | 环境默认绵羊数 |

### 9.2 PlaceMode 完整枚举

**文件位置**：`scripts/game_data.gd` 第 9 行

```
enum PlaceMode { NONE=0, WALL=1, TOWER=2, CASTLE=4, BARRACKS=5,
                 SOLDIER=6, ARCHER=7, MONASTERY=8, ARCHERY_RANGE=9,
                 LANCER=10, MONK_UNIT=11 }
```

### 9.3 快捷键映射

**文件位置**：`scripts/game_data.gd` 第 47 行

`KEY_LIST = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]`

对应键盘 1-0，与 `available_items` 数组顺序对应。

### 9.4 其他全局参数

| 位置 | 参数 | 值 | 说明 |
|------|------|-----|------|
| unit.gd | attack_move_scan_range | 300.0 | 攻击移动时扫描敌人的范围 |
| unit.gd | steer_lock_time | 0.5 | 避让方向锁定时间 |
| building.gd | build_time | 5.0 | 建筑建造时间 |
| building.gd | alert range | 500.0 | 建筑被攻击时通知友军的范围 |
| unit.gd | alert range | 400.0 | 单位被攻击时通知友军的范围 |

---

## 十、选关界面配置

### 10.1 关卡列表

**文件位置**：`scripts/level_select.gd` → `levels` 数组（第 20-49 行）

每个关卡条目格式：

```gdscript
{
    "name": "Map 1: Blitz",          # 显示名称
    "desc": "No base, no gold...",   # 描述文字
    "scene": "res://scenes/maps/map_1.tscn",  # 场景路径
    "icon": "res://assets/.../Icon_01.png",    # 图标图片路径
    "ribbon_row": 0,                           # 丝带装饰行号
}
```

### 10.2 添加新关卡

在 `levels` 数组末尾添加新条目即可。建议：
- `name`: 使用 "Map N: 关卡名" 的格式
- `icon`: 使用 `PATH_ICON_0X` 常量或自定义路径
- `ribbon_row`: 使用 0-9 之间的偶数（对应不同的丝带样式）

---

## 十一、新建完整关卡教程

以下是从零开始创建一个新关卡的完整步骤。

### 步骤 1：创建 MapConfig 资源

1. 在 Godot 编辑器的 FileSystem 面板中，右键点击 `resources/` 目录
2. 选择 **新建资源** → 选择 **MapConfig** → 命名为 `map5_config.tres`
3. 双击打开，在 Inspector 面板中配置：
   - `map_name`: "Your Map Name"
   - `map_bounds`: Rect2(-500, -500, 2000, 1700)（默认范围）
   - `nav_bounds`: 添加 4 个顶点围成矩形
   - `initial_gold`: 8000
   - `camera_start`: Vector2(500, 350)
   - `player_units`: 添加单位
   - `player_buildings`: 添加建筑（至少一个 Castle）
   - `enemy_units`: 添加敌人
   - `enemy_buildings`: 添加敌方建筑（如需要）
   - `environment`: 设置装饰物数量
   - `available_items`: 选择可用的 PlaceMode 枚举
   - `map_description`: 填写描述

### 步骤 2：创建地图场景

1. 在 `scenes/maps/` 目录下新建场景，根节点类型选 **Node2D**
2. 命名为 `Map5`（或自定义名称）
3. 挂载脚本：选中根节点 → Inspector → **Attach Script** → 选择 `scripts/main.gd`
4. 在 Inspector 中将 `map_config` 指向步骤 1 创建的 `.tres` 资源

### 步骤 3：添加必需子节点

按照以下顺序添加子节点（可参考现有地图 `map_2.tscn`）：

**3.1 Ground（ColorRect）**
- 添加 ColorRect 子节点，命名为 `Ground`
- 设置偏移匹配 `map_bounds`：
  - offset_left = -500, offset_top = -500
  - offset_right = 1500, offset_bottom = 1200
- 设置颜色（如草绿色 `Color(0.35, 0.55, 0.25, 1)`）

**3.2 NavigationRegion2D**
- 添加 NavigationRegion2D 子节点
- 选中该节点 → 顶部工具栏点击编辑多边形
- 绘制与 `nav_bounds` 对应的矩形区域
- 或直接在 Inspector 中编辑 `NavigationPolygon` 的 vertices 和 polygons

**3.3 Camera2D**
- 添加 Camera2D 子节点
- 无需额外配置，位置由代码控制

**3.4 PlayerUnits（Node2D）**
- 添加 Node2D 子节点，命名为 `PlayerUnits`

**3.5 EnemyUnits（Node2D）**
- 添加 Node2D 子节点，命名为 `EnemyUnits`

**3.6 Buildings（Node2D）**
- 添加 Node2D 子节点，命名为 `Buildings`

**3.7 SelectionBox（ColorRect）**
- 添加 ColorRect 子节点，命名为 `SelectionBox`
- visible: false
- color: Color(0.4, 0.7, 1, 0.25)
- mouse_filter: Ignore (2)

**3.8 PreviewRect（ColorRect）**
- 添加 ColorRect 子节点，命名为 `PreviewRect`
- visible: false
- color: Color(0, 1, 0, 0.3)
- mouse_filter: Ignore (2)

**3.9 ResultLabel（Label）**
- 添加 Label 子节点，命名为 `ResultLabel`
- 设置合理的 offset（如 left=350, top=300, right=650, bottom=400）
- font_size: 48
- horizontal_alignment: Center (1)
- vertical_alignment: Center (1)
- text: ""（空）

**3.10 AttackMoveIndicator（Label）**
- 添加 Label 子节点，命名为 `AttackMoveIndicator`
- offset: left=10, top=10, right=200, bottom=40
- font_color: Color(1, 0.8, 0.2, 1)
- font_size: 20
- text: "Attack Move (Click)"
- visible: false

### 步骤 4：添加胜利条件

根据关卡类型选择对应的胜利条件脚本：

**4.1 标准对战（DestroyBase）**
- 添加 Node 子节点，命名为 `VictoryDestroyBase`
- 挂载 `scripts/victory_destroy_base.gd`

**4.2 塔防（SurviveWaves）**
- 添加 Node 子节点，命名为 `VictorySurviveWaves`
- 挂载 `scripts/victory_survive_waves.gd`
- 在 Inspector 中设置 `wave_manager_path` = `../WaveManager`

**4.3 闪电战（Blitz）**
- 添加 Node 子节点，命名为 `VictoryBlitz`
- 挂载 `scripts/victory_blitz.gd`
- 在 Inspector 中设置 `capture_points` 数组（添加所有 CapturePoint 的 NodePath）
- 设置 `activation_radius`

**4.4 扩张防守（ExpandDefense）**
- 添加 Node 子节点，命名为 `VictoryExpandDefense`
- 挂载 `scripts/victory_expand_defense.gd`
- 设置 `wave_manager_path`、`capture_points`、`activation_radius`

### 步骤 5：添加波次管理器（可选）

如果关卡需要波次：

1. 添加 Node 子节点，命名为 `WaveManager`
2. 挂载 `scripts/wave_manager.gd`
3. 在 Inspector 中配置：
   - `clear_then_next`: true（推荐，清完一波再出下一波）
   - `waves`: 点击 `+` 添加波次，每波配置 delay、units 等

### 步骤 6：添加占领点（可选）

如果关卡需要占领点：

1. 添加 Area2D 子节点，命名为 `CapturePoint1`（或其他名称）
2. 挂载 `scripts/capture_point.gd`
3. 在场景编辑器中拖放到合适位置
4. 在 Inspector 中配置 capture_radius、reward_type、reward_gold 等

> 如果使用 Blitz 或 ExpandDefense 胜利条件，记得在胜利条件节点中引用这些占领点的 NodePath。

### 步骤 7：注册到选关界面

在 `scripts/level_select.gd` 的 `levels` 数组中添加新条目：

```gdscript
{
    "name": "Map 5: Your Level Name",
    "desc": "描述文字",
    "scene": "res://scenes/maps/map_5.tscn",
    "icon": PATH_ICON_01,  # 或自定义图标路径
    "ribbon_row": 0,
},
```

### 步骤 8：测试

1. 按 F5 或 F6 运行场景
2. 检查：
   - 地图大小和地面颜色是否正确
   - 单位和建筑是否在预期位置生成
   - 摄像机是否在预期位置开始
   - UI 按钮是否显示正确的可用物品
   - 胜利条件是否正常工作
   - 波次是否按预期触发（如有）

### 步骤 9：微调

根据测试结果调整：
- `map_bounds` 和 `nav_bounds`（地图大小）
- `initial_gold`（初始金币平衡性）
- 单位/建筑的初始位置
- 波次的 delay 和单位组成
- `available_items`（可用建造列表）

---

## 附录：文件结构速查

```
scripts/
├── main.gd                  # 游戏主控制器（挂载在地图根节点）
├── game_data.gd             # 全局常量、枚举、路径映射
├── game_ui.gd               # UI 模块（按钮、金币、暂停菜单）
├── game_camera.gd           # 摄像机模块
├── game_spawner.gd          # 生成模块（单位、建筑、环境）
├── unit.gd                  # 单位脚本（属性、AI 状态机）
├── building.gd              # 建筑脚本（属性、建造、箭塔攻击）
├── map_config.gd            # MapConfig 资源定义
├── wave_manager.gd          # 波次管理器
├── capture_point.gd         # 占领点
├── enemy_ai.gd              # 敌方 AI
├── victory_condition.gd     # 胜利条件基类
├── victory_destroy_base.gd  # 摧毁基地
├── victory_survive_waves.gd # 存活波次
├── victory_blitz.gd         # 闪电战
├── victory_expand_defense.gd# 扩张防守
└── level_select.gd          # 选关界面

resources/
├── map1_config.tres         # Map 1 配置
├── map2_config.tres         # Map 2 配置
├── map3_config.tres         # Map 3 配置
└── map4_config.tres         # Map 4 配置

scenes/maps/
├── map_1.tscn               # Map 1 场景
├── map_2.tscn               # Map 2 场景
├── map_3.tscn               # Map 3 场景
└── map_4.tscn               # Map 4 场景
```
