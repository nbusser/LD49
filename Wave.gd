extends Node2D


func generate_line():
	$WaveLine.clear_points()
	var points = $WavePath.curve.get_baked_points()
	for p in points:
		$WaveLine.add_point(p)


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_line()


func _on_PointSpawner_timeout():
	var last_point_pos = $WavePath.curve.get_point_position($WavePath.curve.get_point_count() - 1)
	var last_point_in = $WavePath.curve.get_point_in($WavePath.curve.get_point_count() - 1)
	var last_point_out = $WavePath.curve.get_point_out($WavePath.curve.get_point_count() - 1)
	
	var pos = last_point_pos + Vector2(35, randi()%50-25)
	
	print(last_point_in)
	
	$WavePath.curve.add_point(pos, last_point_in + Vector2(randi()%20 - 10, randi()%20 - 10), last_point_out + Vector2(randi()%20 - 10, randi()%20 - 10))
	generate_line()
