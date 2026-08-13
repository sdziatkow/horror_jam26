class_name ZombieSpawner
extends Node2D

## Need to understand normal and uniform distributions to understand the spawn modes
## Vertical_normal -> spawns uniformally in the x direction, normally in the y direction
## Horizontal_normal -> spawns normally in the y direction, uniformally in the y direction
## Center normal -> spawns normally in both directions
## Uniform -> spawns uniformally in both directions
## Lone ranger -> spawns a single zombie
enum SPAWN_MODES {VERTICAL_NORMAL, HORIZONTAL_NORMAL, CENTER_NORMAL, UNIFORM, LONE_RANGER}


var _spawned_zombies : Array[Zombie]
var _zombie_pool : Array[Zombie] 
var _zombie_scene : PackedScene = preload("res://enemies/Zombie.tscn")

## The normal distribution's standard deviation is changed with a floating point number 0 - 1 (1 being most deviation)
var _preset_spawn_mode : SPAWN_MODES 
var _preset_spawn_count_goal : int
var _preset_normal_deviation : float

## Spawn rectangle where zombies are allowed to spawn. They can move out of this area after being spawned.
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
				_spawn_rect.position.y + randi_range(0, _spawn_rect.size.y))
		 
	
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
		zombie.queue_free()
		##TODO: Don't delete zombie
		## remove from tree, reset, and add back to pool array
		## Need a zombie reset function in Zombie from Sean
	_spawned_zombies.clear()
