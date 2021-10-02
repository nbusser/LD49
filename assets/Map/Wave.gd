extends Node2D

var curve: Curve2D

func init(curve):
	$WavePath.curve = curve
	$WaveLine.clear_points()
	var baked = $WavePath.curve.get_baked_points()
	for p in baked:
		$WaveLine.add_point(p)
	baked.push_back(Vector2(Globals.buffer_size.x, 2000))
	baked.push_back(Vector2(0, 2000))
	baked.push_back(Vector2(0, baked[0].y))
	$Area2D/CollisionPolygon2D.set_polygon(baked)
	$Area2D/Polygon2D.set_polygon(baked)
	self.curve = curve

func get_last_point():
	return self.get_point(-1)

func get_point(index):
	return $WavePath.curve.get_baked_points()[index] + self.global_position

func get_len_points():
	return len($WavePath.curve.get_baked_points())

func get_len():
	return $WavePath.curve.get_baked_length()

func interpolate_baked(x_in_buffer):
	return self.curve.interpolate_baked(x_in_buffer) + self.global_position
