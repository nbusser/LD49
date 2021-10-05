extends Node2D

signal start_charging_cannon
signal stop_charging_cannon
signal dying
signal dead
signal health_changes

onready var Projectile = preload("res://assets/Projectile/Projectile.tscn")

onready var world = get_parent()
onready var cannon = $ship/cannon
onready var cannon_sprite = $ship/cannon/cannon
onready var projectile_origin = $ship/cannon/projectile_origin
onready var vignette_shader = get_tree().get_root().get_node("./Game/HudLayer/HUD/Vignette").material

var can_shoot = true
var shot_loading = false
var shot_start_time
const SHOOT_COOLDOWN = 0.5
var shot_pressed = false

var speed = Globals.PLAYER_DEFAULT_SPEED

var health = Globals.PLAYER_MAX_HEALTH - 1
var is_dying = false

var accelerating = false
var decelerating = false

var in_cutscene = false

onready var aim = $ship/cannon/projectile_origin/aim

const DURATION_ACCELERATE = 2
const DURATION_DECELERATE = 2

var velocity = Vector2(0, 0)

func _process(delta):
	$ship/cannon.look_at(get_global_mouse_position())
	aim.visible = can_shoot and can_control()

func go_cutscene_mode():
	in_cutscene = true
	$Camera2D.zoom = Vector2(0.8, 0.8)
	$Camera2D.position = Vector2(0, -20)
	$ship/flag.position = Vector2(-19, -16)
	self.speed = Globals.PLAYER_MINIMUM_SPEED

func can_move():
	return not is_dying

func can_control():
	return not in_cutscene and not is_dying

func is_sailing():
	return accelerating or decelerating
	
func start_to_play():
	$SoundFx/TrumpetSound.play()
	self.flag_up()
	world._on_SpawnMalfratTimer_timeout()
	
