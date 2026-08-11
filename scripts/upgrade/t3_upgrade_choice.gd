extends Resource
class_name T3UpgradeChoice

## N 选 1 中的单个候选项
@export var choice_id: StringName                   # 如 &"t3_champion_offense"
@export var display_name: String                    # "狂战士"
@export var description: String                     # "HP -20% / DMG +50% / 血怒..."
@export var variant_stats_id: StringName            # 对应的 UnitStats id
@export var variant_scene: PackedScene              # 变体单位的 .tscn
@export var tint: Color = Color.WHITE               # UI 卡片染色
@export var positioning: String = ""                # "高风险高输出" / "极致生存" 等