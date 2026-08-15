extends Node
## 特效测试沙盒（PR-0）：可放置单位清单。加一行 = 左面板多一个按钮。

const SPAWNABLE_UNITS := [
	{ "scene": preload("res://scenes/units/soldier.tscn"), "name": "剑士", "team": 0 },
	{ "scene": preload("res://scenes/units/archer.tscn"), "name": "弓兵", "team": 0 },
	{ "scene": preload("res://scenes/units/lancer.tscn"), "name": "枪兵", "team": 0 },
	{ "scene": preload("res://scenes/units/monk.tscn"), "name": "僧侣", "team": 0 },
	{ "scene": preload("res://scenes/units/pyromancer.tscn"), "name": "火焰法师", "team": 1 },
	{ "scene": preload("res://scenes/units/troll.tscn"), "name": "巨魔", "team": 1 },
	{ "scene": preload("res://scenes/units/skeleton.tscn"), "name": "骷髅", "team": 1 },
	{ "scene": preload("res://scenes/units/soldier.tscn"), "stats": preload("res://resources/stats/boss_soldier_stats.tres"), "name": "Boss剑士", "team": 1 },
]

const SPAWNABLE_DUMMIES := [
	{ "hp": 500 },
	{ "hp": 2000 },
	{ "hp": 5000 },
]

const DUMMY_SCENE := preload("res://scenes/sandbox/dummy.tscn")
