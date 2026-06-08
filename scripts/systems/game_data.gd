class_name GameData
extends RefCounted
## 静态游戏数据：枚举、常量、路径映射

const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

# --- 放置模式 ---
enum PlaceMode { NONE, WALL, TOWER, CASTLE, BARRACKS, SOLDIER, ARCHER, MONASTERY, ARCHERY_RANGE, LANCER, MONK_UNIT }

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
}

# --- 默认全部物品 ---
const ALL_ITEMS := [
	PlaceMode.WALL, PlaceMode.TOWER, PlaceMode.SOLDIER, PlaceMode.ARCHER,
	PlaceMode.CASTLE, PlaceMode.BARRACKS, PlaceMode.MONASTERY,
	PlaceMode.ARCHERY_RANGE, PlaceMode.LANCER, PlaceMode.MONK_UNIT
]

# --- 固定显示顺序（单位在前，建筑在后） ---
const DISPLAY_ORDER := [
	PlaceMode.SOLDIER, PlaceMode.ARCHER, PlaceMode.LANCER, PlaceMode.MONK_UNIT,
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
