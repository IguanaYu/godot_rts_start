extends Resource
class_name T3UpgradeData

## T3 升级数据：一个兵种一组升级（N 选 1）
@export var unit_type: int                          # 目标兵种 Unit.UnitType
@export var unit_class_label: String                # "步兵" / "弓兵" / "僧侣" / "长矛兵"
@export var cost: int = 1000                        # 研究费
@export var choices: Array[Resource] = []           # T3UpgradeChoice 资源数组