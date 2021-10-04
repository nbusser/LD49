extends Node2D

onready var player = get_parent().get_node("Player")

var velocity = Vector2(0, 0)

var is_dying = false

enum DIRECTION {
	LEFT_TO_RIGHT = 1
	RIGHT_TO_LEFT = -1
}

var dir
var destination_x

var active_bird

const COEF_DIST = 0.4
var original_offset

func init(player, offset_player_y, direction=DIRECTION.LEFT_TO_RIGHT):
	self.player = player
	self.dir = direction
	self.original_offset = offset_player_y

	global_position = player.global_position - Vector2(
		Globals.buffer_size.x*COEF_DIST * direction,
		offset_player_y
	)
	
	match direction:
		DIRECTION.LEFT_TO_RIGHT:
			velocity.x = Globals.PLAYER_MAXIMUM_SPEED * 1.2
			$bird_right.show()
			$bird_left.hide()
			active_bird = $bird_right
		DIRECTION.RIGHT_TO_LEFT:
			velocity.x = Globals.PLAYER_DEFAULT_SPEED
			$bird_left.show()
			$bird_right.hide()
			active_bird = $bird_left

func _ready():
	$SoundFx/SpawnSound.play()

func _process(delta):
	var destination_x = player.global_position.x + (Globals.buffer_size.x*COEF_DIST * self.dir)
	if (
		(
			dir == DIRECTION.LEFT_TO_RIGHT
			and global_position.x > destination_x
		) or
		(
			dir == DIRECTION.RIGHT_TO_LEFT
			and global_position.x < destination_x
		)
	):
		queue_free()
	
	var max_speed_y = 500
	if global_position.y > player.global_position.y - original_offset:
		velocity.y +=  (max_speed_y/2)*delta
	else:
		velocity.y -= (max_speed_y/2)*delta
		
	velocity.y = clamp(velocity.y, 0, max_speed_y)
		
	position.x += delta*velocity.x*dir
	position.y -= delta*velocity.y

func _on_Hitbox_body_entered(body):
	player.recover_health()
	$SoundFx/DeathSound.play_sound()
	
	$Tween.interpolate_property(self.active_bird, "modulate",
	self.active_bird.modulate, Color(1, 1, 1, 0), 0.8,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$bird_right.hide()
	
	# TODO: tell UI to do anchor animation
	$anchor.hide()

func _on_Tween_tween_completed(object, key):
	if object == self.active_bird and key == ":modulate":
		queue_free()
