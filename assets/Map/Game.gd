extends Node2D

var player_speed = 10

var current_point_index
var current_buffer_wave
onready var max_screen_width = get_viewport_rect().size.x * Globals.MAX_UNZOOM

var buffers = []
var buffer_line_dict = {}

func _ready():
	var buffer = $WaveGenerator.generate_buffer()
	self.create_wave_line(buffer)
	buffers.append(buffer)

func create_wave_line(buffer):
	var line_buffer = Line2D.new()
	buffer_line_dict[buffer] = line_buffer
	$WaveLines.add_child(line_buffer)
	
	for p in buffer:
		line_buffer.add_point(p)

