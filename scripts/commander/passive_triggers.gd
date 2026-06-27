class_name PassiveTriggers
extends RefCounted
## 被动技能触发点 id 常量（StringName）
## PassiveSkillManager.emit_trigger(id, ctx) 时使用

# 单位死亡：ctx = {unit, killer, alliance_id}
const UNIT_DIED: StringName = &"unit_died"
# 单位生产完成：ctx = {unit, building, alliance_id}
const UNIT_PRODUCED: StringName = &"unit_produced"
# 单位受击：ctx = {unit, attacker, damage, alliance_id}
const UNIT_DAMAGED: StringName = &"unit_damaged"
# 建筑放置完成：ctx = {building, alliance_id}
const BUILDING_PLACED: StringName = &"building_placed"
# 每秒触发：ctx = {}
const TICK_1S: StringName = &"tick_1s"
