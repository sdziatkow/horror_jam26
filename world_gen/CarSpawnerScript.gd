class_name CarSpawner
extends Node2D

var _car_scene : PackedScene = preload("res://car/car.tscn")

var _spawned_cars : Array[Car]
var _car_pool : Array[Car] 

var _player_clearance : float

var _car_length : float

var _lane_length : int

var _top_lane_y_pos : int

var _bottom_lane_y_pos : int

## SEED SYSTEM
## Seeds -> 0 to 3
## Binary Form is used - 2 bits.
## Bit 1 (leftmost) - Top lane is clear on side
## Bit 2 - Bottom lane is clear on right side 

func _ready() -> void:
	_car_length = _car_scene.instantiate().get_spawn_width()

func set_player_clearance(clearance_px : float) -> void:
	_player_clearance = clearance_px

func set_lane_length(length_px : int) -> void:
	_lane_length = length_px

func set_lane_y_pos(top_lane_y_pos : int, bottom_lane_y_pos : int) -> void:
	_top_lane_y_pos = top_lane_y_pos
	_bottom_lane_y_pos = bottom_lane_y_pos

func spawn(seed : int) -> int:
	## Grabbing the individual bits from the seed
	var top_clearance : bool = seed & 1 != 0
	var bottom_clearance : bool = (seed & (1 << 1))
	return _place_on_line(top_clearance, _top_lane_y_pos, true) + (_place_on_line(bottom_clearance, _bottom_lane_y_pos, false) << 1)
	

func _place_on_line(clearance : bool, y_pos : int, go_right : bool) -> int:
	var next_spawn : int = _car_length / 2  if clearance else _car_length / 2 + _player_clearance
	var final_valid_spawn : int = _lane_length - _car_length / 2
	var last_spawn_pos : int
	
	while next_spawn < final_valid_spawn:
		
		last_spawn_pos = next_spawn + randi_range(0, 300) ## TODO: Make this smarter
		var new_car : Car = _car_scene.instantiate()
		add_child(new_car)
		_spawned_cars.append(new_car)
		if not go_right:
			new_car.rotation = PI
		new_car.position = Vector2(last_spawn_pos, y_pos)
		next_spawn = last_spawn_pos + _player_clearance + _car_length
	if last_spawn_pos < final_valid_spawn - _player_clearance: 
		return 1 
	else: 
		return 0  
	
func despawn() -> void:
	for car : Car in _spawned_cars:
		car.queue_free()
	_spawned_cars.clear()
