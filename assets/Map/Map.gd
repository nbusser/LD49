extends Node2D

var on_screen_length

# Called when the node enters the scene tree for the first time.
func _ready():
	$Wave.add_point(Vector2(200, 375))
	$Wave.add_point(Vector2(400, 325))
	$Wave.add_point(Vector2(800, 335))
	$Wave.add_point(Vector2(1200, 299))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
