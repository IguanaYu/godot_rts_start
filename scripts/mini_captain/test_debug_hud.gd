extends CanvasLayer

## Mini Captain 调试信息叠加层。
## 自动发现场景中的 mini 组件并显示实时数据（英雄属性、人口、召唤CD、战斗信息、波次）。

const FONT_SIZE := 14
const COLOR_LABEL := Color(0.9, 0.9, 0.9)
const COLOR_VALUE := Color(0.3, 1.0, 0.3)
const COLOR_WARN := Color(1.0, 0.8, 0.2)
const COLOR_DANGER := Color(1.0, 0.3, 0.3)
const UPDATE_INTERVAL := 0.1

var _main: Node = null
var _hero: Node = null
var _pop_mgr: Node = null
var _test_skill: Node = null
var _wave_mgr: Node = null

var _update_timer: float = 0.0
var _label: RichTextLabel


func _ready() -> void:
	layer = 100
	_find_components()
	_create_ui()


func _find_components() -> void:
	_main = get_tree().current_scene
	if _main == null:
		return
	if "hero_controller" in _main and _main.hero_controller != null:
		var ctrl = _main.hero_controller
		if ctrl.has_method("get_hero"):
			_hero = ctrl.get_hero()
	if "population_manager" in _main:
		_pop_mgr = _main.population_manager
	for child in _main.get_children():
		if child.get_script() == preload("res://scripts/mini_captain/test_summon_skill.gd"):
			_test_skill = child
		var s = child.get_script()
		if s != null and "WaveManager" in str(s):
			_wave_mgr = child


func _create_ui() -> void:
	_label = RichTextLabel.new()
	_label.anchor_left = 0.0
	_label.anchor_top = 0.0
	_label.offset_left = 8
	_label.offset_top = 8
	_label.custom_minimum_size = Vector2(320, 0)
	_label.fit_content = true
	_label.bbcode_enabled = true
	_label.scroll_active = false
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer < UPDATE_INTERVAL:
		return
	_update_timer = 0.0
	_refresh_display()


func _refresh_display() -> void:
	if _label == null:
		return
	var lines: PackedStringArray = []
	lines.append("[b][color=#ffff00]=== Mini Captain Debug ===[/color][/b]")

	if _hero and is_instance_valid(_hero):
		lines.append("")
		_append_hero_info(lines)
	else:
		lines.append("\n[color=#ff4444]英雄未找到[/color]")

	if _pop_mgr and is_instance_valid(_pop_mgr):
		lines.append("")
		_append_pop_info(lines)

	if _test_skill and is_instance_valid(_test_skill):
		lines.append("")
		_append_skill_info(lines)

	lines.append("")
	_append_combat_info(lines)

	if _wave_mgr and is_instance_valid(_wave_mgr):
		lines.append("")
		_append_wave_info(lines)

	_label.text = "\n".join(lines)


func _append_hero_info(lines: PackedStringArray) -> void:
	lines.append("[b]--- 英雄信息 ---[/b]")

	var hp_cur: int = _hero.health.hp if _hero.health else 0
	var hp_max: int = _hero.health.max_hp if _hero.health else 0
	var hp_color := COLOR_VALUE
	if hp_max > 0:
		var ratio: float = float(hp_cur) / hp_max
		if ratio < 0.25:
			hp_color = COLOR_DANGER
		elif ratio < 0.5:
			hp_color = COLOR_WARN
	lines.append("  HP: [color=#%s]%d / %d[/color]" % [_color_to_hex(hp_color), hp_cur, hp_max])

	var atk: int = _hero.stat_set.get_int(&"attack_damage") if _hero.stat_set else 0
	lines.append("  攻击: %d" % atk)

	var range_val: float = _hero.stat_set.get_value(&"attack_range") if _hero.stat_set else 0.0
	lines.append("  射程: %.0f" % range_val)

	var speed: float = _hero.stat_set.get_value(&"move_speed") if _hero.stat_set else 0.0
	lines.append("  速度: %.0f" % speed)

	var state_str: String = _state_string(_hero.state)
	lines.append("  状态: [color=#%s]%s[/color]" % [_color_to_hex(COLOR_WARN), state_str])


func _append_pop_info(lines: PackedStringArray) -> void:
	lines.append("[b]--- 人口 ---[/b]")
	var cur: int = _pop_mgr.current
	var cap: int = _pop_mgr.cap
	var col := COLOR_VALUE
	if cur >= cap:
		col = COLOR_DANGER
	elif cur >= cap * 0.75:
		col = COLOR_WARN
	lines.append("  人口: [color=#%s]%d / %d[/color]" % [_color_to_hex(col), cur, cap])


func _append_skill_info(lines: PackedStringArray) -> void:
	lines.append("[b]--- 召唤技能 ---[/b]")
	var cd_left: float = _test_skill._cd_timer if "_cd_timer" in _test_skill else 0.0
	if cd_left <= 0:
		lines.append("  CD: [color=#%s]就绪 (按空格)[/color]" % _color_to_hex(COLOR_VALUE))
	else:
		lines.append("  CD: [color=#%s]%.1fs[/color]" % [_color_to_hex(COLOR_WARN), cd_left])

	var alive: int = 0
	for unit in get_tree().get_nodes_in_group("player_units"):
		if unit == _hero:
			continue
		if is_instance_valid(unit) and unit.has_method("is_dead") and not unit.is_dead():
			alive += 1
	lines.append("  存活召唤: %d" % alive)


func _append_combat_info(lines: PackedStringArray) -> void:
	lines.append("[b]--- 战斗信息 ---[/b]")
	var alive_enemies: int = 0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if is_instance_valid(u) and u.has_method("is_dead") and not u.is_dead():
			alive_enemies += 1
	lines.append("  存活敌人: %d" % alive_enemies)


func _append_wave_info(lines: PackedStringArray) -> void:
	if _wave_mgr == null:
		return
	lines.append("[b]--- 波次信息 ---[/b]")
	var cw: int = _wave_mgr.current_wave if "current_wave" in _wave_mgr else 0
	var tw: int = _wave_mgr.waves.size() if "waves" in _wave_mgr else 0
	var wa: bool = _wave_mgr.wave_active if "wave_active" in _wave_mgr else false
	lines.append("  波次: %d / %d" % [cw, tw])
	lines.append("  活跃: %s" % ["是" if wa else "否"])


static func _state_string(s: int) -> String:
	match s:
		0: return "GUARD"
		1: return "HOLD"
		2: return "MOVE"
		3: return "ATTACK_MOVE"
		4: return "ATTACK"
		5: return "DEAD"
		6: return "PATROL"
		_: return "未知(%d)" % s


static func _color_to_hex(c: Color) -> String:
	return "%02x%02x%02x" % [int(c.r * 255), int(c.g * 255), int(c.b * 255)]
