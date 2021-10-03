extends Node2D

onready var waves = [$wave, $wave2, $wave3]
onready var splash_particles = [$splash, $splash2, $splash3]
onready var colors = ["1f2baa", "121c91", "090f4b"]

var curve: Curve2D

func init(curve):
	self.curve = curve
	
	$Area2D/CollisionPolygon2D.disabled = true
	$WavePath.curve = curve
	
	# Cheap
	var baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(Globals.buffer_size.x, 2000))
	baked.push_back(Vector2(0, 2000))
	baked.push_back(Vector2(0, baked[0].y))
	
	# Costly
	$WavePath.curve.bake_interval = 50
	baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(Globals.buffer_size.x, 1000))
	baked.push_back(Vector2(0, 1000))
	baked.push_back(Vector2(0, baked[0].y))
	$Area2D/CollisionPolygon2D.set_polygon(baked)
	$Area2D/CollisionPolygon2D.disabled = false
	
	# VFX
	for i in 3:
		waves[i].set_polygon(baked)
		waves[i].material.set_shader_param("width", Globals.buffer_size.x)
		waves[i].color = Color(colors[i])
		splash_particles[i].modulate = Color(colors[i])
		splash_particles[i].emitting = true

func _ready():
	get_viewport().get_node("Game").connect("update_weather", self, "_on_Game_update_weather")

func get_baked_points():
	return $WavePath.curve.get_baked_points()

func get_last_point():
	return self.get_point(-1)

func get_point(index):
	return $WavePath.curve.get_baked_points()[index] + self.global_position

func get_len_points():
	return len($WavePath.curve.get_baked_points())

func get_len():
	return $WavePath.curve.get_baked_length()

func interpolate_baked(x_in_buffer):
	return self.curve.interpolate_baked(x_in_buffer) + self.global_position

func set_splash_pos(i):
	var pos = self.get_point(randi() % self.get_len_points()) - self.global_position
	splash_particles[i].position = pos + waves[i].offset
	
	var visibility_size = 1000000
	splash_particles[i].visibility_rect = Rect2(Vector2(pos.x - visibility_size/2, pos.y - visibility_size/2), Vector2(visibility_size, visibility_size))

func set_splash_amount(i, amount):
	splash_particles[i].lifetime = 2 + (1 - amount) * 10
	splash_particles[i].emitting = amount > 0.0

func _process(delta):
	for i in 3:
		set_splash_pos(i)

func _on_Area2D_body_shape_entered(body_id, body, body_shape, local_shape):
	if body.has_method("_on_hit_water"):
		body._on_hit_water()

func _on_Game_update_weather(value):
	for i in 3:
		set_splash_amount(i, value)
