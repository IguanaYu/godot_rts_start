class_name DifficultyPreset
extends Resource

## 难度预设资源：在 Godot 编辑器 Inspector 中配置每张地图的难度乘数

@export var hp_mult: float = 1.0          ## 敌人HP乘数
@export var atk_mult: float = 1.0         ## 敌人攻击乘数
@export var speed_mult: float = 1.0       ## 敌人速度乘数
@export var count_mult: float = 1.0       ## 敌人数量乘数
@export var gold_mult: float = 1.0        ## 玩家金币乘数
@export var wave_delay_mult: float = 1.0  ## 波次间隔乘数
