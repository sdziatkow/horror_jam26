extends Node2D

class_name Car
signal car_select


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StaticBody2D/Area2D.body_entered.connect(func(player):print("body entered", player))
	emit_signal("car_select")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
