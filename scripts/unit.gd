extends CharacterBody2D
class_name Unit

enum UnitState { IDLE, MOVE, ATTACK, DEAD }
enum UnitType { SOLDIER, ARCHER }
enum Team { PLAYER, ENEMY }

@export var unit_type: UnitType = UnitType.SOLDIER
@export var team: Team = Team.PLAYER

var max_hp: int
var hp: int
var attack_damage: int
var attack_range: float
var attack_cooldown: float
var move_speed: float

var state: UnitState = UnitState.IDLE
var attack_target: Unit = null
var attack_timer: float = 0.0
var selected: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selection_ring: CanvasItem = $SelectionRing
@onready var hp_bar: ProgressBar = $HPBar
@onready var body_visual: ColorRect = $BodyVisual
@onready var type_label: Label = $BodyVisual/TypeLabel

signal died(unit: Unit)

func _ready() -> void:
	_setup_stats()
	_setup_visuals()
	_update_selection_ring()
	_update_hp_bar()

func _setup_stats() -> void:
	match unit_type:
		UnitType.SOLDIER:
			max_hp = 100
			attack_damage = 10
			attack_range = 40.0
			attack_cooldown = 0.8
			move_speed = 120.0
		UnitType.ARCHER:
			max_hp = 60
			attack_damage = 15
			attack_range = 200.0
			attack_cooldown = 1.2
			move_speed = 80.0
	hp = max_hp

func _setup_visuals() -> void:
	var color: Color
	if team == Team.PLAYER:
		color = Color(0.2, 0.5, 1.0)
	else:
		color = Color(1.0, 0.2, 0.2)
	body_visual.color = color
	type_label.text = "S" if unit_type == UnitType.SOLDIER else "A"

func _physics_process(delta: float) -> void:
	if state == UnitState.DEAD:
		return

	velocity = Vector2.ZERO

	match state:
		UnitState.MOVE:
			_move_process()
		UnitState.ATTACK:
			_attack_process(delta)

	if velocity.length_squared() > 1.0:
		move_and_slide()

	attack_timer = max(0.0, attack_timer - delta)

func _move_process() -> void:
	if nav_agent.is_navigation_finished():
		state = UnitState.IDLE
		return
	var next_pos := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_pos)
	velocity = direction * move_speed

func _attack_process(delta: float) -> void:
	if attack_target == null or attack_target.state == UnitState.DEAD:
		attack_target = null
		state = UnitState.IDLE
		return

	var dist := global_position.distance_to(attack_target.global_position)
	if dist > attack_range:
		nav_agent.target_position = attack_target.global_position
		if not nav_agent.is_navigation_finished():
			var next_pos := nav_agent.get_next_path_position()
			velocity = global_position.direction_to(next_pos) * move_speed
	else:
		if attack_timer <= 0.0:
			_perform_attack()
			attack_timer = attack_cooldown

func _perform_attack() -> void:
	if attack_target and attack_target.state != UnitState.DEAD:
		attack_target.take_damage(attack_damage)
		var tween := create_tween()
		tween.tween_property(body_visual, "scale", Vector2(1.3, 1.3), 0.1)
		tween.tween_property(body_visual, "scale", Vector2(1.0, 1.0), 0.1)

func take_damage(amount: int) -> void:
	if state == UnitState.DEAD:
		return
	hp = max(0, hp - amount)
	_update_hp_bar()
	if hp <= 0:
		die()

func die() -> void:
	state = UnitState.DEAD
	died.emit(self)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func move_to(target_pos: Vector2) -> void:
	attack_target = null
	nav_agent.target_position = target_pos
	state = UnitState.MOVE

func command_attack(target: Unit) -> void:
	attack_target = target
	nav_agent.target_position = target.global_position
	state = UnitState.ATTACK

func set_selected(value: bool) -> void:
	selected = value
	_update_selection_ring()

func _update_selection_ring() -> void:
	if selection_ring:
		selection_ring.visible = selected

func _update_hp_bar() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
