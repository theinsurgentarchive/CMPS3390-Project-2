extends Control

var data: Database

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data = get_tree().root.get_node("Database")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	if $UserInput.text_changed && $UserInput.text != "":
		_on_line_edit_text_submitted($UserInput.text)

func _on_line_edit_text_submitted(new_text: String) -> void:
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
