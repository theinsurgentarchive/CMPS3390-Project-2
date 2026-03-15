extends CharacterBody2D
class_name fodderEnemy

@export var speed = 250
@export var damage = 10
@onready var player:CharacterBody2D = get_tree().current_scene.get_node("Player")

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	queue_free()

func _ready():
	position = Vector2(randf_range(-999.99, 999.99), randf_range(-999.99, 999.99))
	$HitBox.setDamage(damage)

func _on_hurt_box_got_hurt(damage: float) -> void:
	print("Fodder Health: " + str($Health.getHealth()))

func _movehandler(delta):
	#if(rotation != position.direction_to(player.position).angle()):
	#	if(rotation < position.direction_to(player.position).angle()):
	#		rotation += 0.01
	#	else:
	#		rotation -= 0.01
	
	look_at(player.position)
	velocity = Vector2.ZERO
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	#velocity = position.direction_to(player.position) * speed
	velocity *= delta
	var collision = move_and_collide(velocity)


func _physics_process(delta: float) -> void:
	_movehandler(delta)

func _on_health_health_empty() -> void:
	
	queue_free()
