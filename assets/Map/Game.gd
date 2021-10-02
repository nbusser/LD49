extends Node2D

onready var Wave = preload("res://assets/Map/Wave.tscn")
var player_speed = 1000
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
	#movePlayer(delta)
	
	$Player.position = waves[1].interpolate_baked(x_in_buffer)
	x_in_buffer += delta*player_speed
	
	if x_in_buffer >= waves[1].curve.get_baked_length():
		discard_old_wave()
		x_in_buffer = 0

func discard_old_wave():
	var old_wave = waves.pop_front()
	if old_wave != null:
		$Waves.remove_child(old_wave)
		
	var future_wave = Wave.instance()
	future_wave.init($WaveGenerator.generate_buffer())
	future_wave.position.x = waves[1].get_last_point().x
	$Waves.add_child(future_wave)
	
	waves.append(future_wave)

func movePlayer(delta):	
	var point_to_go = waves[1].get_point(current_point_index)
	$Player.position = point_to_go

	if abs($Player.position.x - point_to_go.x) < 0.05:
		current_point_index += 1
		
		if current_point_index >= waves[1].get_len_points():
			discard_old_wave()
			current_point_index = 0
