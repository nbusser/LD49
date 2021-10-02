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
	var points_count = $WavePath.curve.get_point_count()
	var last_point_pos = $WavePath.curve.get_point_position(points_count - 1)
	var pos = last_point_pos + Vector2(100, randi()%300-150)
	
	# Insert new point (out of sight)
	$WavePath.curve.add_point(pos)
	
	# Adjust controls of the previous point
	var before_pos = $WavePath.curve.get_point_position(points_count - 2)
	var angle = (pos - before_pos).angle()
	var strength = 25 + randi()%50
	$WavePath.curve.set_point_in(points_count - 1, Vector2(-strength * cos(angle), -strength * sin(angle)))
	$WavePath.curve.set_point_out(points_count - 1, Vector2(strength * cos(angle), strength * sin(angle)))
	
	generate_line()
