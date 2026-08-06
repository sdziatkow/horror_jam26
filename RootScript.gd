extends Node

enum GAME_STATE {ON_ROAD, IN_CAR, IN_ENCOUNTER, MENU}
var state: GAME_STATE
var car_scene: PackedScene = load("res://car/car.tscn")

var _player: Player
var _inv: Inventory

func _ready() -> void:
	state = GAME_STATE.ON_ROAD
	
func _main() -> void:
	pass
	
