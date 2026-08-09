class_name ZombieSpawner
extends Node2D

enum SPAWN_MODES {VERTICAL_NORMAL, HORIZONTAL_NORMAL, CENTER_NORMAL, UNIFORM, LONE_RANGER}

var _spawned_zombies : Array[Zombie]
var _zombie_pool : Array[Zombie] 
var _zombie_scene : PackedScene = preload("res://enemies/Zombie.tscn")

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
	match _preset_spawn_mode:
		SPAWN_MODES.LONE_RANGER:
			_spawn_one(_spawn_rect.position.x + randi_range(0, _spawn_rect.size.x), 
				_spawn_rect.position.y + randi_range(0, _spawn_rect.size.x))
		 
	
func set_spawn_conditions(spawn_mode : SPAWN_MODES, spawn_count_goal : int, normal_deviation : int = 0) -> bool:
	## TODO: check parameters 
	_preset_spawn_mode = spawn_mode 
	_preset_spawn_count_goal = spawn_count_goal
	_preset_normal_deviation = normal_deviation
	return true

func _spawn_one(x_pos_px : int, y_pos_px) -> void:
	var new_zombie : Zombie = _zombie_scene.instantiate()
	add_child(new_zombie)
	new_zombie.z_index = 1
	new_zombie.position = Vector2( x_pos_px, y_pos_px)
	_spawned_zombies.append(new_zombie)

func despawn() -> void:
	for zombie : Zombie in _spawned_zombies:
		_spawned_zombies.erase(zombie)
		zombie.queue_free()
		##TODO: Don't delete zombie
		## remove from tree, reset, and add back to pool array
		## Need a zombie reset function in Zombie from Sean
