extends Node2D

# Called when the node enters the scene tree for the first time.
var speed

onready var player = get_parent().get_node("Player")

var is_dying = false

enum DIRECTION {
	LEFT_TO_RIGHT = 1
	RIGHT_TO_LEFT = -1
}

var dir
var destination_x

var active_bird

func init(player, global_pos_y, direction=DIRECTION.LEFT_TO_RIGHT):
	self.player = player
	self.dir = direction

	global_position = Vector2(
		player.global_position.x - (Globals.buffer_size.x * direction),
		global_pos_y
	)
	
	match direction:
		DIRECTION.LEFT_TO_RIGHT:
			speed = Globals.PLAYER_MAXIMUM_SPEED + 10
			$bird_right.show()
			$bird_left.hide()
			active_bird = $bird_right
		DIRECTION.RIGHT_TO_LEFT:
			speed = Globals.PLAYER_DEFAULT_SPEED
			$bird_left.show()
			$bird_right.hide()
			active_bird = $bird_left

func _ready():
	$SoundFx/SpawnSound.play()
	
func _process(delta):
	var destination_x = player.global_position.x + (Globals.buffer_size.x * self.dir)
	destination_x = player.global_position.x + (600 * self.dir)
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
	
	position.x += delta*speed*dir

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
