extends Control

@export var max_entries: int = 10
@export var fly_in_offset: float = 500.0
@export var fly_in_duration: float = 0.75
@export var stagger: float = 0.12

# Rainbow/glow tuning
@export var rainbow_speed: float = 0.9
@export var rainbow_brightness: float = 1.6

@onready var scores_list: VBoxContainer = $Panel/ScoresList

var data: Database
var rainbow_mat: ShaderMaterial

func _ready() -> void:
	# Build rainbow material once
	rainbow_mat = _make_rainbow_glow_material(rainbow_speed, rainbow_brightness)

	# Ensure Database exists even if this scene is run directly.
	var existing = get_tree().root.get_node_or_null("Database")
	if existing == null:
		var db: Database = Database.new()
		db.name = "Database"
		get_tree().root.add_child(db)
		print("LEADERBOARDS: Database created at /root/Database")
		data = db
	else:
		data = existing as Database
		print("LEADERBOARDS: Found Database at /root/Database")

	assert(data != null, "Database node not found...")
	refresh()

func _make_rainbow_glow_material(speed: float, brightness: float) -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;

uniform float speed = 0.9;
uniform float brightness = 1.6;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float a = tex.a * COLOR.a;

	float h = fract(TIME * speed);
	vec3 rainbow = hsv2rgb(vec3(h, 1.0, 1.0));

	vec3 rgb = rainbow * brightness;
	COLOR = vec4(rgb, a);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("speed", speed)
	mat.set_shader_parameter("brightness", brightness)
	return mat

func refresh() -> void:
	# Clear old rows
	for child in scores_list.get_children():
		child.queue_free()

	var rows: Array = data.get_leaderboard(max_entries)

	if rows.is_empty():
		var lbl := Label.new()
		lbl.text = "No scores yet."
		scores_list.add_child(lbl)
		return

	# Build UI rows and keep references for animation
	var created_rows: Array[Control] = []

	var idx := 0
	for row in rows:
		var h := HBoxContainer.new()
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var rank_lbl := Label.new()
		rank_lbl.text = "#%d" % int(row["rank"])
		rank_lbl.custom_minimum_size.x = 60

		var name_lbl := Label.new()
		name_lbl.text = str(row["name"])
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var score_lbl := Label.new()
		score_lbl.text = str(int(row["score"]))
		score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score_lbl.custom_minimum_size.x = 120

		# Apply rainbow glow ONLY to #1 player rank + name + score
		if idx == 0:
			rank_lbl.material = rainbow_mat
			name_lbl.material = rainbow_mat
			score_lbl.material = rainbow_mat

		h.add_child(rank_lbl)
		h.add_child(name_lbl)
		h.add_child(score_lbl)

		# start invisible (we'll fade in)
		h.modulate.a = 0.0

		scores_list.add_child(h)
		created_rows.append(h)

		idx += 1

	# Wait 1 frame so VBoxContainer positions children
	await get_tree().process_frame

	# Animate each row from right -> final, rgb effect
	for i in range(created_rows.size()):
		var row_ctrl := created_rows[i]
		var final_pos: Vector2 = row_ctrl.global_position

		row_ctrl.set_as_top_level(true)
		row_ctrl.global_position = final_pos + Vector2(fly_in_offset, 0)
		row_ctrl.modulate.a = 0.0

		var delay := float(i) * stagger

		var tw := create_tween()
		tw.set_trans(Tween.TRANS_QUAD)
		tw.set_ease(Tween.EASE_OUT)

		tw.tween_property(row_ctrl, "global_position", final_pos, fly_in_duration).set_delay(delay)
		tw.parallel().tween_property(row_ctrl, "modulate:a", 1.0, 0.35).set_delay(delay + 0.05)


func _on_back_pressed() -> void:
	pass # Replace with function body.
