extends Node2D
class_name HealthComponent
## 血量组件：管理 HP / 受伤 / 死亡 / 血条更新。
## 挂载为需要血量的实体的子节点。

signal died(entity)

var hp: int
var max_hp: int
var _is_dead: bool = false
var hp_bar: ProgressBar = null


func setup(p_max_hp: int, p_hp_bar: ProgressBar = null) -> void:
	max_hp = p_max_hp
	hp = max_hp
	hp_bar = p_hp_bar
	_update_hp_bar()


func take_damage(amount: int) -> void:
	if _is_dead:
		return
	hp = max(0, hp - amount)
	_update_hp_bar()
	if hp <= 0:
		_is_dead = true
		died.emit(get_parent())


func is_dead() -> bool:
	return _is_dead


func heal(amount: int) -> void:
	if _is_dead:
		return
	hp = mini(hp + amount, max_hp)
	_update_hp_bar()


func _update_hp_bar() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
