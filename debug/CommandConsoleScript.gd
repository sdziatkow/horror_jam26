class_name CommandConsole
extends Control

var _PASSWORD : String = "automagic"

var _command_scripts : Dictionary[String, DebugCommandsTemplate] = {
	"player" : PlayerCommands.new()}


@onready var _output_text_edit : TextEdit = $Output
@onready var _input_line_edit : LineEdit = $CommandLine

var _editing : bool = false

func _ready() -> void:
	visible = false
	for script : DebugCommandsTemplate in _command_scripts.values():
		script.give_root_node(get_tree().root)
		script.log.connect(_log_to_console)
	$CommandLine.editing_toggled.connect(_on_edit_toggle)
	$ClearButton.pressed.connect(func(): $Output.text = '')
	$ExitButton.pressed.connect(func(): 
		$CommandLine.release_focus()
		visible = false)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("debug_key") and Input.is_key_pressed(KEY_ALT) and Input.is_key_pressed(KEY_CTRL):
			$CommandLine.release_focus()
			visible = not visible
		if _editing:
			if event.keycode == KEY_ENTER:
				_on_command_input()
	
func _on_edit_toggle(editing : bool) -> void:
	_editing = editing

func _on_command_input() -> void:
	var text = _input_line_edit.text
	if text.length() == 0: return
	var res : Dictionary = _process_command(text)
	if not res["valid"]:
		_error_to_console(res["message"])

func _process_command(command_str : String) -> Dictionary:
	var command_arr : PackedStringArray = command_str.to_lower().split(" ", false)
	
	if command_arr.size() != 3 or command_arr[0] == "help":
		return {"valid": false, "message" : "Command format is \"password script function\""}
	
	if command_arr[0] != _PASSWORD:
		return {"valid": false, "message": "Incorrect password"}
	
	if not _command_scripts.has(command_arr[1]):
		return {"valid": false, "message": "Unrecognized debug script"}
	if command_arr[2] == "help":
		_log_to_console(_command_scripts[command_arr[1]].get_commands())
		return {"valid" : true, "message" : ""}
		
	if not _command_scripts[command_arr[1]].exposed_functions.has(command_arr[2]):
		return {"valid": false, "message": "Unrecognized debug command"}

	_command_scripts[command_arr[1]].exposed_functions[command_arr[2]].call()

	return {"valid" : true, "message" : ""}

func _error_to_console(message : String) -> void:
	_output_text_edit.text += message + '\n'
	
func _log_to_console(message : String) -> void:
	_output_text_edit.text += message + '\n'
