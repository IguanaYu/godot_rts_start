@tool
extends Node2D
class_name Neutral

@export var sprite_scale_x: float = 0.5:
	set(v): sprite_scale_x = v; _refresh_editor()
@export var sprite_scale_y: float = 0.5:
	set(v): sprite_scale_y = v; _refresh_editor()
@export var sprite_lift: float = 20.0:
	set(v): sprite_lift = v; _refresh_editor()
@export var shadow_width: int = 20:
	set(v): shadow_width = v; _refresh_editor()
@export var shadow_height: int = 8:
	set(v): shadow_height = v; _refresh_editor()
@export var shadow_alpha: float = 0.3:
	set(v): shadow_alpha = v; _refresh_editor()

@onready var body_sprite: Sprite2D = $Sprite

const ShadowComp := preload("res://scripts/core/shadow_component.gd")
@onready var _shadow_component: ShadowComp = $ShadowComponent

func _ready() -> void:
	_rebuild_shadow()
	_apply_sprite_position()

func _rebuild_shadow() -> void:
	if _shadow_component:
		_shadow_component.rebuild(shadow_width, shadow_height, shadow_alpha)

func _apply_sprite_position() -> void:
	if _shadow_component:
		_shadow_component.apply_sprite_position(body_sprite, sprite_scale_x, sprite_scale_y, sprite_lift)

func _refresh_editor() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_node_ready():
		return
	_rebuild_shadow()
	_apply_sprite_position()
