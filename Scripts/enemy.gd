class_name Enemy
extends CharacterBody2D

signal enemyDeath(value: int)

@export var speed = 3
@export var damage = 10
@export var type: int = 1
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")
var points: int


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	queue_free()

func _ready():
	position = Vector2(randf_range(-999.99, 999.99), randf_range(-999.99, 999.99))
	var data = get_tree().root.get_node_or_null("Database")
	assert(data != null, "Can't find database node...")
	data = data.getEnemy(type)
	points = data["worth"]
	damage = data["damage"]
	speed = data["speed"]
	$HitBox.setDamage(damage)
	$Sprite2D.texture = load("res://Resources/Fodder.tres")

func _on_hurt_box_got_hurt(_damage: float) -> void:
	print("Health: " + str($Health.getHealth()))

func moveHandler(delta):
	look_at(player.position)
	velocity = Vector2.ZERO
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object is Player:
			pass

func _physics_process(delta: float) -> void:
	moveHandler(delta)

func _on_health_health_empty() -> void:
	enemyDeath.emit(points)
	queue_free()
