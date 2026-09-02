class_name Healer
extends Item

signal used(power: float)

## The type of stat this item will heal.
var heal_type: ItemEnums.HealType

func _init(type: ItemEnums.HealType, name: String, amnt: int, power: float) -> void:
	super(ItemEnums.ItemType.HEALER, name, amnt, power)
	heal_type = type
	
func use() -> void:
	used.emit(get_power())
	dec_amnt(1)
	print(get_amnt())
