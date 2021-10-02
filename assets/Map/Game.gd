extends Node2D

onready var sight_loss_distance = 0.5*get_viewport_rect().size.x*Globals.MAX_UNZOOM

var buffer_0: Path2D
var buffer_1: Path2D
var primary_buffer: Path2D
onready var primary_line = $WaveLine0
var secondary_buffer: Path2D
onready var secondary_line = $WaveLine1
var secondary_generated: bool

var next_buffer_offset
var primary_length
var x_in_buffer


func generate_line(buffer, line):
	line.clear_points()
	for p in buffer.curve.get_baked_points():
		line.add_point(p)


func _ready():
	buffer_0 = $WaveGenerator.generate_buffer()
	buffer_1 = $WaveGenerator.generate_buffer()
	primary_buffer = buffer_0
	secondary_line.position.x = 0
	generate_line(primary_buffer, primary_line)
	secondary_buffer = buffer_1
	secondary_line.position.x = Globals.buffer_size.x
	generate_line(secondary_buffer, secondary_line)
	secondary_generated = true
	primary_length = primary_buffer.curve.get_baked_length()
	x_in_buffer = 2000
	next_buffer_offset = 1


func player_move_checks():
	if (!secondary_generated):
		if (($Player.position.x - (next_buffer_offset-1)*Globals.buffer_size.x) > 2*sight_loss_distance):
			secondary_generated = true
			secondary_buffer = $WaveGenerator.generate_buffer()
			secondary_line.position.x = next_buffer_offset*Globals.buffer_size.x
			generate_line(secondary_buffer, secondary_line)
	elif (x_in_buffer > primary_length):
		next_buffer_offset += 1
		secondary_generated = false
		var tmp_buffer = primary_buffer
		primary_buffer = secondary_buffer
		secondary_buffer = tmp_buffer
		
		primary_length = primary_buffer.curve.get_baked_length()
		x_in_buffer = 0
		
		var tmp_line = primary_line
		primary_line = secondary_line
		secondary_line = tmp_line


func _process(_delta):
	$Player.position = Vector2((next_buffer_offset-1)*Globals.buffer_size.x, 0) + primary_buffer.curve.interpolate_baked(x_in_buffer)
	x_in_buffer += 8
	player_move_checks()
