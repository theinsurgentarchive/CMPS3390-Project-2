extends CharacterBody2D

@export var speed = 150
@onready var player:CharacterBody2D = get_tree().current_scene.get_node("Player")



func _moveHandler(delta):
	look_at(player.position)
	#velocity = Vector2.ZERO
	#velocity = Vector2.RIGHT.rotated(rotation) * speed
	#velocity = position.direction_to(player.position) * speed
	var inweight:float = 0.0
	var invel = position.direction_to(player.position) * speed
	var outweight:float = 0.9
	var outvel = position.direction_to(player.position) * -speed
	var rotweight:float = 2
	var rotvel = position.direction_to(player.position).rotated(PI/2) * speed
	
	
	
	for i in position.distance_to(player.position)/100:
		inweight += 0.1
	
	for i in position.distance_to(player.position)/125:
		outweight -= 0.1
	
	if(global_position.distance_to(player.position) < 200):
		rotweight = 0
		outweight *= 5
	
	if(global_position.distance_to(player.position) > 500):
		rotweight = 0
		inweight *= 5
	
	var intot = (inweight * invel).limit_length(255)
	var outtot = (outvel * outweight).limit_length(255)
	var rottot = (rotvel * rotweight).limit_length(255)
	
	#if(global_position.distance_to(player.position) > 200):
		#pass
		#velocity = position.direction_to(player.position) * speed
		#velocity = Vector2.RIGHT * (speed * 2)
		#collision = move_and_collide(velocity)
		
	#elif(global_position.distance_to(player.position) <= 200):
		#velocity = position.direction_to(player.position).normalized().rotated(PI/2) + position.direction_to(player.position).normalized().rotated(cos(PI/2)) * 100
		#pass
		
	#elif(global_position.distance_to(player.position) < 100):
		#velocity = -velocity
		#pass
		
	
	velocity = (intot + outtot + rottot) * delta
	var collision = move_and_collide(velocity)


func _on_health_health_empty() -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	_moveHandler(delta)

func _on_hurt_box_got_hurt(damage: float) -> void:
	print("Orbiter Health: " + str($Health.getHealth()))
