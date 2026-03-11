class_name Manager
extends Node2D

func _ready() -> void:
	var db = Database.new()
	get_tree().root.add_child(db)
	db.name = "database"
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var positionElement = $HudLayer/HUD/Position
	var healthElement = $HudLayer/HUD/Health
	positionElement.text = "Position: " + str($Player.position)
	healthElement.text = "Health: " + str($Player/Health.getHealth())


func _on_player_die() -> void:
	call_deferred("gameOver")

func gameOver():
	if is_instance_valid($Player):
		$Player.queue_free()
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
