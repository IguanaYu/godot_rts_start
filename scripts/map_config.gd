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

# Player 2 initial data (multiplayer co-op)
@export var player2_units: Array[Dictionary] = []
@export var player2_buildings: Array[Dictionary] = []

# Enemy initial data
@export var enemy_units: Array[Dictionary] = []
@export var enemy_buildings: Array[Dictionary] = []

# AI 队友（单机模式电脑控制的盟军，owner_id=-2, alliance_id=0, color=YELLOW）
# 扁平格式，与 player_units 一致：Array[{"type": int, "pos": Vector2}]
@export var ai_allies: Array[Dictionary] = []

# === 多势力 / 多联盟结构（新格式；为空时由 game_spawner 用旧字段自动构造 fallback）===
# alliance 结构：{ "id": int, "is_ai": bool, "slots": Array[Dictionary] }
# slot 结构：{ "color": int (Faction.Color), "start_pos": Vector2,
#             "initial_gold": int, "units": Array[{type,pos}],
#             "buildings": Array[{type,grid_pos}] }
@export var alliances: Array[Dictionary] = []

# === 据点指挥官（新格式；运行时由场景中的 OutpostCommander 节点自注册）===
# 此字段仅作为可选覆盖，按 commander_uid 覆盖节点上的 OutpostCommanderConfig 默认值
# 结构：{ "uid_a": OutpostCommanderConfig, "uid_b": ... }
@export var outpost_commander_overrides: Dictionary = {}

# 敌方随玩家数动态增强：每多 1 个玩家，敌方单位数 ×mult，并可选追加 extra_groups 波次
@export var enemy_scaling: Dictionary = {"per_player_unit_mult": 1.0, "per_player_extra_groups": []}

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

## 战斗节奏方案：0=DEFAULT / 1=FAST (TTK~4s) / 2=SLOW (TTK~15s)
## 对应 BalanceScheme.Scheme 枚举。由 main.gd 在 _enter_tree 读取并写入 BalanceScheme.current，
## unit.gd 的 _setup_stats 末尾通过 stat_set.add_modifier 应用乘性修饰器。
@export var balance_scheme: int = 0
