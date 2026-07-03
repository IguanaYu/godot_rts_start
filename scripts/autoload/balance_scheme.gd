class_name BalanceScheme
extends RefCounted

## 全局战斗节奏调度器。
## 通过 map_config.balance_scheme 字段在场景加载时设置，
## 由 unit.gd 的 _setup_stats() 末尾读取，对 MAX_HP / ATTACK_DAMAGE / ATTACK_COOLDOWN
## 应用乘性修饰器（复用 stat_set.add_modifier 机制）。
## 由 building.gd 的 _apply_commander_building_stats() 末尾读取，对建筑 max_hp 也应用倍率。

enum Scheme { DEFAULT = 0, FAST = 1, SLOW = 2 }

static var current: Scheme = Scheme.DEFAULT

static func get_modifiers(s: Scheme = -1) -> Dictionary:
	if s == -1:
		s = current
	match s:
		Scheme.FAST:
			# TTK ~3-4s：HP ↓ / DMG ↑ / CD ↓ → DPS 大涨、血量大跌
			return {"hp": 0.7, "dmg": 1.3, "cd": 0.85}
		Scheme.SLOW:
			# TTK ~12s：HP 中度上调、DMG/CD 轻微下调
			return {"hp": 1.3, "dmg": 0.9, "cd": 1.05}
		_:
			return {"hp": 1.0, "dmg": 1.0, "cd": 1.0}

## 建筑 HP 倍率。建筑基础 HP 写死在 building.gd _setup_stats()（castle=500/barracks=250 等），
## 在 health.setup() 之前乘以这个倍率。
## SLOW=3.0：castle 1500 HP，5 个 SLOW soldier 集火 ≈ 28s，给防守方充分反应时间形成拉锯。
static func get_building_hp_mult(s: Scheme = -1) -> float:
	if s == -1:
		s = current
	match s:
		Scheme.FAST:
			return 1.0
		Scheme.SLOW:
			return 2.0
		_:
			return 1.0
