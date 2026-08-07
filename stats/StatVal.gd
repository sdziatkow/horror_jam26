class_name StatVal
extends RefCounted

## Emitted when _val == _MIN
signal on_empty

# Type of stat.
enum StatType {HEALTH, STAMINA}
var _type: StatType

# Values
const _MIN: float = 0.0
var _max: float
var _val: float

func _init(type: StatType, max: float, val: float) -> void:
	_type = type
	_max = max
	_val = val
	
#SETTERS-------------------------------------------------------------------------
func set_val(val: float) -> void:
	_val = val
	_clamp_val()
func set_max(val: float) -> void:
	_max = val
	_clamp_val()
#GETTERS-------------------------------------------------------------------------
func get_val() -> float: return _val
func get_min() -> float: return _MIN
func get_max() -> float: return _max
#FLAGS---------------------------------------------------------------------------
func is_empty() -> bool:
	return (_val == _MIN)
#OPERATIONS----------------------------------------------------------------------
func _clamp_val() -> void:
	clamp(_val, _MIN, _max)

## Increment value by given amount.
func inc(amnt: float) -> void:
	_val += amnt
	_clamp_val()
	
## Decrement value by given amount.
func dec(amnt: float) -> void:
	_val -= amnt
	_clamp_val()
	if (_val == _MIN): on_empty.emit()
	
## Set value to its maximum value.
func fill() -> void: _val = _max

## Set value to its minimum value (0.0).
func empty() -> void: 
	_val = _MIN
	on_empty.emit()
