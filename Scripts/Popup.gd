extends Button

enum types {
	CONFIRM,
	CANCEL
}

signal confirmed(id: int)
signal denied

var id: int
@export var type: types
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed", _on_popup_pressed)

func _on_popup_pressed():
	match type:
		types.CONFIRM:
			confirmed.emit(id)
		types.CANCEL:
			denied.emit()
