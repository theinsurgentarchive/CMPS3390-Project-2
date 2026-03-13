class_name Wave
extends Node

var enemy: PackedScene = load("res://Scenes/Enemy.tscn")
var rng: RandomNumberGenerator
var db: Database = null

var weights: Dictionary = {}
var difficulty: int = 1
var data: Array = []

func initialize(conn: Database, diff: int) -> bool:
	db = conn
	difficulty = diff
	data = db.getEnemies()
	rng = RandomNumberGenerator.new()
	rng.randomize()
	if db != null && !data.is_empty():
		genWeights(data)
		return true
	return false

func genWave(wave: int) -> Array:
	var amount = 1 + (wave * difficulty * rng.randi_range(1, 5))
	print("Enemies in this round: %s" % [str(amount)])
	var enemies = []
	for i in amount:
		var type = randType()
		assert(type > -1, "Enemy type randomizer failed...")
		var e = genEnemy(type)
		assert(e != null, "Enemy generation failed...")
		enemies.append(e)
	assert(!enemies.is_empty(), "No enemies generated...")
	return enemies

func genWeights(items: Array):
	for item in items:
		var key = item["id"]
		var value = item["weight"]
		weights[key] = value
	prints(weights)

func randType() -> int:
	var sum := 0
	for key in weights:
		sum += weights[key]
	var random = rng.randi_range(0, sum - 1)
	for key in weights:
		print(random)
		if random < weights[key]:
			return key - 1
		random -= weights[key]
	print(random)
	return -1

func genEnemy(type: int):
	var e = enemy.instantiate()
	get_tree().current_scene.get_node("Enemies").add_child(e)
	e.add_to_group("Enemies")
	assert((type <= data.size() && type > -1), "Type not in range...")
	assert(data[type] != null, "Enemy data not found...")
	var a: Dictionary
	a[1] = type
	a[2] = data[type]["health"]
	a[3] = data[type]["damage"]
	a[4] = data[type]["speed"]
	a[5] = data[type]["worth"]
	a[6] = load(data[type]["sprite"])
	a[7] = Vector2(
		rng.randf_range(-999.0, 999.0), rng.randf_range(-999.0, 999.0)
	)
	a[8] = get_tree().current_scene.get_node("Player")
	e.initialize(a)
	return e
