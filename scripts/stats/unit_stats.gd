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

# --- 弹道数据（非近战单位使用投射物） ---
@export var projectile_data: Resource = null      # ProjectileData，null=近战直接伤害

# --- 反特化 ---
@export var bonus_vs_unit_types: Array[int] = []    # 对这些 UnitType 造额外伤害
@export var bonus_vs_multiplier: float = 1.0         # 倍率（2.5 = 2.5倍伤害）
@export var bonus_vs_building_multiplier: float = 1.0 # 对建筑倍率
@export var ignores_damage_reduction: bool = false    # 穿甲：无视目标减伤

# --- 续航系 ---
@export var lifesteal_ratio: float = 0.0   # 吸血百分比（0.6 = 回复造成伤害的60%）
@export var lifesteal_flat: int = 0         # 每次攻击固定回血（圣骑士用）
@export var dodge_chance: float = 0.0       # 闪避概率（0.35 = 35%免伤）
@export var regen_per_sec: float = 0.0      # 每秒回血

# --- 光环 ---
@export var aura_range: float = 0.0    # 0 = 无光环
@export var aura_type: String = ""     # "attack"/"defense"/"regen"/"range_bonus"/"shield"
@export var aura_value: float = 0.0    # 数值

# --- 死亡触发 ---
@export var explode_damage: int = 0      # 自爆伤害，0=不自爆
@export var explode_radius: float = 0.0  # 爆炸范围
@export var vengeance_buff_value: float = 0.0    # 同伴死亡时获得的 buff 强度（+攻%）
@export var vengeance_buff_duration: float = 0.0  # buff 持续时间(ms)
@export var vengeance_scan_range: float = 0.0     # 侦测同伴死亡的范围

# --- 击退 ---
@export var knockback_force: float = 0.0   # 命中后将目标推开多少像素，0=无击退

# --- 连锁闪电 ---
@export var chain_count: int = 0           # 连锁次数，0=无连锁
@export var chain_falloff: float = 0.7     # 每次连锁伤害衰减（0.7=70%）
@export var chain_range: float = 120.0     # 连锁搜索范围

# --- 锥形 AoE ---
@export var cone_range: float = 0.0        # 锥形攻击范围，0=无锥形
@export var cone_angle: float = 0.0        # 锥形角度（度），如 90=前方90度扇形

# --- 升级系统 ---
@export var upgrade_hp_per_level: int = 10       # 每级 HP 增加
@export var upgrade_damage_per_level: int = 2    # 每级攻击力增加
@export var upgrade_speed_per_level: float = 5.0 # 每级速度增加
@export var max_upgrade_level: int = 3           # 最大升级等级
@export var upgrade_cost: int = 200              # 每次升级费用
