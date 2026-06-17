class_name GameData
extends RefCounted
## 静态游戏数据：枚举、常量、路径映射

const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

# --- 放置模式 ---
enum PlaceMode { NONE, WALL, TOWER, CASTLE, BARRACKS, SOLDIER, ARCHER, MONASTERY, ARCHERY_RANGE, LANCER, MONK_UNIT,
	SHIELDBEARER, BERSERKER, CROSSBOWMAN, PYROMANCER, CRYOMANCER,
	PIKEMAN, RAM, ARMOR_PIERCER,
	REVENANT, DUELIST, TROLL, PALADIN,
	WAR_DRUMMER, BANNER_BEARER,
	BOMBER, AVENGER,
	HAMMERER }

# --- 费用 ---
const COSTS := {
	PlaceMode.WALL: 50,
	PlaceMode.TOWER: 150,
	PlaceMode.SOLDIER: 100,
	PlaceMode.ARCHER: 120,
	PlaceMode.CASTLE: 500,
	PlaceMode.BARRACKS: 300,
	PlaceMode.MONASTERY: 350,
	PlaceMode.ARCHERY_RANGE: 250,
	PlaceMode.LANCER: 150,
	PlaceMode.MONK_UNIT: 80,
	PlaceMode.SHIELDBEARER: 100,
	PlaceMode.BERSERKER: 100,
	PlaceMode.CROSSBOWMAN: 120,
	PlaceMode.PYROMANCER: 120,
	PlaceMode.CRYOMANCER: 120,
	PlaceMode.PIKEMAN: 130,
	PlaceMode.RAM: 200,
	PlaceMode.ARMOR_PIERCER: 140,
	PlaceMode.REVENANT: 130,
	PlaceMode.DUELIST: 120,
	PlaceMode.TROLL: 160,
	PlaceMode.PALADIN: 180,
	PlaceMode.WAR_DRUMMER: 120,
	PlaceMode.BANNER_BEARER: 150,
	PlaceMode.BOMBER: 80,
	PlaceMode.AVENGER: 120,
	PlaceMode.HAMMERER: 130,
}

# --- 显示名称（翻译键，使用时需 tr()） ---
const MODE_NAMES := {
	PlaceMode.WALL: "ENTITY_WALL",
	PlaceMode.TOWER: "ENTITY_TOWER",
	PlaceMode.SOLDIER: "ENTITY_SOLDIER",
	PlaceMode.ARCHER: "ENTITY_ARCHER",
	PlaceMode.CASTLE: "ENTITY_CASTLE",
	PlaceMode.BARRACKS: "ENTITY_BARRACKS",
	PlaceMode.MONASTERY: "ENTITY_MONASTERY",
	PlaceMode.ARCHERY_RANGE: "ENTITY_ARCHERY",
	PlaceMode.LANCER: "ENTITY_LANCER",
	PlaceMode.MONK_UNIT: "ENTITY_MONK",
	PlaceMode.SHIELDBEARER: "ENTITY_SHIELDBEARER",
	PlaceMode.BERSERKER: "ENTITY_BERSERKER",
	PlaceMode.CROSSBOWMAN: "ENTITY_CROSSBOWMAN",
	PlaceMode.PYROMANCER: "ENTITY_PYROMANCER",
	PlaceMode.CRYOMANCER: "ENTITY_CRYOMANCER",
	PlaceMode.PIKEMAN: "ENTITY_PIKEMAN",
	PlaceMode.RAM: "ENTITY_RAM",
	PlaceMode.ARMOR_PIERCER: "ENTITY_ARMOR_PIERCER",
	PlaceMode.REVENANT: "ENTITY_REVENANT",
	PlaceMode.DUELIST: "ENTITY_DUELIST",
	PlaceMode.TROLL: "ENTITY_TROLL",
	PlaceMode.PALADIN: "ENTITY_PALADIN",
	PlaceMode.WAR_DRUMMER: "ENTITY_WAR_DRUMMER",
	PlaceMode.BANNER_BEARER: "ENTITY_BANNER_BEARER",
	PlaceMode.BOMBER: "ENTITY_BOMBER",
	PlaceMode.AVENGER: "ENTITY_AVENGER",
	PlaceMode.HAMMERER: "ENTITY_HAMMERER",
}

