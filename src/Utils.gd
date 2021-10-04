extends Node


func sigmoid(x: float, k: float):
	return 1.0 / (1.0 + exp((0.5 - x) * k))

func fade_node_in(node, duration = 1, delay = 0):
	if (delay > 0):
		yield(get_tree().create_timer(delay), "timeout")
	$Tween.interpolate_property(node, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func fade_node_out(node, duration = 1, delay = 0):
	if (delay > 0):
		yield(get_tree().create_timer(delay), "timeout")
	$Tween.interpolate_property(node, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0),
		duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
