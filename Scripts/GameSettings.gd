extends Node

const SAVE_PATH: String = "user://settings.cfg"

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	CRITICAL
}

var volume: float = 0.15
var difficulty_index: int = Difficulty.MEDIUM

func _ready() -> void:
	load_settings()
	apply_audio()

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)

	if err != OK:
		# First launch defaults
		volume = 0.5
		difficulty_index = Difficulty.MEDIUM
		save_settings()
		apply_audio()
		return

	volume = clamp(float(config.get_value("audio", "volume", 0.5)), 0.0, 1.0)
	difficulty_index = clamp(int(config.get_value("game", "difficulty_index", Difficulty.MEDIUM)), 0, 3)
	apply_audio()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("game", "difficulty_index", difficulty_index)
	config.save(SAVE_PATH)

func set_volume(value: float) -> void:
	volume = clamp(value, 0.0, 1.0)
	apply_audio()
	save_settings()

func apply_audio() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index == -1:
		return

	if volume <= 0.0:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

func set_difficulty(index: int) -> void:
	difficulty_index = clamp(index, 0, 3)
	save_settings()

func get_difficulty_multiplier() -> int:
	return difficulty_index + 1

func get_difficulty_name() -> String:
	match difficulty_index:
		Difficulty.EASY:
			return "Easy"
		Difficulty.MEDIUM:
			return "Medium"
		Difficulty.HARD:
			return "Hard"
		Difficulty.CRITICAL:
			return "Critical"
		_:
			return "Medium"

func get_difficulty_color() -> Color:
	match difficulty_index:
		Difficulty.EASY:
			return Color(0.2, 1.0, 0.35)
		Difficulty.MEDIUM:
			return Color(1.0, 0.9, 0.2)
		Difficulty.HARD:
			return Color(1.0, 0.2, 0.2)
		Difficulty.CRITICAL:
			return Color(0.8, 0.3, 1.0)
		_:
			return Color.WHITE
