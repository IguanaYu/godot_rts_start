class_name UnitStats
extends Resource
## 单位属性数据资源：每个 .tres 文件定义一种单位的属性
## hero/boss 可通过 parent_id 继承基础兵种属性，只覆盖差异字段

@export var id: StringName = &""                 # 唯一标识，如 &"soldier", &"hero_soldier"
@export var unit_type: int = 0                   # 对应 Unit.UnitType 枚举
@export var category: String = "normal"          # "normal" / "hero" / "boss"
@export var parent_id: StringName = &""          # 父级 id，用于继承

# --- 基础属性 ---
@export var max_hp: int = 100
@export var attack_damage: int = 10
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 0.8
@export var move_speed: float = 120.0
@export var damage_reduction: float = 0.0        # 0.0 = 无减伤

# --- Monk 治疗属性（非 Monk 为 0） ---
@export var heal_range: float = 0.0
@export var heal_amount: int = 0
@export var heal_cooldown: float = 0.0
@export var heal_scan_range: float = 0.0

# --- 视觉缩放（hero/boss 更大） ---
@export var sprite_scale: float = 1.0

# --- 升级系统 ---
@export var upgrade_hp_per_level: int = 10       # 每级 HP 增加
@export var upgrade_damage_per_level: int = 2    # 每级攻击力增加
@export var upgrade_speed_per_level: float = 5.0 # 每级速度增加
@export var max_upgrade_level: int = 3           # 最大升级等级
@export var upgrade_cost: int = 200              # 每次升级费用
