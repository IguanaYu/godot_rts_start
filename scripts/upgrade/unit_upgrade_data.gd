extends RefCounted
## PR-T2-4: 兵种全局升级定义数据（金币购买，按建筑类型展示）
## 先做核心 7 个跑通机制，PR-T2-4b 再扩展到 31 节点（含特色升级/时代门控）

enum Category { UNIT, BUILDING }

enum EffectType { STAT_MOD, GOLD_PRODUCTION }

# 素材路径（复用 upgrade_data.gd 的图标）
const PATH_ICON_HP := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_01.png"
const PATH_ICON_ATK := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_02.png"
const PATH_ICON_SPD := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_03.png"
const PATH_ICON_GOLD := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_06.png"

# 升级节点配置：node_id -> config
# unit_filter: all/combat/soldier/archer/lancer/monk
# building_filter: all/castle/farm/barracks/tower/archery
const CONFIGS := {
	"generic_hp": {
		"name": "UU_NAME_GENERIC_HP",
		"desc": "UU_DESC_GENERIC_HP",
		"icon": PATH_ICON_HP,
		"category": Category.UNIT,
		"effect_type": EffectType.STAT_MOD,
		"unit_filter": "all",
		"stat_name": "max_hp",
		"flat": 0.0,
		"multiplier": 1.10,
		"cost": 300,
		"max_level": 3,
		"cost_growth": 1.5,
	},
	"generic_dmg": {
		"name": "UU_NAME_GENERIC_DMG",
		"desc": "UU_DESC_GENERIC_DMG",
		"icon": PATH_ICON_ATK,
		"category": Category.UNIT,
		"effect_type": EffectType.STAT_MOD,
		"unit_filter": "combat",
		"stat_name": "attack_damage",
		"flat": 0.0,
		"multiplier": 1.10,
		"cost": 300,
		"max_level": 3,
		"cost_growth": 1.5,
	},
	"generic_spd": {
		"name": "UU_NAME_GENERIC_SPD",
		"desc": "UU_DESC_GENERIC_SPD",
		"icon": PATH_ICON_SPD,
		"category": Category.UNIT,
		"effect_type": EffectType.STAT_MOD,
		"unit_filter": "all",
		"stat_name": "move_speed",
		"flat": 0.0,
		"multiplier": 1.10,
		"cost": 300,
		"max_level": 3,
		"cost_growth": 1.5,
	},
	"soldier_hp": {
		"name": "UU_NAME_SOLDIER_HP",
		"desc": "UU_DESC_SOLDIER_HP",
		"icon": PATH_ICON_HP,
		"category": Category.UNIT,
		"effect_type": EffectType.STAT_MOD,
		"unit_filter": "soldier",
		"stat_name": "max_hp",
		"flat": 0.0,
		"multiplier": 1.10,
		"cost": 200,
		"max_level": 3,
		"cost_growth": 1.5,
	},
	"farm_yield": {
		"name": "UU_NAME_FARM_YIELD",
		"desc": "UU_DESC_FARM_YIELD",
		"icon": PATH_ICON_GOLD,
		"category": Category.BUILDING,
		"effect_type": EffectType.GOLD_PRODUCTION,
		"building_filter": "farm",
		"multiplier": 1.30,
		"cost": 500,
		"max_level": 1,
	},
	"castle_hp": {
		"name": "UU_NAME_CASTLE_HP",
		"desc": "UU_DESC_CASTLE_HP",
		"icon": PATH_ICON_HP,
		"category": Category.BUILDING,
		"effect_type": EffectType.STAT_MOD,
		"building_filter": "all",
		"stat_name": "max_hp",
		"flat": 0.0,
		"multiplier": 1.20,
		"cost": 500,
		"max_level": 1,
	},
}

# 全部节点 ID 列表
const ALL_IDS := [
	"generic_hp", "generic_dmg", "generic_spd",
	"soldier_hp",
	"farm_yield", "castle_hp",
]
