class_name HitBox
extends Area2D

var _damage: float = 0.0

func set_dmg(dmg: float) -> void:
	_damage = dmg
	
func get_dmg() -> float:
	return _damage
