extends Node
class_name AggroComponent

## 仇恨/威胁值表组件
## 挂在敌方 AI（EnemyAI 节点）下，节点名固定为 "AggroComponent"。
## 维护一张威胁值表 {Unit: {"value": float, "last_seen": float}}，
## 让 AI 按综合威胁值（伤害 + 位置 + 嘲讽）选目标，而非"最近距离 / 受击立即反击"。
##
## 三种威胁来源：
##   DAMAGE     - 单位造成伤害时累积，take_damage 注入
##   PROXIMITY  - 玩家单位进入警戒圈被动累积，tick_proximity 每帧调用
##   TAUNT      - 嘲讽技能直接设为 TAUNT_THREAT（最高优先级）

enum ThreatSource { DAMAGE, PROXIMITY, TAUNT }

# ===== 可调参数（全部集中在这里便于平衡）=====
const DECAY_RATE: float = 2.0           # 表内威胁值每秒衰减
const HOLD_TIME: float = 1.5            # 目标锁定时长（防 DPS 抖动切目标）
const PROXIMITY_RANGE: float = 220.0    # 位置威胁警戒圈，< enemy_ai.vision_range(250)
const PROXIMITY_RATE: float = 8.0       # 每秒位置威胁累积基础值
const DAMAGE_FACTOR: float = 1.0        # damage → threat 倍率
const DAMAGE_FIRST_BLOOD: float = 30.0  # 首次受伤额外加成（防止开局来回切）
const TAUNT_THREAT: float = 10000.0     # 嘲讽强制最高
const ABSENT_TIMEOUT: float = 5.0       # 目标离开视线多久清除表条目

# 表结构：{ Unit: {"value": float, "last_seen": float (ticks_msec) } }
var _table: Dictionary = {}
var _locked_target = null
var _lock_expire_msec: float = 0.0
var _unit = null  # 父 Unit 引用（缓存）


func _ready() -> void:
	# EnemyAI 挂在 Unit 下，AggroComponent 挂在 EnemyAI 下
	var ai = get_parent()
	if ai:
		_unit = ai.get_parent()


func add_threat(target, amount: float, source: int) -> void:
	if target == null or not is_instance_valid(target):
		return
	if "is_dead" in target and target.is_dead():
		return
	var now := float(Time.get_ticks_msec())
	if not _table.has(target):
		var init_val := 0.0
		if source == ThreatSource.TAUNT:
			init_val = TAUNT_THREAT
		elif source == ThreatSource.DAMAGE:
			init_val = amount + DAMAGE_FIRST_BLOOD
		else:
			init_val = amount
		_table[target] = {"value": init_val, "last_seen": now}
		# 新目标入表，强制刷新锁定（让新威胁者能被立刻注意到）
		_locked_target = null
		_lock_expire_msec = 0.0
		return
	var entry: Dictionary = _table[target]
	if source == ThreatSource.TAUNT:
		entry["value"] = TAUNT_THREAT
	else:
		entry["value"] = float(entry["value"]) + amount
	entry["last_seen"] = now


func has(target) -> bool:
	return _table.has(target)


## 返回当前应攻击的目标。优先级：嘲讽目标 > 锁定目标 > 表中最高威胁 > null
func get_target():
	# 1. 嘲讽（unit.gd::is_taunted 已维护 _taunt_expire_timer）
	if _unit and _unit.has_method("is_taunted") and _unit.is_taunted():
		# 被嘲讽时直接返回 attack_target（嘲讽者由 force_attack_target 设置）
		var at = _unit.get("attack_target")
		if at != null and is_instance_valid(at) and not (at.has_method("is_dead") and at.is_dead()):
			return at
	# 2. 清理无效条目
	_purge_invalid()
	if _table.is_empty():
		_locked_target = null
		return null
	# 3. 锁定目标未过期 → 仍返回锁定
	var now := float(Time.get_ticks_msec())
	if _locked_target != null and is_instance_valid(_locked_target) \
			and not (_locked_target.has_method("is_dead") and _locked_target.is_dead()) \
			and now < _lock_expire_msec:
		return _locked_target
	# 4. 选表中威胁值最高
	var best = null
	var best_val: float = -1.0
	for target in _table.keys():
		var entry: Dictionary = _table[target]
		var v: float = float(entry["value"])
		if v > best_val:
			best_val = v
			best = target
	if best != null:
		_locked_target = best
		_lock_expire_msec = now + HOLD_TIME * 1000.0
	return best


## 时间衰减（每帧调用）
func decay(delta: float) -> void:
	if _table.is_empty():
		return
	var now := float(Time.get_ticks_msec())
	var to_remove: Array = []
	for target in _table.keys():
		var entry: Dictionary = _table[target]
		var v: float = float(entry["value"])
		# TAUNT 来源（值=TAUNT_THREAT）不衰减，由嘲讽到期自动失效
		if v < TAUNT_THREAT:
			v = max(0.0, v - DECAY_RATE * delta)
			entry["value"] = v
		# 离开视线太久 → 移除
		if now - float(entry["last_seen"]) > ABSENT_TIMEOUT * 1000.0:
			to_remove.append(target)
	for t in to_remove:
		_table.erase(t)
		if _locked_target == t:
			_locked_target = null


## 位置威胁累积：扫描 PROXIMITY_RANGE 内的敌方单位，越近累积越快
func tick_proximity(delta: float, my_pos: Vector2) -> void:
	if _unit == null:
		return
	# 复用全局空间分区
	for u in UnitGrid.query_neighbors(my_pos, PROXIMITY_RANGE):
		if not (u is CharacterBody2D):
			continue
		if u == _unit:
			continue
		if "is_dead" in u and u.is_dead():
			continue
		if "team" in u and u.team == _unit.team:
			continue
		if "is_stealthed" in u and u.has_method("is_stealthed") and u.is_stealthed():
			continue
		var d: float = my_pos.distance_to(u.global_position)
		if d > PROXIMITY_RANGE:
			continue
		var weight: float = 1.0 - d / PROXIMITY_RANGE  # 0~1
		# 距离=0时每秒 PROXIMITY_RATE，距离=PROXIMITY_RANGE 时为 0
		add_threat(u, PROXIMITY_RATE * weight * delta, ThreatSource.PROXIMITY)


func clear() -> void:
	_table.clear()
	_locked_target = null
	_lock_expire_msec = 0.0


func remove(target) -> void:
	_table.erase(target)
	if _locked_target == target:
		_locked_target = null


# ============== 内部工具 ==============

func _purge_invalid() -> void:
	var to_remove: Array = []
	for target in _table.keys():
		if target == null or not is_instance_valid(target) \
				or (target.has_method("is_dead") and target.is_dead()):
			to_remove.append(target)
	for t in to_remove:
		_table.erase(t)
		if _locked_target == t:
			_locked_target = null
