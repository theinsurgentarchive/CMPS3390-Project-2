extends Node

var stack: Array[String] = []

func push(scene_path: String) -> void:
	if scene_path == "":
		return
	if stack.is_empty() or stack[-1] != scene_path:
		stack.append(scene_path)

func back(fallback_scene: String = "res://Scenes/mainMenu.tscn") -> void:
	if stack.is_empty():
		get_tree().change_scene_to_file(fallback_scene)
		return

	var prev: String = String(stack.pop_back())
	get_tree().change_scene_to_file(prev)
