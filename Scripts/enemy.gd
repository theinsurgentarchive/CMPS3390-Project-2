class_name Enemy
extends CharacterBody2D

signal enemyDeath(value: int, enemy: Enemy)

enum modes {
	APPROACH,
	ORBIT,
	FLEE
}

@export var health = 1.0
@export var speed = 100.0
@export var damage = 10.0
@export var type: int = 1
@export var worth: int = 100
@export var rot_accel: float = 150.0
@export var orb_dist: float = 300.0
@export var orb_band: float = 40.0
@export var orb_speed: float = 240.0
@export var flee_speed: float = 90.0
@export var flee_dist: float =  160.0
var projectile: PackedScene = load("res://Scenes/projectile.tscn")
@export var sprite: Resource = load("res://Resources/Fodder.tres")
@onready var nav: NavigationAgent2D = $Navigation
var target: CharacterBody2D
var direction = Vector2.ZERO
var initialized = false
var timer: Timer = null
var angle: float = 0.0
var mode: modes = modes.APPROACH
var orb_dir: int = 1

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	queue_free()

func initialize(a: Dictionary):
	orb_dir = 1 if (randi() & 1) == 0 else -1
	$".".name = "Enemy"
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
			timer = Timer.new()
			timer.autostart = true
			timer.one_shot = false
			timer.wait_time = 1.5
			timer.name = "ShootTimer"
			timer.timeout.connect(_shoot)
			add_child(timer)
			nav.avoidance_priority = 1.0
			rot_accel = 60.0
	initialized = true

func _ready() -> void:
	pass

func _shoot():
	var p = projectile.instantiate()
	get_tree().current_scene.get_node("Projectiles").add_child(p)
	p.setType(0, [], 1)
	p.global_position = $Mussle.global_position
	p.rotation = $Mussle.global_rotation
	p.name = "E Projectile"
	p.add_to_group("Projectiles")
	timer.start()

func _on_hurt_box_got_hurt(_damage: float) -> void:
	pass
	# print("Health: " + str($Health.getHealth()))

func moveHandler(delta):
	lookAtSlowly(delta)
	match type:
		0:
			nav.target_position = target.global_position
			direction = global_position.direction_to(nav.get_next_path_position())
			nav.velocity = direction * speed / 2
			
			# velocity = Vector2.RIGHT.rotated(rotation) * speed
		1:
			typeOne(delta)
	var next_pos := nav.get_next_path_position()
	var direction := (next_pos - global_position).normalized()
	nav.velocity = direction * speed

func typeOne(delta: float):
	if not is_instance_valid(target):
		return

	var target_pos: Vector2 = target.global_position
	var targetToEnemy: Vector2 = global_position - target_pos
	var distance: float = targetToEnemy.length()
	var away_dir: Vector2 = targetToEnemy / max(distance, 0.001) # direction away from player

	# if closing > 0, then the player is approaching
	var closing: float = (target.velocity - velocity).dot(away_dir)

	# Hysteresis bands so it doesn't jitter between states at the boundary
	var orb_enter: float = orb_dist + orb_band
	var orb_exit: float = orb_dist + orb_band * 1.5
	var flee_target: float = orb_dist + flee_dist

	match mode:
		modes.APPROACH:
			# Change to orbit mode
			if distance <= orb_enter:
				mode = modes.ORBIT

		modes.ORBIT:
			# Change mode based on distance and if the target is closing in
			if distance > orb_exit:
				mode = modes.APPROACH
			elif closing > flee_dist:
				mode = modes.FLEE

		modes.FLEE:
			# Change to orbit mode
			if distance >= flee_dist or closing < flee_dist * 0.4:
				mode = modes.ORBIT

	match mode:
		modes.APPROACH:
			# Move to target
			nav.target_position = target_pos

		modes.ORBIT:
			# Orbit target
			var base_angle: float = targetToEnemy.angle()
			var step: float = orb_dir * deg_to_rad(orb_speed) * delta
			var orbit := target_pos + Vector2.from_angle(base_angle + step) * orb_dist
			nav.target_position = orbit

		modes.FLEE:
			# Flee target until flee_target distance away
			nav.target_position = target_pos + away_dir * flee_target

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
