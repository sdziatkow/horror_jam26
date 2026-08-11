extends Node

enum GAME_STATE {ON_ROAD, IN_CAR, IN_ENCOUNTER, MENU}
var state: GAME_STATE
var car_scene: PackedScene = load("res://car/car.tscn")

var _inv: Inventory
@onready var _road: Road = $Road
var _player_scene : PackedScene = preload("res://player/Player.tscn")
var _player : Player
var _camera : Camera2D
func _ready() -> void:
	state = GAME_STATE.ON_ROAD

	_player = _player_scene.instantiate()

	_camera = Camera2D.new()
	_player.add_child(_camera)

	_world_setup()

func _main() -> void:
	pass
	
	
func _world_setup() -> void:
		## ROAD / SPAWNING SET-UPS
	_road.give_camera(_camera)
	_road.give_player(_player)
	_road.treadmill_setup()
	_road.start_treadmill()
