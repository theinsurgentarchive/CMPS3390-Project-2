class_name Player
extends CharacterBody2D

signal die

# Global Variables
@export var health: float = 100.0
@export var speed: float = 300.0
var projectile: PackedScene = load("res://Scenes/projectile.tscn")
var targets: Array
var selected: int = 0
var weaponCount: int = 3
var weaponCooldown: Array[Timer]
var weaponModifers: Array[Array]
var weaponColor: Array[Array]
var weapons: Array[Dictionary]
var bodyAnim: Array = ["Idle", "Move"]
var last_selected: int = -1
var weaponNameTween: Tween
var star_rng := RandomNumberGenerator.new()
var flash: bool = false

func initialize(weps: Array[Dictionary], mod: Array):
	# Get weapons
	weapons = weps
	weaponCount = weapons.size()
	for weapon in weapons:
		# Instantiate weapon delays
		var t = Timer.new()
		t.autostart = false
		t.one_shot = true
		t.wait_time = weapon["cooldown"]
		t.name = weapon["name"] + "Delay"
		$Weapon/Delay.add_child(t)
		weaponCooldown.append(t)
		
		# Instantiate weapon modifiers
		var mods = weapon["mods"].split(",")
		weaponModifers.append(mods)
		
		# Get weapon label color
		var color: Array = weapon["color"].split(",")
		color = color.map(
			func(elem):
				return float(elem)
		)
		weaponColor.append(color)
	
	# Set modifiers
	$Health.setMaxHealth(mod[0])
	speed = mod[1]
	selected = mod[2]
	last_selected = selected
	$Health.iFrameLength = mod[3]
	$Weapon.play(weapons[selected]["idle_anim"])

func _ready() -> void:
	star_rng.randomize()
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

func get_rainbow_color() -> Color:
	var colors := [
		Color(1.0, 0.2, 0.2),
		Color(1.0, 0.55, 0.15),
		Color(1.0, 0.9, 0.2),
		Color(0.2, 1.0, 0.35),
		Color(0.2, 0.75, 1.0),
		Color(0.45, 0.35, 1.0),
		Color(1.0, 0.25, 0.85)
	]
	return colors[star_rng.randi_range(0, colors.size() - 1)]

func spawn_weapon_name_stars(label: Label) -> void:
	if !is_instance_valid(label):
		return

	var parent_control = label.get_parent()
	if parent_control == null:
		return

	var label_size := label.size
	var left := label.position.x
	var right := label.position.x + label_size.x
	var top := label.position.y
	var bottom := label.position.y + label_size.y

	for i in range(16):
		var star := Label.new()
		star.text = "★"
		star.visible = true
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star.z_index = label.z_index + 1

		var star_color := get_rainbow_color()
		star.modulate = star_color

		var font_size := star_rng.randi_range(16, 26)
		star.add_theme_font_size_override("font_size", font_size)
		star.add_theme_color_override("font_color", star_color)
		star.add_theme_color_override("font_shadow_color", Color(star_color.r, star_color.g, star_color.b, 0.9))
		star.add_theme_constant_override("shadow_outline_size", 3)
		star.add_theme_constant_override("shadow_offset_x", 0)
		star.add_theme_constant_override("shadow_offset_y", 0)

		parent_control.add_child(star)

		var side := star_rng.randi_range(0, 3)
		var start_pos := Vector2.ZERO
		var end_offset := Vector2.ZERO

		match side:
			0: # top
				start_pos = Vector2(
					star_rng.randf_range(left - 4.0, right + 4.0),
					top - star_rng.randf_range(2.0, 8.0)
				)
				end_offset = Vector2(
					star_rng.randf_range(-70.0, 70.0),
					star_rng.randf_range(-85.0, -30.0)
				)
			1: # bottom
				start_pos = Vector2(
					star_rng.randf_range(left - 4.0, right + 4.0),
					bottom + star_rng.randf_range(2.0, 8.0)
				)
				end_offset = Vector2(
					star_rng.randf_range(-70.0, 70.0),
					star_rng.randf_range(30.0, 85.0)
				)
			2: # left
				start_pos = Vector2(
					left - star_rng.randf_range(4.0, 10.0),
					star_rng.randf_range(top - 4.0, bottom + 4.0)
				)
				end_offset = Vector2(
					star_rng.randf_range(-85.0, -30.0),
					star_rng.randf_range(-55.0, 55.0)
				)
			3: # right
				start_pos = Vector2(
					right + star_rng.randf_range(4.0, 10.0),
					star_rng.randf_range(top - 4.0, bottom + 4.0)
				)
				end_offset = Vector2(
					star_rng.randf_range(30.0, 85.0),
					star_rng.randf_range(-55.0, 55.0)
				)

		star.position = start_pos
		star.scale = Vector2.ONE

		var duration := star_rng.randf_range(0.6, 1.0)

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(star, "position", start_pos + end_offset, duration)
		tween.tween_property(star, "modulate:a", 0.0, duration)
		tween.tween_property(star, "scale", Vector2(0.3, 0.3), duration)
		tween.finished.connect(
			func():
				if is_instance_valid(star):
					star.queue_free()
		)

