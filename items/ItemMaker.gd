class_name ItemMaker
extends RefCounted

static func make_weapon(type: ItemEnums.AmmoType, name: String, power: float, capacity: int) -> Weapon:
	var wpn = Weapon.new(type, name, 1, power, capacity)
	return wpn
	
static func make_ammo(type: ItemEnums.AmmoType, name: String, amnt: int, damage: float) -> Ammo:
	var ammo: Ammo = Ammo.new(type, name, amnt, damage)
	return ammo
	
static func make_healer(type: ItemEnums.HealType, name: String, amnt: int, power: float) -> Healer:
	var healer: Healer = Healer.new(type, name, amnt, power)
	return healer

#RAND-GEN------------------------------------------------------------------------
enum GunType {HANDGUN, RIFLE, SHOTGUN}
static var sizes: Dictionary[String, int] = {
	"Big" : 75,
	"Medium": 45,
	"Small": 15
}

static var damages: Dictionary[String, float] = {
	"massacre": 50.0,
	"security": 30.0,
	"old": 15.0
}

static var heals: Dictionary[String, float] = {
	"sanctuary": 85.0,
	"life": 50.0,
	"regeneration": 20.0 
}

static func rand_item(type: ItemEnums.ItemType) -> Item:
	var item: Item
	var sub_type: String
	var power_mod: String
	var size: String = sizes.keys().pick_random()
	var name: String
	var amnt: int
	var power: float
	match (type):
		ItemEnums.ItemType.HEALER:
			sub_type = ItemEnums.HealType.keys().pick_random()
			power_mod = heals.keys().pick_random()
			power = randi_range(heals[power_mod], heals[power_mod] + 5) * (randf() + 1.0)
		ItemEnums.ItemType.AMMO, ItemEnums.ItemType.WEAPON:
			if (type == ItemEnums.ItemType.WEAPON):
				sub_type = ItemEnums.AmmoType.keys().pick_random()
			else:
				sub_type = GunType.keys().pick_random()
			power_mod = damages.keys().pick_random()
			power = randi_range(damages[power_mod], damages[power_mod] + 5) * (randf() + 1.0)
	name = size + " " + sub_type + " " + ItemEnums.ItemType.find_key(type) + " of " + power_mod
	
	match (type):
		ItemEnums.ItemType.HEALER:
			amnt = randi_range(1, 4)
			item = Healer.new(ItemEnums.HealType[sub_type], name, amnt, power)
		ItemEnums.ItemType.AMMO:
			amnt = randi_range(sizes[size], sizes[size] + 25)
			item = Ammo.new(ItemEnums.AmmoType[sub_type], name, amnt, power)
		ItemEnums.ItemType.WEAPON:
			amnt = randi_range(sizes[size] - 6, sizes[size])
			item = Weapon.new(ItemEnums.AmmoType[sub_type], name, 1, power, amnt)
	return item
