class_name Manager
extends Node2D

@export var maxProjectiles: int = 20
var db: Database
var s: Score

func _ready() -> void:
	if get_tree().root.get_node_or_null("Database") == null:
		db = Database.new()
		get_tree().root.add_child(db)
		db.name = "Database"
	else:
		db = get_tree().root.get_node("Database")
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
	var nameElement = $HudLayer/HUD/PlayerName

	positionElement.text = "Position: " + str($Player.position)
	healthElement.text = "Health: " + str($Player/Health.getHealth())
	

	# ✅ Correct way to access an Autoload called "GameData"
	var pname := ""
	if has_node("/root/GameData"):
		pname = get_node("/root/GameData").player_name

	if pname.strip_edges() == "":
		pname = "Player"

	nameElement.text = "Name: " + pname


func _on_player_die() -> void:
	call_deferred("gameOver")

func gameOver():
	if is_instance_valid($Player):
		$Player.queue_free()
	get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
