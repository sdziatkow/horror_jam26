class_name EquipDisplay
extends Control

var _eq_slots: EquipSlots = null
func give_eq_slots(eq_slots: EquipSlots) -> void:
	_eq_slots = eq_slots
	_eq_slots.weapon_swapped.connect(_on_wpn_swapped)
	_eq_slots.gun_equipped.connect(change_gun)
	_eq_slots.ammo_equipped.connect(change_ammo)
	_eq_slots.healer_equipped.connect(change_healer)
	_eq_slots.no_healer.connect(hide_healer)

func _ready() -> void:
	for child in $Panel.get_children():
		if (child is Label and child.name.length() < 2):
			child.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

#WEAPON-SWAPPING-----------------------------------------------------------------

## Change the color of the newly equippled weapon.
func _on_wpn_swapped(wpn: Weapon, ammo: Ammo) -> void:
	var disp_num: int = wpn.ammo_type + 1
	var label: Label = $Panel.get_node(str(disp_num))
	label.add_theme_color_override("font_color", Color(0, 1, 0.4))
	for child in $Panel.get_children():
		if (child is Label and child.name.length() < 2):
			if (child != label):
				child.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	if (disp_num == 1): # Meelee
		hide_gun_ammo()
		hide_eq_ammo()
	else:
		change_gun(wpn)
		if (ammo != null): 
			change_ammo(ammo)
			show_eq_ammo()
		show_gun_ammo()

func change_gun(gun: Weapon):
	if (gun.ammo_type == _eq_slots.held_weapon):
		if (not gun.ammo_changed.is_connected(update_gun_ammo)):
			gun.ammo_changed.connect(update_gun_ammo)
			gun.on_loading.connect(update_eq_ammo)
		update_gun_ammo(gun.get_curr_ammo(), gun.get_capacity())
		
func show_gun_ammo() -> void:
	$Panel/AmmoLoaded.show()
	$Panel/AMMO.show()
func hide_gun_ammo() -> void:
	$Panel/AmmoLoaded.hide()
	$Panel/AMMO.hide()
func update_gun_ammo(new_amnt: int, capacity: int) -> void:
	$Panel/AmmoLoaded.text = str(new_amnt) + " / " + str(capacity)

#HEALER-DISPLAY------------------------------------------------------------------

func change_healer(healer: Healer) -> void:
	if (healer.heal_type == ItemEnums.HealType.HP):
		$Panel/HP.show()
	else:
		$Panel/SP.show()
		
func hide_healer(type: ItemEnums.HealType) -> void:
	if (type == ItemEnums.HealType.HP):
		$Panel/HP.hide()
	else:
		$Panel/SP.hide()
		
#AMMO-DISPLAY--------------------------------------------------------------------

func change_ammo(ammo: Ammo):
	if (ammo.ammo_type == _eq_slots.held_weapon):
		update_eq_ammo(ammo.get_amnt())
		show_eq_ammo()
func show_eq_ammo() -> void:
	$Panel/AmmoEquipped.show()
	$Panel/AmmoStored.show()
func hide_eq_ammo() -> void:
	$Panel/AmmoEquipped.hide()
	$Panel/AmmoStored.hide()
func update_eq_ammo(new_amnt: int) -> void:
	if (new_amnt < 1):
		$Panel/AmmoEquipped.text = ""
		hide_eq_ammo()
	$Panel/AmmoEquipped.text = str(new_amnt)
