class_name Manager
extends Node2D

@export var maxProjectiles: int = 20
var projectilesSpawn:bool = true
var db: Database
var s: Score
var e: Enemy
var time: Timer
var enemy: PackedScene = load("res://Scenes/Enemy.tscn")
var enemies: Array = []
var wave = 0

func _ready() -> void:
	# Set wave timer
	time = Timer.new()
	get_tree().current_scene.add_child(time)
	time.one_shot = true
	time.wait_time = 2.5
	
	# Get database node
	if get_tree().root.get_node_or_null("Database") == null:
		db = Database.new()
		get_tree().root.add_child(db)
		db.name = "Database"
	else:
		db = get_tree().root.get_node("Database")
	
	# Get score node
	if get_tree().root.get_node_or_null("Score") == null:
		s = Score.new()
		get_tree().root.add_child(s)
		s.name = "Score"
	else:
		s = get_tree().root.get_node("Score")

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
	if enemies.is_empty() && time.is_stopped():
		e = enemy.instantiate()
		get_tree().current_scene.get_node("Enemies").add_child(e)
		e.add_to_group("Enemies")
		e.enemyDeath.connect(_on_enemy_death)
		enemies.append(e)
		print("Spawned Wave: %s" % [wave + 1])
		wave += 1

func _on_player_die() -> void:
	call_deferred("gameOver")

func _on_enemy_death(value: int, e: Enemy) -> void:
	s.setScore(s.score + value)
	enemies.erase(e)
	time.start()
	print("Enemy died")

func gameOver():
	if is_instance_valid($Player):
		$Player.queue_free()
	get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
