class_name Inventory
extends RefCounted

signal on_equipped(item: Item)

var _inv: Dictionary[ItemEnums.ItemType, Array] = {
	ItemEnums.ItemType.HEALER: [],
	ItemEnums.ItemType.AMMO: [],
	ItemEnums.ItemType.WEAPON: []
}
	
func _item_idx_by_name(name: String) -> int:
	for type in _inv:
		for idx in _inv[type].size():
			if (_inv[type].get(idx).get_name() == name):
				return idx
	return -1
	
func has_item(i: Item) -> bool:
	return (_item_idx_by_name(i.get_name()) != -1)
	
func add_item(i: Item) -> void:
	if (has_item(i)):
		var item_idx: int = _item_idx_by_name(i.get_name())
		if (i is Weapon):
			_inv[i.item_type].set(item_idx, i)
			_inv[i.item_type].get(item_idx).on_empty.connect(remove_item)
		else:
			var item: Item = _inv[i.item_type].get(item_idx)
			item.inc_amnt(i.get_amnt())
	else:
		i.on_empty.connect(remove_item.bind(i))
		_inv[i.item_type].push_back(i)
		_inv[i.item_type].back().on_empty.connect(remove_item)
		
func remove_item(i: Item):
	var item_idx: int = _item_idx_by_name(i.get_name())
	_inv[i.item_type].set(item_idx, null)
	
func get_item_by_name(type: ItemEnums.ItemType, name: String) -> Item:
	var idx = _item_idx_by_name(name)
	return _inv[type].get(idx)
	
func get_all_of_type(type: ItemEnums.ItemType) -> Array:
	return _inv[type]
	
func _to_string() -> String:
	var out: String = ""
	for type in _inv:
		out += ItemEnums.ItemType.find_key(type)
		out += ": "
		for item in _inv[type]:
			out += "[" + str(item) + "] | "
		out += "\n"
	return out
