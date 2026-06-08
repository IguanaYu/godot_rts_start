# 地图场景配置指南

完整覆盖地图场景（`.tscn`）和地图配置（`.tres`）的创建流程。
从新建关卡到放置单位、配置波次、胜利条件，可直接复制模板使用。

---

## 架构概览

```
地图配置 (.tres)                ← MapConfig 资源：数值属性（金币、范围、环境等）
地图场景 (.tscn)                ← 实际关卡：节点树 + 预放置单位/建筑 + 波次 + 胜利条件
  ├── main.gd                  ← 读取 MapConfig 初始化游戏
  ├── WaveManager              ← 波次配置（在场景内）
  ├── VictoryXxx               ← 胜利条件脚本
  └── CapturePoint (可选)      ← 占领点

关卡选择 (level_select.gd)      ← 硬编码的关卡列表，注册新地图
```

**初始化流程**：
```
level_select.gd → 加载 map_X.tscn → main.gd._ready()
  → 读取 map_config → 应用难度预设 → 初始化模块
  → 注册预放置单位/建筑 或 从 config 生成
  → 启动波次管理器 → 设置胜利条件
```

---

## 关键文件

| 文件 | 作用 |
|------|------|
| `scripts/map_config.gd` | MapConfig 数据类，所有可配置属性 |
| `scripts/main.gd` | 地图主脚本，读取 config 初始化游戏 |
| `scripts/systems_game/wave_manager.gd` | 波次管理器 |
| `scripts/systems_game/capture_point.gd` | 占领点系统 |
| `scripts/victory/victory_survive_waves.gd` | 生存胜利条件 |
| `scripts/victory/victory_expand_defense.gd` | 扩张防守胜利条件 |
| `scripts/difficulty_preset.gd` | 难度预设资源 |
| `scripts/ui/level_select.gd` | 关卡选择界面 |

---

## 第一步：创建 MapConfig 资源

新建 `resources/mapX_config.tres`：

```
[gd_resource type="Resource" script_class="MapConfig" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/map_config.gd" id="1_cfg"]

[resource]
script = ExtResource("1_cfg")
map_name = "My Map"
map_bounds = Rect2(-500, -500, 2500, 2200)
nav_bounds = Array[Vector2]([Vector2(-500, -500), Vector2(2000, -500), Vector2(2000, 1700), Vector2(-500, 1700)])
initial_gold = 8000
camera_start = Vector2(500, 600)

player_units = Array[Dictionary]( [
	{"type": 0, "pos": Vector2(420, 520)},
] )

player_buildings = Array[Dictionary]( [
	{"type": 2, "grid_pos": Vector2i(7, 8)},
] )

enemy_units = Array[Dictionary]( [
	{"type": 0, "pos": Vector2(1000, -200)},
] )

enemy_buildings = Array[Dictionary]( [
	{"type": 1, "grid_pos": Vector2i(20, -5)},
] )

environment = {"trees": 15, "rocks": 10, "bushes": 12, "sheep": 5}
available_items = Array[int]( [1, 2, 4, 8, 5, 6, 9] )

terrain_theme = 3
border_width = 1
map_description = "My awesome map!"
```

### MapConfig 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `map_name` | String | 地图名称 |
| `map_bounds` | Rect2 | 地图边界（影响相机限制、环境装饰范围） |
| `nav_bounds` | Array[Vector2] | 导航区域顶点（4个点，顺时针） |
| `initial_gold` | int | 初始金币 |
| `camera_start` | Vector2 | 相机初始位置 |
| `player_units` | Array[Dictionary] | 玩家初始单位（如果场景里预放了则不需要） |
| `player_buildings` | Array[Dictionary] | 玩家初始建筑 |
| `enemy_units` | Array[Dictionary] | 敌方初始单位 |
| `enemy_buildings` | Array[Dictionary] | 敌方初始建筑 |
| `environment` | Dictionary | 环境装饰数量：`trees`, `rocks`, `bushes`, `sheep` |
| `available_items` | Array[int] | 可建造物品的 PlaceMode ID 列表 |
| `terrain_theme` | int | 地形主题（0=默认） |
| `map_description` | String | 地图描述文本 |
| `easy_preset` / `normal_preset` / `hard_preset` | Resource | 难度预设覆盖 |

### unit/building Dictionary 格式

```gdscript
# 单位
{"type": 0, "pos": Vector2(420, 520)}
# type: 0=剑士, 1=弓箭手, 2=枪兵, 3=僧侣

# 建筑
{"type": 2, "grid_pos": Vector2i(7, 8)}
# type: 0=城墙, 1=箭塔, 2=城堡, 3=兵营, 4=寺庙, 5=射击场
# grid_pos: 网格坐标（1格=64px），建筑左上角
```

---

## 第二步：创建地图场景

新建 `scenes/maps/map_X.tscn`。完整模板：

