class_name WorldLocation
extends Node2D

@export var _camera_areas : Dictionary[String, Area2D]
@export var _top_left_camera_boundaries : Dictionary[String, Marker2D]
@export var _bottom_right_camera_boundaries : Dictionary[String, Marker2D]
@export var _exit_area : Area2D = null

@export var _spawn_point : Marker2D

@export var _CHARACTER_Z_INDEX : int = 1

var _player : Player = null
var _camera : Camera2D = null

signal leave_location


func _ready() -> void:
	for key : String in _camera_areas.keys():
		_camera_areas[key].body_entered.connect(func(body): 
			if body is Player: _reset_camera_boundaries(key))
	if _exit_area: _exit_area.body_entered.connect(func(body):
		if body is Player: emit_signal("leave_location"))

func go_to_location(player : Player, camera : Camera2D) -> void:
	_camera = camera
	_player = player
	add_child(player)
	player.position = _spawn_point.position
	player.z_index = _CHARACTER_Z_INDEX

func _reset_camera_boundaries(area_key : String) -> void:
	_camera.limit_top = _top_left_camera_boundaries[area_key].position.y
	_camera.limit_left = _top_left_camera_boundaries[area_key].position.x
	_camera.limit_bottom = _bottom_right_camera_boundaries[area_key].position.y
	_camera.limit_right = _bottom_right_camera_boundaries[area_key].position.x
