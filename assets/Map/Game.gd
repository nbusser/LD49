extends Node2D

onready var Wave = preload("res://assets/Map/Wave.tscn")
var player_speed = 250
var x_in_buffer = 0

var current_point_index
onready var max_screen_width = get_viewport_rect().size.x * Globals.MAX_UNZOOM
var waves = []

func _ready():
	var current_wave = Wave.instance()
	current_wave.init($WaveGenerator.generate_buffer())
	$Waves.add_child(current_wave)
	
	var i = 0
	var baked = current_wave.get_node("WavePath").curve.get_baked_points()
	while baked[i].x < $Player.position.x:
		i += 1
	current_point_index = i
	
	var future_wave = Wave.instance()
	future_wave.init($WaveGenerator.generate_buffer())
	future_wave.position.x = current_wave.get_last_point().x
	$Waves.add_child(future_wave)

	waves.append(null)
	waves.append(current_wave)
	waves.append(future_wave)
	
func _process(delta):
	$Player.position = waves[1].interpolate_baked(x_in_buffer)
	x_in_buffer += delta*player_speed
	
	if x_in_buffer >= waves[1].curve.get_baked_length():
		discard_old_wave()
		x_in_buffer = 0
		
	var closest = waves[1].curve.get_closest_point($Player.position + Vector2(35, 0) - waves[1].global_position)
	var rot = closest.angle_to_point($Player.position - waves[1].global_position)
	rot = max(-1.0, rot)
	rot = min(1.0, rot)
	$Player.rotation = lerp($Player.rotation, rot, 0.01)

func discard_old_wave():
	var old_wave = waves.pop_front()
	if old_wave != null:
		$Waves.remove_child(old_wave)
		
	var future_wave = Wave.instance()
	future_wave.init($WaveGenerator.generate_buffer())
	future_wave.position.x = waves[1].get_last_point().x
	$Waves.add_child(future_wave)
	
	waves.append(future_wave)
