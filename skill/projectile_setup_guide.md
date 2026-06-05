# 投射物（弹道）配置指南

项目弹道系统使用数据驱动架构，核心文件在 `scripts/resources/` 下。
本指南覆盖所有配置方式和扩展步骤，可直接复制模板使用。

---

## 架构概览

```
ProjectileData（资源）       ← 定义弹道数值属性 + 效果列表
  ├── speed / arc_height / shot_count / spread_angle
  └── effects: Array[ProjectileEffect]

ProjectileEffect（效果基类） ← 命中时触发的效果，可自由组合
  ├── SlowEffect    { slow_rate, duration }
  └── SplashEffect  { radius, splash_ratio }

Arrow（场景）                ← 通用弹道运行器，读取 ProjectileData 驱动飞行和命中
spawn_projectile()           ← 统一发射入口，在 game_spawner.gd 中
```

**发射流程：**
```
射击者 → 调用 game_spawner.spawn_projectile(data, from, to, target, shooter, damage)
       → Arrow 场景实例化，读取 data 配置飞行参数
       → 命中时遍历 data.effects 逐个执行 apply()
```

---

## 关键文件

| 文件 | 作用 |
|------|------|
| `scripts/resources/projectile_data.gd` | 弹道数据定义（speed, arc_height, effects, shot_count, spread_angle） |
| `scripts/resources/projectile_effect.gd` | 效果基类，定义 `apply(projectile, target)` 接口 |
| `scripts/resources/slow_effect.gd` | 减速效果：`slow_rate`（0~1）, `duration`（秒） |
| `scripts/resources/splash_effect.gd` | 溅射效果：`radius`（像素）, `splash_ratio`（溅射伤害比例） |
| `scripts/effects/arrow.gd` | 通用弹道运行器，一般不需要改 |
| `scripts/systems/game_spawner.gd` | `spawn_projectile()` 统一入口 |
| `scenes/effects/arrow.tscn` | Arrow 场景 |

---

## 配置模板

### 模板 A：普通箭（无特效）

```gdscript
# 在射击者的 _spawn_arrow() 中
func _spawn_arrow(target, damage: int = -1) -> void:
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		spawner.spawn_projectile(null, global_position, target.global_position, target, self, damage)
```

### 模板 B：减速箭

```gdscript
const ProjectileDataScript := preload("res://scripts/resources/projectile_data.gd")
const SlowEffectScript := preload("res://scripts/resources/slow_effect.gd")

func _spawn_arrow(target, damage: int = -1) -> void:
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		var data := ProjectileDataScript.new()
		var slow := SlowEffectScript.new()
		slow.slow_rate = 0.25   # 减速 25%
		slow.duration = 2.0     # 持续 2 秒
		data.effects.append(slow)
		spawner.spawn_projectile(data, global_position, target.global_position, target, self, damage)
```

### 模板 C：双发射箭

```gdscript
const ProjectileDataScript := preload("res://scripts/resources/projectile_data.gd")

func _spawn_arrow(target, damage: int = -1) -> void:
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		var data := ProjectileDataScript.new()
		data.shot_count = 2      # 发射 2 支箭
		data.spread_angle = 10.0 # 散射角度 10°
		spawner.spawn_projectile(data, global_position, target.global_position, target, self, damage)
```

### 模板 D：爆炸溅射箭

```gdscript
const ProjectileDataScript := preload("res://scripts/resources/projectile_data.gd")
const SplashEffectScript := preload("res://scripts/resources/splash_effect.gd")

func _spawn_arrow(target, damage: int = -1) -> void:
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		var data := ProjectileDataScript.new()
		var splash := SplashEffectScript.new()
		splash.radius = 50.0       # 溅射范围 50 像素
		splash.splash_ratio = 0.5  # 溅射伤害 = 基础伤害 × 50%
		data.effects.append(splash)
		spawner.spawn_projectile(data, global_position, target.global_position, target, self, damage)
```

### 模板 E：组合效果（减速 + 溅射 + 双发）

```gdscript
const ProjectileDataScript := preload("res://scripts/resources/projectile_data.gd")
const SlowEffectScript := preload("res://scripts/resources/slow_effect.gd")
const SplashEffectScript := preload("res://scripts/resources/splash_effect.gd")

func _spawn_arrow(target, damage: int = -1) -> void:
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		var data := ProjectileDataScript.new()
		data.shot_count = 2
		data.spread_angle = 10.0
		data.speed = 500.0       # 自定义速度
		data.arc_height = 20.0   # 自定义弧高

		var slow := SlowEffectScript.new()
		slow.slow_rate = 0.3
		slow.duration = 1.5
		data.effects.append(slow)

		var splash := SplashEffectScript.new()
		splash.radius = 40.0
		splash.splash_ratio = 0.3
		data.effects.append(splash)

		spawner.spawn_projectile(data, global_position, target.global_position, target, self, damage)
```

---

## ProjectileData 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `speed` | float | 400.0 | 箭飞行速度（像素/秒） |
| `arc_height` | float | 40.0 | 抛物线弧高（像素） |
| `shot_count` | int | 1 | 每次发射的箭数量 |
| `spread_angle` | float | 0.0 | 多发时的散射角度（度） |
| `effects` | Array | [] | 命中时触发的效果列表 |

## 现有效果组件

### SlowEffect — 减速

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `slow_rate` | float | 0.25 | 减速比例（0.25 = 减速 25%） |
| `duration` | float | 2.0 | 减速持续时间（秒） |

前提：目标必须有 `apply_slow(rate, duration)` 方法（单位默认有）。

### SplashEffect — 溅射

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `radius` | float | 50.0 | 溅射范围（像素） |
| `splash_ratio` | float | 0.5 | 溅射伤害比例（0.5 = 基础伤害的 50%） |

自动根据射击者的 team 查找敌方单位进行溅射。

---

## 扩展新效果

创建新文件 `scripts/resources/xxx_effect.gd`：

```gdscript
class_name XxxEffect
extends ProjectileEffect

@export var param_a: float = 1.0

func apply(_projectile: Node2D, target: Node2D) -> void:
	# 实现效果逻辑
	pass
```

然后在射击者的 `_spawn_arrow()` 中 preload 并 append 到 `data.effects` 即可。

---

## 现有射击者参考

- **弓箭手**（`scripts/units/unit.gd`）：`_spawn_arrow()` 传 `null`（无特效普通箭）
- **箭塔**（`scripts/buildings/building.gd`）：`_spawn_arrow()` 传带 `SlowEffect` 的 data
