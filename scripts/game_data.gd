class_name GameData
extends RefCounted
## 静态游戏数据：枚举、常量、路径映射

const UnitScript := preload("res://scripts/unit.gd")
const BuildingScript := preload("res://scripts/building.gd")

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

# --- 显示名称 ---
const MODE_NAMES := {
	PlaceMode.WALL: "Wall",
	PlaceMode.TOWER: "Tower",
	PlaceMode.SOLDIER: "Soldier",
	PlaceMode.ARCHER: "Archer",
	PlaceMode.CASTLE: "Castle",
	PlaceMode.BARRACKS: "Barracks",
	PlaceMode.MONASTERY: "Monastery",
	PlaceMode.ARCHERY_RANGE: "Archery",
	PlaceMode.LANCER: "Lancer",
	PlaceMode.MONK_UNIT: "Monk",
}

# --- 默认全部物品 ---
const ALL_ITEMS := [
	PlaceMode.WALL, PlaceMode.TOWER, PlaceMode.SOLDIER, PlaceMode.ARCHER,
	PlaceMode.CASTLE, PlaceMode.BARRACKS, PlaceMode.MONASTERY,
	PlaceMode.ARCHERY_RANGE, PlaceMode.LANCER, PlaceMode.MONK_UNIT
]

# --- 快捷键列表 ---
const KEY_LIST := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]

# --- 建筑场景路径 ---
const BUILDING_SCENES := {
	BuildingScript.BuildingType.WALL: "res://scenes/wall.tscn",
	BuildingScript.BuildingType.TOWER: "res://scenes/tower.tscn",
	BuildingScript.BuildingType.CASTLE: "res://scenes/castle.tscn",
	BuildingScript.BuildingType.BARRACKS: "res://scenes/barracks.tscn",
	BuildingScript.BuildingType.MONASTERY: "res://scenes/monastery.tscn",
	BuildingScript.BuildingType.ARCHERY: "res://scenes/archery_building.tscn",
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
	UnitScript.UnitType.SOLDIER: "res://scenes/soldier.tscn",
	UnitScript.UnitType.ARCHER: "res://scenes/archer.tscn",
	UnitScript.UnitType.LANCER: "res://scenes/lancer.tscn",
	UnitScript.UnitType.MONK: "res://scenes/monk.tscn",
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
const MoveClickEffectScene := preload("res://scenes/move_click_effect.tscn")
const AttackClickEffectScene := preload("res://scenes/attack_click_effect.tscn")
const DustEffectScene := preload("res://scenes/dust_effect.tscn")

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
