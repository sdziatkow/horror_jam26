class_name Bullet
extends Area2D

@export var SPEED: float = 1500.0
var _travel_vector: Vector2 = Vector2.ZERO
var _origin: Vector2 = Vector2.ZERO

## The angle at which the bullet will travel. MUST BE SET BEFORE ADDING TO SCENE.
func set_travel_vector(v: Vector2) -> void:
	_travel_vector = v
	global_rotation = _travel_vector.angle()
	
## The original global_position of the bullet. MUST BE SET BEFORE ADDING TO SCENE.
func set_origin(v: Vector2) -> void:
	_origin = v
	global_position = _origin
	
func _physics_process(delta: float) -> void:
	global_position += (_travel_vector * SPEED * delta)
	if (global_position.distance_to(_origin) >= 1000.0):
		queue_free()
