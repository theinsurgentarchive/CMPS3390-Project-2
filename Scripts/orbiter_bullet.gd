extends CharacterBody2D

@export var speed = 500
@onready var player:CharacterBody2D = get_tree().current_scene.get_node("Player")
@onready var targetloc: Vector2= position.direction_to(player.position)

func _Timeout():
	queue_free()

func _ready() -> void:
	$Timer.timeout.connect(_Timeout)

func _physics_process(delta: float) -> void:
	velocity = targetloc * delta * speed
	var collision = move_and_collide(velocity)
	if collision:
		var object = collision.get_collider()
		if object.name == "Player":
			queue_free()
func _on_hit_box_area_entered(area: Area2D) -> void:
	#print("hit")
	#for body in area.get_overlapping_bodies():
	#	print(body.name)
	pass
