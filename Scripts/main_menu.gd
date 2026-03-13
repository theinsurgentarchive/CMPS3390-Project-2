extends Control

# Update these paths if your scenes are named differently.
@export var start_scene: String = "res://Scenes/gameplay.tscn"
@export var settings_scene: String = "res://Scenes/settings.tscn"
@export var credits_scene: String = "res://Scenes/credits.tscn"
@export var leaderboards_scene: String = "res://Scenes/leaderboards.tscn"
@export var quit_scene: String = "res://Scenes/quit.tscn"

func _ready() -> void:
	# Ensure Database exists as soon as the game starts (before any gameplay).
	if get_tree().root.get_node_or_null("Database") == null:
		var db: Database = Database.new()
		db.name = "Database"
		# Defer adding to root until it's safe
		get_tree().root.call_deferred("add_child", db)
		print_debug("MAIN_MENU: Deferring Database add_child() to /root/Database")
	else:
		print_debug("MAIN_MENU: Database already exists at /root/Database")

	# Optional: if you want keyboard/gamepad navigation to start on StartBtn.
	var start_btn := get_node_or_null("ColorRect/MarginContainer/VBoxContainer/StartBtn")
	if start_btn:
		start_btn.grab_focus()

func _process(delta: float) -> void:
	pass

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
	get_tree().quit()
