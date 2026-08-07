class_name Zombie
extends CharacterBody2D

enum State {IDLE, WANDER, CHASE, FREEZE}
var _state: State

@onready var _wander_cntrl: WanderControl = $WanderControl
@onready var _player_detection: PlayerDetection = $PlayerDetection

#MOVEMENT------------------------------------------------------------------------
@export var MAX_SPEED = 80.0
@export var ACCELERATION = 500.0
@export var FRICTION  = 250.0

func _physics_process(delta: float) -> void:
	match (_state):
		State.IDLE:
			_check_for_player()
			_idle_state(delta)
		State.WANDER:
			_check_for_player()
			_wander_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.FREEZE:
			pass
			
## Set velocity to move toward Vector2.ZERO by FRICTION.
func _idle_state(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if (_wander_cntrl.is_timer_stopped()):
		_update_state_and_wander()
	move_and_slide()
	
## Accelerate towards _wander_cntrl's target position until reaching it.
func _wander_state(delta: float) -> void:
	if (_wander_cntrl.is_timer_stopped()):
		_update_state_and_wander()
	var target_pos: Vector2 = _wander_cntrl.get_target_pos()
	_accelerate_towards_point(target_pos, delta)
	_smooth_rotate((target_pos - global_position).angle())
	
	# When reaching target_pos...
	if (global_position.distance_to(target_pos) <= 4.0):
		_update_state_and_wander()
	move_and_slide()
	
## Accelerate towards the player as long as the player is within the detection zone.
func _chase_state(delta: float) -> void:
	var player = _player_detection.get_player_body()
	if (player != null):
		var target_pos: Vector2 = player.global_position
		_accelerate_towards_point(target_pos, delta)
		_smooth_rotate((target_pos - global_position).angle())
		move_and_slide()
	else:
		_state = State.IDLE

## Set velocity to move toward given point at MAX_SPEED by ACCELERATION
func _accelerate_towards_point(point: Vector2, delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	
func _smooth_rotate(angle: float) -> void:
	var anim: Tween = create_tween()
	var anim_time: float = 1.1
	anim.tween_property(self, "rotation", angle, anim_time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
## Returns a random state in given Array. 
func _get_random_state(state_list: Array[State]) -> State:
	state_list.shuffle()
	return state_list.pop_front()
	
## Pick random state between IDLE and WANDER and set _wander_cntrl timer.
func _update_state_and_wander() -> void:
	_state = _get_random_state([State.IDLE, State.WANDER])
	_wander_cntrl.set_wander_timer(randi_range(1, 5))
	
## If player is within detection zone, set _state to State.CHASE
func _check_for_player() -> void:
	if (_player_detection.is_player_detected()):
		_state = State.CHASE
