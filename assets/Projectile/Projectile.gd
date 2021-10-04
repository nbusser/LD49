extends RigidBody2D

onready var particles = $Particles2D

func _on_hit_water():
	particles.emitting = true
