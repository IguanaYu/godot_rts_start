class_name VictoryExpandDefense
extends VictoryCondition

const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

@export var wave_manager_path: NodePath = ^"WaveManager"
@export var capture_points: Array[NodePath] = []

var wave_manager: Node = null
var all_waves_done: bool = false
var game_result: int = 0
var _captured_count: int = 0

func _ready() -> void:
	# 连接 WaveManager
	wave_manager = get_node_or_null(wave_manager_path)
	if wave_manager:
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	# 连接 CapturePoint 信号（CapturePoint 自行管理触发）
	for i in range(capture_points.size()):
		var cp = get_node_or_null(capture_points[i])
		if cp == null:
			continue
		cp.captured.connect(_on_point_captured)

func _on_all_waves_completed() -> void:
	all_waves_done = true

func _on_point_captured(team: int) -> void:
	if team != UnitScript.Team.PLAYER:
		return
	_captured_count += 1

func check() -> int:
	if game_result != 0:
		return game_result

	# 失败：玩家城堡被毁
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				player_castle_alive = true
				break
	if not player_castle_alive:
		game_result = 2
		return 2

	# 胜利：所有点占领 + 波次完成 + 无剩余敌人
	if _captured_count < capture_points.size():
		return 0
	if not all_waves_done:
		return 0

	var enemy_count := 0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			enemy_count += 1
	if enemy_count > 0:
		return 0

	game_result = 1
	return 1
