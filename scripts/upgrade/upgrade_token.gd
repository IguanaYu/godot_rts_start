extends Area2D
## 升级币掉落物：精英怪死后掉落，玩家单位走过拾取

const UD := preload("res://scripts/upgrade/upgrade_data.gd")

var tier: int = UD.Tier.SILVER
var _collected := false
var _base_y: float = 0.0

@onready var glow: Sprite2D = $Glow


func _ready() -> void:
	_base_y = position.y
	_setup_visual()
	_setup_animation()
	# 30 秒后自动消失
	get_tree().create_timer(30.0).timeout.connect(_despawn)


func _setup_visual() -> void:
	var glow_color: Color = UD.TIER_GLOW_COLORS.get(tier, Color(1, 1, 1, 0.3))
	if glow:
		glow.modulate = glow_color
	# 主图标颜色轻微受 tier 影响
	modulate = Color(1, 1, 1, 1)


func _setup_animation() -> void:
	# 上下浮动
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", _base_y - 5.0, 0.8)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", _base_y + 5.0, 0.8)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	# 光晕旋转
	if glow:
		var glow_tween := glow.create_tween()
		glow_tween.set_loops()
		glow_tween.tween_property(glow, "rotation", TAU, 2.5)


func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if not body.is_in_group("player_units"):
		return
	if body.health and body.health.is_dead():
		return
	_collected = true
	# 通知升级管理器
	var tree := get_tree()
	if tree and tree.current_scene:
		var mgr = tree.current_scene.get("upgrade_manager")
		if mgr:
			mgr.add_token(tier)
	# 拾取动画
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)


func _despawn() -> void:
	if _collected:
		return
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
