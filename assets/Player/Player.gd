extends Node2D

signal start_charging_cannon
signal stop_charging_cannon

onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")

onready var world = get_parent()
onready var cannon = $ship/cannon
onready var cannon_sprite = $ship/cannon/cannon
onready var projectile_origin = $ship/cannon/projectile_origin
onready var sails = [$ship/sail, $ship/sail2, $ship/sail3, $ship/sail4, $ship/sail5]
onready var flag = $ship/flag

var can_shoot = true
var shot_loading = false
var shot_start_time
const SHOOT_COOLDOWN = 0.5

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
	if event.is_action_pressed("shoot") && can_shoot && !shot_loading:
		shot_loading = true
		shot_start_time = OS.get_system_time_msecs()
		emit_signal("start_charging_cannon")
	if event.is_action_released("shoot") && shot_loading:
		shot_loading = false
		shoot()
		emit_signal("stop_charging_cannon")
	
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
	var loading_time = (OS.get_system_time_msecs() - shot_start_time)/1000.0
	# TODO Vector2(speed, 0) not ok
	var shoot_velocity = shoot_dir * 500 * (0.5 + clamp(loading_time, 0, Globals.MAX_CANNON_CHARGING_TIME)/Globals.MAX_CANNON_CHARGING_TIME) + Vector2(speed, 0)
	var projectile = Projectile.instance()
	world.emit_signal("spawn_cannonball", projectile, shoot_origin, shoot_velocity)
	
	$Camera2D.add_trauma(0.5)
	
	animate_cannon()
	
	can_shoot = false
	$ShotCooldown.start(SHOOT_COOLDOWN - clamp(loading_time, 0.0, SHOOT_COOLDOWN))

func animate_cannon():
	$Tween.interpolate_property(cannon_sprite, "position",
		Vector2(-10, 0), Vector2(0, 0), SHOOT_COOLDOWN,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_ShotCooldown_timeout():
	can_shoot = true
