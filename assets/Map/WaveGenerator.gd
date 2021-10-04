extends Node2D

var ct_x = 400
var amp_x = 30
var amp_y = 300

onready var pb_last = (2/3)*Globals.buffer_size - Vector2(300, 0)
onready var nb_first = Vector2(0, 0)
onready var nb_second = Vector2(300, 50)
onready var nb_third = Vector2(600, 100)

var next_y = 0
var next_buffer_second_point = Vector2(300, 460)

func _ready():
	pass

func get_control(previous, new):
	var angle = (new - previous).angle()
	print("jdklazjd ", angle)
	var strength = 75
	return Vector2(strength * cos(angle), strength * sin(angle))
#	return Vector2(84.99498, 0.924059)

func get_shift_x():
	return ct_x + randi()%(2*amp_x) - amp_x

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
	
	var contorol = get_control(pb_last - Vector2(Globals.buffer_size.x, 0), nb_second)
	curve.add_point(nb_first, contorol, -contorol)
	contorol = get_control(Vector2.ZERO, Vector2(76,34))
	contorol = Vector2(84.99498, 0.924059)
#	curve.add_point(nb_second, control, -control)
#	curve.add_point(Vector2.ZERO) # Control managed in loop
	
	# 0.9: avoid generating the last point too close to the border
	while curve.get_point_position(curve.get_point_count() - 1).x < 0.9*Globals.buffer_size.x:
		add_point(curve)
	
	pb_last = curve.get_point_position(curve.get_point_count() - 1)

	nb_first = Vector2(0, pb_last.y + get_shift_y())
	nb_second = Vector2(300, nb_first.y + get_shift_y())
	nb_third = Vector2(600, nb_second.y + get_shift_y())

	contorol = get_control(pb_last, nb_second + Vector2(Globals.buffer_size.x, 0))
	curve.add_point(nb_first + Vector2(Globals.buffer_size.x, 0), contorol, -contorol)
	contorol = get_control(nb_first + Vector2(Globals.buffer_size.x, 0), nb_third + Vector2(Globals.buffer_size.x, 0))
	curve.add_point(nb_second + Vector2(Globals.buffer_size.x, 0), contorol, -contorol)
	
	for i in range(curve.get_point_count()):
		print(curve.get_point_position(i))
	
	return curve
