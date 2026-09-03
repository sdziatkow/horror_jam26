class_name Player
extends CharacterBody2D

var _bullet: PackedScene = preload("res://projectiles/Bullet.tscn")
@onready var _anim_state: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
var hp: StatVal = StatVal.new(StatVal.StatType.HEALTH, 100.0, 100.0)
var sp: StatVal = StatVal.new(StatVal.StatType.STAMINA, 50.0, 50.0)
var inv: Inventory = Inventory.new()
var eq_slots: EquipSlots = EquipSlots.new()

@onready var player_footsteps: AudioStreamPlayer2D = $PlayerFootsteps


func _ready() -> void:
	_anim_state.travel("meelee_idle")
	#hp.on_empty.connect(queue_free)
	$HurtBox.taking_damage.connect(hp.dec)
	inv.on_equipped.connect(eq_slots.equip)
	eq_slots.healer_equipped.connect(_update_healer)
	eq_slots.update_meelee_dmg.connect(_update_meelee_dmg)
	eq_slots.swap_weapon(ItemEnums.AmmoType.MEELEE)

## General state of the player
enum State {IDLE, MOVE, ATTACK, RELOAD, FREEZE}
var state = State.MOVE

## Specific move state
enum MoveState {WALK, SPRINT}
var _mv_state: MoveState = MoveState.WALK

## Specific attack state.
enum AttackState {MEELEE, HANDGUN, RIFLE, SHOTGUN}
var _attk_state: AttackState = AttackState.MEELEE

func _physics_process(delta: float) -> void:
	match (state):
		State.IDLE, State.MOVE:
			_move_state(delta)
			_look_at_mouse()
		State.ATTACK:
			_attack_state(delta)
		State.RELOAD:
			_reload_state(delta)
		State.FREEZE:
			pass
		
## For weapon swapping.
func _input(event: InputEvent) -> void:
	if (event.is_action_released("swap_weapon")):
		var new_state: AttackState
		new_state = event.as_text().to_int() - 1
		if (new_state == AttackState.RIFLE or new_state == AttackState.SHOTGUN): return
		if (eq_slots.weapons.get(new_state) == null):
			return
		elif (_attk_state == new_state):
			return
		else:
			_attk_state = new_state
			$BodySprite.show_sprite(_attk_state)
			eq_slots.swap_weapon(ItemEnums.AmmoType[ItemEnums.AmmoType.find_key(_attk_state)])
	if (event.is_action_released("use_heal")):
		var heal_type: ItemEnums.HealType
		var key: String = event.as_text()
		var healer: Healer = eq_slots.healers.get(heal_type)
		if (key == "Z"):
			heal_type = ItemEnums.HealType.HP
		elif (key == "X"):
			heal_type = ItemEnums.HealType.SP
		healer = eq_slots.healers.get(heal_type)
		if (healer == null): return
		healer.use()
		if (healer.is_empty()):
			inv.remove_item(healer)
			eq_slots.healers[heal_type] = null
			eq_slots.no_healer.emit(heal_type)
			print("no_healer")
		

#MOVEMENT------------------------------------------------------------------------
@export var WALK_SPEED: float = 150.0
@export var SPRINT_SPEED: float = 300.0
@export var ACCELERATION: float = 1000.0
@export var FRICTION: float = 500.0

@export var SPRINT_COST: float = 0.50
@export var SPRINT_REGEN: float = 0.05

func _move_state(delta: float) -> void:
	var input_vector = Vector2.ZERO
	
	# Determine the direction of movement based on input.
	input_vector.x = Input.get_action_strength("move_east") - Input.get_action_strength("move_west")
	input_vector.y = Input.get_action_strength("move_south") - Input.get_action_strength("move_north")
	input_vector = input_vector.normalized()
	
	# Check for movement input.
	var moving: bool = (input_vector != Vector2.ZERO)
	if (moving):
		state = State.MOVE
		
		# Check for sprint input.
		if (Input.get_action_strength("sprint") > 0.0 and sp.get_val() >= SPRINT_COST): 
			_mv_state = MoveState.SPRINT
			sp.dec(SPRINT_COST)
		else:
			_mv_state = MoveState.WALK
			sp.inc(SPRINT_REGEN)
		_on_moving(input_vector, delta)
	else:
		sp.inc(SPRINT_REGEN)
		state = State.IDLE 
		_on_idle(delta)
	move_and_slide()
	_switch_anim()
		
	# Check for a attack input.
	if (Input.get_action_strength("attack") > 0.0):
		state = State.ATTACK
		
	# Check for reload input.
	if (_attk_state != AttackState.MEELEE and Input.get_action_strength("reload") > 0.0):
		if (eq_slots.has_ammo() and not eq_slots.weapons[eq_slots.held_weapon].is_fully_loaded()):
			state = State.RELOAD
		
