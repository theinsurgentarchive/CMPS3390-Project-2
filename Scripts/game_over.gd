extends Control

var data: Database
var score: Score
var value: int

func _ready() -> void:
	# Ensure Database exists even if GameOver is run directly.
	var existing = get_tree().root.get_node_or_null("Database")
	if existing == null:
		var db: Database = Database.new()
		db.name = "Database"
		get_tree().root.add_child(db)
		print_debug("GAME_OVER: Database created at /root/Database")
		data = db
	else:
		data = existing as Database
		print_debug("GAME_OVER: Found Database at /root/Database")

	assert(data != null, "Database node not found...")

	score = get_tree().root.get_node("Score")
	assert(score != null, "Score node not found...")

	value = score.getScore()
	$Score.text = "Score: " + str(value)

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	var name: String = $UserInput.text.strip_edges()
	if name == "":
		return
	_on_line_edit_text_submitted(name)

func _on_line_edit_text_submitted(new_text: String) -> void:
	var name: String = new_text.strip_edges()
	if name == "":
		return

	data.addScore(value, name)
	print_debug("GAME_OVER: submitted name='" + name + "' score=" + str(value))
	$Score.text = "Score added to Leaderboard, returning to Main Menu."
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")


func _on_exit_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")


func _on_exit_desktop_pressed() -> void:
	$Score.text = "Goodbye!!!"
	await get_tree().create_timer(1.2).timeout
	get_tree().quit()
