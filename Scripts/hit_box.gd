class_name HitBox
extends Area2D

@export var damage: float = 1.0 : set = setDamage, get = getDamage

func setDamage(dmg: float):
	damage = dmg

func getDamage() -> float:
	return damage
