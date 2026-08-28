extends Node

@export var _DEBUG_MODE : bool

enum GAME_STATE {ON_ROAD, IN_CAR, IN_ENCOUNTER, MENU}
var state: GAME_STATE

var _inv: Inventory

var _player : Player = preload("res://player/Player.tscn").instantiate()
var _camera : Camera2D = Camera2D.new()
var _world : World = preload("res://world_gen/World.tscn").instantiate()

## Called when game is opened
func _ready() -> void:
	add_child(_world)
	_player.add_child(_camera)
	_main()
	if _DEBUG_MODE: $CanvasLayer.add_child(load("res://debug/CommandConsole.tscn").instantiate())
## Called when player presses "play"
func _main() -> void:
	state = GAME_STATE.ON_ROAD
	_world.setup(_player, _camera)
	_world.go_to_road()
	#_world.go_to_gulag()
