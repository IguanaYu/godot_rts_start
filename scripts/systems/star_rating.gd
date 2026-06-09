class_name StarRating
extends RefCounted

## 星级评价系统
## 根据时间、死亡数、副目标完成情况计算1-3星

## 计算1-3星评价
## 参数:
## - time: 完成用时（秒）
## - units_lost: 玩家损失单位数
## - bonus_done: 完成的副目标数量
## - bonus_total: 副目标总数
## - thresholds: {time_3: 3星时限, time_2: 2星时限, deaths_3: 3星死亡上限, deaths_2: 2星死亡上限}
static func calculate(time: float, units_lost: int, bonus_done: int, bonus_total: int, thresholds: Dictionary) -> int:
	var stars := 1  # 至少1星

	# 时间评价
	if time <= thresholds.get("time_3", 999999.0):
		stars += 1  # 达到3星时间要求
	elif time <= thresholds.get("time_2", 999999.0):
		pass  # 符合2星要求
	else:
		stars = max(1, stars)  # 时间超标，至少1星

	# 死亡评价
	if units_lost <= thresholds.get("deaths_3", 0):
		pass  # 已在上面加分
	elif units_lost <= thresholds.get("deaths_2", 5):
		pass  # 符合2星要求
	else:
		stars = max(1, stars)

	# 副目标评价
	if bonus_total > 0 and bonus_done == bonus_total:
		stars += 1

	return clampi(stars, 1, 3)

## 从MapConfig获取星级阈值
static func get_thresholds(map_config: Resource) -> Dictionary:
	if map_config == null:
		return {}

	var thresholds := {}
	if map_config.has_method("get"):
		thresholds = {
			"time_3": map_config.get("star_time_3"),
			"time_2": map_config.get("star_time_2"),
			"deaths_3": map_config.get("star_deaths_3"),
			"deaths_2": map_config.get("star_deaths_2")
		}

	# 默认值
	if thresholds.get("time_3") == null:
		thresholds["time_3"] = 180.0
	if thresholds.get("time_2") == null:
		thresholds["time_2"] = 300.0
	if thresholds.get("deaths_3") == null:
		thresholds["deaths_3"] = 0
	if thresholds.get("deaths_2") == null:
		thresholds["deaths_2"] = 3

	return thresholds