# --- 默认全部物品 ---
const ALL_ITEMS := [
	PlaceMode.WALL, PlaceMode.TOWER, PlaceMode.SOLDIER, PlaceMode.ARCHER,
	PlaceMode.CASTLE, PlaceMode.BARRACKS, PlaceMode.MONASTERY,
	PlaceMode.ARCHERY_RANGE, PlaceMode.LANCER, PlaceMode.MONK_UNIT,
	PlaceMode.SHIELDBEARER, PlaceMode.BERSERKER, PlaceMode.CROSSBOWMAN,
	PlaceMode.PYROMANCER, PlaceMode.CRYOMANCER,
	PlaceMode.PIKEMAN, PlaceMode.RAM, PlaceMode.ARMOR_PIERCER,
	PlaceMode.REVENANT, PlaceMode.DUELIST, PlaceMode.TROLL, PlaceMode.PALADIN,
	PlaceMode.WAR_DRUMMER, PlaceMode.BANNER_BEARER,
	PlaceMode.BOMBER, PlaceMode.AVENGER,
	PlaceMode.HAMMERER,
]

# --- 固定显示顺序（单位在前，建筑在后） ---
const DISPLAY_ORDER := [
	PlaceMode.SOLDIER, PlaceMode.ARCHER, PlaceMode.LANCER, PlaceMode.MONK_UNIT,
	PlaceMode.SHIELDBEARER, PlaceMode.BERSERKER, PlaceMode.CROSSBOWMAN,
	PlaceMode.PYROMANCER, PlaceMode.CRYOMANCER,
	PlaceMode.PIKEMAN, PlaceMode.RAM, PlaceMode.ARMOR_PIERCER,
	PlaceMode.REVENANT, PlaceMode.DUELIST, PlaceMode.TROLL, PlaceMode.PALADIN,
	PlaceMode.WAR_DRUMMER, PlaceMode.BANNER_BEARER,
	PlaceMode.BOMBER, PlaceMode.AVENGER, PlaceMode.HAMMERER,
	PlaceMode.WALL, PlaceMode.TOWER, PlaceMode.BARRACKS,
	PlaceMode.ARCHERY_RANGE, PlaceMode.MONASTERY, PlaceMode.CASTLE,
]

# --- 固定快捷键映射（每种物品始终对应同一个按键） ---
const MODE_HOTKEYS := {
	PlaceMode.SOLDIER:       KEY_1,
	PlaceMode.ARCHER:        KEY_2,
	PlaceMode.LANCER:        KEY_3,
	PlaceMode.MONK_UNIT:     KEY_4,
	PlaceMode.WALL:          KEY_5,
	PlaceMode.TOWER:         KEY_6,
	PlaceMode.BARRACKS:      KEY_7,
	PlaceMode.ARCHERY_RANGE: KEY_8,
	PlaceMode.MONASTERY:     KEY_9,
	PlaceMode.CASTLE:        KEY_0,
}

# --- 按钮图标纹理路径 ---
const MODE_ICONS := {
	PlaceMode.WALL:          "res://assets/buildings/blue_house/House1.png",
	PlaceMode.TOWER:         "res://assets/buildings/blue_tower/Tower.png",
	PlaceMode.CASTLE:        "res://assets/buildings/blue_castle/Castle.png",
	PlaceMode.BARRACKS:      "res://assets/buildings/blue_barracks/Barracks.png",
	PlaceMode.MONASTERY:     "res://assets/buildings/blue_monastery/Monastery.png",
	PlaceMode.ARCHERY_RANGE: "res://assets/buildings/blue_archery/Archery.png",
	PlaceMode.SOLDIER:       "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.ARCHER:        "res://assets/units/blue_archer/Archer_Idle.png",
	PlaceMode.LANCER:        "res://assets/units/blue_lancer/Lancer_Idle.png",
	PlaceMode.MONK_UNIT:     "res://assets/units/blue_monk/Idle.png",
	PlaceMode.SHIELDBEARER:  "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.BERSERKER:     "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.CROSSBOWMAN:   "res://assets/units/blue_archer/Archer_Idle.png",
	PlaceMode.PYROMANCER:    "res://assets/units/blue_archer/Archer_Idle.png",
	PlaceMode.CRYOMANCER:    "res://assets/units/blue_archer/Archer_Idle.png",
	PlaceMode.PIKEMAN:       "res://assets/units/blue_lancer/Lancer_Idle.png",
	PlaceMode.RAM:           "res://assets/units/blue_lancer/Lancer_Idle.png",
	PlaceMode.ARMOR_PIERCER: "res://assets/units/blue_archer/Archer_Idle.png",
	PlaceMode.REVENANT:      "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.DUELIST:       "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.TROLL:         "res://assets/units/blue_lancer/Lancer_Idle.png",
	PlaceMode.PALADIN:       "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.WAR_DRUMMER:   "res://assets/units/blue_monk/Idle.png",
	PlaceMode.BANNER_BEARER: "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.BOMBER: "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.AVENGER: "res://assets/units/blue_warrior/Warrior_Idle.png",
	PlaceMode.HAMMERER: "res://assets/units/blue_lancer/Lancer_Idle.png",
}

