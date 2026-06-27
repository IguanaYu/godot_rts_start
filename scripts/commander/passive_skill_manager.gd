extends Node
## 被动技能管理器：维护玩家方 profile 的被动技能，按 trigger id 派发事件
## 单位侧（unit.gd / building.gd / game_spawner.gd）在关键事件触发点调用 emit_trigger
## 被动技能实现（passives/*.gd）通过 register_static(manager, profile) 静态方法注册到对应 trigger

const PassiveTriggersClass := preload("res://scripts/commander/passive_triggers.gd")

# 触发点 id → Callable 列表
var _handlers: Dictionary = {}  # {StringName: Array[Callable]}

# 当前玩家方 profile（决定可激活的被动）
var _profile = null

# tick 计时
var _tick_acc: float = 0.0
const TICK_INTERVAL: float = 1.0


func set_profile(profile) -> void:
	_profile = profile
	_handlers.clear()
	if profile == null:
		return
	# 按 profile.passive_skills 实例化对应实现
	for passive_id in profile.passive_skills:
		var impl = _load_passive_impl(passive_id)
		if impl == null:
			continue
		# 实现类提供静态/实例 register 方法，把 handler 加到 _handlers
		impl.register(self, profile)


## 由被动技能 id 加载实现（约定 res://scripts/commander/passives/<id>.gd）
func _load_passive_impl(passive_id: StringName):
	var path := "res://scripts/commander/passives/" + String(passive_id) + ".gd"
	if not ResourceLoader.exists(path):
		push_warning("[PassiveSkillManager] passive impl not found: " + String(passive_id))
		return null
	var script := load(path)
	if script == null:
		return null
	return script.new()


func register(trigger_id: StringName, handler: Callable) -> void:
	if not _handlers.has(trigger_id):
		_handlers[trigger_id] = []
	_handlers[trigger_id].append(handler)


func emit_trigger(trigger_id: StringName, ctx: Dictionary) -> void:
	if not _handlers.has(trigger_id):
		return
	for handler in _handlers[trigger_id]:
		handler.call(ctx)


func _process(delta: float) -> void:
	_tick_acc += delta
	if _tick_acc >= TICK_INTERVAL:
		_tick_acc = 0.0
		emit_trigger(PassiveTriggersClass.TICK_1S, {})
