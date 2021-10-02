extends Node2D

var curve: Curve2D

func init(curve):
	$WavePath.curve = curve
	for p in $WavePath.curve.get_baked_points():
		$WaveLine.add_point(p)
	self.curve = curve
		
func get_last_point():
	return self.get_point(-1)

func get_point(index):
	return $WavePath.curve.get_baked_points()[index] + self.global_position

func get_len_points():
	return len($WavePath.curve.get_baked_points())

func interpolate_baked(x_in_buffer):
	return self.curve.interpolate_baked(x_in_buffer) + self.global_position
