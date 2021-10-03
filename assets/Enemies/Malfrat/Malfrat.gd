extends Node2D

signal dead

const MALFRAT_DANGER_DISTANCE = 600
const MALFRAT_DEFAULT_SPEED = Globals.PLAYER_MINIMUM_SPEED * 0.8
const MALFRAT_MAXIMUM_SPEED = Globals.PLAYER_MAXIMUM_SPEED * 1.75
const MALFRAT_FLEE_DURATION = .75
const MALFRAT_UNFLEE_DURATION = .75

var speed = MALFRAT_DEFAULT_SPEED
var current_wave;
var x_in_buffer

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
