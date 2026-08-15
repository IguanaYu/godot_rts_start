extends Node
## ParticlePool Autoload：特效对象池
## - spawn(key, pos, opts) 取实例播放，播完自动归还（finished 信号为主，超时兜底）
## - 帧动画配方（dust/explosion）与 GPUParticles2D 配方都支持（鸭子类型 begin_play/finished）
## - _ready() 自动 prewarm_all()，沙盒/测试场景不经过 main.gd 也能用
## - 超时用 delta 累计（含 Engine.time_scale），暂停时 pool PAUSABLE 计时同步冻结

const RECIPES := {
	"dust": {
		"scene": preload("res://scenes/effects/dust_effect.tscn"),
		"prewarm": 30,
		"timeout": 0.6,
	},
	"explosion": {
		"scene": preload("res://scenes/effects/explosion.tscn"),
		"prewarm": 20,
		"timeout": 0.9,
	},
	"hit_spark": {
		"scene": preload("res://scenes/effects/particles/hit_spark.tscn"),
		"prewarm": 20,
		"timeout": 0.65,
	},
	"debris": {
		"scene": preload("res://scenes/effects/particles/debris.tscn"),
		"prewarm": 10,
		"timeout": 1.1,
	},
	"energy_fog": {
		"scene": preload("res://scenes/effects/particles/energy_fog.tscn"),
		"prewarm": 5,
		"timeout": 1.7,
	},
	"heal_orb": {
		"scene": preload("res://scenes/effects/particles/heal_orb.tscn"),
		"prewarm": 10,
		"timeout": 1.4,
	},
	"blood_mist": {
		"scene": preload("res://scenes/effects/particles/blood_mist.tscn"),
		"prewarm": 10,
		"timeout": 0.8,
	},
	"dust_gpu": {
		"scene": preload("res://scenes/effects/particles/dust.tscn"),
		"prewarm": 5,
		"timeout": 0.95,
	},
}

var _idle: Dictionary = {}
var _active: Dictionary = {}
var _elapsed: Dictionary = {}  # key -> {instance_id: seconds}
var _defaults: Dictionary = {}  # instance_id -> {scale, rotation, modulate}
var _peak: Dictionary = {}
var _extra: Dictionary = {}

var _pool_root: Node2D


func _ready() -> void:
	_pool_root = Node2D.new()
	_pool_root.name = "PoolRoot"
	add_child(_pool_root)
	for key in RECIPES:
		_idle[key] = []
		_active[key] = []
		_elapsed[key] = {}
		_peak[key] = 0
		_extra[key] = 0
	prewarm_all()


func spawn(key: String, pos: Vector2, opts: Dictionary = {}) -> Node2D:
	if not RECIPES.has(key):
		push_error("ParticlePool: unknown key '%s'" % key)
		return null
	var node: Node2D = _idle[key].pop_back() if not _idle[key].is_empty() else _create(key)
	_active[key].append(node)
	_elapsed[key][node.get_instance_id()] = 0.0
	_peak[key] = maxi(_peak[key], _active[key].size())
	node.visible = true
	node.global_position = pos
	if opts.has("scale"):
		node.scale = Vector2(opts["scale"]) if opts["scale"] is float else opts["scale"]
	if opts.has("rotation"):
		node.rotation = opts["rotation"]
	if opts.has("modulate"):
		node.modulate = opts["modulate"]
	node.begin_play()
	return node


func prewarm(key: String, count: int) -> void:
	if not RECIPES.has(key):
		push_error("ParticlePool: unknown key '%s'" % key)
		return
	for i in count:
		_idle[key].append(_create(key))


func prewarm_all() -> void:
	for key in RECIPES:
		var deficit: int = RECIPES[key]["prewarm"] - _idle[key].size() - _active[key].size()
		for i in deficit:
			_idle[key].append(_create(key))


func recall_all() -> void:
	for key in _active.keys():
		for node in _active[key].duplicate():
			_release(key, node)


func get_stats() -> Dictionary:
	var stats := {}
	for key in RECIPES:
		stats[key] = {
			"idle": _idle[key].size(),
			"active": _active[key].size(),
			"peak": _peak[key],
			"extra": _extra[key],
		}
	return stats


func _create(key: String) -> Node2D:
	var node: Node2D = RECIPES[key]["scene"].instantiate()
	if node is FrameAnimatedEffect:
		node.pooled = true
	if _idle[key].is_empty() and _active[key].size() > 0:
		push_warning("ParticlePool '%s' empty, dynamic +1 (active=%d)" % [key, _active[key].size()])
		_extra[key] += 1
	_defaults[node.get_instance_id()] = {
		"scale": node.scale,
		"rotation": node.rotation,
		"modulate": node.modulate,
	}
	node.visible = false
	node.finished.connect(_release.bind(key, node))
	_pool_root.add_child(node)
	return node


func _release(key: String, node: Node2D) -> void:
	# 幂等：finished 信号与超时兜底可能都触发，只有还在 _active 才归还
	if not _active[key].has(node):
		return
	_active[key].erase(node)
	_elapsed[key].erase(node.get_instance_id())
	if node is GPUParticles2D:
		node.emitting = false
	node.visible = false
	var def: Dictionary = _defaults.get(node.get_instance_id(), {})
	if def.has("scale"):
		node.scale = def["scale"]
	if def.has("rotation"):
		node.rotation = def["rotation"]
	if def.has("modulate"):
		node.modulate = def["modulate"]
	_idle[key].append(node)


func _process(delta: float) -> void:
	for key in _active.keys():
		if _active[key].is_empty():
			continue
		var timeout: float = RECIPES[key]["timeout"]
		var elapsed: Dictionary = _elapsed[key]
		for node in _active[key].duplicate():
			var id: int = node.get_instance_id()
			elapsed[id] = elapsed.get(id, 0.0) + delta
			if elapsed[id] > timeout:
				_release(key, node)
