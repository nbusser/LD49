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
var is_dying = false

var accelerating = false
var decelerating = false

var in_cutscene = false

const DURATION_ACCELERATE = 2
const DURATION_DECELERATE = 2

var velocity = Vector2(0, 0)

func go_cutscene_mode():
	in_cutscene = true
	$Camera2D.zoom = Vector2(0.8, 0.8)
	$Camera2D.position = Vector2(0, -20)
	$ship/flag.position = Vector2(-19, -16)
	self.speed = Globals.PLAYER_MINIMUM_SPEED

func can_control():
	return not in_cutscene and not is_dying

func is_sailing():
	return accelerating or decelerating
	
func flag_up():
	var flag_up_pos = Vector2(-21.5, -203.7)
	$Tween.interpolate_property($ship/flag, "position",
	$ship/flag.position, flag_up_pos, 4,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

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

func update_velocity(v):
	velocity = v

func _input(event):
	if not can_control():
		return

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
	
	var shoot_velocity = velocity + shoot_dir * 500 * (0.5 + loading_time/Globals.MAX_CANNON_CHARGING_TIME)
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


func _on_Tween_tween_completed(object, key):
	# TODO: sink when dying
	if object == $ship/flag:
		var normal_zoom = Vector2(3.0, 3.0)
		$Tween.interpolate_property($Camera2D, "zoom",
		$Camera2D.zoom, normal_zoom, 2,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		
		var normal_position = Vector2(1000, -173.027)
		$Tween.interpolate_property($Camera2D, "position",
		$Camera2D.position, normal_position, 2,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		in_cutscene = false
		
		self.speed = Globals.PLAYER_DEFAULT_SPEED

func _on_Hitbox_body_entered(body):
	if not is_dying:
		self.health -= 1
		if self.health <= 0:
			self.die()
			
func _on_DyingAnimationTimer_timeout():
	$Tween.interpolate_property(self, "position",
	self.position, Vector2(self.position.x, self.position.y + 1000), 4,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func die():
	is_dying = true

	$Tween.interpolate_property(self, "rotation",
	self.rotation, 1, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
