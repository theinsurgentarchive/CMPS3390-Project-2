class_name HurtBox
extends Area2D

signal gotHurt(damage: float)

@export var health: Health

func _ready():
	connect("area_entered", _on_area_entered)
	

func _on_area_entered(area: Area2D):
	if $"." is Player && area.owner.name.contains("P Projectile"):
		return
	if area is HitBox:
		var hp = health.health - area.damage
		health.setHealth(hp)
		gotHurt.emit(area.damage)
