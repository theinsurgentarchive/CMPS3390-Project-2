class_name Enemy
extends CharacterBody2D

signal enemyDeath(value: int, enemy: Enemy)

@export var health = 1.0
@export var speed = 100.0
@export var damage = 10.0
@export var type: int = 1
@export var rot_accel = 150.0
@export var sprite: Resource = load("res://Resources/Fodder.tres")
@onready var target: CharacterBody2D = get_tree().current_scene.get_node("Player")
@onready var nav: NavigationAgent2D = $Navigation
var rng: RandomNumberGenerator
var points: int = 100.0
var direction = Vector2.ZERO

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	queue_free()

func start():
	position = Vector2(rng.randf_range(-999.99, 999.99), rng.randf_range(-999.99, 999.99))
	var data = get_tree().root.get_node_or_null("Database")
	assert(data != null, "Can't find database node...")
	data = data.getEnemy(type)
	points = data["worth"]
	damage = data["damage"]
	speed = data["speed"]
	health = data["health"]
	sprite = load(data["sprite"])
	nav.max_speed = speed
	$HitBox.setDamage(damage)
	$Sprite2D.texture = sprite

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	start()

func _on_hurt_box_got_hurt(_damage: float) -> void:
	print("Health: " + str($Health.getHealth()))

func moveHandler(delta):
	lookAtSlowly(delta)
	match type:
		1:
			nav.avoidance_priority = 1.0
			direction = global_position.direction_to(nav.get_next_path_position())
			velocity = direction * speed
			# velocity = Vector2.RIGHT.rotated(rotation) * speed
		2:
			nav.avoidance_priority = 2.0
			# velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_and_slide()

func _physics_process(delta: float) -> void:
	moveHandler(delta)

func _on_health_health_empty() -> void:
	enemyDeath.emit(points, $".")
	queue_free()

func lookAtSlowly(delta: float):
	var t_vector = (target.global_position - global_position).normalized()
	var t_angle = t_vector.angle()
	rotation = rotate_toward(rotation, t_angle, deg_to_rad(rot_accel) * delta)

func _on_nav_timer_timeout() -> void:
	if is_instance_valid(target):
		nav.target_position = target.global_position
