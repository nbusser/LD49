extends Node2D

var curve: Curve2D

func init(curve):
	$Area2D/CollisionPolygon2D.disabled = true
	$WavePath.curve = curve
	
	# Cheap
	var baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(Globals.buffer_size.x, 2000))
	baked.push_back(Vector2(0, 2000))
	baked.push_back(Vector2(0, baked[0].y))
	$Polygon2D.set_polygon(baked)
	$Background.set_polygon(baked)
	$Background2.set_polygon(baked)
	$Background.z_index = 1
	$Background2.z_index = 2
	$Polygon2D.material.set_shader_param("width", Globals.buffer_size.x)
	$Background.material.set_shader_param("width", Globals.buffer_size.x)
	$Background2.material.set_shader_param("width", Globals.buffer_size.x)
	
	# Costly
	$WavePath.curve.bake_interval = 50
	baked = $WavePath.curve.get_baked_points()
	baked.push_back(Vector2(Globals.buffer_size.x, 1000))
	baked.push_back(Vector2(0, 1000))
	baked.push_back(Vector2(0, baked[0].y))
	$Area2D/CollisionPolygon2D.set_polygon(baked)
	$Area2D/CollisionPolygon2D.disabled = false
	self.curve = curve

func get_baked_points():
	return $WavePath.curve.get_baked_points()

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
