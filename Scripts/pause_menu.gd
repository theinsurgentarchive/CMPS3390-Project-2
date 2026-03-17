extends Control

signal emit

var score: Score
var db: Database
var selected: bool
func _ready() -> void:
	# Get database
	db = get_tree().root.get_node_or_null("Database")
	assert(db != null, "Database node not found...")
	
	# Get score
	score = get_tree().root.get_node("Score")
	assert(score != null, "Score node not found...")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		togglePause()

func togglePause():
	if selected:
		return
	if !visible:
		$Background/Score.text = "Score: " + str(score.getScore())
		MusicPlayer.play()
	else:
		MusicPlayer.stop()
	visible = !visible
	get_tree().paused = !get_tree().paused

func _on_continue_pressed() -> void:
	if selected:
		return
	togglePause()


func _on_menu_exit_pressed() -> void:
	if selected:
		return
	selected = true
	$Background/Score.text = "Returning to Main Menu..."
	get_tree().paused = false
	emit.emit()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")


func _on_desktop_exit_pressed() -> void:
	if selected:
		return
	selected = true
	$Background/Score.text = "Goodbye!!!"
	get_tree().paused = false
	emit.emit()
	await get_tree().create_timer(2.0).timeout
	db.get("db").close_db()
	get_tree().quit()
