class_name Healer
extends Item

## The type of stat this item will heal.
var heal_type: ItemEnums.HealType

func _init(type: ItemEnums.HealType, name: String, amnt: int, power: float) -> void:
	super(ItemEnums.ItemType.HEALER, name, amnt, power)
	heal_type = type
