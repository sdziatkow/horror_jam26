class_name Player
extends CharacterBody2D

@onready var _anim_state: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
var hp: StatVal = StatVal.new(StatVal.StatType.HEALTH, 100.0, 100.0)
var sp: StatVal = StatVal.new(StatVal.StatType.STAMINA, 50.0, 50.0)

func _ready() -> void:
	_anim_state.travel("meelee_idle")
	$MeeleePivot/MeeleeHitBox.set_dmg(25.0)
	#hp.on_empty.connect(queue_free)
	$HurtBox.taking_damage.connect(hp.dec)
	
## General state of the player
enum State {MOVE, ATTACK, FREEZE}
var _state = State.MOVE

func _physics_process(delta: float) -> void:
	match (_state):
		State.MOVE:
			_move_state(delta)
			_look_at_mouse()
		State.ATTACK:
			_determine_attk(delta)
		State.FREEZE:
			pass

#MOVEMENT------------------------------------------------------------------------
@export var WALK_SPEED: float = 150.0
@export var SPRINT_SPEED: float = 300.0
@export var ACCELERATION: float = 1000.0
@export var FRICTION: float = 500.0

@export var SPRINT_COST: float = 0.50
@export var SPRINT_REGEN: float = 0.05

## Specific move state
enum MoveState {WALK, SPRINT}
var _mv_state: MoveState = MoveState.WALK

func _move_state(delta: float) -> void:
	var input_vector = Vector2.ZERO
	
	# Determine the direction of movement based on input.
	input_vector.x = Input.get_action_strength("move_east") - Input.get_action_strength("move_west")
	input_vector.y = Input.get_action_strength("move_south") - Input.get_action_strength("move_north")
	input_vector = input_vector.normalized()
	
	var moving: bool = (input_vector != Vector2.ZERO)
	if (moving): _on_moving(input_vector, delta)
	else: _on_idle(delta)
	move_and_slide()
	
	# Check for a change in _mv_state
	if (Input.get_action_strength("sprint") > 0.0 and sp.get_val() >= SPRINT_COST): 
		_mv_state = MoveState.SPRINT
		sp.dec(SPRINT_COST)
	else:
		_mv_state = MoveState.WALK
		sp.inc(SPRINT_REGEN)
		
	# Check for a attack input.
	if (Input.get_action_strength("attack") > 0.0):
		_state = State.ATTACK
		
## Move the in given direction (input_vector).
func _on_moving(input_vector: Vector2, delta: float) -> void:
	var max_speed: float
	
	# Determine max_speed based on _mv_state.
	match (_mv_state):
		MoveState.WALK: 
			max_speed = WALK_SPEED
		MoveState.SPRINT: 
			max_speed = SPRINT_SPEED
	
	# Update velocity to move toward max_speed by ACCELERATION * delta
	velocity = velocity.move_toward(input_vector * max_speed, ACCELERATION * delta)
	velocity = velocity.limit_length(max_speed)
	_anim_state.travel("meelee_walk")
	
## Update velocity to move toward ZERO by FRICTION * delta
func _on_idle(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_anim_state.travel("meelee_idle")
		
#ATTACKING-----------------------------------------------------------------------

## Specific attack state.
enum AttackState {MEELEE, SHOOT}
var _attk_state = AttackState

## Determine whether the player has meelee or gun equipped and set state accordingly.
func _determine_attk(delta: float) -> void:
	_meelee_state(delta)
	
func _meelee_state(delta: float) -> void:
	velocity = Vector2.ZERO
	_anim_state.travel("meelee_attk")
	
func _shoot_state(delta: float) -> void:
	pass
	
func _on_attk_finished() -> void:
	_smooth_look_at_mouse()
	_state = State.MOVE
	
#UTIL----------------------------------------------------------------------------

## Update rotation of CharacterBody2D.
func _look_at_mouse() -> void:
	global_rotation = (get_global_mouse_position() - global_position).angle()
	
## For adjusting back to looking at mouse when _look_at_mouse() is not active.
func _smooth_look_at_mouse() -> void:
	var angle: float = (get_global_mouse_position() - global_position).angle()
	var time: float = 0.1
	var anim: Tween = create_tween()
	anim.tween_property(self, "global_rotation", angle, time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func get_spawn_diameter() -> float:
	return max($CollisionShape2D.shape.height, $CollisionShape2D.shape.radius * 2)
