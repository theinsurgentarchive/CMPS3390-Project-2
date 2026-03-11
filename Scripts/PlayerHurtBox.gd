extends HurtBox

func _on_area_entered(area: Area2D):
	if area.owner.name.contains("P Projectile"):
		return
	if area is HitBox:
		var hp = health.health - area.damage
		health.setHealth(hp)
		gotHurt.emit(area.damage)
