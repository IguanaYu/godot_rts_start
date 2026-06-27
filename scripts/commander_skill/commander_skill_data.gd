class_name CommanderSkillData
extends RefCounted
## 指挥官技能数据定义

enum SkillId {
	# --- 原有 ---
	ORBITAL_STRIKE,
	HEAL_FIELD,
	SHIELD_WALL,
	UNIT_DROP,
	# --- Layer 1 扩展 ---
	NAPALM_STRIKE,     # 凝固汽油弹
	CLUSTER_BOMB,      # 集束炸弹
	SNIPER_MARK,       # 狙击标记
	POISON_CLOUD,      # 毒气云
	EMERGENCY_REPAIR,  # 紧急维修（全图友方建筑）
	FORCE_FIELD,       # 力场屏障（无敌阻挡）
	REPAIR_DRONE,      # 维修无人机（持续治疗）
	SUPPLY_DROP,       # 补给箱（免费冷却换金币）
	# --- balanced 独占 ---
	FORTIFY,
}

enum CastType {
	INSTANT,
	TARGET_POINT,
	TARGET_AREA,
}

enum CostType {
	ENERGY,
	GOLD,
}

const MAX_ENERGY := 100.0
const ENERGY_REGEN_RATE := 2.0

const SKILL_CONFIGS := {
	SkillId.ORBITAL_STRIKE: {
		"name": "SKILL_ORBITAL_STRIKE",
		"description": "SKILL_ORBITAL_STRIKE_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 40,
		"cooldown": 30.0,
		"cast_type": CastType.TARGET_POINT,
		"radius": 80.0,
		"damage": 150,
		"hotkey": KEY_Z,
	},
	SkillId.HEAL_FIELD: {
		"name": "SKILL_HEAL_FIELD",
		"description": "SKILL_HEAL_FIELD_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 30,
		"cooldown": 25.0,
		"cast_type": CastType.TARGET_AREA,
		"radius": 120.0,
		"heal_amount": 50,
		"hotkey": KEY_X,
	},
	SkillId.SHIELD_WALL: {
		"name": "SKILL_SHIELD_WALL",
		"description": "SKILL_SHIELD_WALL_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 25,
		"cooldown": 20.0,
		"cast_type": CastType.TARGET_POINT,
		"duration": 15.0,
		"hotkey": KEY_C,
	},
	SkillId.UNIT_DROP: {
		"name": "SKILL_UNIT_DROP",
		"description": "SKILL_UNIT_DROP_DESC",
		"cost_type": CostType.GOLD,
		"cost": 300,
		"cooldown": 60.0,
		"cast_type": CastType.TARGET_POINT,
		"units": [0, 0, 1],
		"hotkey": KEY_V,
	},
	# --- Layer 1 扩展 ---
	SkillId.NAPALM_STRIKE: {
		"name": "SKILL_NAPALM_STRIKE",
		"description": "SKILL_NAPALM_STRIKE_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 35,
		"cooldown": 25.0,
		"cast_type": CastType.TARGET_AREA,
		"radius": 90.0,
		"duration": 5.0,
		"dps": 30,
		"hotkey": KEY_B,
	},
	SkillId.CLUSTER_BOMB: {
		"name": "SKILL_CLUSTER_BOMB",
		"description": "SKILL_CLUSTER_BOMB_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 45,
		"cooldown": 35.0,
		"cast_type": CastType.TARGET_AREA,
		"radius": 140.0,
		"damage": 50,
		"sub_explosions": 6,
		"hotkey": KEY_N,
	},
	SkillId.SNIPER_MARK: {
		"name": "SKILL_SNIPER_MARK",
		"description": "SKILL_SNIPER_MARK_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 20,
		"cooldown": 8.0,
		"cast_type": CastType.TARGET_POINT,
		"radius": 15.0,
		"damage": 500,
		"hotkey": KEY_F,
	},
	SkillId.POISON_CLOUD: {
		"name": "SKILL_POISON_CLOUD",
		"description": "SKILL_POISON_CLOUD_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 30,
		"cooldown": 25.0,
		"cast_type": CastType.TARGET_AREA,
		"radius": 110.0,
		"duration": 8.0,
		"dps": 15,
		"hotkey": KEY_T,
	},
	SkillId.EMERGENCY_REPAIR: {
		"name": "SKILL_EMERGENCY_REPAIR",
		"description": "SKILL_EMERGENCY_REPAIR_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 40,
		"cooldown": 30.0,
		"cast_type": CastType.INSTANT,
		"heal_ratio": 0.4,
		"hotkey": KEY_O,
	},
	SkillId.FORCE_FIELD: {
		"name": "SKILL_FORCE_FIELD",
		"description": "SKILL_FORCE_FIELD_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 20,
		"cooldown": 15.0,
		"cast_type": CastType.TARGET_AREA,
		"radius": 60.0,
		"duration": 8.0,
		"hotkey": KEY_J,
	},
	SkillId.REPAIR_DRONE: {
		"name": "SKILL_REPAIR_DRONE",
		"description": "SKILL_REPAIR_DRONE_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 35,
		"cooldown": 25.0,
		"cast_type": CastType.TARGET_AREA,
		"radius": 100.0,
		"duration": 10.0,
		"hps": 8,
		"hotkey": KEY_K,
	},
	SkillId.SUPPLY_DROP: {
		"name": "SKILL_SUPPLY_DROP",
		"description": "SKILL_SUPPLY_DROP_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 0,
		"cooldown": 60.0,
		"cast_type": CastType.TARGET_POINT,
		"gold_bonus": 100,
		"hotkey": KEY_L,
	},
	# --- balanced 独占 ---
	SkillId.FORTIFY: {
		"name": "SKILL_FORTIFY",
		"description": "SKILL_FORTIFY_DESC",
		"cost_type": CostType.ENERGY,
		"cost": 35,
		"cooldown": 60.0,
		"cast_type": CastType.INSTANT,
		"duration": 12.0,
		"max_hp_bonus": 0.5,
		"attack_bonus": 0.3,
		"hotkey": KEY_G,
	},
}

const ALL_SKILLS := [
	SkillId.ORBITAL_STRIKE, SkillId.HEAL_FIELD, SkillId.SHIELD_WALL, SkillId.UNIT_DROP,
	SkillId.NAPALM_STRIKE, SkillId.CLUSTER_BOMB, SkillId.SNIPER_MARK, SkillId.POISON_CLOUD,
	SkillId.EMERGENCY_REPAIR, SkillId.FORCE_FIELD, SkillId.REPAIR_DRONE, SkillId.SUPPLY_DROP,
	SkillId.FORTIFY,
]


# 技能图标路径（供面板 / 配置弹窗共用）
const SKILL_ICONS_BY_ID := {
	SkillId.ORBITAL_STRIKE: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_01.png",
	SkillId.HEAL_FIELD: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_02.png",
	SkillId.SHIELD_WALL: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_03.png",
	SkillId.UNIT_DROP: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_04.png",
	SkillId.NAPALM_STRIKE: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_05.png",
	SkillId.CLUSTER_BOMB: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_06.png",
	SkillId.SNIPER_MARK: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_07.png",
	SkillId.POISON_CLOUD: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_08.png",
	SkillId.EMERGENCY_REPAIR: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_09.png",
	SkillId.FORCE_FIELD: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_10.png",
	SkillId.REPAIR_DRONE: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_11.png",
	SkillId.SUPPLY_DROP: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_12.png",
	SkillId.FORTIFY: "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_04.png",
}
