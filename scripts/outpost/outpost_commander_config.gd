class_name OutpostCommanderConfig
extends Resource
## 据点敌人指挥官配置（由 OutpostCommander 节点持有，设计师在 Inspector 调参）
## 实例文件可放 resources/outpost_commanders/*.tres 也可内嵌在节点上

@export var commander_uid: StringName = &""            # 设计师给的唯一 id，供 map_config.overrides 引用
@export var alliance_id: int = 1                       # 敌方联盟 id（玩家=0）
@export var territory_radius: float = 350.0            # 领地半径（像素）

# === 资源池上限 + 恢复曲线 ===
@export var mana_max: float = 100.0                    # 法力上限；regen = mana_max/60 ≈ 1 分钟回满
@export var gold_max: int = 500                        # 资源（钱）上限
@export var gold_regen: float = 5.0                    # 每秒回钱
@export var strategy_max: int = 4                      # 策略点上限
@export var strategy_regen: float = 0.05               # 每秒回策略点（~20s 1 点）

# === 启用法术/策略（设计师裁剪，做"辅助据点"等差异化）===
@export var enabled_spells: Array[StringName] = [
	&"inspire", &"call_to_arms", &"release_garrison", &"heal", &"shield",
]
@export var enabled_strategies: Array[StringName] = [
	&"attack", &"coordinate", &"defend", &"expand",
]

# === 性格倾向 (0-1, 影响决策权重) ===
@export_range(0.0, 1.0) var aggression: float = 0.5      # 高 → 偏好 attack / coordinate
@export_range(0.0, 1.0) var defensiveness: float = 0.5   # 高 → 偏好 defend
@export_range(0.0, 1.0) var expansionist: float = 0.5    # 高 → 偏好 expand

# === 强制策略（非空则跳过决策树，用于"只会防守"等强约束据点）===
@export var forced_strategy: StringName = &""

# === 成本/冷却覆盖（按 uid 调整单关难度）===
@export var spell_overrides: Dictionary = {}            # {inspire: {cost: 30, cooldown: 25}}
@export var strategy_overrides: Dictionary = {}
