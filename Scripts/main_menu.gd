extends Control

# Update these paths if your scenes are named differently.
@export var start_scene: String = "res://Scenes/gameplay.tscn"
@export var settings_scene: String = "res://Scenes/settings.tscn"
@export var credits_scene: String = "res://Scenes/credits.tscn"
@export var leaderboards_scene: String = "res://Scenes/leaderboards.tscn"
@export var quit_scene: String = "res://Scenes/quit.tscn"
var db: Database

func _ready() -> void:
	#start menu music
	MusicPlayer.play()
	# Start database node
	db = get_tree().root.get_node_or_null("Database")
	if db == null:
		db = Database.new()
		db.name = "Database"
		get_tree().root.add_child.call_deferred(db)
	
	# Start score node
	var s = get_tree().root.get_node_or_null("Score")
	if s == null:
		s = Score.new()
		s.name = "Score"
		get_tree().root.add_child.call_deferred(s)
	
	var start_btn := get_node_or_null("ColorRect/MarginContainer/VBoxContainer/StartBtn")
	if start_btn:
		start_btn.grab_focus()

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file(start_scene)

func _on_settings_btn_pressed() -> void:
	get_tree().change_scene_to_file(settings_scene)

func _on_credits_btn_pressed() -> void:
	get_tree().change_scene_to_file(credits_scene)

func _on_leader_btn_pressed() -> void:
	SceneHistory.push(get_tree().current_scene.scene_file_path)
	get_tree().change_scene_to_file(leaderboards_scene)

func _on_quit_btn_pressed() -> void:
	db.get("db").close_db()
	get_tree().quit()
