class_name Zombie
extends CharacterBody2D

enum State {IDLE, WANDER, CHASE, ATTACK, FREEZE}
var _state: State

@onready var _anim_state: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var _wander_cntrl: WanderControl = $WanderControl
@onready var _player_detection: PlayerDetection = $PlayerDetection
var hp: StatVal = StatVal.new(StatVal.StatType.HEALTH, 50.0, 50.0)

func _ready() -> void:
	_anim_state.travel("meelee_idle")
	$HurtBox.taking_damage.connect(hp.dec)
	#hp.on_empty.connect(queue_free)
	$MeeleePivot/MeeleeHitBox.set_dmg(25.0)

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
		State.ATTACK:
			_attk_state(delta)
		State.FREEZE:
			pass
			
## Set velocity to move toward Vector2.ZERO by FRICTION.
func _idle_state(delta: float) -> void:
	_anim_state.travel("meelee_idle")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if (_wander_cntrl.is_timer_stopped()):
		_update_state_and_wander()
	move_and_slide()
	
## Accelerate towards _wander_cntrl's target position until reaching it.
func _wander_state(delta: float) -> void:
	_anim_state.travel("meelee_walk")
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
	_anim_state.travel("meelee_walk")
	var player = _player_detection.get_player_body()
	if (player != null):
		var target_pos: Vector2 = player.global_position
		var is_at_player: bool = (global_position.distance_to(target_pos) <= 120.0)
		if (is_at_player):
			_smooth_rotate((target_pos - global_position).angle(), 0.5)
			_state = State.ATTACK
		else:
			_accelerate_towards_point(target_pos, delta)
			_smooth_rotate((target_pos - global_position).angle())
			move_and_slide()
	else:
		_state = State.IDLE

## Set velocity to move toward given point at MAX_SPEED by ACCELERATION
func _accelerate_towards_point(point: Vector2, delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	
func _smooth_rotate(angle: float, time: float = 0.5) -> void:
	var anim: Tween = create_tween()
	anim.tween_property(self, "global_rotation", angle, time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
## Pick random state between IDLE and WANDER and set _wander_cntrl timer.
func _update_state_and_wander() -> void:
	_state = [State.IDLE, State.WANDER].pick_random()
	_wander_cntrl.set_wander_timer(randi_range(1, 5))
	
## If player is within detection zone, set _state to State.CHASE
func _check_for_player() -> void:
	if (_player_detection.is_player_detected()):
		_state = State.CHASE
		
#ATTACKING-----------------------------------------------------------------------

func _attk_state(delta: float) -> void:
	_anim_state.travel("meelee_attk")
	velocity = Vector2.ZERO
	
func _on_attk_finished() -> void:
	_state = State.IDLE
	
#UTIL----------------------------------------------------------------------------

func reset() -> void:
	_state = State.IDLE
	hp.fill()
