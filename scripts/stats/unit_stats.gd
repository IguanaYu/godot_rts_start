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

# --- 隐身 ---
@export var stealth_on_idle: bool = false   # 非战斗时自动隐身（半透明+不被索敌）
@export var stealth_reveal_duration: float = 2.0  # 攻击/受击后显形秒数

# --- 闪现 ---
@export var blink_range: float = 0.0        # 闪现距离，0=无闪现
@export var blink_cooldown: float = 5.0     # 闪现冷却秒数

# --- 护盾光环（Warden） ---
@export var shield_amount: int = 0          # 每次加的护盾值，0=无护盾光环
@export var shield_aura_range: float = 0.0  # 护盾光环范围
@export var shield_cooldown: float = 3.0    # 加盾周期（秒）

# --- 嘲讽（Stoneguard） ---
@export var taunt_range: float = 0.0        # 嘲讽范围，0=无嘲讽
@export var taunt_duration: float = 0.0     # 嘲讽持续秒数
@export var taunt_pulse_interval: float = 1.0  # 嘲讽脉冲间隔（秒）

# --- 驱散（Inquisitor） ---
@export var dispel_on_hit: bool = false     # 命中时清除目标所有增益 buff
@export var cleanse_on_heal: bool = false   # 治疗友军时清除其 debuff（中毒/减速）

# --- 召唤（Necromancer） ---
@export var summon_max: int = 0             # 同时可维持的召唤物上限，0=不召唤
@export var summon_stats_id: StringName = &""  # 召唤物使用的 stats_id
@export var summon_type: int = 0            # 召唤物 UnitType
@export var summon_chance: float = 1.0      # 每次攻击命中时召唤概率（0-1）
@export var summon_lifetime: float = 15.0   # 召唤物存活秒数（0=永久）

# --- 升级系统 ---
@export var upgrade_hp_per_level: int = 10       # 每级 HP 增加
@export var upgrade_damage_per_level: int = 2    # 每级攻击力增加
@export var upgrade_speed_per_level: float = 5.0 # 每级速度增加
@export var max_upgrade_level: int = 3           # 最大升级等级
@export var upgrade_cost: int = 200              # 每次升级费用
