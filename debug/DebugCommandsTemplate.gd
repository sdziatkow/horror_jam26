class_name DebugCommandsTemplate
extends RefCounted

var _root_node : Node 

var exposed_functions : Dictionary[String, Callable]

signal log(message : String)

func give_root_node(root : Node) -> void:
	_root_node = root

func get_commands() -> String:
	return ", ".join(exposed_functions.keys())

func _log_to_console(message : String) -> void:
	emit_signal("log", message)
