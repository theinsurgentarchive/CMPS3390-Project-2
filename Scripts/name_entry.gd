extends Control

@export var start_scene: String = "res://Scenes/gameplay.tscn"

var name_input: LineEdit
var error_label: Label

func _ready() -> void:
	# Find by node name anywhere under this scene
	name_input = find_child("NameInput", true, false) as LineEdit
	error_label = find_child("ErrorLabel", true, false) as Label

	if error_label:
		error_label.visible = false

	if name_input:
		name_input.grab_focus()
		name_input.text_submitted.connect(_on_name_submitted)
	else:
		push_error("NameInput not found or not a LineEdit. Rename your LineEdit node to 'NameInput'.")

func _on_continue_btn_pressed() -> void:
	if not name_input:
		return
	_submit_name(name_input.text)

func _on_name_submitted(text: String) -> void:
	_submit_name(text)

func _submit_name(raw: String) -> void:
	var cleaned := raw.strip_edges()

	if cleaned.is_empty():
		if error_label:
			error_label.text = "Please enter a name."
			error_label.visible = true
		return

	if cleaned.length() > 16:
		cleaned = cleaned.left(16)

	GameData.player_name = cleaned
	get_tree().change_scene_to_file(start_scene)
