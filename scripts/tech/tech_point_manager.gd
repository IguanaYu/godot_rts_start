extends Node
## 科技点管理器：累积科技点 → 解锁科技等级
##
## 科技点为暗线资源，只增不消耗，达到阈值后解锁新的科技等级。
## 未来可通过 set_category_multiplier() 实现指挥官差异化。

signal points_changed(points: int)
signal level_unlocked(level: int)

const TPD := preload("res://scripts/tech/tech_point_data.gd")

## 当前科技点
var tech_points: int = 0

## 当前已解锁的最高科技等级（默认 1）
var tech_level: int = 1

## 来源倍率表：来源分类 → 倍率（默认 1.0）
var _category_multipliers: Dictionary = {}

## 已触发过等级解锁事件的等级，防止重复通知
var _notified_levels: Dictionary = {1: true}


func _ready() -> void:
	_notified_levels[1] = true


## 添加科技点
## category: 来源分类（用于倍率计算），参考 TPD.CATEGORY_*
func add_points(amount: int, category: String = "") -> void:
	if amount <= 0:
		return
	var mult: float = _category_multipliers.get(category, 1.0)
	var final_amount := maxi(1, int(amount * mult))
	tech_points += final_amount
	print("[Tech] +", final_amount, " (", category, ") total=", tech_points)
	points_changed.emit(tech_points)
	_check_level_unlock()


## 设置特定来源分类的倍率（用于指挥官差异化）
func set_category_multiplier(category: String, multiplier: float) -> void:
	_category_multipliers[category] = multiplier


## 清除特定来源分类的倍率（恢复默认 1.0）
func reset_category_multiplier(category: String) -> void:
	_category_multipliers.erase(category)


## 查询科技等级是否已解锁
func is_level_unlocked(level: int) -> bool:
	return tech_level >= level


## 获取下一个未解锁的科技等级（如果没有则返回 -1）
func get_next_unlocked_level() -> int:
	for lvl in [2, 3]:
		if not is_level_unlocked(lvl):
			return lvl
	return -1


## 获取当前科技等级到下一级还需的点数
func get_points_to_next_level() -> int:
	for lvl in [2, 3]:
		if not is_level_unlocked(lvl):
			var threshold: int = TPD.TECH_LEVEL_THRESHOLDS.get(lvl, 999999)
			return maxi(0, threshold - tech_points)
	return 0


## 检查是否达到新的等级阈值
func _check_level_unlock() -> void:
	for lvl in [2, 3]:
		if _notified_levels.has(lvl):
			continue
		var threshold: int = TPD.TECH_LEVEL_THRESHOLDS.get(lvl, 999999)
		if tech_points >= threshold:
			tech_level = lvl
			_notified_levels[lvl] = true
			level_unlocked.emit(lvl)
