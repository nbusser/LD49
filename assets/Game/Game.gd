extends Node

onready var bg_shader = $ViewportContainer/Viewport/Background/bg.material
onready var rain = $ViewportContainer/Viewport/Weather/rain
onready var clouds = $ViewportContainer/Viewport/Background/clouds
onready var viewport_shader = $ViewportContainer.material
onready var player = $ViewportContainer/Viewport/Map/Player

var cutscene_mode = false

onready var sail_shader = preload("res://assets/Shaders/sail_shader.tres")
onready var flag_shader = preload("res://assets/Shaders/flag_shader.tres")

func _ready():
	WorldEnv.connect("update_time", self, "_on_update_time")
	WorldEnv.connect("update_weather", self, "_on_update_weather")
	WorldEnv.set_time(0)
	WorldEnv.set_weather(0)
	player.connect("dead", self, "gameover")
	self.activate_cutscene()
	viewport_shader.set_shader_param("lightning_threshold", Globals.LIGHTNING_THRESHOLD)

func _process(delta):
	WorldEnv.add_time(delta * Globals.TIME_MULTIPLIER)

func gameover():
	$HudLayer/HUD.hide()
	$HudLayer/GameOver.show()

func _on_update_time(value):
	bg_shader.set_shader_param("time", value)
	viewport_shader.set_shader_param("time", value)
	clouds.modulate.a = 1 - 0.9 * Utils.sigmoid(value, 10)

func _on_update_weather(value):
	bg_shader.set_shader_param("weather", value)
	viewport_shader.set_shader_param("weather", value)
	sail_shader.set_shader_param("weather", value)
	flag_shader.set_shader_param("weather", value)
	rain.lifetime = 1 + (1 - value) * 10
	rain.emitting = value > 0.0
	var lightness = 1 - 0.8 * value
	clouds.modulate = Color(lightness, lightness, lightness, clouds.modulate.a)

func activate_cutscene():
	cutscene_mode = true
	player.go_cutscene_mode()
	$CutsceneHint.start()

func _unhandled_input(event):
	if cutscene_mode and event.is_action_pressed("FlagUp"):
		$Musics.scheduleValseDesFlots()
		player.start_to_play()
		cutscene_mode = false
		$HudLayer/HUD.hide_hint()

func _on_CutsceneHint_timeout():
	if cutscene_mode:
		$HudLayer/HUD.show_hint()

func _on_GameOver_restart():
	get_tree().change_scene("res://assets/Game/Game.tscn")
