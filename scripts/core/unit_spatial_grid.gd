extends Node
## 单位空间分区 autoload。
## 每物理帧开始时自动 clear + 注册全图所有 alive 单位，
## 单位逻辑用 UnitGrid.query_neighbors(pos, radius) 替代 get_nodes_in_group(...)。
##
## 注册顺序保证：autoload 节点的 _physics_process 用 priority=-100 先跑，
## 确保单位 _physics_process 查询时拿到当前帧快照。

const CELL_SIZE: float = 64.0

## key: Vector2i (cell 坐标), value: Array[Unit]
var _cells: Dictionary = {}


func _ready() -> void:
	set_physics_process_priority(-100)


func _physics_process(_delta: float) -> void:
	clear()
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			register(u)
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			register(u)


func clear() -> void:
	_cells.clear()


## 注册一个单位到当前帧的 grid。
func register(unit) -> void:
	var cell := _world_to_cell(unit.global_position)
	if not _cells.has(cell):
		_cells[cell] = []
	var bucket: Array = _cells[cell]
	bucket.append(unit)


## 查询覆盖 pos、半径 radius 范围内的所有单位（未做精确距离过滤）。
## 调用方需再做 distance_to 判断。
func query_neighbors(pos: Vector2, radius: float) -> Array:
	var result: Array = []
	var min_cell := _world_to_cell(pos - Vector2(radius, radius))
	var max_cell := _world_to_cell(pos + Vector2(radius, radius))
	var x := min_cell.x
	while x <= max_cell.x:
		var y := min_cell.y
		while y <= max_cell.y:
			if _cells.has(Vector2i(x, y)):
				var bucket: Array = _cells[Vector2i(x, y)]
				for u in bucket:
					result.append(u)
			y += 1
		x += 1
	return result


func _world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / CELL_SIZE)), int(floor(pos.y / CELL_SIZE)))
