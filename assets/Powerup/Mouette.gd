extends Node2D

# Called when the node enters the scene tree for the first time.
const SPEED = Globals.PLAYER_MAXIMUM_SPEED + 10

onready var player = get_parent().get_node("Player")

var is_dying = false

func _ready():
	$SoundFx/SpawnSound.play()
	
func _process(delta):
	if global_position.x > player.global_position.x + Globals.buffer_size.x:
		queue_free()
	
	position.x += delta*SPEED

func _on_Hitbox_body_entered(body):
	print("touché")
	$SoundFx/DeathSound.play_sound()

func _on_DeathSound_finished():
	queue_free()
