class_name Projectile
extends CharacterBody2D

enum types {
	BULLET,
	ROCKET,
	SLUG
}

@export var liveFor: float = 12.0
@export var maxSpeed: float = 250.0
@export var accel: float = 300.0
@export var damage: float = 1.0
@export var type: types = types.BULLET
var target = null
var currentSpeed = 0.0
var rot_accel = 120.0
var lastAngle = 0.0
var enemy: bool

func setType(select: int, bodies: Array, e: bool):
	enemy = e
	
	# Wall Collision
	collision_layer = 0
	set_collision_layer_value(3, true)
	
	collision_mask = 0
	set_collision_mask_value(1, true)

	# HitBox Collision
	$HitBox.collision_layer = 0
	$HitBox.set_collision_layer_value(3, true)
	
	$HitBox.collision_mask = 0
	if enemy:
		$HitBox.set_collision_mask_value(2, true)
		$Sprite.play("E_bullet")
		currentSpeed = 50.0
		
		damage = 5.0
	else:
		$HitBox.set_collision_mask_value(4, true)
		match select:
			0:
				$Sprite.play("Bullet")
				type = types.BULLET
				currentSpeed = 750.0
				damage = 3.0
			1:
				$Sprite.play("Rocket")
				type = types.ROCKET
				setTarget(bodies)
				currentSpeed = 50.0
				damage = 10.0
			2:
				$Sprite.play("Slug")
				type = types.SLUG
				$HitBox/Collision.scale = Vector2(4.0, 4.0)
				currentSpeed = 2000.0
				damage = 40.0
	$HitBox.setDamage(damage)

func setTarget(targets: Array):
	var closest = null
	var shortest_dist = INF
	for t in targets:
		if !is_instance_valid(t):
			continue
		var current_dist = get_global_mouse_position().distance_squared_to(t.global_position)
		if current_dist < shortest_dist:
			shortest_dist = current_dist
			closest = t
	target = closest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start(liveFor)

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	
	if area is HurtBox:
		if type != types.SLUG:
			queue_free()
	if (
		enemy && area.owner.name.contains("P Projectile") ||
		!enemy && area.owner.name.contains("E Projectile")
	):
		queue_free()

func _on_timer_timeout():
	queue_free()

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
	currentSpeed = move_toward(currentSpeed, maxSpeed, accel * delta)
	velocity = Vector2.RIGHT.rotated(rotation) * currentSpeed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if type == types.SLUG:
			if object.owner is Arena || object is Arena:
				queue_free()
		else:
			queue_free()

func lookAtSlowly(delta: float):
	var t_vector = (target.global_position - global_position).normalized()
	var t_angle = t_vector.angle()
	rotation = rotate_toward(rotation, t_angle, deg_to_rad(rot_accel) * delta)
