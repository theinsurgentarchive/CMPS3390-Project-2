class_name Projectile
extends CharacterBody2D

enum types {
	BULLET,
	ROCKET,
	SLUG
}

@export var liveFor: float = 30.0
@export var maxSpeed: float = 250.0
@export var accel: float = 300.0
@export var damage: float = 1.0
@export var type: types = types.BULLET
var target = null
var currentSpeed = 0.0
var rot_accel = 120.0
var lastAngle = 0.0

func setType(select: int, bodies: Array):
	match select:
		0:
			$Sprite.play("Bullet")
			type = types.BULLET
			currentSpeed = 750.0
		1:
			$Sprite.play("Rocket")
			type = types.ROCKET
			setTarget(bodies)
		2:
			$Sprite.play("Slug")
			type = types.SLUG
			currentSpeed = 2000.0

func setTarget(targets: Array):
	var closest = null
	var shortest_dist = INF
	for t in targets:
		if !is_instance_valid(t):
			continue
		var current_dist = global_position.distance_squared_to(t.global_position)
		if current_dist < shortest_dist:
			shortest_dist = current_dist
			closest = t
	target = closest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start(liveFor)
	$HitBox.setDamage(damage)

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	for body in area.get_overlapping_bodies():
		if $".".name.contains("P Projectile"):
			if body is Enemy:
				queue_free()
			if body is Player:
				return
			if body.owner is Arena:
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
				lookAtSlowly(delta)
		types.SLUG:
			pass
	lastAngle = rotation
	if abs(rotation - lastAngle) < 0.001:
		currentSpeed = move_toward(currentSpeed, maxSpeed, accel * delta)
	else:
		currentSpeed = move_toward(currentSpeed, 0, accel * 6 * delta)
	velocity = Vector2.RIGHT.rotated(rotation) * currentSpeed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object.owner is Arena || object is Arena:
			queue_free()

func lookAtSlowly(delta: float):
	var t_vector = (target.global_position - global_position).normalized()
	var t_angle = t_vector.angle()
	rotation = rotate_toward(rotation, t_angle, deg_to_rad(rot_accel) * delta)
