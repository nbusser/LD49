extends RigidBody2D

onready var splash_particles = $splash

var water_hitted = false

func _on_hit_water():
	if not water_hitted:
		$PloufSound.play_sound()
	splash_particles.emitting = true
	water_hitted = true
