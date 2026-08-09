class_name ZombieSpawner
extends Node2D

enum SPAWN_MODES {VERTICAL_NORMAL, HORIZONTAL_NORMAL, CENTER_NORMAL, UNIFORM, LONE_RANGER}

var _spawned_zombies : Array[Zombie]
var _zombie_pool : Array[Zombie] 

var _preset_spawn_mode : SPAWN_MODES 
var _preset_spawn_count_goal : int
var _preset_normal_deviation : float

var _spawn_rect : Rect2 


func set_spawn_rect(rect : Rect2) -> void:
	_spawn_rect = rect

func custom_spawn(spawn_mode : SPAWN_MODES, spawn_count_goal : int, normal_deviation : int = 0) -> bool:
	## TODO: check parameters 
	return true
	
func preset_spawn() -> void:
	pass
	
func set_spawn_conditions(spawn_mode : SPAWN_MODES, spawn_count_goal : int, normal_deviation : int = 0) -> bool:
	## TODO: check parameters 
	_preset_spawn_mode = spawn_mode 
	_preset_spawn_count_goal = spawn_count_goal
	_preset_normal_deviation = normal_deviation
	return true

func despawn() -> void:
	for zombie : Zombie in _spawned_zombies:
		zombie.queue_free()
		##TODO: Don't delete zombie
		## remove from tree, reset, and add back to pool array
		## Need a zombie reset function in Zombie from Sean
