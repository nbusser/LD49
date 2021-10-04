extends Node


onready var currentMusic = $CalmBeforeTheStorm
onready var nextMusic = $JeuneEtDynamiquePirate

# Called when the node enters the scene tree for the first time.
func _ready():
	$CalmBeforeTheStorm.stream.set_loop(false)
	$StartColereDeNeptune.stream.set_loop(false)
	$LoopColereDeNeptune.stream.set_loop(true)
	$EndColereDeNeptune.stream.set_loop(false)
	$LoopLaValseDesFlots.stream.set_loop(true)
	$EndLaValseDesFlots.stream.set_loop(false)
	$JeuneEtDynamiquePirate.stream.set_loop(true)
	
	$CalmBeforeTheStorm.play()
	

func _on_CalmBeforeTheStorm_finished():
	nextMusic.play()
	currentMusic = nextMusic
	$CalmBeforeTheStorm.stream.set_loop(true)
	
func _on_LoopLaValseDesFlots_finished():
	$LoopLaValseDesFlots.stream.set_loop(true)
	
func changeMusic():
	nextMusic.play()
	currentMusic = nextMusic

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
