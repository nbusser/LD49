extends Node2D

signal start_charging_cannon
signal stop_charging_cannon

onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")

onready var world = get_parent()
onready var cannon = $ship/cannon
onready var cannon_sprite = $ship/cannon/cannon
onready var projectile_origin = $ship/cannon/projectile_origin

var can_shoot = true
var shot_loading = false
var shot_start_time
const SHOOT_COOLDOWN = 0.5
var shot_pressed = false

var speed = Globals.PLAYER_DEFAULT_SPEED

var health = Globals.PLAYER_MAX_HEALTH

var accelerating = false
var decelerating = false

const DURATION_ACCELERATE = 2
const DURATION_DECELERATE = 2

func is_sailing():
	return accelerating or decelerating

func cancel_animations():
	$Tween.stop_all()

	$Tween.interpolate_property(self, "speed",
	speed, Globals.PLAYER_DEFAULT_SPEED, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()
	
	$Tween.interpolate_property($Camera2D, "zoom",
	$Camera2D.zoom, $Camera2D.DEFAULT_ZOOM, 2.0,
	Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()

func _input(event):
	if event.is_action_pressed("shoot"):
		shot_pressed = true
	if event.is_action_released("shoot"):
		shot_pressed = false
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
		self.speed, Globals.PLAYER_MAXIMUM_SPEED, DURATION_ACCELERATE,
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
		self.speed, Globals.PLAYER_MINIMUM_SPEED, DURATION_DECELERATE,
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
	loading_time = clamp(loading_time, 0, Globals.MAX_CANNON_CHARGING_TIME)
	
	# TODO Vector2(speed, 0) not ok
	var shoot_velocity = shoot_dir * 700 * (0.5 + loading_time/Globals.MAX_CANNON_CHARGING_TIME) + Vector2(speed, 0)
	var projectile = Projectile.instance()
	world.emit_signal("spawn_cannonball", projectile, shoot_origin, shoot_velocity)
	
	var min_trauma = 0.4
	var max_added_trauma = 0.3
	var trauma_value = min_trauma + (loading_time*max_added_trauma)/Globals.MAX_CANNON_CHARGING_TIME
	$Camera2D.add_trauma(trauma_value)
	
	animate_cannon(loading_time)
	
	can_shoot = false
	$ShotCooldown.start(SHOOT_COOLDOWN - clamp(loading_time, 0.0, SHOOT_COOLDOWN))

func animate_cannon(loading_time):
	var min_recoil = 40
	var max_added_recoil = 60
	var recoil_value = min_recoil + (loading_time*max_added_recoil)/Globals.MAX_CANNON_CHARGING_TIME
	
	$Tween.interpolate_property(cannon_sprite, "position",
		Vector2(-recoil_value, 0), Vector2(0, 0), SHOOT_COOLDOWN,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_ShotCooldown_timeout():
	can_shoot = true
	if shot_pressed:
		shot_loading = true
		shot_start_time = OS.get_system_time_msecs()
		emit_signal("start_charging_cannon")
