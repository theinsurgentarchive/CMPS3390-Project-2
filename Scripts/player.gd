extends CharacterBody2D

# Global Variables
@export var speed: float = 300.0
@export var select: int = 0
@export var projectile: PackedScene = load("res://Scenes/projectile.tscn")
@export var max_projectiles: int = 20
var maxWeapons = 3
var wepAnim = {
		"idle": ["Guns_idle", "Rockets_idle", "Railgun_idle"],
		"fire": ["Guns_fire", "Rockets_fire", "Railgun_fire"]
	}
var bodyAnim = ["Idle", "Move"]

func _ready() -> void:
	$Body.play(bodyAnim[0])
	$Weapon.play(wepAnim.idle[0])

func moveHandler(delta: float):
	var dir := Input.get_vector("Left", "Right", "Up", "Down")
	var mouse_pos = get_global_mouse_position()
	if !dir.is_zero_approx():
		var anim = bodyAnim[1]
		if $Body.animation != anim:
			$Body.play(anim)
	else:
		var anim = bodyAnim[0]
		if $Body.animation != anim:
			$Body.play(anim)
	
	# Move Player
	look_at(mouse_pos)
	velocity = dir * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())

func wepHandler():
	# Select Weapon Slot
	for i in range(maxWeapons):
		var slot = i + 1
		if (slot >= 10):
			slot = 0
		if Input.is_action_just_pressed("Slot_" + str(slot)):
			select = i
			break
			
	if Input.is_action_just_pressed("Slot_next"):
		select = (select + 1) % maxWeapons
	if Input.is_action_just_pressed("Slot_prev"):
		if (select <= 0):
			select = maxWeapons - 1
		else:
			select -= 1
	
	# Fire Weapon
	if Input.is_action_pressed("Fire"):
		var anim = wepAnim.fire[select]
		if $Weapon.animation != anim:
			$Weapon.play(anim)
		if (checkProjectiles()):
			var p = projectile.instantiate()
			get_tree().current_scene.get_node("Projectiles").add_child(p)
			p.global_position = $Mussle.global_position
			p.rotation = $Mussle.global_rotation
			p.name = "P Projectile"
			p.add_to_group("Projectiles")
	else:
		var anim = wepAnim.idle[select]
		if $Weapon.animation != anim:
			$Weapon.play(anim)

func checkProjectiles() -> bool:
	var group = get_tree().get_nodes_in_group("Projectiles")
	var num = 0
	for item in group:
		if item.name.contains("P Projectile"):
			num += 1
	if num >= max_projectiles:
		return false
	else:
		return true

func _physics_process(delta: float) -> void:
	moveHandler(delta)
	wepHandler()
