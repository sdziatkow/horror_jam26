class_name World
extends Node2D

var _player : Player = null

var _camera : Camera2D = null

var _road_scene : PackedScene = preload("res://locations/Road.tscn")
var _road : Road

var _gulag_scene : PackedScene = preload("res://locations/Gulag.tscn")
var _gulag : WorldLocation = null

func setup(player : Player, camera : Camera2D) -> void:
	_camera = camera
	_player = player
	
func go_to_road() -> bool:
	if (_player == null or _camera == null):
		return false
	_road = _road_scene.instantiate()
	add_child(_road)
	_road.go_to_location(_player, _camera)
	_road.treadmill_setup()
	_road.start_treadmill()
	return true

func go_to_gulag() -> bool:
	if (_player == null or _camera == null):
		return false
	_gulag = _gulag_scene.instantiate()
	add_child(_gulag)
	_gulag.go_to_location(_player, _camera)
	return true
