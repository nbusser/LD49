extends RigidBody2D

onready var splash_particles = $splash

func _on_hit_water():
	splash_particles.emitting = true
