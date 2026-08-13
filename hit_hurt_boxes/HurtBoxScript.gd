class_name HurtBox
extends Area2D

signal taking_damage(dmg: float)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(hit_box: HitBox) -> void:
	taking_damage.emit(hit_box.get_dmg())
	
func toggle_invincible(b: bool) -> void:
	$CollisionShape2D.disabled = b
