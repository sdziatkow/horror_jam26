class_name WorldCommands
extends DebugCommandsTemplate


func _init() -> void:
	exposed_functions["countzombies"] = _count_zombies
	
	
func _count_zombies() -> void:
	var count = 0
	for node in _root_node.find_children("*", "Zombie", true, false):
		count += 1
	_log_to_console("Total number of zombies loaded: " + str(count))
	
