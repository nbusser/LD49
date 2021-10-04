extends Node2D

signal dead

const MALFRAT_DANGER_DISTANCE = 600
onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")
const MALFRAT_DEFAULT_SPEED = Globals.PLAYER_MINIMUM_SPEED * 0.8
const MALFRAT_MAXIMUM_SPEED = Globals.PLAYER_MAXIMUM_SPEED * 1.75
const MALFRAT_FLEE_DURATION = .75
const MALFRAT_UNFLEE_DURATION = .75

var speed = MALFRAT_DEFAULT_SPEED
var current_wave
var x_in_buffer

var player

var is_accelerating = false
var is_dying = false

const MALFRAT_MAX_HEALTH = 3
var health = MALFRAT_MAX_HEALTH

func _ready():
	$Canon/Trajectory.clear_points()

func set_player(player):
	self.player = player
	player.connect("dying", self, "stop_firing")

func stop_firing():
	$PrepareShoot.stop()
	$RefreshBalistic.stop()
	$ShootCooldownTimer.stop()
	$Canon/Trajectory.clear_points()

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
	
	self.stop_firing()

	$Tween.interpolate_property(self, "rotation",
	self.rotation, 1, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Hitbox_body_entered(body):
	$DamageSoundPlayer.play_sound()
	if not is_dying:
		self.health -= 1
		# TODO: shader take dmg
		if self.health <= 0:
			die()

func _process(delta):
	pass
		
func shoot():
	$CanonSoundPlayer.play_sound()
	#var shoot_velocity = shoot_dir * 700 * (0.5 + loading_time/Globals.MAX_CANNON_CHARGING_TIME) + Vector2(speed, 0)
	var projectile = Projectile.instance()
	projectile.collision_layer = 2
	projectile.collision_mask = 2
	var shoot_velocity = ($Canon/Trajectory.points[1] - $Canon/Trajectory.points[0]).normalized() * .7 * abs(player.global_position.x - $Canon.global_position.x)
	get_parent().get_parent().emit_signal("spawn_cannonball", projectile, position, shoot_velocity)

func _on_ShootCooldownTimer_timeout():
	$PrepareShoot.start()
	$RefreshBalistic.start()

func _on_PrepareShoot_timeout():
	$RefreshBalistic.stop()
	
	self.shoot()
	$Canon/Trajectory.clear_points()
	$ShootCooldownTimer.start()

func parabolic_parameters(h):
	var b = -(player.global_position - $Canon.global_position)
	var delta = (
		4 * pow(h, 2) * pow(b.x, 2) - 4 * h * pow(b.x, 2) * b.y
	)

	var a = (
		(-2 * h * b.x + b.x * b.y - sqrt(delta))
		/ pow(b.x, 3)
	)
	
	var a_prime = (b.y / b.x) - a * b.x
	return Vector2(a, a_prime)

func parabolic_height(x, parameters):
	
	var y = parameters[0] * pow(x, 2) + parameters[1] * x
	
	return -y

func get_min_h(inf, sup, peaks):
	var h = inf
	
	while sup - h > 1:
		var found = false
		for p in peaks:
			var y = parabolic_height(p.x, parabolic_parameters(h))
			if y > p.y:
				found = true
				break
		
		if found:
			inf = h
			h = (sup + h) / 2
		else:
			sup = h
			h = (inf + h) / 2
	return h

func compute_trajectory():
	var parabolic_offset = 0

	var peaks = get_node("../../").get_peaks_to_player(self)

	var bottom = min(get_node("../../Player").position.y, self.position.y)

	var top = 1000
	for p in peaks:
		if p.y < top:
			top = p.y

	var h = get_min_h(self.position.y - bottom, self.position.y - top,peaks)

	var distance_x = abs($Canon.global_position.x - player.global_position.x)
	var parameters = parabolic_parameters(h)
	$Canon/Trajectory.clear_points()
	for x in range(distance_x):
		var p = Vector2(-x, parabolic_height(x, parameters))
		$Canon/Trajectory.add_point(p)

func _on_RefreshBalistic_timeout():
	self.compute_trajectory()
