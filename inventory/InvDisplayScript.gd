class_name InvDisplay
extends Control

var _inv: Inventory
func give_inventory(inv: Inventory):
	_inv = inv
	
@onready var _item_type_list: ItemList = $ItemTypeList
@onready var _item_list: ItemList = $ItemList

@onready var _item_disp: Panel = $ItemDisplay
@onready var _item_name: Label = $ItemDisplay/Label
@onready var _item_stats: GridContainer = $ItemDisplay/GridContainer
@onready var _eq_button: Button = $ItemDisplay/Button
var _item_map: Dictionary[int, Item]
var _curr_item: Item = null

func _ready() -> void:
	_eq_button.hide()
	_item_type_list.item_selected.connect(_handle_type_selection)
	_fill_item_type_list()
	_item_list.item_selected.connect(_handle_item_selection)
	
	_item_stats.columns = 2
	for i in 6:
		_item_stats.add_child(Label.new())
	
func _fill_item_type_list() -> void:
	for type in ItemEnums.ItemType:
		_item_type_list.add_item(type)
func _handle_type_selection(idx: int) -> void:
	var txt: String = _item_type_list.get_item_text(idx)
	if (_curr_item != null):
		if (ItemEnums.ItemType[txt] != _curr_item.item_type):
			_clear_item_disp()
	_fill_item_list(ItemEnums.ItemType[txt])
	
	
func _fill_item_list(type: ItemEnums.ItemType) -> void:
	_item_list.clear()
	_item_map.clear()
	var items: Array = _inv.get_all_of_type(type)
	for i in items:
		if (i != null):
			var idx = _item_list.add_item(i.get_name())
			_item_map[idx] = i
func _handle_item_selection(idx: int) -> void:
	_clear_item_disp()
	_curr_item = _item_map.get(idx)
	_item_name.text = _curr_item.get_name()
	if (_curr_item is Weapon):
		if (_curr_item.is_gun()):
			_item_stats.get_child(0).text = "Ammo Capacity"
			_item_stats.get_child(1).text = "|" + str(_curr_item.get_capacity())
			_item_stats.get_child(2).text = "Loaded Ammo"
			_item_stats.get_child(3).text = "|" + str(_curr_item.get_curr_ammo())
			_item_stats.get_child(4).text = "Ammo Damage"
			_item_stats.get_child(5).text = "|%.2f" % _curr_item.get_dmg()
		else:
			_item_stats.get_child(0).text = "Damage"
			_item_stats.get_child(1).text = "|%.2f" % _curr_item.get_power()
	else:
		_item_stats.get_child(0).text = "Held Amount"
		_item_stats.get_child(1).text = "|" + str(_curr_item.get_amnt())
		if (_curr_item is Healer):
			_item_stats.get_child(2).text = "Healing Power:"
		else:
			_item_stats.get_child(2).text = "Damage:"
		_item_stats.get_child(3).text = "|%.2f" % _curr_item.get_power()
	_add_equip_btn(_curr_item)
	
func _add_equip_btn(item: Item) -> void:
	if (item.is_equipped()):
		_eq_button.text = "Equipped"
		_eq_button.disabled = true
	else:
		_eq_button.disabled = false
		_eq_button.text = "Equip"
		_eq_button.button_up.connect(_on_equip_btn_up.bind(item))
	_eq_button.show()
	
func _on_equip_btn_up(item: Item) -> void:
	_inv.on_equipped.emit(item)
	if (_eq_button.button_up.is_connected(_on_equip_btn_up.bind(item))):
		_eq_button.button_up.disconnect(_on_equip_btn_up.bind(item))
	_eq_button.text = "Equipped"
	_eq_button.disabled = true
	
func _clear_item_disp() -> void:
	_item_name.text = ""
	for child in _item_stats.get_children():
		child.text = ""
	_eq_button.hide()
	
	
