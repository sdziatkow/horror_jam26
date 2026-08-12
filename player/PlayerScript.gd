class_name Player
extends CharacterBody2D

@onready var _anim_state: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

func _ready() -> void:
	_anim_state.travel("meelee_idle")
	
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

## Specific move state
enum MoveState {WALK, SPRINT}
var _mv_state: MoveState = MoveState.WALK

## Update rotation of CharacterBody2D and MeeleeHitBox based on mouse position.
func _look_at_mouse() -> void:
		global_rotation = (get_global_mouse_position() - global_position).angle()
		$MeeleePivot.global_rotation = global_rotation
			
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
	if (Input.get_action_strength("sprint") > 0.0): 
		_mv_state = MoveState.SPRINT
	else:
		_mv_state = MoveState.WALK
		
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
	_state = State.MOVE
