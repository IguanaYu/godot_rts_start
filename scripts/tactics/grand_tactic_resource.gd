class_name GrandTacticResource
extends Resource

## 战术类型
enum TacticId {
	SUMMON_WAVE,       # 持续召唤小怪（每 effect_interval 一波）
	SUMMON_ELITE,      # 召唤精英 + 联动死亡
	MORALE_BOOST,      # aura 鼓舞士气（移速/攻击/防御）
	FINAL_SUMMON,      # 结束时召唤大量友军
}

## 战术名称（显示用）
@export var tactic_name: String = ""
## 战术类型
@export var tactic_id: TacticId = TacticId.SUMMON_WAVE
## 引导总时长（秒）
@export var channel_time: float = 30.0

# --- 周期性效果参数 ---
## 引导中每次触发的间隔（SUMMON_WAVE 用，0=不触发）
@export var effect_interval: float = 5.0
## 每次触发数量
@export var effect_count: int = 1
## 召唤的单位类型（UnitType 枚举）
@export var effect_unit_type: int = 0
## 召唤的 stats_id
@export var effect_stats_id: StringName = &""

# --- Aura 参数（MORALE_BOOST 用） ---
@export var aura_type: String = ""
@export var aura_value: float = 0.0
@export var aura_range: float = 0.0

# --- 精英参数（SUMMON_ELITE 用） ---
## 召唤精英数
@export var elite_count: int = 0
## 精英 stats_id 列表
@export var elite_stats_ids: Array[StringName] = []
## 是否联动死亡（杀释放者则精英也死）
@export var linked_death: bool = false

# --- 结束时召唤参数（FINAL_SUMMON 用） ---
## 结束时召唤的编组（格式同 wave_manager groups）
@export var final_summon_groups: Array[Dictionary] = []
