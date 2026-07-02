extends RefCounted
## 科技点系统静态数据：阈值、各行为基础点数、来源分类

## 科技等级解锁阈值（累积科技点达到后解锁对应等级）
const TECH_LEVEL_THRESHOLDS := {
	2: 1000,  # Tier 2: 累积 1000 科技点
	3: 3000,  # Tier 3: 累积 3000 科技点
}

## 来源分类（用于指挥官倍率查询）
const CATEGORY_BUILD_CONSTRUCTION := "build_construction"   # 建造建筑完成
const CATEGORY_KILL_ENEMY_BUILDING := "kill_enemy_building" # 摧毁敌方建筑
const CATEGORY_KILL_ENEMY_UNIT := "kill_enemy_unit"         # 消灭敌方单位
const CATEGORY_OWN_UNIT_DIED := "own_unit_died"             # 己方单位死亡
const CATEGORY_PRODUCE_UNIT := "produce_unit"               # 生产单位
const CATEGORY_PASSIVE := "passive"                         # 每 60s 被动获得

## 各行为基础科技点数
const BASE_POINTS := {
	# 建造建筑完成
	"building_castle":    300,
	"building_barracks":  200,
	"building_monastery": 200,
	"building_archery":   200,
	"building_tower":     100,
	"building_wall":      100,
	# 摧毁敌方建筑
	"kill_building":      100,
	# 消灭敌方单位
	"kill_unit":          1,
	# 己方单位死亡
	"own_unit_died":      2,
	# 生产一个单位
	"produce_unit":       5,
	# 每 60 秒被动
	"passive_60s":        10,
}

## 获取建筑对应的科技点数
static func get_build_points(building_type: int) -> int:
	match building_type:
		0: return BASE_POINTS.get("building_wall", 100)       # WALL
		1: return BASE_POINTS.get("building_tower", 100)      # TOWER
		2: return BASE_POINTS.get("building_castle", 300)     # CASTLE
		3: return BASE_POINTS.get("building_barracks", 200)   # BARRACKS
		4: return BASE_POINTS.get("building_monastery", 200)  # MONASTERY
		5: return BASE_POINTS.get("building_archery", 200)    # ARCHERY
		_: return 0

## 获取建筑对应的来源分类
static func get_build_category(building_type: int) -> String:
	match building_type:
		2: return CATEGORY_BUILD_CONSTRUCTION  # CASTLE
		3, 4, 5: return CATEGORY_BUILD_CONSTRUCTION  # BARRACKS/MONASTERY/ARCHERY
		_: return CATEGORY_BUILD_CONSTRUCTION  # WALL/TOWER
