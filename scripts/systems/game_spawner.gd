extends Node
## 生成模块：单位/建筑生成、环境装饰、特效

const D := preload("res://scripts/systems/game_data.gd")
const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

var _main_node: Node2D
var _player_units_node: Node2D
var _enemy_units_node: Node2D
var _buildings_node: Node2D

# Callbacks for building placement (grid module functions)
var place_building_callback: Callable
var snap_to_grid_callback: Callable
var is_grid_free_callback: Callable

func initialize(main_node: Node2D, player_units: Node2D, enemy_units: Node2D, buildings: Node2D) -> void:
	_main_node = main_node
	_player_units_node = player_units
	_enemy_units_node = enemy_units
	_buildings_node = buildings

# --- 单位创建 ---

func create_unit(type: int, team: int, pos: Vector2) -> CharacterBody2D:
	var scene_path: String = D.UNIT_SCENES.get(type, "res://scenes/units/soldier.tscn")
	var unit_scene := load(scene_path)
	var unit: CharacterBody2D = unit_scene.instantiate()
	unit.set("team", team)
	unit.position = pos
	unit.connect("died", Callable(_main_node, "_on_unit_died"))
	return unit

# --- 从配置生成 ---

func spawn_from_config(map_config: Resource) -> void:
	if map_config == null:
		return

	# Spawn player units
	for spawn in map_config.player_units:
		var unit := create_unit(spawn.type, UnitScript.Team.PLAYER, spawn.pos)
		_player_units_node.add_child(unit)
		unit.add_to_group("player_units")

	# Spawn enemy units
	for spawn in map_config.enemy_units:
		var unit := create_unit(spawn.type, UnitScript.Team.ENEMY, spawn.pos)
		_enemy_units_node.add_child(unit)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(load("res://scripts/units/enemy_ai.gd"))
		unit.add_child(ai)

	# Spawn player buildings
	for spawn in map_config.player_buildings:
		place_building_callback.call(spawn.type, BuildingScript.Team.PLAYER, spawn.grid_pos)

	# Spawn enemy buildings
	for spawn in map_config.enemy_buildings:
		place_building_callback.call(spawn.type, BuildingScript.Team.ENEMY, spawn.grid_pos)

# --- 环境装饰 ---

func spawn_environment(map_config: Resource, map_bounds: Rect2) -> void:
	var env_node := Node2D.new()
	env_node.name = "Environment"
	env_node.z_index = 1
	_main_node.add_child(env_node)
	_main_node.move_child(env_node, 1)

	var spawn_min_x: float = map_bounds.position.x + 100
	var spawn_max_x: float = map_bounds.end.x - 100
	var spawn_min_y: float = map_bounds.position.y + 100
	var spawn_max_y: float = map_bounds.end.y - 100

	var tree_count := D.DEFAULT_TREES
	var rock_count := D.DEFAULT_ROCKS
	var bush_count := D.DEFAULT_BUSHES
	var sheep_count := D.DEFAULT_SHEEP

	if map_config != null:
		var env: Dictionary = map_config.environment
		tree_count = env.get("trees", D.DEFAULT_TREES)
		rock_count = env.get("rocks", D.DEFAULT_ROCKS)
		bush_count = env.get("bushes", D.DEFAULT_BUSHES)
		sheep_count = env.get("sheep", D.DEFAULT_SHEEP)

	var tree_scene := load("res://scenes/environment/tree.tscn")
	for i in range(tree_count):
		var tree: Node2D = tree_scene.instantiate()
		tree.position = Vector2(randf_range(spawn_min_x, spawn_max_x), randf_range(spawn_min_y, spawn_max_y))
		tree.get_node("Sprite").texture = load(D.TREE_TEXTURES[i % 4])
		tree.get_node("Sprite").frame = randi() % 8
		env_node.add_child(tree)

	var rock_scene := load("res://scenes/environment/rock.tscn")
	for i in range(rock_count):
		var rock: Node2D = rock_scene.instantiate()
		rock.position = Vector2(randf_range(spawn_min_x, spawn_max_x), randf_range(spawn_min_y, spawn_max_y))
		rock.get_node("Sprite").texture = load(D.ROCK_TEXTURES[i % 4])
		env_node.add_child(rock)

	var bush_scene := load("res://scenes/environment/bush.tscn")
	for i in range(bush_count):
		var bush: Node2D = bush_scene.instantiate()
		bush.position = Vector2(randf_range(spawn_min_x, spawn_max_x), randf_range(spawn_min_y, spawn_max_y))
		bush.get_node("Sprite").texture = load(D.BUSH_TEXTURES[i % 4])
		env_node.add_child(bush)

	var sheep_scene := load("res://scenes/environment/sheep.tscn")
	for i in range(sheep_count):
		var sheep: Node2D = sheep_scene.instantiate()
		sheep.position = Vector2(randf_range(spawn_min_x, spawn_max_x), randf_range(spawn_min_y, spawn_max_y))
		env_node.add_child(sheep)

# --- 放置时生成玩家单位 ---

func place_player_unit(unit_type: int, click_pos: Vector2) -> void:
	var unit := create_unit(unit_type, UnitScript.Team.PLAYER, click_pos)
	_player_units_node.add_child(unit)
	unit.add_to_group("player_units")
	spawn_dust_effect(click_pos)

# --- Public API (for WaveManager, CapturePoint) ---

func spawn_enemy_wave(units: Array, wave_attack: bool = false, wave_target: Vector2 = Vector2.ZERO) -> void:
	for unit_data in units:
		var type: int = unit_data.get("type", 0)
		var pos: Vector2 = unit_data.get("pos", Vector2.ZERO)
		spawn_enemy_unit(type, pos, wave_attack, wave_target)

func spawn_enemy_unit(type: int, pos: Vector2, wave_attack: bool = false, wave_target: Vector2 = Vector2.ZERO) -> void:
	var unit := create_unit(type, UnitScript.Team.ENEMY, pos)
	_enemy_units_node.add_child(unit)
	spawn_dust_effect(pos)
	unit.add_to_group("enemy_units")
	var ai := Node2D.new()
	ai.name = "EnemyAI"
	ai.set_script(load("res://scripts/units/enemy_ai.gd"))
	unit.add_child(ai)
	if wave_attack and wave_target != Vector2.ZERO:
		ai.call_deferred("start_wave_attack", wave_target)

func spawn_unit_near(type: int, pos: Vector2, team: int) -> void:
	var offset := Vector2(randf_range(-50, 50), randf_range(-50, 50))
	var unit := create_unit(type, team, pos + offset)
	if team == UnitScript.Team.PLAYER:
		_player_units_node.add_child(unit)
		unit.add_to_group("player_units")
		spawn_dust_effect(pos + offset)
	else:
		_enemy_units_node.add_child(unit)
		spawn_dust_effect(pos + offset)
		unit.add_to_group("enemy_units")
		var ai := Node2D.new()
		ai.name = "EnemyAI"
		ai.set_script(load("res://scripts/units/enemy_ai.gd"))
		unit.add_child(ai)

# --- 特效 ---

func spawn_click_effect(scene: PackedScene, pos: Vector2) -> void:
	var effect: Node2D = scene.instantiate()
	_main_node.get_tree().current_scene.add_child(effect)
	effect.global_position = pos

func spawn_dust_effect(pos: Vector2) -> void:
	var effect: Node2D = D.DustEffectScene.instantiate()
	_main_node.get_tree().current_scene.add_child(effect)
	effect.global_position = pos

func show_floating_text(text: String, color: Color, world_pos: Vector2) -> void:
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	_main_node.add_child(ft)
	ft.setup(text, color, world_pos)
