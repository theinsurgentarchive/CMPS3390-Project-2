class_name Manager
extends Node2D

signal waveComplete(wave: int)
signal waveStarting(wave: int)

@export var maxProjectiles: int = 12000
@export var waveGen: Script = load("res://Scripts/wave.gd")
@export var difficulty: int = 1
var projectilesSpawn: bool = true
var db: Database
var s: Score
var time: Timer
var enemy: PackedScene = load("res://Scenes/Enemy.tscn")
var enemies: Array = []
var wave = 0
var waveOver: bool = false

func _ready() -> void:
	# Set wave timer
	time = Timer.new()
	time.name = "WaveTimer"
	time.autostart = false
	time.one_shot = true
	time.wait_time = 2.5
	get_tree().current_scene.add_child(time)
	
	# Get database node
	db = get_tree().root.get_node_or_null("Database")
	assert(db != null, "Database node not found...")
	
	# Get score node
	s = get_tree().root.get_node_or_null("Score")
	assert(s != null, "Score node not found...")
	
	$Enemies.set_script(waveGen)
	$Enemies.initialize(db, difficulty)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var positionElement = $HudLayer/HUD/Position
	var healthElement = $HudLayer/HUD/Health

	positionElement.text = "Position: " + str($Player.position)
	healthElement.text = "Health: " + str($Player/Health.getHealth())
	
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
			# e = enemy.instantiate()
			# get_tree().current_scene.get_node("Enemies").add_child(e)
			# e.add_to_group("Enemies")
			# e.type = 0
			# e.enemyDeath.connect(_on_enemy_death)
func _on_player_die() -> void:
	call_deferred("gameOver")

func _on_enemy_death(value: int, e: Enemy) -> void:
	s.setScore(s.score + value)
	enemies.erase(e)
	# time.start()
	print("Enemy died")

func gameOver():
	if is_instance_valid($Player):
		$Player.queue_free()
	get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
