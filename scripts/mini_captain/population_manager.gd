extends Node

## 召唤兵人口系统。初始 8,满人口禁召,可通过 upgrade_cap 提升。

const INITIAL_POP: int = 8

var current: int = 0   # 已占人口
var cap: int = INITIAL_POP  # 上限

signal population_changed(current: int, cap: int)

func can_summon(count: int = 1) -> bool:
	return current + count <= cap

func add(count: int = 1) -> void:
	current += count
	population_changed.emit(current, cap)

func remove(count: int = 1) -> void:
	current = max(0, current - count)
	population_changed.emit(current, cap)

func upgrade_cap(amount: int) -> void:
	cap += amount
	population_changed.emit(current, cap)
