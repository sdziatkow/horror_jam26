class_name EquipSlots
extends RefCounted

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
	
func equip(item: Item) -> void:
	item.toggle_equipped(true)
	if (item is Weapon):
		if (weapons[item.ammo_type] != null):
			weapons[item.ammo_type].toggle_equipped(false)
		weapons[item.ammo_type] = item
	elif (item is Ammo):
		if (ammos[item.ammo_type] != null):
			ammos[item.ammo_type].toggle_equipped(false)
		ammos[item.ammo_type] = item
	elif (item is Healer):
		if (healers[item.heal_type] != null):
			healers[item.heal_type].toggle_equipped(false)
		healers[item.heal_type] = item
		
func has_ammo() -> bool:
	if (ammos[held_weapon] == null): return false
	if (ammos[held_weapon].get_amnt() < 1): return false
	return true
