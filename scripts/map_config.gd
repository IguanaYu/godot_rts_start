class_name MapConfig
extends Resource

@export var map_name: String = ""
@export var map_bounds: Rect2 = Rect2(-500, -500, 2000, 1700)
@export var nav_bounds: Array[Vector2] = [Vector2(-500, -500), Vector2(1500, -500), Vector2(1500, 1200), Vector2(-500, 1200)]
@export var initial_gold: int = 10000
@export var camera_start: Vector2 = Vector2(500, 350)

# Player initial data
@export var player_units: Array[Dictionary] = []
@export var player_buildings: Array[Dictionary] = []

# Enemy initial data
@export var enemy_units: Array[Dictionary] = []
@export var enemy_buildings: Array[Dictionary] = []

# Environment counts
@export var environment: Dictionary = {"trees": 15, "rocks": 10, "bushes": 12, "sheep": 5}

# Available PlaceMode items for this map
@export var available_items: Array[int] = []

@export var map_description: String = ""

# Difficulty presets (editable in Inspector, null = use defaults)
@export var easy_preset: Resource = null
@export var normal_preset: Resource = null
@export var hard_preset: Resource = null

# Terrain settings
@export var terrain_theme: int = 0
@export var water_areas: Array[Rect2] = []
@export var border_width: int = 1

# Commander skills available for this map
@export var commander_skills: Array[int] = []
## Star rating thresholds
@export var star_time_3: float = 180.0  # 3星时限
@export var star_time_2: float = 300.0  # 2星时限
@export var star_deaths_3: int = 0  # 3星死亡上限
@export var star_deaths_2: int = 3  # 2星死亡上限
