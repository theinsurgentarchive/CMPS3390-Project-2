extends Node2D

@export var speed: float = 300.0

func _process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += dir * speed * delta
	
