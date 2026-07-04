extends CanvasLayer
## 仇恨系统调试 HUD：
## 实时显示每个敌方单位的威胁值表 + AI 状态 + 当前目标
## F1 切换可见性

const EnemyAIScript := preload("res://scripts/units/enemy_ai.gd")

const REFRESH_INTERVAL: float = 0.2
const TAUNT_THREAT_THRESHOLD: float = 9000.0

var _root: Control
var _label: Label
var _timer: Timer
var _visible: bool = true


func _ready() -> void:
	layer = 50
	_build_ui()
	_timer = Timer.new()
	_timer.wait_time = REFRESH_INTERVAL
	_timer.autostart = true
	_timer.timeout.connect(_refresh)
	add_child(_timer)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_label = Label.new()
	_label.position = Vector2(10, 80)
	_label.size = Vector2(700, 600)
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	_label.text = "[Aggro Debug HUD loading...]"
	_root.add_child(_label)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			_visible = not _visible
			_root.visible = _visible


func _refresh() -> void:
	if not _visible:
		return
	var enemies := get_tree().get_nodes_in_group("enemy_units")
	var lines: PackedStringArray = []
	lines.append("[Aggro Debug HUD — F1 toggle]")
	lines.append("")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var snapshot := _snapshot_unit(enemy)
		lines.append_array(snapshot)
		lines.append("")
	_label.text = "\n".join(lines)


func _snapshot_unit(enemy) -> PackedStringArray:
	var lines: PackedStringArray = []
	var name := _safe_name(enemy)
	var ai = enemy.get_node_or_null("EnemyAI")
	if ai == null:
		lines.append("%s: (no EnemyAI)" % name)
		return lines

	var state_str := "UNKNOWN"
	if "ai_state" in ai:
		var keys = EnemyAIScript.AIState.keys()
		state_str = keys[ai.ai_state] if ai.ai_state < keys.size() else str(ai.ai_state)

	var mode_str := "UNKNOWN"
	if "behavior_mode" in ai:
		var mkeys = EnemyAIScript.BehaviorMode.keys()
		mode_str = mkeys[ai.behavior_mode] if ai.behavior_mode < mkeys.size() else str(ai.behavior_mode)

	var target_name := "(null)"
	if "chase_target" in ai and is_instance_valid(ai.chase_target):
		target_name = _safe_name(ai.chase_target)

	lines.append("%s  STATE=%s  MODE=%s  target=%s" % [name, state_str, mode_str, target_name])

	# 显示入场锁剩余时间
	if "_state_enter_time" in ai:
		var elapsed: float = (float(Time.get_ticks_msec()) - float(ai._state_enter_time)) / 1000.0
		var lock_total: float = float(EnemyAIScript.STATE_ENTRY_LOCK_MSEC) / 1000.0
		var lock_tag := ""
		if elapsed < lock_total:
			lock_tag = "  [LOCK %.1fs]" % (lock_total - elapsed)
		lines.append("  state age: %.1fs%s" % [elapsed, lock_tag])

	# 显示 _recent_attackers（新的目标选择依据）
	if "_recent_attackers" in ai:
		var attackers: Dictionary = ai._recent_attackers
		if attackers.is_empty():
			lines.append("  recent attackers: (empty)")
		else:
			lines.append("  recent attackers:")
			var now := float(Time.get_ticks_msec())
			var a_entries: Array = []
			for attacker in attackers.keys():
				if not is_instance_valid(attacker):
					continue
				a_entries.append({"attacker": attacker, "time": float(attackers[attacker])})
			a_entries.sort_custom(func(a, b): return a["time"] > b["time"])
			for entry in a_entries:
				var a_name := _safe_name(entry["attacker"])
				var age := (now - float(entry["time"])) / 1000.0
				var tag := ""
				if ai.chase_target == entry["attacker"]:
					tag = "  [CURRENT]"
				lines.append("    %-22s  %.1fs ago%s" % [a_name, age, tag])

	# 显示 aggro 表（保留：用于 skill_component + 嘲讽标记）
	var aggro = enemy.get_node_or_null("EnemyAI/AggroComponent")
	if aggro == null:
		lines.append("  (no AggroComponent)")
		return lines

	var snap: Dictionary = aggro.debug_snapshot()
	var entries: Array = snap.get("entries", [])
	if entries.is_empty():
		lines.append("  threat table: (empty)")
	else:
		lines.append("  threat table:")
		var now := float(Time.get_ticks_msec())
		var lock_expire: float = float(snap.get("lock_expire_msec", 0.0))
		var lock_remaining: float = max(0.0, (lock_expire - now) / 1000.0)
		var locked_target = snap.get("locked_target")
		for entry in entries:
			var t = entry["target"]
			var t_name := _safe_name(t)
			var v: float = float(entry["value"])
			var age := (now - float(entry["last_seen_msec"])) / 1000.0
			var source_tag := _infer_source(v, age)
			var lock_tag := ""
			if locked_target != null and is_instance_valid(locked_target) and locked_target == t:
				lock_tag = "  [LOCK %.1fs]" % lock_remaining
			lines.append("    %-22s = %8.1f  (%s, %.1fs ago)%s" % [t_name, v, source_tag, age, lock_tag])
	return lines


func _infer_source(value: float, age: float) -> String:
	if value >= TAUNT_THREAT_THRESHOLD:
		return "TAUNT"
	# 30 = DAMAGE_FIRST_BLOOD；新近(<=0.3s)且值偏大 → 大概率是 DAMAGE 累积
	if value >= 25.0 and age <= 0.5:
		return "DAMAGE?"
	if value >= 5.0 and age <= 0.2:
		return "PROX/DAMAGE?"
	return "faded"


func _safe_name(node) -> String:
	if node == null or not is_instance_valid(node):
		return "(invalid)"
	if "stats_data" in node and node.stats_data != null and "id" in node.stats_data:
		return "%s(%s)" % [node.name, node.stats_data.id]
	return node.name
