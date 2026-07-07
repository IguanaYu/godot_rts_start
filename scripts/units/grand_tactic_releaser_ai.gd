class_name GrandTacticReleaserAI
extends Node

## 大战术释放者 AI
## 管理引导计时、战术阶段分发、联动死亡。
## 作为子节点挂在大战术释放者 Unit 上（类似 BossAI 结构）。

## 引导开始
signal channel_started(releaser: GrandTacticReleaserAI)
## 引导中周期性触发
signal channel_tick(releaser: GrandTacticReleaserAI, progress: float)
## 引导完成
signal channel_completed(releaser: GrandTacticReleaserAI)
## 被击杀导致中断
signal channel_interrupted(releaser: GrandTacticReleaserAI)

## 战术配置
@export var tactic: Resource = null

var _owner_unit: CharacterBody2D = null
var _channel_progress: float = 0.0
var _tick_accumulator: float = 0.0
var _is_channeling: bool = false
var _has_completed: bool = false
var _linked_minions: Array[Node] = []
var _channel_visual: Node2D = null

const UnitScript := preload("res://scripts/units/unit.gd")
const ChannelVisualScript := preload("res://scripts/units/grand_tactic_channel_visual.gd")

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_owner_unit = get_parent() as CharacterBody2D
	if _owner_unit == null:
		push_error("GrandTacticReleaserAI: Parent must be a CharacterBody2D")
		return

	add_to_group("grand_tactic_releaser")
	# 把单位也加入组，让 unit.gd 的 _aura_process debug print 能识别
	if not _owner_unit.is_in_group("grand_tactic_releaser"):
		_owner_unit.add_to_group("grand_tactic_releaser")

	# 禁用攻击
	if _owner_unit.has_method("set_attack_disabled"):
		_owner_unit.set_attack_disabled(true)

	# 设为原地待命（deferred：等 NavigationAgent 就绪）
	if _owner_unit.has_method("hold_position"):
		_owner_unit.hold_position.call_deferred()

	# 开始引导
	_is_channeling = true
	channel_started.emit(self)
	_show_channel_visual("start")
	# defer 到下一帧：父节点 unit._ready 跑完 _setup_stats 才能确保 aura_range 不被重置
	_apply_tactic_start.call_deferred()
	var tactic_name: String = tactic.tactic_name if tactic else "<none>"
	var channel_time: float = tactic.channel_time if tactic else 0.0
	print("[GrandTactic] %s 引导开始 (tactic=%s, channel_time=%.1fs)" %
		[_owner_unit.name, tactic_name, channel_time])


func set_game_controller(gc: Node2D) -> void:
	pass  # Phase 3 集成时用


func _exit_tree() -> void:
	# 单位被 queue_free 时清理视觉节点（_channel_visual 是 current_scene 的子节点，不会自动清理）
	_destroy_channel_visual()


func _process(delta: float) -> void:
	if not _is_channeling or _has_completed:
		return
	if _owner_unit == null or not is_instance_valid(_owner_unit):
		return
	if _owner_unit.has_method("is_dead") and _owner_unit.is_dead():
		_interrupt()
		return

	_channel_progress += delta
	_tick_accumulator += delta

	# 引导中周期性触发
	if tactic and tactic.effect_interval > 0.0 and _tick_accumulator >= tactic.effect_interval:
		_tick_accumulator -= tactic.effect_interval
		var progress_pct: float = _channel_progress / tactic.channel_time * 100.0
		print("[GrandTactic] tick progress=%.0f%%" % progress_pct)
		_apply_tactic_tick()
		channel_tick.emit(self, _channel_progress / tactic.channel_time)

	# 引导进度视觉更新
	_update_channel_visual()

	# 引导完成
	if tactic and _channel_progress >= tactic.channel_time:
		_has_completed = true
		_is_channeling = false
		channel_completed.emit(self)
		_show_channel_visual("complete")
		_apply_tactic_complete()
		print("[GrandTactic] 引导完成，准备释放战术")


## 手动中断引导（被击杀时调用）
func _interrupt() -> void:
	if not _is_channeling:
		return
	_is_channeling = false
	channel_interrupted.emit(self)
	print("[GrandTactic] 引导被中断（被击杀）")
	_cleanup_linked_minions()
	_destroy_channel_visual()


## 注册联动死亡单位
func link_minion(minion: Node) -> void:
	if minion == null or not is_instance_valid(minion):
		return
	_linked_minions.append(minion)
	if minion.has_signal("died"):
		minion.died.connect(_on_linked_minion_died.bind(minion))


## 联动死亡：杀释放者则精英也死
func _cleanup_linked_minions() -> void:
	if tactic == null or not tactic.linked_death:
		return
	var killed: int = 0
	for m in _linked_minions:
		if is_instance_valid(m) and m.has_method("is_dead") and not m.is_dead():
			m.die()
			killed += 1
	_linked_minions.clear()
	if killed > 0:
		print("[GrandTactic] 联动死亡清理 %d 个单位" % killed)


## 单个联动单位死亡时从列表清理
func _on_linked_minion_died(_minion: Node) -> void:
	_prune_linked_minions()


func _prune_linked_minions() -> void:
	var alive: Array = []
	for m in _linked_minions:
		if is_instance_valid(m) and m.has_method("is_dead") and not m.is_dead():
			alive.append(m)
	_linked_minions = alive


func get_channel_progress() -> float:
	if tactic == null or tactic.channel_time <= 0.0:
		return 0.0
	return _channel_progress / tactic.channel_time


