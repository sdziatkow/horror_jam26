class_name Road
extends Node2D






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

## Each segment will have it's own zombie spawner.
var _zombie_spawner_scene = preload("res://world_gen/ZombieSpawner.tscn")
var _zombie_spawners : Array[ZombieSpawner]

## This is some space on the top and bottom of the map where zombies won't spawn
var _SPAWN_VERTICAL_MARGIN : int = 100

## The world needs to move the player back periodically
var _player : Player



func _ready() -> void:
	
	## Set up the tick timer
	add_child(_tick_timer)
	_tick_timer.one_shot = false
	_tick_timer.timeout.connect(_tick_process)
	
	##TODO: I use the sprite_size in _treadmill_setup. Maybe refactor later.
	var sprite_size = $Parallax2D/RoadSprite.texture.get_size()
	var sprite_pos = $Parallax2D/RoadSprite.position
	_segment_width = sprite_size.x
	
	##Setting player movement boundaries 
	$UpperBoundary.position.y = 0
	$LowerBoundary.position.y = sprite_size.y
	$LeftBoundary.position.x = -sprite_size.x
	
	## The spawners are reused. Once it reaches the end, it loops around
	## Just like if you painted a dot on a treadmill.
	_treadmill_setup()
	
func _treadmill_setup() -> void:
	## Setting up all the spawners
	for i in range(_TOTAL_SEGMENTS):
		var new_spawner : ZombieSpawner = _zombie_spawner_scene.instantiate()
		add_child(new_spawner)
		_zombie_spawners.append(new_spawner)
		
		## Set spawn rectangle using width: road size height : road size - 2 * vertical margin 
		var sprite_size = $Parallax2D/RoadSprite.texture.get_size()
		new_spawner.set_spawn_rect(Rect2(0, _SPAWN_VERTICAL_MARGIN, 
			sprite_size.x, sprite_size.y - 2 * _SPAWN_VERTICAL_MARGIN))
		
		## Only spawn condition I made right now, just set it now
		new_spawner.set_spawn_conditions(ZombieSpawner.SPAWN_MODES.LONE_RANGER, 1)
		new_spawner.preset_spawn()
		
	## Placing spawners
	for i in range (- _BACK_SEGMENTS, _TOTAL_SEGMENTS - _BACK_SEGMENTS):
		_zombie_spawners[i + _BACK_SEGMENTS].position.x = - i * _segment_width
		_zombie_spawners[i + _BACK_SEGMENTS].position.y = 0
	

func give_camera(camera : Camera2D) -> void:
	## setting the camera boundaries equal to the player movement boundaires.
	## Might have to refactor this later if we add decorations around the map.
	camera.limit_top = $UpperBoundary.position.y
	camera.limit_bottom = $LowerBoundary.position.y
	camera.limit_left = -_segment_width

##TODO: I don't want the world to own the player
func give_player(player : Player) -> void:
	add_child(player)
	_player = player
	_player.position = Vector2(200, 200)

## Starts the tick timer, generation, world movement, etc.
func start_treadmill() -> void:
	_tick_timer.start(_TICK_LEN)
	
func stop_treadmill() -> void:
	_tick_timer.stop()
	
## This is the big one
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
	
	## Clamping the value at zero and then deciding if to move back everything
	if _move_percentage < 0:
		_move_percentage = 0
	elif _move_percentage >= 1:
		_move_percentage = 0
		_move_back()

## Moves all the segments back by one segment length
func _move_back():
	for node in get_children():
		if node is Player or node is ZombieSpawner:
			node.position.x -= _segment_width
