class_name Database
extends Node

var db: SQLite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	var file = FileAccess
	var path = "res://sql/data.db"
	db.path = path
	db.open_db()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
