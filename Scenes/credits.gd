extends Control

@export var meteor_texture: Texture2D
@export var fly_time: float = 1.2          # originally 0.7
@export var delay_between: float = 0.25
@export var x_start_offset: float = 250.0
@export var x_end_offset: float = 250.0
@export var y_jitter: float = 0.0 # set to like 8.0 if you want tiny randomness

# Spark burst tuning
@export var spark_count: int = 20
@export var spark_size: Vector2 = Vector2(7, 7)
@export var spark_spread_px: float = 200.0            # orginally 80
@export var spark_life: float = 2.0                   # orginally 0.35
@export var spark_brightness: float = 2.0

# Rainbow sparkle tuning
@export var spark_rainbow_speed: float = 1.2

# Random spark bursts after credits fully revealed
@export var ambient_sparks_enabled: bool = true
@export var ambient_sparks_interval_min: float = 0.35
@export var ambient_sparks_interval_max: float = 0.9
@export var ambient_spark_bursts_per_interval: int = 1
@export var ambient_start_delay: float = 1.0  # ADDED: wait after last name

@onready var meteor_layer: Control = $MeteorLayer
@onready var names_root: Control = $Names

var _labels_total: int = 0
var _labels_revealed: int = 0
var _ambient_running: bool = false

func _ready() -> void:
	_labels_total = 0
	_labels_revealed = 0

	# Hide all names first + count labels
	for n in names_root.get_children():
		if n is Label:
			_labels_total += 1
		if n is CanvasItem:
			(n as CanvasItem).visible = false

	_reveal_names()

func _reveal_names() -> void:
	call_deferred("_reveal_next", 0)

func _reveal_next(index: int) -> void:
	var kids := names_root.get_children()
	if index >= kids.size():
		return

	var label := kids[index]
	if not (label is Label):
		_reveal_next(index + 1)
		return

	var lbl := label as Label
	var pos := lbl.global_position + lbl.size * 0.5

	_spawn_meteor_and_reveal(lbl, pos)

	var t := get_tree().create_timer(fly_time + delay_between)
	t.timeout.connect(func():
		_reveal_next(index + 1)
	)

func _hsv_to_rgb(h: float, s: float, v: float) -> Color:
	h = fposmod(h, 1.0)
	var i := int(floor(h * 6.0))
	var f := h * 6.0 - float(i)
	var p := v * (1.0 - s)
	var q := v * (1.0 - f * s)
	var t := v * (1.0 - (1.0 - f) * s)

	match i % 6:
		0: return Color(v, t, p, 1.0)
		1: return Color(q, v, p, 1.0)
		2: return Color(p, v, t, 1.0)
		3: return Color(p, q, v, 1.0)
		4: return Color(t, p, v, 1.0)
		_: return Color(v, p, q, 1.0)

func _spawn_spark_burst(center_global: Vector2) -> void:
	var base_h := fposmod(Time.get_ticks_msec() / 1000.0 * spark_rainbow_speed, 1.0)

	for i in range(spark_count):
		var s := ColorRect.new()
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.size = spark_size
		meteor_layer.add_child(s)

		s.global_position = center_global - (spark_size * 0.5)

		var h := fposmod(base_h + float(i) / float(max(1, spark_count)), 1.0)
		var c := _hsv_to_rgb(h, 1.0, 1.0)
		s.color = Color(c.r * spark_brightness, c.g * spark_brightness, c.b * spark_brightness, 1.0)

		var ang := randf() * TAU
		var dist := randf_range(spark_spread_px * 0.35, spark_spread_px)
		var target := s.global_position + Vector2(cos(ang), sin(ang)) * dist

		var life := randf_range(spark_life * 0.75, spark_life * 1.25)

		var tw := create_tween()
		tw.set_trans(Tween.TRANS_QUAD)
		tw.set_ease(Tween.EASE_OUT)

		tw.tween_property(s, "global_position", target, life)
		tw.parallel().tween_property(s, "modulate:a", 0.0, life)

		s.scale = Vector2(1.0, 1.0)
		tw.parallel().tween_property(s, "scale", Vector2(0.3, 0.3), life)

		tw.tween_callback(func():
			s.queue_free()
		)

func _spawn_random_spark_burst() -> void:
	var rect := get_viewport_rect()
	var margin := 24.0
	var x := randf_range(margin, rect.size.x - margin)
	var y := randf_range(margin, rect.size.y - margin)
	_spawn_spark_burst(Vector2(x, y))

func _start_ambient_sparks() -> void:
	if _ambient_running:
		return
	_ambient_running = true
	_ambient_sparks_loop()

func _ambient_sparks_loop() -> void:
	if not ambient_sparks_enabled:
		_ambient_running = false
		return

	for i in range(max(1, ambient_spark_bursts_per_interval)):
		_spawn_random_spark_burst()

	var wait := randf_range(ambient_sparks_interval_min, ambient_sparks_interval_max)
	var t := get_tree().create_timer(wait)
	t.timeout.connect(func():
		_ambient_sparks_loop()
	)

func _glow_reveal(lbl: Label) -> void:
	lbl.visible = true

	var center := lbl.global_position + lbl.size * 0.5
	_spawn_spark_burst(center)

	lbl.modulate = Color(2.2, 2.2, 2.2, 0.0)
	lbl.scale = Vector2(1.15, 1.15)

	var tw := create_tween()
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_OUT)

	tw.tween_property(lbl, "modulate:a", 1.0, 0.18)
	tw.parallel().tween_property(lbl, "modulate", Color(1, 1, 1, 1), 0.45)
	tw.parallel().tween_property(lbl, "scale", Vector2(1.0, 1.0), 0.25)

	_labels_revealed += 1
	if ambient_sparks_enabled and not _ambient_running and _labels_revealed >= _labels_total and _labels_total > 0:
		# ADDED: wait 1 second (or whatever ambient_start_delay is) before starting ambient bursts
		var t := get_tree().create_timer(ambient_start_delay)
		t.timeout.connect(func():
			_start_ambient_sparks()
		)

func _spawn_meteor_and_reveal(lbl: Label, target_center: Vector2) -> void:
	if meteor_texture == null:
		_glow_reveal(lbl)
		return

	var meteor := TextureRect.new()
	meteor.texture = meteor_texture
	meteor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	meteor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	meteor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meteor_layer.add_child(meteor)

	meteor.custom_minimum_size = Vector2(480, 240)

	var screen_w: float = get_viewport_rect().size.x
	var y := target_center.y + randf_range(-y_jitter, y_jitter)

	var start_x: float = screen_w + x_start_offset
	var end_x: float = -meteor.custom_minimum_size.x - x_end_offset

	var start := Vector2(start_x, y - meteor.custom_minimum_size.y * 0.5)
	var end := Vector2(end_x, y - meteor.custom_minimum_size.y * 0.5)

	meteor.global_position = start
	meteor.modulate.a = 1.0

	var tw := create_tween()
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_OUT)

	tw.tween_property(meteor, "global_position", end, fly_time)

	var reveal_delay := fly_time * 0.3
	var rt := get_tree().create_timer(reveal_delay)
	rt.timeout.connect(func():
		_glow_reveal(lbl)
	)

	tw.tween_property(meteor, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		meteor.queue_free()
	)
