class_name Projectile
extends CharacterBody2D

enum types {
	BULLET,
	ROCKET,
	SLUG
}

@export var liveFor: float = 6.0
@export var speed: float = 25.0
@export var damage: float = 1.0
@export var type: types
var target = null

func setType(select: int, bodies: Array):
	var array = bodies.filter(
		func(element):
			if element is Player:
				bodies.erase(element)
	)
	print("Selected: " + str(select))
	prints(array)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start(liveFor)
	$Sprite.play("Rocket")
	$HitBox.setDamage(damage)

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	for body in area.get_overlapping_bodies():
		if body is Player:
			queue_free()

func _on_timer_timeout():
	queue_free()

@onready var proj = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match type:
		types.BULLET:
			pass
		types.ROCKET:
			if target != null:
				look_at(target)
		types.SLUG:
			pass
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object is Arena:
			queue_free()
