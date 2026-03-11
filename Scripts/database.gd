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

func getEnemy(type: int):
	var exists = db.select_rows("enemy", "id == '%s'" % [str(type)], ["*"])
	assert(!exists.is_empty(), "Enemy not found...");
	return exists[0]

func getWeapon(type: int):
	var exists = db.select_rows("weapon", "id == '%s'" % [str(type)], ["*"])
	assert(!exists.is_empty(), "Weapon not found...");
	return exists[0]

func addScore(score: int, n: String):
	var exists = db.select_rows("player", "name == '%s'" % [n], ["*"])
	var binding
	var query
	var fail
	var pid
	if !exists.is_empty():
		print_debug("Player already exists.")
		pid = exists[0]["id"]
		query = '''
			INSERT INTO leaderboard(id, score) VALUES (:id, :score)
			ON CONFLICT(id) DO UPDATE SET score = :score;
		''';
		binding = {"id": pid, "score": score}
		fail = db.query_with_named_bindings(query, binding)
		assert(fail, "Failed to insert Player " + str(pid) + " Score...")
	else:
		print_debug("Generating Player...")
		query = "INSERT INTO player(name) VALUES (?)"
		binding = [n]
		fail = db.query_with_bindings(query, binding)
		assert(fail, "Player generation failed...")
		pid = db.last_insert_rowid
		query = '''
			INSERT INTO leaderboard(id, score) VALUES (:id, :score)
			ON CONFLICT(id) DO UPDATE SET score = :score;
		''';
		binding = {"id": pid, "score": score}
		fail = db.query_with_named_bindings(query, binding)
		assert(fail, "Failed to insert Player " + str(pid) + " Score...")
