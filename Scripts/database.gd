class_name Database
extends Node

const DATABASE_RES = "res://sql/data.db"
const DATABASE_USER = "user://data.db"

var db: SQLite

func _ready() -> void:
	# Create database connection
	var dir = DirAccess.open("user://")
	# Check if the database file exists in the user path; if not, copy it from resources
	if !dir.file_exists(DATABASE_USER):
		var db_file_content: PackedByteArray = FileAccess.get_file_as_bytes(DATABASE_RES)
		var file: FileAccess = FileAccess.open(DATABASE_USER, FileAccess.WRITE)
		file.store_buffer(db_file_content)
		file.close()
	db = SQLite.new()
	db.path = DATABASE_USER
	var dbOK: bool = db.open_db()
	assert(dbOK, "Database connection failed...")
	print("Database: DB opened successfully")
	
	# Run startup script
	var q: String = FileAccess.get_file_as_string("res://sql/sqltables.sql")
	db.query(q)

func getEnemy(type: int):
	var exists = db.select_rows("enemy", "id == '%s'" % [str(type)], ["*"])
	assert(!exists.is_empty(), "Enemy not found...")
	return exists[0]

func getEnemies():
	var enemies = db.select_rows("enemy", "", ["*"])
	return enemies

func getWeapon(type: int):
	var exists = db.select_rows("weapon", "id == '%s'" % [str(type)], ["*"])
	assert(!exists.is_empty(), "Weapon not found...")
	return exists[0]

func getWeapons():
	var weapons = db.select_rows("weapon", "", ["*"])
	return weapons

func addScore(score: int, n: String):
	var exists = db.select_rows("player", "name == '%s'" % [n], ["*"])
	var binding
	var query
	var ok
	var pid

	if !exists.is_empty():
		print("Database: Player already exists: " + n)
		pid = exists[0]["id"]
		var current = db.select_rows("leaderboard", "id == %s" % [pid], ["score"])
		if score <= current[0]["score"]:
			print("Database: CURRENT SCORE RETAINED, input less than or equal to current")
			return
		query = '''
			INSERT INTO leaderboard(id, score) VALUES (:id, :score)
			ON CONFLICT(id) DO UPDATE SET score = :score;
		'''
		binding = {"id": pid, "score": score}
		ok = db.query_with_named_bindings(query, binding)
		assert(ok, "Failed to insert/update leaderboard for Player " + str(pid) + "...")
	
		print("Database: SAVED SCORE (existing) -> name='" + n + "' id=" + str(pid) + " score=" + str(score))

	else:
		print("Database: Generating new Player: " + n)

		query = "INSERT INTO player(name) VALUES (?)"
		binding = [n]
		ok = db.query_with_bindings(query, binding)
		assert(ok, "Player generation failed...")

		pid = db.last_insert_rowid

		query = '''
			INSERT INTO leaderboard(id, score) VALUES (:id, :score)
			ON CONFLICT(id) DO UPDATE SET score = :score;
		'''
		binding = {"id": pid, "score": score}
		ok = db.query_with_named_bindings(query, binding)
		assert(ok, "Failed to insert/update leaderboard for Player " + str(pid) + "...")

		print("Database: SAVED SCORE (new) -> name='" + n + "' id=" + str(pid) + " score=" + str(score))

# [{"name": "PlayerName", "score": 1234}, ...]
# array index is the row's rank
func get_leaderboard(limit: int = 15) -> Array:
	print("Database: Reading leaderboard from FORCED DB: " + db.path)

	var query = """
		SELECT p.name AS name, l.score AS score
		FROM leaderboard l
		INNER JOIN player p ON p.id = l.id
		ORDER BY l.score DESC
		LIMIT :limit;
	"""
	var ok = db.query_with_named_bindings(query, {"limit": limit})
	assert(ok, "Failed to read leaderboard...")

	var rows: Array = []
	if db.query_result == null:
		return rows

	var rank := 1
	for r in db.query_result:
		rows.append({
			"rank": rank,
			"name": str(r.get("name", "")),
			"score": int(r.get("score", 0))
		})
		rank += 1

	return rows