# --- 预加载按钮图标纹理 ---
const ICON_TEXTURES := {
	PlaceMode.WALL:          preload("res://assets/buildings/blue_house/House1.png"),
	PlaceMode.TOWER:         preload("res://assets/buildings/blue_tower/Tower.png"),
	PlaceMode.CASTLE:        preload("res://assets/buildings/blue_castle/Castle.png"),
	PlaceMode.BARRACKS:      preload("res://assets/buildings/blue_barracks/Barracks.png"),
	PlaceMode.MONASTERY:     preload("res://assets/buildings/blue_monastery/Monastery.png"),
	PlaceMode.ARCHERY_RANGE: preload("res://assets/buildings/blue_archery/Archery.png"),
	PlaceMode.SOLDIER:       preload("res://assets/units/blue_warrior/Warrior_Idle.png"),
	PlaceMode.ARCHER:        preload("res://assets/units/blue_archer/Archer_Idle.png"),
	PlaceMode.LANCER:        preload("res://assets/units/blue_lancer/Lancer_Idle.png"),
	PlaceMode.MONK_UNIT:     preload("res://assets/units/blue_monk/Idle.png"),
	PlaceMode.SHIELDBEARER:  preload("res://assets/units/blue_warrior/Warrior_Idle.png"),
	PlaceMode.BERSERKER:     preload("res://assets/units/blue_warrior/Warrior_Idle.png"),
	PlaceMode.CROSSBOWMAN:   preload("res://assets/units/blue_archer/Archer_Idle.png"),
	PlaceMode.PYROMANCER:    preload("res://assets/units/blue_archer/Archer_Idle.png"),
	PlaceMode.CRYOMANCER:    preload("res://assets/units/blue_archer/Archer_Idle.png"),
	PlaceMode.PIKEMAN:       preload("res://assets/units/blue_lancer/Lancer_Idle.png"),
	PlaceMode.RAM:           preload("res://assets/units/blue_lancer/Lancer_Idle.png"),
	PlaceMode.ARMOR_PIERCER: preload("res://assets/units/blue_archer/Archer_Idle.png"),
	PlaceMode.REVENANT:      preload("res://assets/units/blue_warrior/Warrior_Idle.png"),
	PlaceMode.DUELIST:       preload("res://assets/units/blue_warrior/Warrior_Idle.png"),
	PlaceMode.TROLL:         preload("res://assets/units/blue_lancer/Lancer_Idle.png"),
	PlaceMode.PALADIN:       preload("res://assets/units/blue_warrior/Warrior_Idle.png"),
	PlaceMode.WAR_DRUMMER:   preload("res://assets/units/blue_monk/Idle.png"),
	PlaceMode.BANNER_BEARER: preload("res://assets/units/blue_warrior/Warrior_Idle.png"),
	}

# --- Q模式：造兵快捷键 ---
const UNIT_PRODUCTION_HOTKEYS := {
	KEY_1: PlaceMode.SOLDIER,
	KEY_2: PlaceMode.ARCHER,
	KEY_3: PlaceMode.LANCER,
	KEY_4: PlaceMode.MONK_UNIT,
}

# --- W模式：建筑快捷键 ---
const BUILDING_PLACEMENT_HOTKEYS := {
	KEY_1: PlaceMode.WALL,
	KEY_2: PlaceMode.TOWER,
	KEY_3: PlaceMode.BARRACKS,
	KEY_4: PlaceMode.ARCHERY_RANGE,
	KEY_5: PlaceMode.MONASTERY,
	KEY_6: PlaceMode.CASTLE,
}

# --- 快捷键列表（旧版兼容） ---
const KEY_LIST := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]

