class_name Player
extends CharacterBody2D

signal die

enum weapons {
	ROCKETS,
	GUNS,
	RAILGUN
}
# Global Variables
@export var speed: float = 300.0
@export var defaultSelect: int = 0
@export var projectile: PackedScene = load("res://Scenes/projectile.tscn")
@export var maxProjectiles: int = 20
@export var weaponDelay: Array = [0.1, 0.2, 3]
var select = 0
var maxWeapons = 3
var wepAnim = {
		"idle": ["Guns_idle", "Rockets_idle", "Railgun_idle"],
		"fire": ["Guns_fire", "Rockets_fire", "Railgun_fire"]
	}
var bodyAnim = ["Idle", "Move"]

func _ready() -> void:
	select = defaultSelect
	$StartupDelay.start()
	$Body.play(bodyAnim[0])
	$Weapon.play(wepAnim.idle[0])

func _on_hurt_box_got_hurt(damage: float) -> void:
	print("Health: " + str($Health.getHealth()))
	if $Health.iFrameTimer == null:
		$Health.temporaryInvul($Health.iFrameLength)
	else:
		if $Health.iFrameTimer.is_stopped() && $Health.health > 0:
			$Health.temporaryInvul($Health.iFrameLength)
func _on_health_health_empty() -> void:
	print("Health Depleted")
	if !$Health.getInvul():
		die.emit()
	
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
	# Starting Delay
	if (!$StartupDelay.is_stopped()):
		return
		
	# Select Weapon Slot
	for i in range(weapons.size()):
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
		if (checkProjectiles() && $Weapon/Delay.is_stopped()):
			var p = projectile.instantiate()
			get_tree().current_scene.get_node("Projectiles").add_child(p)
			p.global_position = $Weapon/Mussle.global_position
			p.rotation = $Weapon/Mussle.global_rotation
			p.name = "P Projectile"
			p.add_to_group("Projectiles")
			$Weapon/Delay.start(weaponDelay[select])
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
	if num >= maxProjectiles:
		return false
	else:
		return true

func _physics_process(delta: float) -> void:
	moveHandler(delta)
	wepHandler()
