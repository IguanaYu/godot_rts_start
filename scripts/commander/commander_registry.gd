extends Node
## 指挥官注册表：加载所有 resources/commanders/*.tres，按 id 查 CommanderProfile

const CommanderProfileClass := preload("res://scripts/commander/commander_profile.gd")

var _registry: Dictionary = {}  # {StringName id: CommanderProfile}
var _ordered_ids: Array[StringName] = []  # 保持加载顺序，供 UI 列表用

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir := DirAccess.open("res://resources/commanders")
	if dir == null:
		push_warning("[CommanderRegistry] resources/commanders/ not found")
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".tres") and not fname.begins_with("."):
			var path := "res://resources/commanders/" + fname
			var res := load(path)
			if res is CommanderProfileClass and res.id != &"":
				_registry[res.id] = res
				_ordered_ids.append(res.id)
		fname = dir.get_next()

func get_profile(id: StringName) -> Resource:
	if _registry.has(id):
		return _registry[id]
	push_warning("[CommanderRegistry] unknown commander id: " + String(id))
	# 兜底：返回第一个 profile
	if _ordered_ids.size() > 0:
		return _registry[_ordered_ids[0]]
	return null

func has_profile(id: StringName) -> bool:
	return _registry.has(id)

func get_all_ids() -> Array[StringName]:
	return _ordered_ids.duplicate()
