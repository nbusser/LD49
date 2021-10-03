extends Node

var cutscene_mode = false

func _ready():
	# self.activate_cutscene()
	pass
	
func _input(event):
	if cutscene_mode and event.is_action_pressed("FlagUp"):
		$Map/Player.flag_up()
		cutscene_mode = false
		$HudLayer/HUD.hide_hint()

func activate_cutscene():
	cutscene_mode = true
	$Map/Player.go_cutscene_mode()
	$CutsceneHint.start()

func _on_CutsceneHint_timeout():
	$HudLayer/HUD.show_hint()
