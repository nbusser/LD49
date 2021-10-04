extends Node

const INTRO = "intro"
const LOOP = "loop"
const END = "end"

onready var currentIntroMusic = null
onready var currentLoopMusic = $CalmBeforeTheStorm
onready var currentEndMusic = null
onready var nextIntroMusic = $StartColereDeNeptune
onready var nextLoopMusic = $LoopColereDeNeptune
onready var nextEndMusic = $EndColereDeNeptune
onready var currentMusic = null

onready var currentMusicType = LOOP

# Called when the node enters the scene tree for the first time.
func _ready():
	$CalmBeforeTheStorm.stream.set_loop(false)
	$StartColereDeNeptune.stream.set_loop(false)
	$LoopColereDeNeptune.stream.set_loop(true)
	$EndColereDeNeptune.stream.set_loop(false)
	$LoopLaValseDesFlots.stream.set_loop(true)
	$EndLaValseDesFlots.stream.set_loop(false)
	$JeuneEtDynamiquePirate.stream.set_loop(true)
	currentMusic = currentLoopMusic
	currentMusic.play()
	currentMusic.connect("finished", self, "_on_CurrentMusic_finished")
	
	
func _on_CurrentMusic_finished():
	match currentMusicType:
		INTRO:
			if (currentLoopMusic != null):
				changeMusic(currentLoopMusic)
				currentMusicType = LOOP
			elif (currentEndMusic != null):
				changeMusic(currentEndMusic)
				currentMusicType = END
			else:
				changeMusicToNext()
		LOOP:
			currentMusic.stream.set_loop(true)
			if (currentEndMusic != null):
				changeMusic(currentEndMusic)
				currentMusicType = END
			else:
				changeMusicToNext()
		END:
			changeMusicToNext()
	
func changeMusic(next):
	currentMusic.disconnect("finished", self, "_on_CurrentMusic_finished")
	currentMusic = next
	currentMusic.play()
	currentMusic.connect("finished", self, "_on_CurrentMusic_finished")

func changeMusicToNext():
	if (nextIntroMusic != null):
		changeMusic(nextIntroMusic)
		updateMusicToNext()
		currentMusicType = INTRO
	elif (nextLoopMusic):
		changeMusic(nextLoopMusic)
		updateMusicToNext()
		currentMusicType = LOOP
	elif (nextEndMusic):
		changeMusic(nextEndMusic)
		updateMusicToNext()
		currentMusicType = END
	else:
		changeMusic(currentMusic)

func updateMusicToNext():
	currentIntroMusic = nextIntroMusic
	currentLoopMusic = nextLoopMusic
	currentEndMusic = nextEndMusic
	
func scheduleBeforeTheStorm():
	currentLoopMusic.stream.set_loop(false)
	nextIntroMusic = null
	nextLoopMusic = $CalmBeforeTheStorm
	nextEndMusic = null

func scheduleColereDeNeptune():
	currentLoopMusic.stream.set_loop(false)
	nextIntroMusic = $StartColereDeNeptune
	nextLoopMusic = $LoopColereDeNeptune
	nextEndMusic = $EndColereDeNeptune
	
func scheduleValseDesFlots():
	currentLoopMusic.stream.set_loop(false)
	nextIntroMusic = null
	nextLoopMusic = $LoopLaValseDesFlots
	nextEndMusic = $EndLaValseDesFlots
	
func scheduleJeuneEtDynamiquePirate():
	currentLoopMusic.stream.set_loop(false)
	nextIntroMusic = null
	nextLoopMusic = $JeuneEtDynamiquePirate
	nextEndMusic = null