```
[gd_scene format=3 uid="uid://自定义"]

# === 脚本引用 ===
[ext_resource type="Script" path="res://scripts/main.gd" id="main_script"]
[ext_resource type="Resource" path="res://resources/mapX_config.tres" id="map_config"]
[ext_resource type="Script" path="res://scripts/victory/victory_survive_waves.gd" id="victory"]
[ext_resource type="Script" path="res://scripts/systems_game/wave_manager.gd" id="wave_mgr"]

# === 单位场景引用 ===
[ext_resource type="PackedScene" path="res://scenes/units/soldier.tscn" id="soldier"]
[ext_resource type="PackedScene" path="res://scenes/units/archer.tscn" id="archer"]
[ext_resource type="PackedScene" path="res://scenes/units/lancer.tscn" id="lancer"]

# === 建筑场景引用 ===
[ext_resource type="PackedScene" path="res://scenes/buildings/castle.tscn" id="castle"]
[ext_resource type="PackedScene" path="res://scenes/buildings/tower.tscn" id="tower"]

# === 导航区域 ===
[sub_resource type="NavigationPolygon" id="NavPoly_1"]
vertices = PackedVector2Array(-500, -500, 2000, -500, 2000, 1700, -500, 1700)
polygons = [PackedInt32Array(0, 1, 2, 3)]

# === 根节点 ===
[node name="MapX" type="Node2D"]
script = ExtResource("main_script")
map_config = ExtResource("map_config")

# === 地面 ===
[node name="Ground" type="ColorRect" parent="."]
offset_left = -500.0
offset_top = -500.0
offset_right = 2000.0
offset_bottom = 1700.0
color = Color(0.35, 0.55, 0.25, 1)

# === 导航 ===
[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]
navigation_polygon = SubResource("NavPoly_1")

# === 相机 ===
[node name="Camera2D" type="Camera2D" parent="."]

# === 玩家单位 ===
[node name="PlayerUnits" type="Node2D" parent="."]

[node name="PlayerSoldier1" parent="PlayerUnits" instance=ExtResource("soldier")]
position = Vector2(420, 520)

# === 敌方单位（必须 team = 1）===
[node name="EnemyUnits" type="Node2D" parent="."]

[node name="EnemySoldier1" parent="EnemyUnits" instance=ExtResource("soldier")]
position = Vector2(1000, -200)
team = 1

# === 建筑 ===
[node name="Buildings" type="Node2D" parent="."]

[node name="PlayerCastle" parent="Buildings" instance=ExtResource("castle")]
position = Vector2(544, 608)

[node name="EnemyTower1" parent="Buildings" instance=ExtResource("tower")]
position = Vector2(1312, -288)
team = 1

# === UI 节点（必须）===
[node name="SelectionBox" type="ColorRect" parent="."]
visible = false
color = Color(0.4, 0.7, 1, 0.25)
mouse_filter = 2

[node name="PreviewRect" type="ColorRect" parent="."]
visible = false
color = Color(0, 1, 0, 0.3)
mouse_filter = 2

[node name="ResultLabel" type="Label" parent="."]
offset_left = 350.0
offset_top = 500.0
offset_right = 650.0
offset_bottom = 600.0
theme_override_font_sizes/font_size = 48
horizontal_alignment = 1
vertical_alignment = 1
text = ""

[node name="AttackMoveIndicator" type="Label" parent="."]
offset_left = 10.0
offset_top = 10.0
offset_right = 200.0
offset_bottom = 40.0
theme_override_colors/font_color = Color(1, 0.8, 0.2, 1)
theme_override_font_sizes/font_size = 20
text = "Attack Move (Click)"
visible = false

# === 波次管理器 ===
[node name="WaveManager" type="Node" parent="."]
script = ExtResource("wave_mgr")
clear_then_next = false
waves = Array[Dictionary]( [
	{
		"delay": 30.0,
		"wave_attack": true,
		"wave_target": Vector2(500, 600),
		"units": Array[Dictionary]( [
			{"type": 0, "pos": Vector2(1850, 0)},
			{"type": 0, "pos": Vector2(1850, 100)},
			{"type": 1, "pos": Vector2(1900, 50)}
		] )
	},
	{
		"delay": 60.0,
		"wave_attack": true,
		"wave_target": Vector2(500, 600),
		"units": Array[Dictionary]( [
			{"type": 0, "pos": Vector2(1850, -100)},
			{"type": 0, "pos": Vector2(1850, 0)},
			{"type": 0, "pos": Vector2(1850, 100)},
			{"type": 1, "pos": Vector2(1900, 50)},
			{"type": 1, "pos": Vector2(1900, 150)}
		] )
	}
] )

# === 胜利条件 ===
[node name="VictorySurviveWaves" type="Node" parent="."]
script = ExtResource("victory")
wave_manager_path = NodePath("../WaveManager")
```

---

## 第三步：配置波次

### 波次格式

