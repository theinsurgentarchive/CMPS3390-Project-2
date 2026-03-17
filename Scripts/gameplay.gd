class_name Manager
extends Node2D

signal waveComplete(wave: int)
signal waveStarting(wave: int)

@export var maxProjectiles: int = 12000
@export var waveGen: Script = load("res://Scripts/wave.gd")
@export var difficulty: int = 1
@export var health: float = 100.0
@export var speed: float = 300.0
@export var defaultSelect: int = 0
@export var invulerabilityTimer: float = 0.5
var projectilesSpawn: bool = true
var db: Database
var s: Score
var time: Timer
var p: Player
var player: PackedScene = load("res://Scenes/player.tscn")
var enemy: PackedScene = load("res://Scenes/Enemy.tscn")
var enemies: Array = []
var wave: int = 0
var waveOver: bool = false
var pauseReturn: bool = false

func _ready() -> void:
	$HudLayer/PauseMenu.visible = false
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

func completeWave(wave: int):
	$HudLayer/HUD/Wave/Text.text = "Wave " + str(wave) + " Finish"
	$HudLayer/HUD/Wave.color = Color(0.376, 0.651, 0.253, 0.514)
	$HudLayer/HUD/Wave.show()
	var tween = create_tween()
	tween.tween_property($HudLayer/HUD/Wave, "modulate:a", 1.0, 0.3).from(0.0)
	await tween.finished
	await get_tree().create_timer(2.2).timeout
	$HudLayer/HUD/Wave.hide()

func startWave(wave: int):
	$HudLayer/HUD/Wave/Text.text = "Wave " + str(wave) + " Start"
	$HudLayer/HUD/Wave.color = Color(0.847, 0.443, 0.184, 0.514)
	$HudLayer/HUD/Wave.show()
	var tween = create_tween()
	tween.tween_property($HudLayer/HUD/Wave, "modulate:a", 1.0, 0.3).from(0.0)
	await tween.finished
	await get_tree().create_timer(2.2).timeout
	$HudLayer/HUD/Wave.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	# time.start()
	print("Enemy died")

func gameOver():
	if is_instance_valid($Player):
		$Player.queue_free()
	get_tree().change_scene_to_file("res://Scenes/gameover.tscn")


func _on_pause_menu_emit() -> void:
	pauseReturn = true
	$ActionPhase.stop()
