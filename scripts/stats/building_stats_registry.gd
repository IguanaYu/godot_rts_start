extends Node
## 建筑属性注册表：按 stats_id 查 BuildingStats 资源
## 启动时加载所有 resources/stats/buildings/*.tres，建立 id → stats 映射

const BuildingStatsClass := preload("res://scripts/stats/building_stats.gd")

var _registry: Dictionary = {}  # {StringName id: BuildingStats resource}

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir := DirAccess.open("res://resources/stats/buildings")
	if dir == null:
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".tres") and not fname.begins_with("."):
			var path := "res://resources/stats/buildings/" + fname
			var res := load(path)
			if res is BuildingStatsClass and res.id != &"":
				_registry[res.id] = res
		fname = dir.get_next()

func get_by_id(id: StringName) -> Resource:
	if _registry.has(id):
		return _registry[id]
	# 兜底：返回第一个 building_type 匹配的（用于未知 stats_id 时不崩溃）
	push_warning("[BuildingStatsRegistry] unknown id: " + String(id))
	return null

func has_id(id: StringName) -> bool:
	return _registry.has(id)

func get_all_ids() -> Array:
	return _registry.keys()


## 按 building_type 查询（T1: building_placer.get_current_cost 用）
func get_by_type(bt: int) -> Resource:
	for id in _registry:
		var stats = _registry[id]
		if stats.building_type == bt:
			return stats
	return null
