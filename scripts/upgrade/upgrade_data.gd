extends RefCounted
## 升级定义数据：18个升级，3个 tier，3种效果类型

enum Tier { SILVER, GOLD, DIAMOND }

enum EffectType { STAT_MOD, SPAWN_UNITS, GIVE_GOLD }

# --- 升级 ID ---
enum UpgradeId {
	# 白银 (9)
	HP_BOOST_5,
	ATK_BOOST_5,
	SPD_BOOST_5,
	DEF_BOOST_3,
	HP_FLAT_10,
	ATK_FLAT_2,
	SPAWN_SOLDIERS_2,
	GIVE_GOLD_100,
	HEAL_BOOST_5,
	# 黄金 (6)
	HP_BOOST_10,
	ATK_BOOST_10,
	DEF_BOOST_5,
	COOLDOWN_10,
	SPAWN_MIX_3,
	GIVE_GOLD_250,
	# 钻石 (3)
	HP_BOOST_20,
	ATK_BOOST_20,
	SPAWN_ARMY_6,
}

const _F := "flat"
const _M := "multiplier"

# 素材路径
const PATH_ICON_HP := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_01.png"
const PATH_ICON_ATK := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_02.png"
const PATH_ICON_SPD := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_03.png"
const PATH_ICON_DEF := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_04.png"
const PATH_ICON_SPAWN := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_05.png"
const PATH_ICON_GOLD := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_06.png"
const PATH_ICON_HEAL := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_07.png"
const PATH_ICON_CD := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_08.png"

# 每个升级的完整配置
const CONFIGS := {
	# ========== 白银 ==========
	UpgradeId.HP_BOOST_5: {
		"name": "UPGRADE_HP_BOOST_5",
		"desc": "UPGRADE_HP_BOOST_5_DESC",
		"icon": PATH_ICON_HP,
		"tier": Tier.SILVER,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "max_hp",
		_F: 0.0, _M: 1.05,
		"unit_filter": "all",
	},
	UpgradeId.ATK_BOOST_5: {
		"name": "UPGRADE_ATK_BOOST_5",
		"desc": "UPGRADE_ATK_BOOST_5_DESC",
		"icon": PATH_ICON_ATK,
		"tier": Tier.SILVER,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "attack_damage",
		_F: 0.0, _M: 1.05,
		"unit_filter": "combat",
	},
	UpgradeId.SPD_BOOST_5: {
		"name": "UPGRADE_SPD_BOOST_5",
		"desc": "UPGRADE_SPD_BOOST_5_DESC",
		"icon": PATH_ICON_SPD,
		"tier": Tier.SILVER,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "move_speed",
		_F: 0.0, _M: 1.05,
		"unit_filter": "all",
	},
	UpgradeId.DEF_BOOST_3: {
		"name": "UPGRADE_DEF_BOOST_3",
		"desc": "UPGRADE_DEF_BOOST_3_DESC",
		"icon": PATH_ICON_DEF,
		"tier": Tier.SILVER,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "damage_reduction",
		_F: 0.03, _M: 1.0,
		"unit_filter": "all",
	},
	UpgradeId.HP_FLAT_10: {
		"name": "UPGRADE_HP_FLAT_10",
		"desc": "UPGRADE_HP_FLAT_10_DESC",
		"icon": PATH_ICON_HP,
		"tier": Tier.SILVER,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "max_hp",
		_F: 10.0, _M: 1.0,
		"unit_filter": "all",
	},
	UpgradeId.ATK_FLAT_2: {
		"name": "UPGRADE_ATK_FLAT_2",
		"desc": "UPGRADE_ATK_FLAT_2_DESC",
		"icon": PATH_ICON_ATK,
		"tier": Tier.SILVER,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "attack_damage",
		_F: 2.0, _M: 1.0,
		"unit_filter": "combat",
	},
	UpgradeId.SPAWN_SOLDIERS_2: {
		"name": "UPGRADE_SPAWN_2",
		"desc": "UPGRADE_SPAWN_2_DESC",
		"icon": PATH_ICON_SPAWN,
		"tier": Tier.SILVER,
		"effect_type": EffectType.SPAWN_UNITS,
		"spawn_units": [{"type": 0, "count": 2}],  # 0 = SOLDIER
	},
	UpgradeId.GIVE_GOLD_100: {
		"name": "UPGRADE_GOLD_100",
		"desc": "UPGRADE_GOLD_100_DESC",
		"icon": PATH_ICON_GOLD,
		"tier": Tier.SILVER,
		"effect_type": EffectType.GIVE_GOLD,
		"gold_amount": 100,
	},
	UpgradeId.HEAL_BOOST_5: {
		"name": "UPGRADE_HEAL_5",
		"desc": "UPGRADE_HEAL_5_DESC",
		"icon": PATH_ICON_HEAL,
		"tier": Tier.SILVER,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "heal_amount",
		_F: 0.0, _M: 1.05,
		"unit_filter": "monk",
	},
	# ========== 黄金 ==========
	UpgradeId.HP_BOOST_10: {
		"name": "UPGRADE_HP_BOOST_10",
		"desc": "UPGRADE_HP_BOOST_10_DESC",
		"icon": PATH_ICON_HP,
		"tier": Tier.GOLD,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "max_hp",
		_F: 0.0, _M: 1.10,
		"unit_filter": "all",
	},
	UpgradeId.ATK_BOOST_10: {
		"name": "UPGRADE_ATK_BOOST_10",
		"desc": "UPGRADE_ATK_BOOST_10_DESC",
		"icon": PATH_ICON_ATK,
		"tier": Tier.GOLD,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "attack_damage",
		_F: 0.0, _M: 1.10,
		"unit_filter": "combat",
	},
	UpgradeId.DEF_BOOST_5: {
		"name": "UPGRADE_DEF_BOOST_5",
		"desc": "UPGRADE_DEF_BOOST_5_DESC",
		"icon": PATH_ICON_DEF,
		"tier": Tier.GOLD,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "damage_reduction",
		_F: 0.05, _M: 1.0,
		"unit_filter": "all",
	},
	UpgradeId.COOLDOWN_10: {
		"name": "UPGRADE_CD_10",
		"desc": "UPGRADE_CD_10_DESC",
		"icon": PATH_ICON_CD,
		"tier": Tier.GOLD,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "attack_cooldown",
		_F: 0.0, _M: 0.90,
		"unit_filter": "combat",
	},
	UpgradeId.SPAWN_MIX_3: {
		"name": "UPGRADE_SPAWN_3",
		"desc": "UPGRADE_SPAWN_3_DESC",
		"icon": PATH_ICON_SPAWN,
		"tier": Tier.GOLD,
		"effect_type": EffectType.SPAWN_UNITS,
		"spawn_units": [{"type": 0, "count": 2}, {"type": 1, "count": 1}],  # 2战士+1弓手
	},
	UpgradeId.GIVE_GOLD_250: {
		"name": "UPGRADE_GOLD_250",
		"desc": "UPGRADE_GOLD_250_DESC",
		"icon": PATH_ICON_GOLD,
		"tier": Tier.GOLD,
		"effect_type": EffectType.GIVE_GOLD,
		"gold_amount": 250,
	},
	# ========== 钻石 ==========
	UpgradeId.HP_BOOST_20: {
		"name": "UPGRADE_HP_BOOST_20",
		"desc": "UPGRADE_HP_BOOST_20_DESC",
		"icon": PATH_ICON_HP,
		"tier": Tier.DIAMOND,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "max_hp",
		_F: 0.0, _M: 1.20,
		"unit_filter": "all",
	},
	UpgradeId.ATK_BOOST_20: {
		"name": "UPGRADE_ATK_BOOST_20",
		"desc": "UPGRADE_ATK_BOOST_20_DESC",
		"icon": PATH_ICON_ATK,
		"tier": Tier.DIAMOND,
		"effect_type": EffectType.STAT_MOD,
		"stat_name": "attack_damage",
		_F: 0.0, _M: 1.20,
		"unit_filter": "combat",
	},
	UpgradeId.SPAWN_ARMY_6: {
		"name": "UPGRADE_SPAWN_6",
		"desc": "UPGRADE_SPAWN_6_DESC",
		"icon": PATH_ICON_SPAWN,
		"tier": Tier.DIAMOND,
		"effect_type": EffectType.SPAWN_UNITS,
		"spawn_units": [{"type": 0, "count": 3}, {"type": 1, "count": 2}, {"type": 2, "count": 1}],
	},
}

