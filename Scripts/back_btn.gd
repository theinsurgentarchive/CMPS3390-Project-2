extends TextureButton

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		_pressed()

func _pressed() -> void:
	SceneHistory.back("res://Scenes/mainMenu.tscn")
