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
		DIRECTION.RIGHT_TO_LEFT:
			speed = Globals.PLAYER_DEFAULT_SPEED
			$bird_left.show()
			$bird_right.hide()

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

func get_anchor():
	#TODO To fix
	var dest = get_tree().get_root().get_node("Game/HudLayer/HUD/CannonChargingBar").rect_global_position
	$Tween.interpolate_property($AnchorSprite, "position",
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Hitbox_body_entered(body):
	$SoundFx/DeathSound.play_sound()
	$bird_left.hide()
	$bird_right.hide()
	$anchor.hide()
	#get_anchor()

func _on_DeathSound_finished():
	queue_free()