## Move the in given direction (input_vector).
func _on_moving(input_vector: Vector2, delta: float) -> void:
	var max_speed: float
	
	# Determine max_speed based on _mv_state.
	match (_mv_state):
		MoveState.WALK:   max_speed = WALK_SPEED
		MoveState.SPRINT: max_speed = SPRINT_SPEED
	
	# Update velocity to move toward max_speed by ACCELERATION * delta
	velocity = velocity.move_toward(input_vector * max_speed, ACCELERATION * delta)
	velocity = velocity.limit_length(max_speed)
	
## Update velocity to move toward ZERO by FRICTION * delta
func _on_idle(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
#ATTACKING-----------------------------------------------------------------------

## Determine whether the player has meelee or gun equipped and set state accordingly.
func _attack_state(delta: float) -> void:
	if (eq_slots.weapons[eq_slots.held_weapon].is_gun() and
		eq_slots.weapons[eq_slots.held_weapon].is_empty()
	): 
		state = State.MOVE
		return
	velocity = Vector2.ZERO
	_switch_anim()
	
## Instantiate a bullet scene and add it to BulletSpawn node.
func _shoot() -> void:
	var bullet: Bullet = _bullet.instantiate()
	bullet.set_travel_vector(Vector2.from_angle(global_rotation))
	bullet.set_origin($BulletSpawn.global_position)
	bullet.get_node("HitBox").set_dmg(eq_slots.weapons[eq_slots.held_weapon].on_shoot())
	$BulletSpawn/Node.add_child(bullet)
	
func _reload_state(delta: float) -> void:
	var ammo: Ammo = eq_slots.ammos[eq_slots.held_weapon]
	if (ammo == null): return
	var wpn: Weapon = eq_slots.weapons[eq_slots.held_weapon]
	wpn.load_bullets(ammo)
	if (ammo.is_empty()):
		inv.remove_item(ammo)
		eq_slots.ammos[eq_slots.held_weapon] = null
	velocity = Vector2.ZERO
	_switch_anim()
	
func _on_attk_finished() -> void:
	_smooth_look_at_mouse()
	state = State.MOVE
	
#UTIL----------------------------------------------------------------------------

## Update rotation of CharacterBody2D.
func _look_at_mouse() -> void:
	global_rotation = (get_global_mouse_position() - global_position).angle()
	
## For adjusting back to looking at mouse when _look_at_mouse() is not active.
func _smooth_look_at_mouse() -> void:
	var angle: float = (get_global_mouse_position() - global_position).angle()
	var time: float = 0.1
	var anim: Tween = create_tween()
	anim.tween_property(self, "global_rotation", angle, time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		
## Play animation based on _state and _attk_state.
func _switch_anim() -> void:
	var prefix: String = str(AttackState.find_key(_attk_state)).to_lower()
	var suffix: String = str(State.find_key(state)).to_lower()
	var travel_to: String = prefix + "_" + suffix
	_anim_state.travel(travel_to)

func get_spawn_diameter() -> float:
	return max($CollisionShape2D.shape.height, $CollisionShape2D.shape.radius * 2)
	
#INVENTORY-----------------------------------------------------------------------

func _update_meelee_dmg(dmg: float) -> void:
	$MeeleePivot/MeeleeHitBox.set_dmg(dmg)
	
func _update_healer(healer: Healer) -> void:
	var stat: StatVal
	if (healer.heal_type == ItemEnums.HealType.HP):
		stat = hp
	elif (healer.heal_type == ItemEnums.HealType.SP):
		stat = sp
	healer.used.connect(stat.inc)


func _on_footstep_timer_timeout() -> void:
	player_footsteps.play()
