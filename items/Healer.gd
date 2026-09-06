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
	
#DISPLAY-------------------------------------------------------------------------
func _set_disp_info() -> void:
	_disp_info["Held Amount"] = str(get_amnt())
	var new_key: String = "[" + ItemEnums.HealType.find_key(heal_type) + "]Healing Power"
	_disp_info[new_key] = "%.2f" % get_power()
		
func disp_info() -> Dictionary[String, String]:
	_set_disp_info()
	return _disp_info
