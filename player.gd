extends Node2D

@export var speed: float = 300.0

func _process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	look_at(get_global_mouse_position())
	position += dir * speed * delta
