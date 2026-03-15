class_name Player
extends CharacterBody2D

signal die

enum weapons {
	ROCKETS,
	GUNS,
	RAILGUN
}
# Global Variables
@export var health: float = 100.0
@export var speed: float = 300.0
@export var defaultSelect: int = 0
@export var weaponDelay: Array = [0.1, 0.2, 3]
@onready var maxProjectiles = get_tree().current_scene.get("maxProjectiles")
var projectile: PackedScene = load("res://Scenes/projectile.tscn")
var targets: Array
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
	$Health.setMaxHealth(health)

func _on_hurt_box_got_hurt(_damage: float) -> void:
	# print_debug("Health: " + str($Health.getHealth()))
	if $Health.iFrameTimer == null:
		$Health.temporaryInvul($Health.iFrameLength)
	else:
		if $Health.iFrameTimer.is_stopped() && $Health.health > 0:
			$Health.temporaryInvul($Health.iFrameLength)

func _on_health_health_empty() -> void:
	# print_debug("Health Depleted")
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
	move_and_slide()

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
			$Weapon/Delay.stop()
			break
			
	if Input.is_action_just_pressed("Slot_next"):
		select = (select + 1) % maxWeapons
		$Weapon/Delay.stop()
	if Input.is_action_just_pressed("Slot_prev"):
		if (select <= 0):
			select = maxWeapons - 1
		else:
			select -= 1
		$Weapon/Delay.stop()
	
	# Fire Weapon
	if Input.is_action_pressed("Fire"):
		var anim = wepAnim.fire[select]
		if $Weapon.animation != anim:
			$Weapon.play(anim)
		if (checkProjectiles() && $Weapon/Delay.is_stopped()):
			var p = projectile.instantiate()
			get_tree().current_scene.get_node("Projectiles").add_child(p)
			p.setType(select, targets, false)
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
	return get_tree().current_scene.get("projectilesSpawn")

func _process(delta: float) -> void:
	targets = targets.filter(
		func(target):
			return is_instance_valid(target)
	)
	if Input.is_action_just_pressed("Pause"):
		$Health.setHealth(0.0)

func _physics_process(delta: float) -> void:
	moveHandler(delta)
	wepHandler()


func _on_lock_on_box_body_entered(body: Node2D) -> void:
	if body == self || body is Projectile || body is Arena:
		return
	
	targets.append(body)

func _on_lock_on_box_body_exited(body: Node2D) -> void:
	targets.erase(body)
