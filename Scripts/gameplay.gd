extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
<<<<<<< Updated upstream
	pass # Replace with function body.
=======
	$HudLayer/PauseMenu.visible = false
	
	# Load saved difficulty from settings
	if Engine.has_singleton("GameSettings") or get_tree().root.get_node_or_null("GameSettings") != null:
		difficulty = GameSettings.get_difficulty_multiplier()

	# Pause menu music
	MusicPlayer.stop()

	# Set wave timer
	time = Timer.new()
	time.name = "WaveTimer"
	time.autostart = false
	time.one_shot = true
	time.wait_time = 2.5
	get_tree().current_scene.add_child(time)

	connect("waveComplete", completeWave)
	connect("waveStarting", startWave)

	# Get database node
	db = get_tree().root.get_node_or_null("Database")
	assert(db != null, "Database node not found...")

	# Get score node
	s = get_tree().root.get_node_or_null("Score")
	assert(s != null, "Score node not found...")

	# Initialize Player Node
	p = player.instantiate()
	p.name = "Player"
	get_tree().current_scene.add_child(p)

	var weps: Array = db.getWeapons()
	var mod = [health, speed, defaultSelect, invulerabilityTimer]
	p.initialize(weps, mod)
	p.die.connect(_on_player_die)

	$Enemies.set_script(waveGen)
	$Enemies.initialize(db, difficulty)
>>>>>>> Stashed changes


func _process(delta: float) -> void:
<<<<<<< Updated upstream
	var hud = $hudLayer/hud/position
	hud.text = "Position: " + str($Player.position)
=======
	var positionElement = $HudLayer/HUD/Position
	var healthElement = $HudLayer/HUD/Health
	var ScoreElement = $HudLayer/HUD/Score

	positionElement.text = "Position: " + str($Player.position)
	healthElement.text = "Health: " + str($Player/Health.getHealth())
	ScoreElement.text = "Score: " + str(s.getScore())

	# Limit projectile count
	var group = get_tree().get_nodes_in_group("Projectiles")
	var num = group.size()
	if num >= maxProjectiles:
		projectilesSpawn = false
	else:
		projectilesSpawn = true

	# Spawn wave
	if enemies.is_empty():
		if !waveOver:
			waveOver = true
			if wave != 0:
				waveComplete.emit(wave)
				print("Wave: %s Completed." % [wave])
			wave += 1
			time.start()

		if time.is_stopped():
			if waveOver:
				waveOver = false
				waveStarting.emit(wave)

			enemies = $Enemies.genWave(wave)
			for e in enemies:
				e.enemyDeath.connect(_on_enemy_death)
			print("Spawned Wave: %s" % [wave])

func _on_player_die() -> void:
	if pauseReturn:
		return
	call_deferred("gameOver")

func _on_enemy_death(value: int, e: Enemy) -> void:
	s.setScore(s.score + value)
	enemies.erase(e)
	print("Enemy died")

func gameOver():
	if is_instance_valid($Player):
		$Player.queue_free()
	get_tree().change_scene_to_file("res://Scenes/gameover.tscn")

func _on_pause_menu_emit() -> void:
	pauseReturn = true
>>>>>>> Stashed changes
