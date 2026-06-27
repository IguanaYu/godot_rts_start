extends Node
## 单位属性注册表：按 stats_id 查 UnitStats 资源
## 启动时加载所有 resources/stats/*.tres（含变体），建立 id → stats 映射

const UnitStatsClass := preload("res://scripts/stats/unit_stats.gd")

var _registry: Dictionary = {}  # {StringName id: UnitStats resource}

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir := DirAccess.open("res://resources/stats")
	if dir == null:
		push_warning("[UnitStatsRegistry] resources/stats/ not found")
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".tres") and not fname.begins_with("."):
			var path := "res://resources/stats/" + fname
			var res := load(path)
			if res is UnitStatsClass and res.id != &"":
				_registry[res.id] = res
		fname = dir.get_next()

func get_by_id(id: StringName) -> Resource:
	if _registry.has(id):
		return _registry[id]
	push_warning("[UnitStatsRegistry] unknown id: " + String(id))
	return null

func has_id(id: StringName) -> bool:
	return _registry.has(id)
