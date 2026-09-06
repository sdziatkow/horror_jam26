class_name BulletSpawn
extends Marker2D

const GUN_POS: Dictionary[Player.AttackState, Vector2] = {
	Player.AttackState.HANDGUN: Vector2(54.0, 24.0),
	Player.AttackState.SHOTGUN: Vector2(80.0, 16.0)
}

func set_pos(gun: Player.AttackState):
	if (gun == Player.AttackState.MEELEE or gun == Player.AttackState.RIFLE):
		return
	position = GUN_POS[gun]
