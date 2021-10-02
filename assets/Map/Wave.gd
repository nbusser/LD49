extends Node2D

func init(curve):
	$WavePath.curve = curve
	for p in $WavePath.curve.get_baked_points():
		$WaveLine.add_point(p)
		
func get_last_point():
	return self.get_point(-1)

func get_point(index):
	return $WavePath.curve.get_baked_points()[index] + self.global_position

func get_len_points():
	return len($WavePath.curve.get_baked_points())
