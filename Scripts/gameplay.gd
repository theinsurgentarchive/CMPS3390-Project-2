extends Node2D

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
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
