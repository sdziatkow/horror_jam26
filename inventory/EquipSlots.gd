class_name EquipSlots
extends RefCounted

signal update_meelee_dmg(dmg: float)
signal weapon_swapped(weapon: Weapon, ammo: Ammo)
signal gun_equipped(new_gun: Weapon)
signal ammo_equipped(new_ammo: Ammo)
signal healer_equipped(new_healer: Healer)
signal no_healer(heal_type: ItemEnums.HealType)

var weapons: Dictionary[ItemEnums.AmmoType, Weapon] = {
	ItemEnums.AmmoType.MEELEE : null,
	ItemEnums.AmmoType.HANDGUN : null,
	ItemEnums.AmmoType.RIFLE : null,
	ItemEnums.AmmoType.SHOTGUN : null
}

var ammos: Dictionary[ItemEnums.AmmoType, Ammo] = {
	ItemEnums.AmmoType.MEELEE : null,
	ItemEnums.AmmoType.HANDGUN : null,
	ItemEnums.AmmoType.RIFLE : null,
	ItemEnums.AmmoType.SHOTGUN : null
}
var healers: Dictionary[ItemEnums.HealType, Healer] = {
	ItemEnums.HealType.HP : null,
	ItemEnums.HealType.SP : null
}

var held_weapon: ItemEnums.AmmoType = ItemEnums.AmmoType.MEELEE

func swap_weapon(type: ItemEnums.AmmoType) -> void:
	held_weapon = type
	weapon_swapped.emit(weapons[held_weapon], ammos[held_weapon])
	
func equip(item: Item) -> void:
	item.toggle_equipped(true)
	if (item is Weapon):
		if (weapons[item.ammo_type] != null):
			weapons[item.ammo_type].toggle_equipped(false)
		weapons[item.ammo_type] = item
		if (item.ammo_type == ItemEnums.AmmoType.MEELEE):
			update_meelee_dmg.emit(item.get_power())
		else:
			gun_equipped.emit(item)
	elif (item is Ammo):
		if (ammos[item.ammo_type] != null):
			ammos[item.ammo_type].toggle_equipped(false)
		ammos[item.ammo_type] = item
		ammo_equipped.emit(item)
	elif (item is Healer):
		if (healers[item.heal_type] != null):
			healers[item.heal_type].toggle_equipped(false)
		healers[item.heal_type] = item
		healer_equipped.emit(item)
	
func has_ammo() -> bool:
	if (ammos[held_weapon] == null): return false
	if (ammos[held_weapon].get_amnt() < 1): return false
	return true