# --- 建筑场景路径 ---
const BUILDING_SCENES := {
	BuildingScript.BuildingType.WALL: "res://scenes/buildings/wall.tscn",
	BuildingScript.BuildingType.TOWER: "res://scenes/buildings/tower.tscn",
	BuildingScript.BuildingType.CASTLE: "res://scenes/buildings/castle.tscn",
	BuildingScript.BuildingType.BARRACKS: "res://scenes/buildings/barracks.tscn",
	BuildingScript.BuildingType.MONASTERY: "res://scenes/buildings/monastery.tscn",
	BuildingScript.BuildingType.ARCHERY: "res://scenes/buildings/archery_building.tscn",
}

# --- 建筑网格尺寸 ---
const BUILDING_GRID_SIZES := {
	BuildingScript.BuildingType.WALL: Vector2i(1, 1),
	BuildingScript.BuildingType.TOWER: Vector2i(1, 1),
	BuildingScript.BuildingType.CASTLE: Vector2i(3, 3),
	BuildingScript.BuildingType.BARRACKS: Vector2i(2, 2),
	BuildingScript.BuildingType.MONASTERY: Vector2i(2, 2),
	BuildingScript.BuildingType.ARCHERY: Vector2i(2, 2),
}

# --- 单位场景路径 ---
const UNIT_SCENES := {
	UnitScript.UnitType.SOLDIER: "res://scenes/units/soldier.tscn",
	UnitScript.UnitType.ARCHER: "res://scenes/units/archer.tscn",
	UnitScript.UnitType.LANCER: "res://scenes/units/lancer.tscn",
	UnitScript.UnitType.MONK: "res://scenes/units/monk.tscn",
}

# --- 变体单位场景（按 stats id 查找，优先于 UNIT_SCENES） ---
const ENEMY_VARIANT_SCENES := {
	&"elite_archer": "res://scenes/units/elite_archer.tscn",
	&"shieldbearer": "res://scenes/units/shieldbearer.tscn",
	&"berserker": "res://scenes/units/berserker.tscn",
	&"crossbowman": "res://scenes/units/crossbowman.tscn",
	&"pyromancer": "res://scenes/units/pyromancer.tscn",
	&"cryomancer": "res://scenes/units/cryomancer.tscn",
	&"pikeman": "res://scenes/units/pikeman.tscn",
	&"ram": "res://scenes/units/ram.tscn",
	&"armor_piercer": "res://scenes/units/armor_piercer.tscn",
	&"revenant": "res://scenes/units/revenant.tscn",
	&"duelist": "res://scenes/units/duelist.tscn",
	&"troll": "res://scenes/units/troll.tscn",
	&"paladin": "res://scenes/units/paladin.tscn",
	&"war_drummer": "res://scenes/units/war_drummer.tscn",
	&"banner_bearer": "res://scenes/units/banner_bearer.tscn",
	&"bomber": "res://scenes/units/bomber.tscn",
	&"avenger": "res://scenes/units/avenger.tscn",
	&"hammerer": "res://scenes/units/hammerer.tscn",
}

# --- PlaceMode → BuildingType 映射 ---
const PLACE_MODE_TO_BUILDING := {
	PlaceMode.WALL: BuildingScript.BuildingType.WALL,
	PlaceMode.TOWER: BuildingScript.BuildingType.TOWER,
	PlaceMode.CASTLE: BuildingScript.BuildingType.CASTLE,
	PlaceMode.BARRACKS: BuildingScript.BuildingType.BARRACKS,
	PlaceMode.MONASTERY: BuildingScript.BuildingType.MONASTERY,
	PlaceMode.ARCHERY_RANGE: BuildingScript.BuildingType.ARCHERY,
}

