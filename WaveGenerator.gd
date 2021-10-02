extends Node2D

onready var curve = $WavePath.curve
onready var buffer_size = 1.5 * get_viewport_rect().size

onready var previous_buffer_last_point = (2/3)*buffer_size
var next_y = 0 # TODO: utiliser

func generate_line():
	$WaveLine.clear_points()
	var points = curve.get_baked_points()
	for p in points:
		$WaveLine.add_point(p)


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_buffer()
	generate_line()


func get_control(previous, new):
	var angle = (new - previous).angle()
	var strength = 25 + randi()%50
	return Vector2(strength * cos(angle), strength * sin(angle))


func get_shift_x():
	return 100


func get_shift_y():
	return (randi()%200-100)


# TODO constraint waves
func add_point():
	var points_count = curve.get_point_count()
	var previous = curve.get_point_position(points_count - 2)
	var current = curve.get_point_position(points_count - 1)
	
	# Insert new point (out of sight)
	var new = current + Vector2(get_shift_x(), get_shift_y())
	curve.add_point(new)
	
	# Adjust controls of the previous point
	var control = get_control(previous, new)
	curve.set_point_in(points_count - 1, -control)
	curve.set_point_out(points_count - 1, control)


func generate_buffer():
	curve.clear_points()
	var init_control = get_control(previous_buffer_last_point - Vector2(buffer_size.x, 0), Vector2(0, 0))
	curve.add_point(Vector2(0, next_y), -init_control, init_control)
	curve.add_point(Vector2(get_shift_x(), next_y))
	
	# 0.96: avoid generating the last point too close to the border
	while curve.get_point_position(curve.get_point_count() - 1).x < 0.9*buffer_size.x:
		add_point()

	previous_buffer_last_point = curve.get_point_position(curve.get_point_count() - 1)
	next_y = previous_buffer_last_point.y + get_shift_y()

	var control = get_control(previous_buffer_last_point, Vector2(buffer_size.x, next_y))
	curve.set_point_in(curve.get_point_count() - 1, -control)
	curve.set_point_out(curve.get_point_count() - 1, control)
		
	return curve.get_baked_points()
