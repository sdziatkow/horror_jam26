extends Node2D

class_name Car

func _ready() -> void:
	$Button.visible = false
	
	var area = $StaticBody2D/Area2D
	
#	turn search button on when player walks into car area
	area.body_entered.connect(func(_body): 
		if _body is Player:
			$Button.visible = true)
		
#	turn search button off when player walks out of car area
	area.body_exited.connect(func(_body):
		if _body is Player:
			$Button.visible = false)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	print("player searched car")