# --- PlaceMode → UnitType 映射 ---
const PLACE_MODE_TO_UNIT := {
	PlaceMode.SOLDIER: UnitScript.UnitType.SOLDIER,
	PlaceMode.ARCHER: UnitScript.UnitType.ARCHER,
	PlaceMode.LANCER: UnitScript.UnitType.LANCER,
	PlaceMode.MONK_UNIT: UnitScript.UnitType.MONK,
	PlaceMode.SHIELDBEARER: UnitScript.UnitType.SOLDIER,
	PlaceMode.BERSERKER: UnitScript.UnitType.SOLDIER,
	PlaceMode.CROSSBOWMAN: UnitScript.UnitType.ARCHER,
	PlaceMode.PYROMANCER: UnitScript.UnitType.ARCHER,
	PlaceMode.CRYOMANCER: UnitScript.UnitType.ARCHER,
	PlaceMode.PIKEMAN: UnitScript.UnitType.LANCER,
	PlaceMode.RAM: UnitScript.UnitType.LANCER,
	PlaceMode.ARMOR_PIERCER: UnitScript.UnitType.ARCHER,
	PlaceMode.REVENANT: UnitScript.UnitType.SOLDIER,
	PlaceMode.DUELIST: UnitScript.UnitType.SOLDIER,
	PlaceMode.TROLL: UnitScript.UnitType.LANCER,
	PlaceMode.PALADIN: UnitScript.UnitType.SOLDIER,
	PlaceMode.WAR_DRUMMER: UnitScript.UnitType.MONK,
	PlaceMode.BANNER_BEARER: UnitScript.UnitType.SOLDIER,
	PlaceMode.BOMBER: UnitScript.UnitType.SOLDIER,
	PlaceMode.AVENGER: UnitScript.UnitType.SOLDIER,
	PlaceMode.HAMMERER: UnitScript.UnitType.LANCER,
}

# --- PlaceMode → stats_id 映射（变体单位） ---
const PLACE_MODE_TO_STATS_ID := {
	PlaceMode.SHIELDBEARER: &"shieldbearer",
	PlaceMode.BERSERKER: &"berserker",
	PlaceMode.CROSSBOWMAN: &"crossbowman",
	PlaceMode.PYROMANCER: &"pyromancer",
	PlaceMode.CRYOMANCER: &"cryomancer",
	PlaceMode.PIKEMAN: &"pikeman",
	PlaceMode.RAM: &"ram",
	PlaceMode.ARMOR_PIERCER: &"armor_piercer",
	PlaceMode.REVENANT: &"revenant",
	PlaceMode.DUELIST: &"duelist",
	PlaceMode.TROLL: &"troll",
	PlaceMode.PALADIN: &"paladin",
	PlaceMode.WAR_DRUMMER: &"war_drummer",
	PlaceMode.BANNER_BEARER: &"banner_bearer",
	PlaceMode.BOMBER: &"bomber",
	PlaceMode.AVENGER: &"avenger",
	PlaceMode.HAMMERER: &"hammerer",
}

# --- 网格 ---
const GRID_SIZE := 64

# --- 相机默认值 ---
const CAMERA_SPEED := 600.0
const EDGE_MARGIN := 30.0
const ZOOM_STEP := 0.15
const MIN_ZOOM := 0.4
const MAX_ZOOM := 2.0

# --- 特效场景 ---
const MoveClickEffectScene := preload("res://scenes/effects/move_click_effect.tscn")
const AttackClickEffectScene := preload("res://scenes/effects/attack_click_effect.tscn")
const DustEffectScene := preload("res://scenes/effects/dust_effect.tscn")
const SpawnEffectScene := preload("res://scenes/effects/spawn_effect.tscn")

# --- 环境纹理路径 ---
const TREE_TEXTURES := [
	"res://assets/environment/trees/Tree1.png",
	"res://assets/environment/trees/Tree2.png",
	"res://assets/environment/trees/Tree3.png",
	"res://assets/environment/trees/Tree4.png",
]
const ROCK_TEXTURES := [
	"res://assets/environment/rocks/Rock1.png",
	"res://assets/environment/rocks/Rock2.png",
	"res://assets/environment/rocks/Rock3.png",
	"res://assets/environment/rocks/Rock4.png",
]
const BUSH_TEXTURES := [
	"res://assets/environment/bushes/Bushe1.png",
	"res://assets/environment/bushes/Bushe2.png",
	"res://assets/environment/bushes/Bushe3.png",
	"res://assets/environment/bushes/Bushe4.png",
]

# --- 环境默认数量 ---
const DEFAULT_TREES := 15
const DEFAULT_ROCKS := 10
const DEFAULT_BUSHES := 12
const DEFAULT_SHEEP := 5


## 判断 PlaceMode 是否是单位
static func is_unit_mode(mode: int) -> bool:
	return mode in PLACE_MODE_TO_UNIT


## 判断 PlaceMode 是否是建筑
static func is_building_mode(mode: int) -> bool:
	return mode in PLACE_MODE_TO_BUILDING


## 获取建筑的网格尺寸，如果不是建筑返回 Vector2i(1,1)
static func get_building_grid_size(building_type: int) -> Vector2i:
	if building_type in BUILDING_GRID_SIZES:
		return BUILDING_GRID_SIZES[building_type]
	return Vector2i(1, 1)
