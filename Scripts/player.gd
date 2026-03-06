extends CharacterBody2D

@export var speed: float = 300.0

func get_input():
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed

func _physics_process(delta: float) -> void:
	get_input()
	look_at(get_global_mouse_position())
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())
