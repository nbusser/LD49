extends Node2D

var pb_last = Vector2(-400, 45)
var nb_first = Vector2(0, 0)
var nb_second = Vector2(400, 85)
var nb_third = Vector2(800, 140)

var amp_y = 300

func _ready():
	pass

func get_control(previous, new):
	var angle = (new - previous).angle()
	var strength = 75 + randi()%20
	return Vector2(strength * cos(angle), strength * sin(angle))

func get_shift_x():
	return 400

func get_shift_y():
	return (randi()%(2*amp_y) - amp_y)

func add_point(curve):
	var points_count = curve.get_point_count()
	var previous = curve.get_point_position(points_count - 2)
	var current = curve.get_point_position(points_count - 1)
	
	# Insert new point
	var shift_y = get_shift_y()
	if (current.y + shift_y < 50 || current.y + shift_y > Globals.buffer_size.y - 50):
		shift_y = -shift_y
	var new = current + Vector2(get_shift_x(), shift_y)
	curve.add_point(new)
	
	# Adjust controls of the previous point
	var control = get_control(previous, new)
	curve.set_point_in(points_count - 1, -control)
	curve.set_point_out(points_count - 1, control)

func generate_buffer():
	var curve = Curve2D.new()
	
	curve.clear_points()
	
	var control = get_control(pb_last - Vector2(Globals.buffer_size.x, 0), nb_second)
	curve.add_point(nb_first, -control, control)
	control = get_control(nb_first, nb_third)
	curve.add_point(nb_second, -control, control)
	curve.add_point(nb_third) # Control managed in loop
	
	# 0.9: avoid generating the last point too close to the border
	while curve.get_point_position(curve.get_point_count() - 1).x < 0.9*Globals.buffer_size.x:
		add_point(curve)
	
	pb_last = curve.get_point_position(curve.get_point_count() - 1)
	nb_first = Vector2(0, pb_last.y + 300)
	nb_second = nb_first + Vector2(get_shift_x(), 300)
	nb_third = nb_second + Vector2(get_shift_x(), get_shift_y())
	
	var while_last_id = curve.get_point_count() - 1
	control = get_control(curve.get_point_position(while_last_id - 1), pb_last)
	curve.set_point_in(while_last_id, -control)
	curve.set_point_out(while_last_id, control)
	
	control = get_control(pb_last, nb_second + Vector2(Globals.buffer_size.x, 0))
	curve.add_point(nb_first + Vector2(Globals.buffer_size.x, 0), -control, control)
	control = get_control(nb_first + Vector2(Globals.buffer_size.x, 0), nb_third + Vector2(Globals.buffer_size.x, 0))
	curve.add_point(nb_second + Vector2(Globals.buffer_size.x, 0), -control, control)
	
	for i in range(curve.get_point_count()):
		print(curve.get_point_position(i))
	
	return curve
