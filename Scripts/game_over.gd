extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	$Timer.start()
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
