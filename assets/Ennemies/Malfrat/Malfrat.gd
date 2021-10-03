extends Node2D

const MALFRAT_DANGER_DISTANCE = 1500
const MALFRAT_DEFAULT_SPEED = Globals.PLAYER_MINIMUM_SPEED * 0.8
const MALFRAT_MAXIMUM_SPEED = Globals.PLAYER_MAXIMUM_SPEED * 3.0
const MALFRAT_FLEE_DURATION = 2.0
const MALFRAT_UNFLEE_DURATION = 2.0

var speed = MALFRAT_DEFAULT_SPEED
var current_wave;
var x_in_buffer

var is_accelerating = false

func accelerate():
	if not is_accelerating:
		$Tween.interpolate_property(self, "speed",
		speed, MALFRAT_MAXIMUM_SPEED, MALFRAT_FLEE_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		is_accelerating = true

func _on_Tween_tween_completed(object, key):
	if speed == MALFRAT_MAXIMUM_SPEED:
		is_accelerating = false
		$Tween.interpolate_property(self, "speed",
		speed, MALFRAT_DEFAULT_SPEED, MALFRAT_UNFLEE_DURATION,
		Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.start()