# 按 tier 分组的 ID 列表
const BY_TIER := {
	Tier.SILVER: [
		UpgradeId.HP_BOOST_5, UpgradeId.ATK_BOOST_5, UpgradeId.SPD_BOOST_5,
		UpgradeId.DEF_BOOST_3, UpgradeId.HP_FLAT_10, UpgradeId.ATK_FLAT_2,
		UpgradeId.SPAWN_SOLDIERS_2, UpgradeId.GIVE_GOLD_100, UpgradeId.HEAL_BOOST_5,
	],
	Tier.GOLD: [
		UpgradeId.HP_BOOST_10, UpgradeId.ATK_BOOST_10, UpgradeId.DEF_BOOST_5,
		UpgradeId.COOLDOWN_10, UpgradeId.SPAWN_MIX_3, UpgradeId.GIVE_GOLD_250,
	],
	Tier.DIAMOND: [
		UpgradeId.HP_BOOST_20, UpgradeId.ATK_BOOST_20, UpgradeId.SPAWN_ARMY_6,
	],
}

const TIER_NAMES := {
	Tier.SILVER: "UPGRADE_TIER_SILVER",
	Tier.GOLD: "UPGRADE_TIER_GOLD",
	Tier.DIAMOND: "UPGRADE_TIER_DIAMOND",
}

const TIER_COLORS := {
	Tier.SILVER: Color(0.78, 0.78, 0.78, 1.0),
	Tier.GOLD: Color(1.0, 0.85, 0.0, 1.0),
	Tier.DIAMOND: Color(0.4, 0.7, 1.0, 1.0),
}

const TIER_GLOW_COLORS := {
	Tier.SILVER: Color(0.75, 0.75, 0.8, 0.35),
	Tier.GOLD: Color(1.0, 0.85, 0.0, 0.4),
	Tier.DIAMOND: Color(0.3, 0.6, 1.0, 0.5),
}
