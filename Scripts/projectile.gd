class_name Projectile
extends CharacterBody2D

@export var liveFor: float = 6.0
@export var speed: float = 25.0
@export var damage: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start(liveFor)
	$Sprite.play("Rocket")
	$HitBox.setDamage(damage)
	# target = 

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == null:
		return
	queue_free()

func _on_timer_timeout():
	queue_free()

@onready var proj = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# look_at(target)
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object is Arena:
			proj = $"."
			proj.queue_free()