func flag_up(duration=2):
	$SoundFx/FlagChangeSound.play()
	$SoundFx/FlagSound.play()
	var flag_up_pos = Vector2(-21.5, -203.7)
	$Tween.interpolate_property($ship/flag, "position",
	$ship/flag.position, flag_up_pos, duration,
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
	
	$Tween.interpolate_method(self, "set_vignette",
	vignette_shader.get_shader_param("vignette"), 0.0, 0.2,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func accelerate():
	$Tween.stop_all()

	$Tween.interpolate_property(self, "speed",
	self.speed, Globals.PLAYER_MAXIMUM_SPEED, DURATION_ACCELERATE,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	$Tween.interpolate_property($Camera2D, "zoom",
	$Camera2D.zoom, $Camera2D.DEFAULT_ZOOM*0.90, DURATION_ACCELERATE,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	$Tween.interpolate_method(self, "set_vignette",
	vignette_shader.get_shader_param("vignette"), 0.7, DURATION_ACCELERATE,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	accelerating = true
	
func decelerate():
	$Tween.stop_all()
	
	self.set_vignette(0.0)
	
	$Tween.interpolate_property(self, "speed",
	self.speed, Globals.PLAYER_MINIMUM_SPEED, DURATION_DECELERATE,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	$Tween.interpolate_property($Camera2D, "zoom",
	$Camera2D.zoom, $Camera2D.DEFAULT_ZOOM*1.5, DURATION_DECELERATE,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	decelerating = true

func update_velocity(v):
	velocity = v

func set_vignette(vignette_value):
	self.vignette_shader.set_shader_param("vignette", vignette_value)

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
		accelerate()
		
	if event.is_action_released("Accelerate") and accelerating:
		cancel_animations()
		accelerating = false
		
	if event.is_action_pressed("Decelerate") and not is_sailing():
		decelerate()
		
	if event.is_action_released("Decelerate") and decelerating:
		cancel_animations()
		decelerating = false

func shoot():
	var shoot_origin = projectile_origin.global_position
	var shoot_dir = Vector2.RIGHT.rotated(cannon.global_rotation)
	var loading_time = (OS.get_system_time_msecs() - shot_start_time)/1000.0
	loading_time = clamp(loading_time, 0, Globals.MAX_CANNON_CHARGING_TIME)
	
	var shoot_velocity = velocity + shoot_dir * 500 * (1.17 + loading_time/Globals.MAX_CANNON_CHARGING_TIME)
	var projectile = Projectile.instance()
	world.emit_signal("spawn_cannonball", projectile, shoot_origin, shoot_velocity)
	
	var min_trauma = 0.4
	var max_added_trauma = 0.3
	var trauma_value = min_trauma + (loading_time*max_added_trauma)/Globals.MAX_CANNON_CHARGING_TIME
	$Camera2D.add_trauma(trauma_value)
	
	animate_cannon(loading_time)
	
	can_shoot = false
	$ShotCooldown.start(SHOOT_COOLDOWN - clamp(loading_time, 0.0, SHOOT_COOLDOWN))
	
	$SoundFx/CanonSound.play_sound()
	
func animate_cannon(loading_time):
	var min_recoil = 40
	var max_added_recoil = 60
	var recoil_value = min_recoil + (loading_time*max_added_recoil)/Globals.MAX_CANNON_CHARGING_TIME
	
	cannon.fire()
	
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

var hidden_flag = false
func hide_flag(duration=1.0):
	$SoundFx/FlagChangeSound.play()
	$SoundFx/FlagSound.stop()
	hidden_flag = true
	var hidden_flag_position = Vector2(-19, -16)
	$Tween.interpolate_property($ship/flag, "position",
	$ship/flag.position, hidden_flag_position, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Tween_tween_completed(object, key):
	# Death animation
	if is_dying:
		# Step 1: camera finished its simultaneous zoom and position change, go lower flag
		if object == $Camera2D and key == ":position":
			$DeathTimers/WaitToLowerFlag.start()
		elif object == $ship/flag and key == ":position":
			# Step 2: ship has finished to lower its flag, go wait
			if hidden_flag:
				hidden_flag = false
				$DeathTimers/WaitToRaiseWhiteFlagTimer.start()
			# Step 3: ship has finished to raise its white flag
			else:
				$DeathTimers/WaitToSinkTimer.start()
		# Step 4: ship has finished to sink-rotate, go sink
		elif object == $ship and key == ":rotation":
			$SoundFx/SinkSound.play_sound()
			$Tween.interpolate_property($ship, "position",
			$ship.position, Vector2($ship.position.x, $ship.position.y + 300), 1.0,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		# Step 5: ship is sunk, player is dead now
		elif object == $ship and key == ":position":
			emit_signal("dead")
			self.hide()

	elif object == $ship/flag:
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

func recover_health():
	if self.health < Globals.PLAYER_MAX_HEALTH:
		self.health += 1
		emit_signal("health_changes", self.health)

func _on_Hitbox_body_entered(body):
	if $InvincibilityTime.time_left <= 0:
		if not is_dying:
			$Camera2D.add_trauma(1.0)
			$SoundFx/DamageSound.play_sound()
			self.health -= 1
			emit_signal("health_changes", self.health)
			if self.health <= 0:
				self.die()
			else:
				start_invincibility_period()
			
func start_invincibility_period():
	$InvincibilityTime.start()
	$ship/hull.material.set_shader_param("blink", true)

func _on_InvincibilityTime_timeout():
	$ship/hull.material.set_shader_param("blink", false)
			
func _on_DyingAnimationTimer_timeout():
	$Tween.interpolate_property(self, "position",
	self.position, Vector2(self.position.x, self.position.y + 1000), 4,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func die():
	is_dying = true
	emit_signal("dying")
	
	$Tween.stop_all()
	
	$Tween.interpolate_method(self, "set_vignette",
	vignette_shader.get_shader_param("vignette"), 0.0, 0.2,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

	$Tween.interpolate_property($Camera2D, "zoom",
	$Camera2D.zoom, Vector2(0.8, 0.8), 0.5,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$Tween.interpolate_property($Camera2D, "position",
	$Camera2D.position, Vector2(0, -21), 0.5,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_WaitToLowerFlag_timeout():
	self.hide_flag()

func _on_WaitToRaiseWhiteFlagTimer_timeout():
	$ship/flag.color = Color(1, 1, 1, 1)
	flag_up(1.0)

func _on_WaitToSinkTimer_timeout():
	$SoundFx/SinkRotateSound.play_sound()
	var rotation_direction = 1 if $ship.rotation > 0 else -1
	$Tween.interpolate_property($ship, "rotation",
	$ship.rotation, rotation_direction+$ship.rotation, 1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
