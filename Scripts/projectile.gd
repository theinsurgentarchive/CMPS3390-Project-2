extends CharacterBody2D

@export var speed: float = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start(10.0)
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$AnimatedSprite2D.play("Rocket")
	pass # Replace with function body.

func _on_timer_timeout():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
		
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	var collision = move_and_collide(velocity * delta)
