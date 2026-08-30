class_name EquipDisplay
extends Control

func _ready() -> void:
	for child in $Panel.get_children():
		if (child is Label):
			child.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))


func _input(event: InputEvent):
	if (event.is_action_pressed("swap_weapon")):
		var label: Label = $Panel.get_node(event.as_text())
		label.add_theme_color_override("font_color", Color(0, 1, 0.4))
		for child in $Panel.get_children():
			if (child is Label):
				if (child != label):
					child.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
