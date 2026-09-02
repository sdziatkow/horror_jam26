# abstract class Item
@abstract
class_name Item
extends RefCounted

## When amount is less than 1.
signal on_empty(i: Item)

## The type of item this is. [HEALER, AMMO, WEAPON]
var item_type: ItemEnums.ItemType
var _name: String
var _amnt: int
var _power: float
var _equipped: bool

func _init(type: ItemEnums.ItemType, name: String, amnt: int, power: float) -> void:
	item_type = type
	set_name(name)
	set_amnt(amnt)
	set_power(power)
	toggle_equipped(false)
	
#SETTERS-------------------------------------------------------------------------

func set_name(name: String) -> void:
	_name = name
	
## The amount of this item being held.
func set_amnt(amnt: int) -> void:
	_amnt = amnt
	if (is_empty()):
		_amnt = 0
	
## The healing or damage power of this item.
func set_power(power: float) -> void:
	_power = power
	
func toggle_equipped(b: bool) -> void:
	_equipped = b

#GETTERS-------------------------------------------------------------------------

func get_name() -> String:
	return _name
	
## The amount of this item being held.
func get_amnt() -> int:
	return _amnt
	
## The healing or damage power of this item.
func get_power() -> float:
	return _power
	
#FLAGS---------------------------------------------------------------------------
func is_equipped() -> bool:
	return _equipped
func is_empty() -> bool:
	return (_amnt < 1)
	
#OPERATIONS----------------------------------------------------------------------

func inc_amnt(val: int) -> void:
	_amnt += val
	
func dec_amnt(val: int) -> void:
	_amnt -= val
	if (is_empty()):
		on_empty.emit(self)
		_amnt = 0
		
func _to_string() -> String:
	var out: String = ""
	out += "Name: " + get_name() +"|Amount: " + str(get_amnt()) + "|"
	out += "Power: " + "%.2f" % get_power()
	return out
