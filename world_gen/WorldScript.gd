class_name World
extends Node2D

var _player : Player = null

var _camera : Camera2D = null

var _road : Road = preload("res://world_gen/Road.tscn").instantiate()

func _ready() -> void:
	add_child(_road)

func give_camera(camera : Camera2D) -> void:
	_camera = camera

func give_player(player : Player) -> void:
	_player = player
	
func go_to_road() -> bool:
	if (_player == null or _camera == null):
		return false
	_road.give_camera(_camera)
	_road.give_player(_player)
	_road.treadmill_setup()
	_road.start_treadmill()

	return true
