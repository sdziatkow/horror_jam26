class_name Road
extends Node2D


var _player : Player

var _zombie_spawners : Array[ZombieSpawner]

var _TICK_LEN : float = 1
var _BACK_SEGMENTS : int = 1
var _TOTAL_SEGMENTS : int = 4

var _tick_timer : Timer = Timer.new()

var _segment_width : int

var _move_weight : float = 0

func _ready() -> void:
	
	add_child(_tick_timer)
	_tick_timer.one_shot = false
	_tick_timer.timeout.connect(_tick_process)
	
	_segment_width = $Parallax2D/RoadSprite.texture.get_width()
	
	$LeftBoundary.position.x = -_segment_width


func _treadmill_setup() -> void:
	for i in range(_TOTAL_SEGMENTS):
		var new_spawner = ZombieSpawner.new()
		new_spawner.set_spawn_rect($Parallax2D/RoadSprite.get_rect())
		new_spawner.set_spawn_conditions(ZombieSpawner.SPAWN_MODES.LONE_RANGER, 1)
		_zombie_spawners.append(new_spawner)
	

func give_camera(camera : Camera2D) -> void:
	camera.limit_top = $UpperBoundary.position.y
	camera.limit_bottom = $LowerBoundary.position.y
	camera.limit_left = -_segment_width


func give_player(player : Player) -> void:
	add_child(player)
	_player = player
	_player.position = Vector2(200, 200)

func start_treadmill() -> void:
	_tick_timer.start(_TICK_LEN)
	
func stop_treadmill() -> void:
	_tick_timer.stop()
	
func _tick_process() -> void:
	var pos = _player.global_position.x
	
	if pos <= -.5 * _segment_width:
		_move_weight -= .1
		
	elif pos >= 1.5 * _segment_width:
		_move_weight += .3
	elif pos >= _segment_width:
		_move_weight += .2
	
	if _move_weight < 0:
		_move_weight = 0
	elif _move_weight >= 1:
		_move_weight = 0
		_move_back()

func _move_back():
	for node in get_children():
		if node is Player:
			node.position.x -= _segment_width
