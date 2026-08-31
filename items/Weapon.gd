class_name Weapon
extends Item

signal on_loading(equipped_ammo_count: int)
signal ammo_changed(ammo_left: int, capacity: int)

## The type of ammo this weapon uses, and the type of weapon itself.
var ammo_type: ItemEnums.AmmoType # Which weapon it is.
var _ammo: Array[float] = []
var _capacity: int

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
	return _ammo.size()
func get_dmg() -> float:
	if (_ammo.is_empty()): return 0.0
	return _ammo.back()

#FLAGS---------------------------------------------------------------------------

func is_empty() -> bool:
	return (_ammo.is_empty())

func is_fully_loaded() -> bool:
	return (_ammo.size() >= _capacity)
	
func is_gun() -> bool:
	return (ammo_type != ItemEnums.AmmoType.MEELEE)

#OPERATIONS----------------------------------------------------------------------

## Will load the gun with the given ammo. Will do nothing if meelee, ammo is empty, or gun is fully loaded.
func load_bullets(ammo: Ammo) -> void:
	if (not is_gun()): return # Case 1: Not a gun.
	if (ammo == null): return # Case 2: Given null ammo.
	if (ammo.get_amnt() <= 0): return # Case 2: Given ammo is empty.
	if (is_fully_loaded()): return # Case 3: Gun is fully loaded.
	while (not is_fully_loaded() and ammo.get_amnt() > 0):
		_ammo.push_front(ammo.get_power())
		ammo.dec_amnt(1)
	ammo_changed.emit(get_curr_ammo(), _capacity)
	on_loading.emit(ammo.get_amnt())
	

## Removes and returns the next bullet's damage.
func on_shoot() -> float:
	if (is_empty()): return 0.0
	var dmg = _ammo.pop_back()
	ammo_changed.emit(get_curr_ammo(), _capacity)
	return dmg
	
		
func _to_string() -> String:
	var out: String = ""
	out += "Name: " + get_name() +"|Amount: " + str(get_amnt()) + "|"
	out += "Power: " + "%.2f" % get_power()
	out += "|Capacity:" + str(_capacity) + "|Loaded: " + str(_ammo)
	return out
