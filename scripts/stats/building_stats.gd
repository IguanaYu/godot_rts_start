class_name BuildingStats
extends Resource
## 建筑属性数据资源：替代 building.gd:_setup_stats() 的硬编码
## 指挥官变体 category = "commander_variant"，由 CommanderProfile.building_variants 引用

@export var id: StringName = &""                 # 唯一标识，如 &"barracks", &"barracks_fortified"
@export var building_type: int = 0               # 对应 Building.BuildingType 枚举
@export var category: String = "normal"          # "normal" / "commander_variant"
@export var parent_id: StringName = &""          # 父级 id（元数据）

# --- 基础属性 ---
@export var max_hp: int = 100
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var cost_override: int = -1              # -1 = 用默认 COSTS 表
@export var build_time: float = 5.0

# --- 箭塔攻击（TOWER 用） ---
@export var attack_damage: float = 0.0
@export var attack_range: float = 0.0
@export var attack_cooldown: float = 1.5

# --- 生产系统（BARRACKS / MONASTERY / ARCHERY / CASTLE 用） ---
@export var production_cooldown: float = 0.0
@export var production_variant_ids: Array[StringName] = []  # 取代硬编码产兵绑定
@export var is_gold_producer: bool = false       # CASTLE = true

# --- 光环系统 ---
@export var aura_range: float = 0.0
@export var aura_type: String = ""
@export var aura_value: float = 0.0

# --- 视觉 ---
@export var tint: Color = Color.WHITE
@export var sprite_scale: float = 1.0
