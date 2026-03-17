extends Control

@onready var volume_slider: HSlider = $Volume/VolumeSlider
@onready var volume_label: Label = $Volume/VolLabel

@onready var difficulty_slider: HSlider = $Difficulty/DifficultySlider
@onready var difficulty_label: Label = $Difficulty/DiffLabel


func _ready() -> void:
	setup_volume_slider()
	setup_difficulty_slider()
	load_saved_values()


func setup_volume_slider() -> void:
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 1

	if !volume_slider.value_changed.is_connected(_on_volume_changed):
		volume_slider.value_changed.connect(_on_volume_changed)

func setup_difficulty_slider() -> void:
	difficulty_slider.min_value = 0
	difficulty_slider.max_value = 3
	difficulty_slider.step = 1

	if !difficulty_slider.value_changed.is_connected(_on_difficulty_changed):
		difficulty_slider.value_changed.connect(_on_difficulty_changed)

func load_saved_values() -> void:
	volume_slider.value = GameSettings.volume * 100.0
	update_volume_label(volume_slider.value)

	difficulty_slider.value = GameSettings.difficulty_index
	update_difficulty_label(GameSettings.difficulty_index)

func _on_volume_changed(value: float) -> void:
	var normalized := value / 100.0
	GameSettings.set_volume(normalized)
	update_volume_label(value)

func _on_difficulty_changed(value: float) -> void:
	var index := int(value)
	GameSettings.set_difficulty(index)
	update_difficulty_label(index)

func update_volume_label(value: float) -> void:
	volume_label.text = "Volume: " + str(int(round(value))) + "%"

func update_difficulty_label(index: int) -> void:
	var diff_name := ""
	var diff_color := Color.WHITE

	match index:
		0:
			diff_name = "Easy"
			diff_color = Color(0.2, 1.0, 0.35)
		1:
			diff_name = "Medium"
			diff_color = Color(1.0, 0.9, 0.2)
		2:
			diff_name = "Hard"
			diff_color = Color(1.0, 0.2, 0.2)
		3:
			diff_name = "Critical"
			diff_color = Color(0.8, 0.3, 1.0)

	difficulty_label.text = "Difficulty: " + diff_name
	difficulty_label.add_theme_color_override("font_color", diff_color)
	difficulty_label.add_theme_color_override("font_shadow_color", diff_color)
	difficulty_label.add_theme_constant_override("shadow_outline_size", 4)
	difficulty_label.add_theme_constant_override("shadow_offset_x", 0)
	difficulty_label.add_theme_constant_override("shadow_offset_y", 0)

func _on_back_pressed() -> void:
	GameSettings.save_settings()
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
