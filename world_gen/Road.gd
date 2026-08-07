class_name Road
extends Node2D


var _player : Player

var _TICK_LEN : float = 1

var _tick_timer : Timer = Timer.new()

var _road_width : int

var _move_weight : float = 0

func _ready() -> void:
	add_child(_tick_timer)
	_tick_timer.one_shot = false
	_tick_timer.timeout.connect(_tick_process)
	_road_width = $Parallax2D/RoadSprite.texture.get_width()
	$LeftBoundary.position.x = -_road_width

func give_camera(camera : Camera2D) -> void:
	camera.limit_top = $UpperBoundary.position.y
	camera.limit_bottom = $LowerBoundary.position.y
	camera.limit_left = -_road_width


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
	
	if pos <= -.5 * _road_width:
		_move_weight -= .1
		
	elif pos >= 1.5 * _road_width:
		_move_weight += .3
	elif pos >= _road_width:
		_move_weight += .2
	
	if _move_weight < 0:
		_move_weight = 0
	elif _move_weight >= 1:
		_move_weight = 0
		_move_back()

func _move_back():
	for node in get_children():
		if node is Player:
			node.position.x -= _road_width
