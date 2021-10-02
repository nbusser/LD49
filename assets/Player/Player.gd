extends Node2D

onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")

onready var world = get_parent()
onready var cannon = $ship/cannon
onready var cannon_sprite = $ship/cannon/cannon
onready var projectile_origin = $ship/cannon/projectile_origin
onready var sails = [$ship/sail, $ship/sail2, $ship/sail3, $ship/sail4, $ship/sail5]
onready var flag = $ship/flag

var can_shoot = true
const SHOOT_COOLDOWN = 1.0

const DEFAULT_SPEED = 100
var speed = DEFAULT_SPEED

export var sail_color = Color("dbdbdb")
export var flag_color = Color("dbc954")

func _ready():
	for sail in sails:
		sail.color = sail_color
	flag.color = flag_color

var accelerating = false
var decelerating = false

const DURATION_ACCELERATE = 2
const DURATION_DECELERATE = 2

func is_sailing():
	return accelerating or decelerating

func cancel_animations():
	$Tween.stop_all()

	$Tween.interpolate_property(self, "speed",
	speed, DEFAULT_SPEED, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()
	
	$Tween.interpolate_property($Camera2D, "zoom",
	$Camera2D.zoom, $Camera2D.DEFAULT_ZOOM, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()

func _input(event):
	if event.is_action_pressed("shoot") && can_shoot:
		shoot()
	
	if event.is_action_pressed("Accelerate") and not is_sailing():
		$Tween.stop_all()
		
		$Tween.interpolate_property(self, "speed",
		self.speed, DEFAULT_SPEED*2.5, DURATION_ACCELERATE,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		
		$Tween.interpolate_property($Camera2D, "zoom",
		$Camera2D.zoom, $Camera2D.DEFAULT_ZOOM*0.90, DURATION_ACCELERATE,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		
		accelerating = true
		
	if event.is_action_released("Accelerate") and accelerating:
		cancel_animations()
		accelerating = false
		
	if event.is_action_pressed("Decelerate") and not is_sailing():
		$Tween.stop_all()
		
		$Tween.interpolate_property(self, "speed",
		self.speed, DEFAULT_SPEED/2, DURATION_DECELERATE,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.start()
		
		$Tween.interpolate_property($Camera2D, "zoom",
		$Camera2D.zoom, $Camera2D.DEFAULT_ZOOM*1.5, DURATION_DECELERATE,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		
		decelerating = true
		
	if event.is_action_released("Decelerate") and decelerating:
		cancel_animations()
		decelerating = false

func shoot():
	var shoot_origin = projectile_origin.global_position
	var shoot_dir = Vector2.RIGHT.rotated(cannon.global_rotation)
	var shoot_velocity = shoot_dir * 500
	var projectile = Projectile.instance()
	world.add_child(projectile)
	projectile.global_transform.origin = shoot_origin
	projectile.linear_velocity = shoot_velocity
	
	animate_cannon()
	
	can_shoot = false
	$ShotCooldown.start()

func animate_cannon():
	$Tween.interpolate_property(cannon_sprite, "position",
		Vector2(-10, 0), Vector2(0, 0), SHOOT_COOLDOWN,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_ShotCooldown_timeout():
	can_shoot = true
