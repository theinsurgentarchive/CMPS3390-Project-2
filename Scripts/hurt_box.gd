class_name HurtBox
extends Area2D

signal gotHurt(damage: float)

@export var health: Health
var areas: Array

func _ready():
	connect("area_entered", _on_area_entered)

func _on_area_exited(area: Area2D):
	areas.erase(area)
	
func _physics_process(delta: float) -> void:
	areas = areas.filter(
		func(elem):
			return is_instance_valid(elem)
	)
	for area in areas:
		check(area)

func _on_area_entered(area: Area2D):
	if self.owner is Player && area.owner.name.contains("P Projectile"):
		return
	if self.owner is Enemy && area.owner.name.contains("E Projectile"):
		return
	if area.owner is Arena:
		return
	areas.append(area)
func check(area: Area2D) -> void:
	if area is HitBox && !health.getInvul():
		var hp = health.health - area.damage
		health.setHealth(hp)
		gotHurt.emit(area.damage)
