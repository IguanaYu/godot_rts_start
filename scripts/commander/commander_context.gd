extends Node
## 指挥官运行时上下文：维护每个 alliance_id 对应的 CommanderProfile
## alliance_id = 0：玩家方（玩家和 AI 队友共用一个 profile）
## alliance_id >= 1：每个敌方联盟独立 profile（由 map_config.alliances[i].commander_id 指定）
## 建筑初始化/单位生产时通过本节点查"当前 alliance 用哪个指挥官"

const CommanderProfileClass := preload("res://scripts/commander/commander_profile.gd")

# 默认 profile id（兜底）
const DEFAULT_PLAYER_COMMANDER := &"balanced"
const DEFAULT_AI_COMMANDER := &"balanced"

# alliance_id → CommanderProfile
var _profiles: Dictionary = {}


func set_profile_for_alliance(alliance_id: int, profile) -> void:
	if profile == null:
		_profiles.erase(alliance_id)
		return
	_profiles[alliance_id] = profile


func get_profile_for_alliance(alliance_id: int):
	if _profiles.has(alliance_id):
		return _profiles[alliance_id]
	# 兜底：玩家方默认 balanced，敌方也默认 balanced
	var fallback_id := DEFAULT_PLAYER_COMMANDER if alliance_id == 0 else DEFAULT_AI_COMMANDER
	return CommanderRegistry.get_profile(fallback_id)


func set_player_profile(profile) -> void:
	set_profile_for_alliance(0, profile)


func get_player_profile():
	return get_profile_for_alliance(0)


## 由 building_type + alliance_id 查可用建筑变体 stats_id 列表
func get_building_variant_ids(building_type: int, alliance_id: int) -> Array:
	var profile = get_profile_for_alliance(alliance_id)
	if profile == null:
		return []
	return profile.get_building_variants_for_type(building_type)


## 由 building_type + alliance_id 查默认（第一个）建筑变体 stats_id
func get_default_building_stats_id(building_type: int, alliance_id: int) -> StringName:
	var ids := get_building_variant_ids(building_type, alliance_id)
	if ids.size() > 0:
		return ids[0]
	# 兜底：用基础建筑 id（barracks/archery/monastery/tower/castle/wall）
	return _fallback_basic_building_id(building_type)


## 由 building_type + alliance_id 查该建筑可生产的单位变体 stats_id 列表
func get_unit_variant_ids_for_building(building_type: int, alliance_id: int) -> Array:
	var profile = get_profile_for_alliance(alliance_id)
	if profile == null:
		return []
	# 建筑类型 → UnitType 映射（BARRACKS→SOLDIER, ARCHERY→ARCHER, MONASTERY→MONK）
	var unit_type := _building_type_to_unit_type(building_type)
	if unit_type < 0:
		return []
	return profile.get_unit_variants_for_type(unit_type)


# BuildingType 枚举：WALL=0, TOWER=1, CASTLE=2, BARRACKS=3, MONASTERY=4, ARCHERY=5
# UnitType 枚举：SOLDIER=0, ARCHER=1, LANCER=2, MONK=3
func _building_type_to_unit_type(building_type: int) -> int:
	match building_type:
		3: return 0  # BARRACKS → SOLDIER
		5: return 1  # ARCHERY → ARCHER
		4: return 3  # MONASTERY → MONK
		# LANCER 暂无专属建筑，通过城堡产（沿用现有逻辑）
	return -1


func _fallback_basic_building_id(building_type: int) -> StringName:
	match building_type:
		0: return &"wall"
		1: return &"tower"
		2: return &"castle"
		3: return &"barracks"
		4: return &"monastery"
		5: return &"archery"
	return &""
