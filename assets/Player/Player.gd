extends Node2D

onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")

onready var world = get_parent()
onready var cannon = $cannon
onready var projectile_origin = $cannon/projectile_origin

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()

func shoot():
	var shoot_origin = projectile_origin.global_position
	var shoot_dir = Vector2.RIGHT.rotated(cannon.global_rotation)
	var shoot_velocity = shoot_dir * 300
	var projectile = Projectile.instance()
	world.add_child(projectile)
	projectile.global_transform.origin = shoot_origin
	projectile.linear_velocity = shoot_velocity
