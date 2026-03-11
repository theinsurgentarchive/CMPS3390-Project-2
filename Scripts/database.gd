class_name Database
extends Node

var db: SQLite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	var file = FileAccess
	var path = "res://sql/data.db"
	db.path = path
	var dbOK = db.open_db()
	if !dbOK:
		printerr(Error.ERR_CANT_CONNECT)
		return
	var q = file.get_file_as_string("res://sql/sqltables.sql")
	db.query(q)
