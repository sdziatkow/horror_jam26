class_name Ammo
extends Item

## The type of gun this ammo works with.
var ammo_type: ItemEnums.AmmoType

func _init(type: ItemEnums.AmmoType, name: String, amnt: int, power: float) -> void:
	super(ItemEnums.ItemType.AMMO, name, amnt, power)
	ammo_type = type

#DISPLAY-------------------------------------------------------------------------
func _set_disp_info() -> void:
	_disp_info["Held Amount"] = str(get_amnt())
	_disp_info["Damage"] = "%.2f" % get_power()
		
func disp_info() -> Dictionary[String, String]:
	_set_disp_info()
	return _disp_info
