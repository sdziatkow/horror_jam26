extends Node

enum GAME_STATE {ON_ROAD, IN_CAR, IN_ENCOUNTER, MENU}
var state: GAME_STATE

var _inv: Inventory
@onready var _road: Road = $Road
var _player_scene : PackedScene = preload("res://player/Player.tscn")

func _ready() -> void:
	state = GAME_STATE.ON_ROAD


	var player = _player_scene.instantiate()
	var camera = Camera2D.new()
	player.add_child(camera)

	## ROAD / SPAWNING SET-UPS
	_road.give_camera(camera)
	_road.give_player(player)
	_road.start_treadmill()

func _main() -> void:
	pass
