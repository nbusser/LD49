extends Node


func sigmoid(x: float, k: float):
	return 1.0 / (1.0 + exp((0.5 - x) * k))
