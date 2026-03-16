class_name Player
extends CharacterBody2D

signal die

# Global Variables
@export var health: float = 100.0
@export var speed: float = 300.0
var projectile: PackedScene = load("res://Scenes/projectile.tscn")
var targets: Array
var select: int = 0
var weaponCount: int = 3
var weaponCooldown: Array[Timer]
var weapons: Array[Dictionary]
var bodyAnim: Array = ["Idle", "Move"]

func initialize(weps: Array[Dictionary], mod: Array):
	# Get weapons
	weapons = weps
	print(weapons)
	weaponCount = weapons.size()
	# Instantiate weapon delays
	for weapon in weapons:
		var t = Timer.new()
		t.autostart = false
		t.one_shot = true
		t.wait_time = weapon["cooldown"]
		t.name = weapon["name"] + "Delay"
		$Weapon/Delay.add_child(t)
		weaponCooldown.append(t)
	
	# Set modifiers
	$Health.setMaxHealth(mod[0])
	speed = mod[1]
	select = mod[2]
	$Health.iFrameLength = mod[3]
	$Weapon.play(weapons[select]["idle_anim"])

func _ready() -> void:
	$StartupDelay.start()
	$Body.play(bodyAnim[0])

func _on_hurt_box_got_hurt(_damage: float) -> void:
	if $Health.iFrameTimer == null:
		$Health.temporaryInvul($Health.iFrameLength)
	if $Health.iFrameTimer.is_stopped() && $Health.health > 0:
		$Health.temporaryInvul($Health.iFrameLength)

func _on_health_health_empty() -> void:
	if !$Health.getInvul():
		die.emit()
	
func moveHandler(delta: float):
	var dir := Input.get_vector("Left", "Right", "Up", "Down")
	var mouse_pos = get_global_mouse_position()
	var anim: String
	
	# Set animation to idle if no inputs,
	# otherwise set animation to move
	if !dir.is_zero_approx():
		anim = bodyAnim[1]
		if $Body.animation != anim:
			$Body.play(anim)
	else:
		anim = bodyAnim[0]
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
		
	# Select weapon slot
	for i in range(weapons.size()):
		var slot = i + 1
		if (slot >= 10):
			slot = 0
		if Input.is_action_just_pressed("Slot_" + str(slot)):
			select = i
			break
	if Input.is_action_just_pressed("Slot_next"):
		select = (select + 1) % weaponCount
	if Input.is_action_just_pressed("Slot_prev"):
		if (select <= 0):
			select = weaponCount - 1
		else:
			select -= 1
	
	# Fire Weapon
	if $Weapon.animation == "None":
		return
	if Input.is_action_pressed("Fire"):
		var anim = weapons[select]["fire_anim"]
		if $Weapon.animation != anim:
			$Weapon.play(anim)
			
		# Initialize projectile to gameplay manager
		if (checkProjectiles() && weaponCooldown[select].is_stopped()):
			var p = projectile.instantiate()
			get_tree().current_scene.get_node("Projectiles").add_child(p)
			p.setType(select, targets, false)
			p.global_position = $Weapon/Mussle.global_position
			p.rotation = $Weapon/Mussle.global_rotation
			p.name = "P Projectile"
			p.add_to_group("Projectiles")
			
			# Start weapon cooldown
			weaponCooldown[select].start(weapons[select]["cooldown"])
	else:
		var anim = weapons[select]["idle_anim"]
		if $Weapon.animation != anim:
			$Weapon.play(anim)

func checkProjectiles() -> bool:
	return get_tree().current_scene.get("projectilesSpawn")

func _process(delta: float) -> void:
	# Remove targets that have left the SceneTree
	targets = targets.filter(
		func(target):
			return is_instance_valid(target)
	)
	
	# Open Pause Menu (Currently just ends game)
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
