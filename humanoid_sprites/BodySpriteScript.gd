class_name BodySprite
extends Node2D

@onready var _sprites: Dictionary[Player.AttackState, Sprite2D] = {
	Player.AttackState.MEELEE: $MeeleeSprite,
	Player.AttackState.HANDGUN: $HandgunSprite,
	Player.AttackState.RIFLE: $RifleSprite,
	Player.AttackState.SHOTGUN: $ShotgunSprite
}

func _ready() -> void:
	show_sprite(Player.AttackState.MEELEE)
		
## Make given sprite visible and hide all others.
func show_sprite(type: Player.AttackState) -> void:
	for i in _sprites:
		if (i == type):
			_sprites[i].show()
		else:
			_sprites[i].hide()
