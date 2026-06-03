class_name CommanderSkillData
extends RefCounted
## 指挥官技能数据定义

enum SkillId {
	ORBITAL_STRIKE,
	HEAL_FIELD,
	SHIELD_WALL,
	UNIT_DROP,
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
}

const ALL_SKILLS := [SkillId.ORBITAL_STRIKE, SkillId.HEAL_FIELD, SkillId.SHIELD_WALL, SkillId.UNIT_DROP]

const SKILL_HOTKEYS := {
	SkillId.ORBITAL_STRIKE: KEY_Z,
	SkillId.HEAL_FIELD: KEY_X,
	SkillId.SHIELD_WALL: KEY_C,
	SkillId.UNIT_DROP: KEY_V,
}

const HOTKEY_TO_SKILL := {
	KEY_Z: SkillId.ORBITAL_STRIKE,
	KEY_X: SkillId.HEAL_FIELD,
	KEY_C: SkillId.SHIELD_WALL,
	KEY_V: SkillId.UNIT_DROP,
}
