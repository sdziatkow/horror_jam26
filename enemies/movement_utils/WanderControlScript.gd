class_name WanderControl
extends Node2D

@export var WANDER_RANGE: int = 50

@onready var _timer = $Timer

var _start_pos: Vector2
var _target_pos: Vector2

func _ready() -> void:
	
	# global_position is the position of this node's parent node.
	_start_pos = global_position
	_target_pos = global_position
	_timer.timeout.connect(_on_timer_timeout)
	
#POSITION-HANDLING---------------------------------------------------------------

## The position to move to. Updated when _timer is timed out.
func get_target_pos() -> Vector2: return _target_pos

## Set target_pos to a random value within WANDER_RANGE
func _update_target_pos() -> void:
	var new_pos: Vector2 = Vector2(_rand_val_within_range(), _rand_val_within_range())
	_target_pos = _start_pos + new_pos
	
## Returns a random number between [-WANDER_RANGE, WANDER_RANGE]
func _rand_val_within_range() -> int:
	return randi_range(-WANDER_RANGE, WANDER_RANGE)

#TIMER---------------------------------------------------------------------------

## Starts the timer with given duration.
func set_wander_timer(duration: int) -> void:
	_timer.start(duration)
	
func get_time_left() -> float:
	return _timer.time_left
	
func is_timer_stopped() -> bool:
	return _timer.is_stopped()
	
## Updates the target pos.
func _on_timer_timeout() -> void:
	_update_target_pos()
