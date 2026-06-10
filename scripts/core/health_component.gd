extends Node2D
class_name HealthComponent
## 血量组件：管理 HP / 受伤 / 死亡 / 血条更新。
## 挂载为需要血量的实体的子节点。

signal died(entity)

var hp: int
var max_hp: int
var _is_dead: bool = false
var hp_bar: ProgressBar = null
var _team: int = 0
var _bg_style: StyleBoxFlat = null
var _fill_style: StyleBoxFlat = null


func setup(p_max_hp: int, p_hp_bar: ProgressBar = null, p_team: int = 0) -> void:
	max_hp = p_max_hp
	hp = max_hp
	hp_bar = p_hp_bar
	_team = p_team
	_init_hp_bar_style()
	_update_hp_bar()


func _init_hp_bar_style() -> void:
	if not hp_bar:
		return

	_bg_style = StyleBoxFlat.new()
	_bg_style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
	_bg_style.set_border_width_all(1)
	_bg_style.border_color = Color(0.3, 0.6, 1.0) if _team == 0 else Color(1.0, 0.3, 0.3)
	_bg_style.set_corner_radius_all(1)
	hp_bar.add_theme_stylebox_override("background", _bg_style)

	_fill_style = StyleBoxFlat.new()
	_fill_style.bg_color = Color(0.2, 0.8, 0.2)
	_fill_style.set_corner_radius_all(1)
	hp_bar.add_theme_stylebox_override("fill", _fill_style)


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
	if not hp_bar:
		return
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	if _fill_style:
		var ratio := float(hp) / float(max_hp) if max_hp > 0 else 1.0
		if ratio > 0.5:
			_fill_style.bg_color = Color(0.2, 0.8, 0.2)
		elif ratio > 0.25:
			_fill_style.bg_color = Color(1.0, 0.85, 0.0)
		else:
			_fill_style.bg_color = Color(0.9, 0.2, 0.15)
