class_name Enemy
extends CharacterBody2D

signal enemyDeath(value: int, enemy: Enemy)

@export var health = 1.0
@export var speed = 100.0
@export var damage = 10.0
@export var type: int = 1
@export var worth: int = 100
@export var rot_accel = 150.0
@export var sprite: Resource = load("res://Resources/Fodder.tres")
@onready var nav: NavigationAgent2D = $Navigation
var target: CharacterBody2D
var direction = Vector2.ZERO
var initialized = false

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	queue_free()

func initialize(a: Dictionary):
	type = a[1]
	health = a[2]
	damage = a[3]
	speed = a[4]
	worth = a[5]
	sprite = a[6]
	position = a[7]
	target = a[8]
	nav.max_speed = speed
	$HitBox.setDamage(damage)
	$Sprite2D.texture = sprite
	match type:
		0:
			nav.avoidance_priority = 0.5
		1:
			nav.avoidance_priority = 1.0
	initialized = true

func _ready() -> void:
	pass

func _on_hurt_box_got_hurt(_damage: float) -> void:
	pass
	# print("Health: " + str($Health.getHealth()))

func moveHandler(delta):
	lookAtSlowly(delta)
	match type:
		0:
			direction = global_position.direction_to(nav.get_next_path_position())
			nav.velocity = direction * speed / 2
			
			# velocity = Vector2.RIGHT.rotated(rotation) * speed
		1:
			direction = global_position.direction_to(nav.get_next_path_position())
			nav.velocity = direction * speed / 2
			# velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_and_slide()

func _physics_process(delta: float) -> void:
	if !initialized:
		return
	moveHandler(delta)

func _on_health_health_empty() -> void:
	enemyDeath.emit(worth, $".")
	queue_free()

func lookAtSlowly(delta: float):
	var t_vector = (target.global_position - global_position).normalized()
	var t_angle = t_vector.angle()
	rotation = rotate_toward(rotation, t_angle, deg_to_rad(rot_accel) * delta)

func _on_nav_timer_timeout() -> void:
	if is_instance_valid(target):
		nav.target_position = target.global_position


func _on_navigation_velocity_computed(safe_velocity: Vector2) -> void:
	if !initialized:
		return
	velocity = safe_velocity
	move_and_slide()
