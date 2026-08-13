class_name PlayerCommands
extends DebugCommandsTemplate

func _init() -> void:
	exposed_functions["doubletime"] = _double_speed
	exposed_functions["halftime"] = _half_speed

func _double_speed() -> void:
	for node in _root_node.find_children("*", "Player", true, false):
		node.SPRINT_SPEED = node.SPRINT_SPEED * 2
		node.WALK_SPEED = node.WALK_SPEED * 2
		_log_to_console("Player speed has been doubled.")

func _half_speed() -> void:
	for node in _root_node.find_children("*", "Player", true, false):
		node.SPRINT_SPEED = node.SPRINT_SPEED / 2
		node.WALK_SPEED = node.WALK_SPEED / 2
		_log_to_console("Player speed has been halved.")
