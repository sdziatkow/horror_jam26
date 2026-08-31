extends Node

@export var _DEBUG_MODE : bool

enum GAME_STATE {ON_ROAD, IN_CAR, IN_ENCOUNTER, MENU}
var state: GAME_STATE
var prev_state: GAME_STATE

var _player : Player = preload("res://player/Player.tscn").instantiate()
var _camera : Camera2D = Camera2D.new()
var _world : World = preload("res://world_gen/World.tscn").instantiate()
var _inv_disp: InvDisplay  = preload("res://inventory/InvDisplay.tscn").instantiate()
var _eq_disp: EquipDisplay = preload("res://inventory/EquipDisplay.tscn").instantiate()
var _hp_bar: StatBar = preload("res://stats/StatBar.tscn").instantiate()
var _sp_bar: StatBar = preload("res://stats/StatBar.tscn").instantiate()

@onready var _ui_layer = $CanvasLayer

## Called when game is opened
func _ready() -> void:
	add_child(_world)
	_player.add_child(_camera)
	_set_up_inv()
	_set_up_stat_bars()
	_main()
	if _DEBUG_MODE: $CanvasLayer.add_child(load("res://debug/CommandConsole.tscn").instantiate())
## Called when player presses "play"
func _main() -> void:
	state = GAME_STATE.ON_ROAD
	_world.setup(_player, _camera)
	_world.go_to_road()
	#_world.go_to_gulag()
	
	# For fun
	#for i in 5:
		#_player.inv.add_item(ItemMaker.rand_item(ItemEnums.ItemType.HEALER))
		#_player.inv.add_item(ItemMaker.rand_item(ItemEnums.ItemType.AMMO))
		#_player.inv.add_item(ItemMaker.rand_item(ItemEnums.ItemType.WEAPON))
	
## Add and equip knife to player. Give inv and eq_slots to their displays.
func _set_up_inv() -> void:
	var knife: Weapon = ItemMaker.make_weapon(
	ItemEnums.AmmoType.MEELEE,
	"Knife",
	25.0,
	0
	)
	var gun: Weapon = ItemMaker.make_weapon(
	ItemEnums.AmmoType.HANDGUN,
	"Handgun",
	0.0,
	5
	)
	var ammo: Ammo = ItemMaker.make_ammo(
	ItemEnums.AmmoType.HANDGUN,
	"Handgun Ammo",
	10,
	25.0
	)
	var healer: Healer = ItemMaker.make_healer(
		ItemEnums.HealType.SP,
		"Stamina Healer",
		3,
		25.0
	)
	_player.inv.add_item(knife)
	_player.inv.add_item(gun)
	_player.inv.add_item(ammo)
	_player.inv.add_item(healer)
	_player.eq_slots.equip(knife)
	_inv_disp.give_inventory(_player.inv)
	_eq_disp.give_eq_slots(_player.eq_slots)
	_ui_layer.add_child(_eq_disp)
	_ui_layer.add_child(_inv_disp)
	_inv_disp.visible = false
	
func _input(event: InputEvent) -> void:
	if (event.is_action_released("open_inventory")):
		_inv_disp.visible = not _inv_disp.visible
		if (_inv_disp.visible):
			pause_game()
		else:
			resume_game()
		
func resume_game() -> void:
	var temp_state: GAME_STATE = state
	state = prev_state
	prev_state = temp_state
	_player.state = Player.State.MOVE
	_player._smooth_look_at_mouse()
	
func pause_game() -> void:
	prev_state = state
	state = GAME_STATE.MENU
	_player.state = Player.State.FREEZE
	
func _set_up_stat_bars() -> void:
	_hp_bar.give_stat(_player.hp)
	_sp_bar.give_stat(_player.sp)
	_ui_layer.add_child(_hp_bar)
	_ui_layer.add_child(_sp_bar)
	_hp_bar.set_up()
	_sp_bar.set_up()
	_sp_bar.global_position.y += _hp_bar.size.y + 5
