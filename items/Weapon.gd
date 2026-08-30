class_name Weapon
extends Item

## The type of ammo this weapon uses, and the type of weapon itself.
var ammo_type: ItemEnums.AmmoType # Which weapon it is.
var _capacity: int # Total bullets before reload.
var _curr_ammo: int # Current bullets loaded.

func _init(type: ItemEnums.AmmoType, name: String, amnt: int, power: float, capacity: int) -> void:
	super(ItemEnums.ItemType.WEAPON, name, amnt, power, )
	ammo_type = type
	set_amnt(amnt)
	set_power(power)
	set_capacity(capacity)
	
#SETTERS-------------------------------------------------------------------------

func set_amnt(amnt: int) -> void:
	super.set_amnt(1)
	
## Sets the damage of this Weapon. If this is a gun, it will do nothing because its damage depends on its ammo's damage.
func set_power(power: float) -> void:
	if (is_gun()): 
		super.set_power(0.0)
		return
	super.set_power(power)
	
## Sets the amount of ammo this weapon can hold. If this is not a gun, it will do nothing.
func set_capacity(val: int) -> void:
	if (not is_gun()): 
		_capacity = 0
		return
	_capacity = val
	
#GETTERS-------------------------------------------------------------------------

func get_capacity() -> int:
	return _capacity
func get_curr_ammo() -> int:
	return _curr_ammo

#FLAGS---------------------------------------------------------------------------

func is_empty() -> bool:
	return (_curr_ammo < 1)

func is_fully_loaded() -> bool:
	return ((_capacity - _curr_ammo) == 0)
	
func is_gun() -> bool:
	return (ammo_type != ItemEnums.AmmoType.MEELEE)

#OPERATIONS----------------------------------------------------------------------

func inc_ammo(val: int) -> void:
	if (is_fully_loaded()): return
	_curr_ammo += val

func dec_ammo(val: int) -> void:
	_curr_ammo -= val
	if (_curr_ammo < 0):
		_curr_ammo = 0

## Will load the gun with the given ammo. Will do nothing if meelee, ammo is empty, or gun is fully loaded.
func load_bullets(ammo: Ammo) -> void:
	if (not is_gun()): return # Case 1: Not a gun.
	if (ammo.get_amnt() <= 0): return # Case 2: Given ammo is empty.
	if (is_fully_loaded()): return # Case 3: Gun is fully loaded.
	while ammo.get_amnt() > 0:
		ammo.dec_amnt(1)
		inc_ammo(1)
		
func _to_string() -> String:
	var out: String = ""
	out += "Name: " + get_name() +"|Amount: " + str(get_amnt()) + "|"
	out += "Power: " + "%.2f" % get_power()
	out += "|Capacity:" + str(_capacity) + "|Loaded: " + str(_curr_ammo)
	return out
