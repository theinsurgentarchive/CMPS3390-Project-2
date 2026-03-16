class_name Database
extends Node

var db: SQLite

func _ready() -> void:
	db = SQLite.new()

	# FORCE using the required project DB file
	db.path = "res://sql/data.db"
	print("Database: FORCED DB PATH = " + db.path)

	var dbOK: bool = db.open_db()
	assert(dbOK, "Database connection failed...")
	print("Database: DB opened successfully (res://sql/data.db).")

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
		print_debug("Database: Player already exists: " + n)
		pid = exists[0]["id"]

		query = '''
			INSERT INTO leaderboard(id, score) VALUES (:id, :score)
			ON CONFLICT(id) DO UPDATE SET score = :score;
		'''
		binding = {"id": pid, "score": score}
		ok = db.query_with_named_bindings(query, binding)
		assert(ok, "Failed to insert/update leaderboard for Player " + str(pid) + "...")

		print_debug("Database: SAVED SCORE (existing) -> name='" + n + "' id=" + str(pid) + " score=" + str(score))

	else:
		print_debug("Database: Generating new Player: " + n)

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

		print_debug("Database: SAVED SCORE (new) -> name='" + n + "' id=" + str(pid) + " score=" + str(score))

# [{ "rank": 1, "name": "PlayerName", "score": 1234 }, ...]
func get_leaderboard(limit: int = 10) -> Array:
	print_debug("Database: Reading leaderboard from FORCED DB: " + db.path)

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