```gdscript
{
    "delay": 45.0,                          # 游戏开始后多少秒触发
    "wave_attack": true,                     # true=波次单位会进攻指定目标
    "wave_target": Vector2(500, 600),        # 进攻目标坐标
    "units": Array[Dictionary]( [            # 生成的单位列表
        {"type": 0, "pos": Vector2(1850, 0)},
        {"type": 1, "pos": Vector2(1900, 50)}
    ] )
}
```

### 波次管理器属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `clear_then_next` | bool | true=当前波清完才出下一波，false=按时间自动出 |
| `waves` | Array[Dictionary] | 波次列表，按顺序触发 |

### 波次单位 type 映射

| type | 单位 |
|------|------|
| 0 | 剑士 |
| 1 | 弓箭手 |
| 2 | 枪兵 |
| 3 | 僧侣 |

---

## 第四步：配置胜利条件

### 选项 A：生存模式（存活 + 清完波次）

使用 `victory_survive_waves.gd`：

```
[node name="VictorySurviveWaves" type="Node" parent="."]
script = ExtResource("victory_survive")
wave_manager_path = NodePath("../WaveManager")
```

- **胜利**：所有波次完成 + 场上无剩余敌人
- **失败**：玩家城堡被摧毁

### 选项 B：扩张防守（占领点 + 清波）

使用 `victory_expand_defense.gd`，需配合 CapturePoint 节点：

```
[ext_resource type="Script" path="res://scripts/systems_game/capture_point.gd" id="capture_point"]
[ext_resource type="Script" path="res://scripts/victory/victory_expand_defense.gd" id="victory_expand"]

[node name="CapturePoint1" type="Area2D" parent="."]
position = Vector2(400, -200)
script = ExtResource("capture_point")
trigger_type = 0
detection_radius = 250.0
capture_radius = 100.0
capture_speed = 30.0
reward_gold = 600

[node name="VictoryExpandDefense" type="Node" parent="."]
script = ExtResource("victory_expand")
wave_manager_path = NodePath("../WaveManager")
capture_points = [NodePath("../CapturePoint1")]
```

- **胜利**：占领所有点 + 所有波次完成 + 场上无敌人
- **失败**：玩家城堡被摧毁

---

## 第五步：注册到关卡选择

在 `scripts/ui/level_select.gd` 的 `levels` 数组中添加：

```gdscript
var levels := [
    # ... 现有关卡 ...
    {
        "name_key": "LEVEL_X_NAME",       # 翻译键
        "desc_key": "LEVEL_X_DESC",       # 翻译键
        "scene": "res://scenes/maps/map_X.tscn",
        "icon": PATH_ICON_05,              # 图标贴图路径
        "ribbon_row": 0,                   # 背景丝带行号
    },
]
```

同时在翻译文件中添加 `LEVEL_X_NAME` 和 `LEVEL_X_DESC` 的翻译。

---

## 可用单位/建筑场景

### 单位

| id | 路径 | type | 说明 |
|----|------|------|------|
| `soldier` | `res://scenes/units/soldier.tscn` | 0 | 剑士 |
| `archer` | `res://scenes/units/archer.tscn` | 1 | 弓箭手 |
| `lancer` | `res://scenes/units/lancer.tscn` | 2 | 枪兵 |
| `monk` | `res://scenes/units/monk.tscn` | 3 | 僧侣 |
| `elite_archer` | `res://scenes/units/elite_archer.tscn` | 1 | 精英弓箭手（发光箭、高属性） |

### 建筑

| id | 路径 | type | 网格尺寸 |
|----|------|------|----------|
| `wall` | `res://scenes/buildings/wall.tscn` | 0 | 1x1 |
| `tower` | `res://scenes/buildings/tower.tscn` | 1 | 1x1 |
| `castle` | `res://scenes/buildings/castle.tscn` | 2 | 3x3 |
| `barracks` | `res://scenes/buildings/barracks.tscn` | 3 | 2x2 |
| `monastery` | `res://scenes/buildings/monastery.tscn` | 4 | 2x2 |
| `archery_building` | `res://scenes/buildings/archery_building.tscn` | 5 | 2x2 |

---

## 注意事项

### 敌方必须设 team = 1

```
# 敌方单位和建筑必须设置
team = 1
```
默认是 0（PLAYER），忘记设置敌人会变成友军。

### 容器节点不可删除

`PlayerUnits`、`EnemyUnits`、`Buildings` 三个容器节点必须存在。

### UI 节点必须存在

`SelectionBox`、`PreviewRect`、`ResultLabel`、`AttackMoveIndicator` 是 main.gd 必需的，不能删除。

### 坐标系

- Y 轴正方向向下，负值 = 地图上方
- 网格大小 = 64px（`GameData.GRID_SIZE`）
- 建筑位置建议放在网格交点上

### 导航区域

`NavigationPolygon` 的顶点范围必须覆盖所有单位可达区域。单位不会走出导航区域外。

### ext_resource 的 UID

如果 UID 不正确，Godot 会用 path 回退并自动修正。首次保存后 UID 会自动更新。