func show_weapon_name() -> void:
	if !get_tree().current_scene.has_node("HudLayer/HUD/WeaponName"):
		return

	var label = get_tree().current_scene.get_node("HudLayer/HUD/WeaponName") as Label
	var weapon_text := ""
	var weapon_color := Color.WHITE
	var color = weaponColor[selected]
	
	weapon_text = weapons[selected]["name"].to_upper()
	weapon_color = Color(color[0],color[1],color[2],color[3])

	label.text = weapon_text
	label.visible = true
	label.modulate = Color(1, 1, 1, 0)

	label.add_theme_color_override("font_color", weapon_color)
	label.add_theme_color_override("font_shadow_color", Color(weapon_color.r, weapon_color.g, weapon_color.b, 0.8))
	label.add_theme_constant_override("shadow_outline_size", 4)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)

	spawn_weapon_name_stars(label)

	if weaponNameTween != null and weaponNameTween.is_valid():
		weaponNameTween.kill()

	weaponNameTween = create_tween()
	weaponNameTween.tween_property(label, "modulate:a", 1.0, 0.2)
	weaponNameTween.tween_interval(0.8)
	weaponNameTween.tween_property(label, "modulate:a", 0.0, 0.8)
	await weaponNameTween.finished
	if is_instance_valid(label):
		label.visible = false

func wepHandler():
	# Starting Delay
	if !$StartupDelay.is_stopped():
		return
		
	var changed_weapon := false
		
	# Select weapon slot
	for i in range(weapons.size()):
		var slot = i + 1
		if slot >= 10:
			slot = 0
		if Input.is_action_just_pressed("Slot_" + str(slot)):
			if selected != i:
				selected = i
				changed_weapon = true
			break

	if Input.is_action_just_pressed("Slot_next"):
		selected = (selected + 1) % weaponCount
		changed_weapon = true

	if Input.is_action_just_pressed("Slot_prev"):
		if selected <= 0:
			selected = weaponCount - 1
		else:
			selected -= 1
		changed_weapon = true

	if changed_weapon and selected != last_selected:
		last_selected = selected
		show_weapon_name()
	
	# Fire Weapon
	if $Weapon.animation == "None":
		return

	if Input.is_action_pressed("Fire"):
		var anim = weapons[selected]["fire_anim"]
		if $Weapon.animation != anim:
			$Weapon.play(anim)
			
		# Initialize projectile to gameplay manager
		if checkProjectiles() && weaponCooldown[selected].is_stopped():
			var p = projectile.instantiate()
			get_tree().current_scene.get_node("Projectiles").add_child(p)
			var mods: Array = [
				weapons[selected]["projectile"],
				weapons[selected]["start_speed"],
				weapons[selected]["speed"],
				weapons[selected]["damage"],
				weaponModifers[selected]
			]
			p.setType(targets, false, mods)
			p.global_position = $Weapon/Mussle.global_position
			p.rotation = $Weapon/Mussle.global_rotation
			p.name = "P Projectile"
			p.add_to_group("Projectiles")
			
			# Start weapon cooldown
			weaponCooldown[selected].start(weapons[selected]["cooldown"])
	else:
		var anim = weapons[selected]["idle_anim"]
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
	if $Health.getInvul():
		flash = !flash
	else:
		flash = false

func _physics_process(delta: float) -> void:
	modulate = Color(1.0, 0.247, 0.188, 0.714) if flash else Color.WHITE
	moveHandler(delta)
	wepHandler()

func _on_lock_on_box_body_entered(body: Node2D) -> void:
	if body == self || body is Projectile || body is Arena:
		return
	targets.append(body)

func _on_lock_on_box_body_exited(body: Node2D) -> void:
	targets.erase(body)