func get_remaining_time() -> float:
	if tactic == null:
		return 0.0
	return max(0.0, tactic.channel_time - _channel_progress)


func is_channeling() -> bool:
	return _is_channeling


func has_completed() -> bool:
	return _has_completed


# --- 视觉反馈 ---

func _show_channel_visual(phase: String) -> void:
	match phase:
		"start":
			_create_channel_visual()
		"complete":
			_destroy_channel_visual()


func _update_channel_visual() -> void:
	if _channel_visual == null or not is_instance_valid(_channel_visual):
		return
	if tactic == null:
		return
	_channel_visual.progress = _channel_progress / tactic.channel_time
	_channel_visual.remaining_sec = get_remaining_time()


func _create_channel_visual() -> void:
	if _channel_visual != null and is_instance_valid(_channel_visual):
		return
	if tactic == null or _owner_unit == null:
		return
	var visual := Node2D.new()
	visual.set_script(ChannelVisualScript)
	visual.target_unit = _owner_unit
	visual.channel_time = tactic.channel_time
	visual.tactic_name = tactic.tactic_name
	# 加为 owner_unit 的子节点：自动跟随，位置永远 (0,0) relative
	# 用 call_deferred：AI._ready 期间 owner_unit 还在 setup children，直接 add 会失败
	_owner_unit.add_child.call_deferred(visual)
	_channel_visual = visual


func _destroy_channel_visual() -> void:
	if _channel_visual != null and is_instance_valid(_channel_visual):
		_channel_visual.queue_free()
	_channel_visual = null


# --- 战术效果 ---

const GrandTacticRes := preload("res://scripts/tactics/grand_tactic_resource.gd")

func _get_spawner() -> Node:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	return scene.get("spawner_module")


func _apply_tactic_tick() -> void:
	if tactic == null or not is_instance_valid(_owner_unit):
		return
	match tactic.tactic_id:
		GrandTacticRes.TacticId.SUMMON_WAVE:
			_do_summon_wave()
		GrandTacticRes.TacticId.MORALE_BOOST:
			pass  # aura 由 _aura_process 自动跑，tick 不做事


func _apply_tactic_start() -> void:
	if tactic == null or not is_instance_valid(_owner_unit):
		return
	match tactic.tactic_id:
		GrandTacticRes.TacticId.SUMMON_ELITE:
			_do_summon_elite()
		GrandTacticRes.TacticId.MORALE_BOOST:
			_do_morale_boost()


func _do_summon_elite() -> void:
	var spawner := _get_spawner()
	if spawner == null:
		push_warning("[GrandTactic] 找不到 spawner_module，无法召唤精英")
		return
	var summoned: int = 0
	for i in range(tactic.elite_count):
		var stats_id: StringName = tactic.elite_stats_ids[i % tactic.elite_stats_ids.size()] if tactic.elite_stats_ids.size() > 0 else &""
		var offset := Vector2(randf_range(-80, 80), randf_range(-80, 80))
		var pos: Vector2 = _owner_unit.global_position + offset
		var elite = spawner.spawn_summon(0, stats_id, pos, 1)
		if elite:
			link_minion(elite)
			summoned += 1
	print("[GrandTactic] SUMMON_ELITE 召唤 %d 个精英（联动死亡=%s）" % [summoned, tactic.linked_death])


func _do_morale_boost() -> void:
	# 把 tactic 的 aura 参数注入到 unit，让 unit.gd._aura_process 自动跑
	_owner_unit.aura_type = tactic.aura_type
	_owner_unit.aura_value = tactic.aura_value
	_owner_unit.aura_range = tactic.aura_range
	print("[GrandTactic] MORALE_BOOST 激活 aura (type=%s, value=%.2f, range=%.0f)" %
		[tactic.aura_type, tactic.aura_value, tactic.aura_range])


func _apply_tactic_complete() -> void:
	if tactic == null or not is_instance_valid(_owner_unit):
		return
	match tactic.tactic_id:
		GrandTacticRes.TacticId.FINAL_SUMMON:
			_do_final_summon()


func _do_summon_wave() -> void:
	var spawner := _get_spawner()
	if spawner == null:
		push_warning("[GrandTactic] 找不到 spawner_module，无法召唤")
		return
	for i in range(tactic.effect_count):
		var offset := Vector2(randf_range(-60, 60), randf_range(-60, 60))
		var pos: Vector2 = _owner_unit.global_position + offset
		var minion = spawner.spawn_summon(
			tactic.effect_unit_type,
			tactic.effect_stats_id,
			pos,
			1  # ENEMY team
		)
		if minion and tactic.linked_death:
			link_minion(minion)
	print("[GrandTactic] SUMMON_WAVE 召唤 %d 个单位" % tactic.effect_count)


func _do_final_summon() -> void:
	var spawner := _get_spawner()
	if spawner == null:
		push_warning("[GrandTactic] 找不到 spawner_module，无法召唤")
		return
	var total: int = 0
	for group in tactic.final_summon_groups:
		var type: int = int(group.get("type", 0))
		var count: int = int(group.get("count", 0))
		for i in range(count):
			var offset := Vector2(randf_range(-100, 100), randf_range(-100, 100))
			var pos: Vector2 = _owner_unit.global_position + offset
			spawner.spawn_summon(type, &"", pos, 1)
			total += 1
	print("[GrandTactic] FINAL_SUMMON 召唤 %d 个单位" % total)
