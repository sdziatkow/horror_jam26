class_name InvDisplay
extends Control

var _inv: Inventory
func give_inventory(inv: Inventory):
	_inv = inv
	
#ITEM-SELECTION------------------------------------------------------------------
## ItemList Object displays a selectable list of ItemEnums.ItemType
@onready var _item_type_list: ItemList = $ItemTypeList

## ItemList Object displays a selectable list of Items of sub-type depending on _item_type_list selection.
@onready var _item_list: ItemList = $ItemList

#ITEM-DISPLAY--------------------------------------------------------------------
## Displays the currently selected Item Object from _item_list.
@onready var _item_disp: Panel = $ItemDisplay

## Displays the currently selected Item Object's name.
@onready var _item_name: Label = $ItemDisplay/Label

## Displays the currently selected Item Object's stats.
@onready var _item_stats: GridContainer = $ItemDisplay/GridContainer

## Allows the user to equip the currently selected Item Object.
@onready var _eq_button: Button = $ItemDisplay/Button

## Currently selected Item Object.
var _curr_item: Item = null

#DISPLAY-------------------------------------------------------------------------
## A map holding each Item Object's ItemList index for easy access.
var _item_map: Dictionary[int, Item]
func _ready() -> void:
	_eq_button.hide()
	_item_type_list.item_selected.connect(_handle_type_selection)
	_fill_item_type_list()
	_item_list.item_selected.connect(_handle_item_selection)
	
	# Add labels for _item_stats in _item_disp.
	const COLS: int = 2
	const ROWS: int = 3
	_item_stats.columns = COLS
	for i in (COLS * ROWS):
		_item_stats.add_child(Label.new())
	hidden.connect(on_hidden)
	
## Fill the ItemList with all keys of ItemEnums.ItemType.
func _fill_item_type_list() -> void:
	for type in ItemEnums.ItemType:
		_item_type_list.add_item(type)
		
## Fill clear _item_disp and _fill_item_list() with selected ItemType.
func _handle_type_selection(idx: int) -> void:
	var txt: String = _item_type_list.get_item_text(idx)
	if (_curr_item != null):
		if (ItemEnums.ItemType[txt] != _curr_item.item_type):
			_clear_item_disp()
	_fill_item_list(ItemEnums.ItemType[txt])
	
## Fill _item_list with Item Objects of given type from _inv.
func _fill_item_list(type: ItemEnums.ItemType) -> void:
	_item_list.clear()
	_item_map.clear()
	var items: Array = _inv.get_all_of_type(type)
	for i in items:
		if (i != null):
			var idx = _item_list.add_item(i.get_name())
			_item_map[idx] = i
			
## Display the seleceted item from ItemList.
func _handle_item_selection(idx: int) -> void:
	_clear_item_disp()
	_curr_item = _item_map.get(idx)
	_item_name.text = _curr_item.get_name()
	var disp_info: Dictionary[String, String] = _curr_item.disp_info()
	var row: int = 0
	for key in disp_info:
		_item_stats.get_child(row).text = key
		_item_stats.get_child(row + 1).text = "|" + disp_info[key]
		row += 2
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
	_eq_button.disabled = true
	
#ON-VISIBILITY-CHANGE------------------------------------------------------------

func on_hidden() -> void:
	_clear_item_disp()
	_item_list.clear()
	_item_map.clear()
	_item_type_list.deselect_all()
	_curr_item = null
