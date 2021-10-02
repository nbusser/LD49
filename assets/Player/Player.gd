extends Node2D

onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")

onready var world = get_parent()
onready var cannon = $ship/cannon
onready var cannon_sprite = $ship/cannon/cannon
onready var projectile_origin = $ship/cannon/projectile_origin
onready var sails = [$ship/sail, $ship/sail2, $ship/sail3, $ship/sail4, $ship/sail5]
onready var flag = $ship/flag

var can_shoot = true
const SHOOT_COOLDOWN = 0.3

export var sail_color = Color("dbdbdb")
export var flag_color = Color("dbc954")

func _ready():
	for sail in sails:
		sail.color = sail_color
	flag.color = flag_color

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
	
	animate_cannon()

func animate_cannon():
	$tween.interpolate_property(cannon_sprite, "position",
		Vector2(-10, 0), Vector2(0, 0), SHOOT_COOLDOWN,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween.start()
