extends Node

## 单英雄控制层。替代 RTS 框选,把鼠标点击翻译成 hero.move_to()。
## 英雄默认 GUARD 状态,自动索敌攻击(unit.gd _guard_process)。

var hero  # Unit, duck typing

func initialize(hero_unit) -> void:
	hero = hero_unit
	# 英雄默认 GUARD 状态,自动索敌攻击,不需要额外 AI 脚本

func move_to(pos: Vector2) -> void:
	if hero and is_instance_valid(hero):
		hero.move_to(pos)  # 复用 unit.gd:1288

func get_hero():
	return hero
