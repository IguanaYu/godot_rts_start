class_name CommanderProfile
extends Resource
## 指挥官配置：定义可用单位变体、建筑变体、面板技能、被动技能、初始加成
## 实例文件放 resources/commanders/*.tres，由 CommanderRegistry 加载

@export var id: StringName = &""
@export var display_name: String = ""            # 本地化 key，如 "COMMANDER_BALANCED_NAME"
@export var description: String = ""             # 本地化 key
@export var portrait: Texture2D

# 单位变体：UnitType 枚举值 → 可用 stats_id 列表
@export var unit_variants: Dictionary = {}
# 建筑变体：BuildingType 枚举值 → 可用 building_stats_id 列表
@export var building_variants: Dictionary = {}

# 面板主动技能（CommanderSkillData.SkillId 枚举值数组）
@export var active_skills: Array[int] = []

# 被动技能 id（StringName，对应 scripts/commander/passives/ 下的实现）
@export var passive_skills: Array[StringName] = []

# 视觉染色
@export var unit_color_tint: Color = Color.WHITE
@export var building_color_tint: Color = Color.WHITE

# 起始金币加成
@export var starting_gold_bonus: int = 0


func get_unit_variants_for_type(unit_type: int) -> Array:
	if unit_variants.has(unit_type):
		return unit_variants[unit_type]
	return []


func get_building_variants_for_type(building_type: int) -> Array:
	if building_variants.has(building_type):
		return building_variants[building_type]
	return []
