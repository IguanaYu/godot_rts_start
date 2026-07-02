class_name SkillResource
extends Resource

## 技能交付方式
enum DeliveryType {
	PROJECTILE,      # 弹道投射
	INSTANT_SELF,    # 自身即时
	INSTANT_RANGE,   # 范围即时
}

## 目标选择类型
enum TargetType {
	ENEMY_NEAREST,
	ALLY_NEAREST_WOUNDED,
	SELF,
	CURRENT_ATTACK_TARGET,
	ENEMY_ATTACKING_ALLY,  # 正在攻击友军的敌人（嘲讽用）
	ALLY_LOWEST_HP,        # 血量百分比最低的友军（治疗/护盾用）
	ENEMY_HIGHEST_THREAT,  # 威胁值表最高（敌方施法者用，依赖 AggroComponent）
}

## 触发条件
enum TriggerCondition {
	ON_ATTACK,       # 攻击时触发
	PERIODIC_SCAN,   # 周期性扫描
	ON_CHASE,        # 追击时触发
	PASSIVE,         # 被动持续
}

## 技能类别
enum SkillCategory {
	ACTIVE,          # 主动技能（消耗蓝+冷却）
	ALTERNATIVE,     # 替代攻击（不消耗蓝）
	PASSIVE,         # 被动（不消耗蓝，持续生效）
}

@export var skill_name: String = ""
@export var skill_id: StringName = &""       # 唯一标识，如 &"taunt"
@export var category: SkillCategory = SkillCategory.ACTIVE
@export var delivery_type: DeliveryType = DeliveryType.INSTANT_SELF
@export var target_type: TargetType = TargetType.ENEMY_NEAREST
@export var trigger_condition: TriggerCondition = TriggerCondition.ON_ATTACK
@export var cooldown: float = 0.0
@export var mana_cost: float = 0.0
@export var cast_range: float = 0.0
@export var trigger_interval: float = 1.0   # PERIODIC_SCAN 的扫描间隔
@export var priority: int = 0
@export var effect_scene: PackedScene = null # 弹道场景（PROJECTILE 时用）
@export var projectile_data: Resource = null # 弹道数据
