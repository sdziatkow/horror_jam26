class_name Ammo
extends Item

## The type of gun this ammo works with.
var ammo_type: ItemEnums.AmmoType

func _init(type: ItemEnums.AmmoType, name: String, amnt: int, power: float) -> void:
	super(ItemEnums.ItemType.AMMO, name, amnt, power)
