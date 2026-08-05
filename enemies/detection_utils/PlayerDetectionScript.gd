class_name PlayerDetection
extends Area2D

var _player_body: CharacterBody2D

func _ready() -> void:
	_player_body = null
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: CharacterBody2D) -> void:
	_player_body = body
func _on_body_exited(body: CharacterBody2D) -> void:
	_player_body = null
	
## Returns true if the player is within the detection zone.
func is_player_detected() -> bool:
	return _player_body != null
	
## Returns the player's CharacterBody2D if within zone. Otherwise will be null.
func get_player_body() -> CharacterBody2D:
	return _player_body
