class_name Projectile
extends CharacterBody2D


@export var liveFor: float = 12.0
@export var maxSpeed: float = 250.0
@export var accel: float = 300.0
@export var damage: float = 1.0
var target = null
var currentSpeed = 0.0
var rot_accel = 120.0
var lastAngle = 0.0
var enemy: bool
var pierce: bool = false
var seeking: bool = false

func _ready() -> void:
	$Life.start(liveFor)

func setType(targets: Array, is_enemy: bool, mod: Array):
	enemy = is_enemy
	
	# Projectile main collider on the Projectiles layer
	collision_layer = 0
	set_collision_layer_value(3, true)
	
	# Wall Collision Detection
	collision_mask = 0
	set_collision_mask_value(1, false)

	# HitBox collider lives on Projectiles layer
	$HitBox.collision_layer = 0
	$HitBox.set_collision_layer_value(3, true)
	$HitBox.collision_mask = 0
	
	# Set Projectile Parameters
	if enemy:
		$HitBox.set_collision_mask_value(2, true)
		$Sprite.play("E_bullet")
		currentSpeed = 50.0
		damage = 5.0
	else:
		$HitBox.set_collision_mask_value(4, true)
		$Sprite.play(mod[0])
		currentSpeed = mod[1]
		maxSpeed = mod[2]
		damage = mod[3]
		for i in mod[4]:
			match i:
				"Pierce":
					pierce = true
				"Large":
					$HitBox/Collision.scale = Vector2(4.0, 4.0)
				"Seeking":
					seeking = true
					setTarget(targets)
				"None":
					break
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

# Remove itself from SceneTree if valid
func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	
	if area is HurtBox:
		if !pierce:
			queue_free()
	if (
		enemy && area.owner.name.contains("P Projectile") ||
		!enemy && area.owner.name.contains("E Projectile")
	):
		queue_free()

# Removes itself from SceneTree if alive for too long
func _on_life_timeout() -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	# Start tracking if seeking
	if seeking:
		if target != null:
			lookAtSlowly(delta)
			
	# Approach maxSpeed & set move direction
	currentSpeed = move_toward(currentSpeed, maxSpeed, accel * delta)
	velocity = Vector2.RIGHT.rotated(rotation) * currentSpeed
	
	# Remove itself from SceneTree if valid
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if pierce:
			if object.owner is Arena || object is Arena:
				queue_free()
		else:
			if object.name.contains("Player") && !enemy:
				return
			queue_free()

func lookAtSlowly(delta: float):
	var t_vector = (target.global_position - global_position).normalized()
	var t_angle = t_vector.angle()
	rotation = rotate_toward(rotation, t_angle, deg_to_rad(rot_accel) * delta)
