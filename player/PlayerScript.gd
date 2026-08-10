class_name Player
extends CharacterBody2D

#MOVEMENT------------------------------------------------------------------------
@export var WALK_SPEED: float = 150.0
@export var SPRINT_SPEED: float = 300.0
@export var ACCELERATION: float = 1000.0
@export var FRICTION: float = 500.0

enum State {MOVE, SHOOT, FREEZE}
enum MoveState {WALK, SPRINT}

var _state = State.MOVE
var _mv_state: MoveState = MoveState.WALK

func _physics_process(delta: float) -> void:
	match (_state):
		State.MOVE:
			_move_state(delta)
			rotation = (get_global_mouse_position() - position).angle()
		State.SHOOT:
			_shoot_state(delta)
		State.FREEZE:
			pass
			
func _move_state(delta: float) -> void:
	var input_vector = Vector2.ZERO
	
	# Determine the direction of movement based on input.
	input_vector.x = Input.get_action_strength("move_east") - Input.get_action_strength("move_west")
	input_vector.y = Input.get_action_strength("move_south") - Input.get_action_strength("move_north")
	input_vector = input_vector.normalized()
	
	var moving: bool = (input_vector != Vector2.ZERO)
	if (moving):
		var max_speed: float
		
		# Determine max_speed based on _mv_state.
		match (_mv_state):
			MoveState.WALK: max_speed = WALK_SPEED
			MoveState.SPRINT: max_speed = SPRINT_SPEED
		
		# Update velocity to move toward max_speed by ACCELERATION * delta
		velocity = velocity.move_toward(input_vector * max_speed, ACCELERATION * delta)
		velocity = velocity.limit_length(max_speed)
	
	# Update velocity to move toward ZERO by FRICTION * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
	
	# Check for a change in _mv_state
	if (Input.get_action_strength("sprint") > 0.0): 
		_mv_state = MoveState.SPRINT
	else:
		_mv_state = MoveState.WALK
	
func _shoot_state(delta: float) -> void:
	pass
	
func get_spawn_diameter() -> float:
	return max($CollisionShape2D.shape.height, $CollisionShape2D.shape.radius * 2)
