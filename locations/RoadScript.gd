class_name Road
extends WorldLocation


## Every tick, decisions about world generation are made 
var _TICK_LEN : float = 1
var _tick_timer : Timer = Timer.new()

## The world is made of segments. Right now, a segment is the size of the road sprite
var _BACK_SEGMENTS : int = 1
var _TOTAL_SEGMENTS : int = 4

var _segment_width : int

## When the move percentage reaches 100 percent (1.00), 
## everything on the map moves back (like things placed on a treadmill)
var _move_percentage : float = 0.0

## Each segment will have it's own zombie spawner and car spawner.
var _zombie_spawner_scene = preload("res://world_gen/ZombieSpawner.tscn")
var _zombie_spawners : Array[ZombieSpawner]

var _car_spawner_scene = preload("res://world_gen/CarSpawner.tscn")
var _car_spawners : Array[CarSpawner]

## Keeps track of what segment needs to be moved to front of treadmill
var _spawner_ind : int = 0

## This is some space on the top and bottom of the map where zombies won't spawn
var _SPAWN_VERTICAL_MARGIN : int = 100


## Seed to generate cars 
var _next_car_seed : int = randi_range(0,3)

func _ready() -> void:
	super._ready()
	## Set up the tick timer
	add_child(_tick_timer)
	_tick_timer.one_shot = false
	_tick_timer.timeout.connect(_tick_process)
	
	##TODO: I use the sprite_size in _treadmill_setup. Maybe refactor later.
	var sprite_size = $Parallax2D/RoadSide.texture.get_size()
	var sprite_pos = $Parallax2D/RoadSide.position
	_segment_width = sprite_size.x
	
	## Setting player movement boundaries 
	$Boundaries/TopCollision.position.y = 0
	$Boundaries/BottomCollision.position.y = sprite_size.y
	$Boundaries/LeftCollision.position.x = -sprite_size.x
	
	## The spawners are reused. Once it reaches the end, it loops around
	## Just like if you painted a dot on a treadmill.
	
	
func treadmill_setup() -> void:
	## Setting up all the spawners
	for i in range(_TOTAL_SEGMENTS):
		var new_zombie_spawner : ZombieSpawner = _zombie_spawner_scene.instantiate()
		add_child(new_zombie_spawner)
		_zombie_spawners.append(new_zombie_spawner)
		
		var new_car_spawner : CarSpawner = _car_spawner_scene.instantiate()
		add_child(new_car_spawner)
		_car_spawners.append(new_car_spawner)
		
		## Set spawn rectangle using width: road size height : road size - 2 * vertical margin 
		var sprite_size = $Parallax2D/RoadSide.texture.get_size()
		new_zombie_spawner.set_spawn_rect(Rect2(0, _SPAWN_VERTICAL_MARGIN, 
			sprite_size.x, sprite_size.y - 2 * _SPAWN_VERTICAL_MARGIN))
		
		## Set spawn lines for car spawner
		new_car_spawner.set_lane_y_pos($TopLane.points[0].y, $BottomLane.points[0].y)
		new_car_spawner.set_lane_length($TopLane.points[1].x - $TopLane.points[0].x)
		new_car_spawner.set_player_clearance(_player.get_spawn_diameter())
		
		## Only spawn condition I made right now, just set it now
		new_zombie_spawner.set_spawn_conditions(ZombieSpawner.SPAWN_MODES.LONE_RANGER, 1)
		new_zombie_spawner.preset_spawn()
		
		_next_car_seed = new_car_spawner.spawn(_next_car_seed)
		
	## Placing spawners
	for i in range (- _BACK_SEGMENTS, _TOTAL_SEGMENTS - _BACK_SEGMENTS):
		_zombie_spawners[i + _BACK_SEGMENTS].position.x = i * _segment_width
		_zombie_spawners[i + _BACK_SEGMENTS].position.y = 0
		
		_car_spawners[i + _BACK_SEGMENTS].position.x = i * _segment_width
		_car_spawners[i + _BACK_SEGMENTS].position.y = 0
	

## Starts the tick timer, generation, world movement, etc.
func start_treadmill() -> void:
	_tick_timer.start(_TICK_LEN)
	
func stop_treadmill() -> void:
	_tick_timer.stop()
	
## Moves all the segments back by one segment length
func _move_treadmill():
	
	## Move the player back
	_player.position.x -= _segment_width
	
	## Move all the spawners back
	for spawner : ZombieSpawner in _zombie_spawners:
		spawner.position.x -= _segment_width
	var end_zombie_spawner = _zombie_spawners[_spawner_ind]
	
	for spawner : CarSpawner in _car_spawners:
		spawner.position.x -= _segment_width
	var end_car_spawner = _car_spawners[_spawner_ind]
	
	##TODO: Refactor this into a function
	end_zombie_spawner.despawn()
	end_zombie_spawner.preset_spawn()
	
	end_car_spawner.despawn()
	_next_car_seed = end_car_spawner.spawn(_next_car_seed)
	
	## Move spawners to end
	var end_segment_pos = (_TOTAL_SEGMENTS - _BACK_SEGMENTS - 1) * _segment_width
	end_zombie_spawner.position.x = end_segment_pos
	end_car_spawner.position.x = end_segment_pos
	
	## Increase spawner by 1 or reset to 0
	_spawner_ind = (_spawner_ind + 1) % _TOTAL_SEGMENTS
	

func _tick_process() -> void:
	## Everything is decided by the player's position
	var pos = _player.global_position.x
	
	## The move percentages are normalized by the tick length. Faster ticks -> less movement
	
	## If you're at the back of the map, decrease the move percentage 10%
	if pos <= -.5 * _segment_width:
		_move_percentage -= .1 * _TICK_LEN
		
	## If you're far into the second segment, or beyond, increase the move percentage 30%
	elif pos >= 1.5 * _segment_width:
		_move_percentage += .3 * _TICK_LEN
	## If you're in the start of the second segment, increase the move percentage 20%
	elif pos >= _segment_width:
		_move_percentage += .2 * _TICK_LEN
	
	## Clamping the percentage at above zero and then deciding if to move back everything
	if _move_percentage < 0:
		_move_percentage = 0
	elif _move_percentage >= 1:
		_move_percentage = 0
		_move_treadmill()
