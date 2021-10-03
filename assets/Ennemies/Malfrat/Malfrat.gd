extends Node2D

signal dead

onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")

const MALFRAT_DANGER_DISTANCE = 1200
const MALFRAT_DEFAULT_SPEED = Globals.PLAYER_MINIMUM_SPEED * 0.8
const MALFRAT_MAXIMUM_SPEED = Globals.PLAYER_MAXIMUM_SPEED * 3.0
const MALFRAT_FLEE_DURATION = 1.5
const MALFRAT_UNFLEE_DURATION = 1.5

var speed = MALFRAT_DEFAULT_SPEED
var current_wave
var x_in_buffer

var is_aiming = false

var player

var is_accelerating = false
var is_dying = false

const MALFRAT_MAX_HEALTH = 3
var health = MALFRAT_MAX_HEALTH

func can_move():
	return not is_dying

func accelerate():
	if can_move() and not is_accelerating:
		$Tween.interpolate_property(self, "speed",
		speed, MALFRAT_MAXIMUM_SPEED, (0.5+randf())*MALFRAT_FLEE_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		is_accelerating = true

func _on_Tween_tween_completed(object, key):
	if not is_dying:
		if speed == MALFRAT_MAXIMUM_SPEED:
			is_accelerating = false
			$Tween.interpolate_property(self, "speed",
			speed, MALFRAT_DEFAULT_SPEED, (1.0+randf())*MALFRAT_UNFLEE_DURATION,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			$Tween.start()
	else:
		if key == ":rotation":
			$DyingAnimationTimer.start()
		elif key == ":position":
			emit_signal("dead", self)
			
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

func _on_Hitbox_body_entered(body):
	if not is_dying:
		self.health -= 1
		# TODO: shader take dmg
		if self.health <= 0:
			die()

func _process(delta):
	if is_aiming:
		self.compute_trajectory()
		
func shoot():
	#var shoot_velocity = shoot_dir * 700 * (0.5 + loading_time/Globals.MAX_CANNON_CHARGING_TIME) + Vector2(speed, 0)
	var projectile = Projectile.instance()
	projectile.collision_layer = 2
	projectile.collision_mask = 2
	var shoot_velocity = Vector2(50, 50)
	get_parent().get_parent().emit_signal("spawn_cannonball", projectile, $Canon.global_position, shoot_velocity)

func _on_ShootCooldownTimer_timeout():
	is_aiming = true
	$PrepareShoot.start()

func _on_PrepareShoot_timeout():
	is_aiming = false
	$Canon/Trajectory.clear_points()
	self.shoot()
	$ShootCooldownTimer.start()

func parabolic(x, trajectory_minima):
	# f(x) = (-H/2(bx²))x²+(by/bx+H/(2bx))x 
	var b = player.global_position - $Canon.global_position
	b = -b
	return (
		(
			(-trajectory_minima/(2 * pow(b.x, 2))) 
			* pow(x, 2)
		)
		+ (
			((b.y/b.x) + trajectory_minima/(2*b.x))
			* x
		)
	)

func compute_trajectory():
	var maximum = get_node("../../").get_highest_point_between(self)
	maximum = abs(maximum.y - $Canon.global_position.y)
	
	var distance = $Canon.global_position - player.global_position
	
	print(parabolic(476, maximum))
	print("yo")
	print(distance)
	print(maximum)
	var i = 1
	for y in $Canon/Yannicks.get_children():
		y.position = Vector2(-(distance.x/i), parabolic(distance.x/i, maximum))
		i += 1
		print("y")
		print(distance.x/i)
		print(parabolic(distance.x/i, maximum))

	$Canon/Trajectory.clear_points()
	for x in range(1500):
		$Canon/Trajectory.add_point(
			Vector2(
				- x,# - abs(distance.x),
				parabolic(x, maximum)
				)
		)
