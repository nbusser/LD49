extends Node

var killed_malfrats = 0

onready var bg_shader = $ViewportContainer/Viewport/Background/bg.material
onready var rain = $ViewportContainer/Viewport/Weather/rain
onready var clouds = $ViewportContainer/Viewport/Background/clouds
onready var viewport_shader = $ViewportContainer.material
onready var player = $ViewportContainer/Viewport/Map/Player
onready var map = $ViewportContainer/Viewport/Map

var cutscene_mode = false

onready var sail_shader = preload("res://assets/Shaders/sail_shader.tres")
onready var flag_shader = preload("res://assets/Shaders/flag_shader.tres")

func _ready():
	randomize()
	WorldEnv.connect("update_time", self, "_on_update_time")
	WorldEnv.connect("update_weather", self, "_on_update_weather")
	WorldEnv.set_time(0)
	WorldEnv.set_weather(0)
	player.connect("dead", self, "gameover")
	self.activate_cutscene()
	viewport_shader.set_shader_param("lightning_threshold", Globals.LIGHTNING_THRESHOLD)
	$ViewportContainer/Viewport/Map.connect("malfrat_died", self, "increase_dead_enemies")
	$HudLayer/HUD.update_win_counter(0, Globals.MALFRATS_TO_KILL)

func increase_dead_enemies():
	killed_malfrats += 1
	$HudLayer/HUD.update_win_counter(killed_malfrats, Globals.MALFRATS_TO_KILL)
	if killed_malfrats == Globals.MALFRATS_TO_KILL:
		win()

func win():
	$HudLayer/HUD.hide_stats()
	$HudLayer/VictoryScreen.show()
	$ViewportContainer/Viewport/Map.freeze_win()

func _process(delta):
	WorldEnv.add_time(delta * Globals.TIME_MULTIPLIER)

func gameover():
	$HudLayer/HUD.hide_stats()
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
	rain.emitting = value > (Globals.SUNNY_THRESHOLD - 0.05)
	var lightness = 1 - 0.8 * value
	clouds.modulate = Color(lightness, lightness, lightness, clouds.modulate.a)

	if value == 0:
		$RainSound.stop()
	else:
		if not $RainSound.playing:
			$RainDelay.start()

func activate_cutscene():
	cutscene_mode = true
	player.go_cutscene_mode()
	$CutsceneHint.start()

func _unhandled_input(event):
	if cutscene_mode and event.is_action_pressed("FlagUp"):
		$Musics.scheduleValseDesFlots()
		player.start_to_play()
		map._on_SpawnMouetteTimer_timeout()
		cutscene_mode = false
		$HudLayer/HUD.hide_hint()
		$WeatherChangeTimer.start((randf() * 60) + 5)

func _on_CutsceneHint_timeout():
	if cutscene_mode:
		#$HudLayer/HUD.show_hint()
		pass

func restart():
	get_tree().change_scene("res://assets/Game/Game.tscn")

func _on_GameOver_restart():
	restart()


func _on_WeatherChangeTimer_timeout():
	if (WorldEnv.get_weather() < Globals.SUNNY_THRESHOLD):
		$TweenWeatherChange.interpolate_method(
			WorldEnv,
			"set_weather",
			WorldEnv.get_weather(),
			rand_range(Globals.SUNNY_THRESHOLD, Globals.LIGHTNING_THRESHOLD),
			Globals.TRANSITION,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN
			)
		$Musics.scheduleJeuneEtDynamiquePirate()
		$WeatherChangeTimer.start((randf() * 60) + 10 + Globals.TRANSITION)
	elif (WorldEnv.get_weather() > Globals.LIGHTNING_THRESHOLD):
		$TweenWeatherChange.interpolate_method(
			WorldEnv,
			"set_weather",
			WorldEnv.get_weather(),
			rand_range(Globals.SUNNY_THRESHOLD, Globals.LIGHTNING_THRESHOLD),
			Globals.TRANSITION,
			Tween.TRANS_LINEAR,
			Tween.EASE_OUT
			)
		map._on_SpawnMouetteTimer_timeout()
		$Musics.scheduleJeuneEtDynamiquePirate()
		$WeatherChangeTimer.start((randf() * 60) + 10 + Globals.TRANSITION)
	elif (randf() > 0.35):
		$TweenWeatherChange.interpolate_method(
			WorldEnv,
			"set_weather",
			WorldEnv.get_weather(),
			rand_range(Globals.LIGHTNING_THRESHOLD, 1.0),
			Globals.TRANSITION,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN
			)
		$Musics.scheduleColereDeNeptune()
		$WeatherChangeTimer.start((randf() * 60) + 15 + Globals.TRANSITION)
	else:
		$TweenWeatherChange.interpolate_method(
			WorldEnv,
			"set_weather",
			WorldEnv.get_weather(),
			rand_range(Globals.SUNNY_THRESHOLD, Globals.LIGHTNING_THRESHOLD),
			Globals.TRANSITION,
			Tween.TRANS_LINEAR,
			Tween.EASE_OUT
			)
		$Musics.scheduleValseDesFlots()
		$WeatherChangeTimer.start((randf() * 60) + 5 + Globals.TRANSITION)
	$TweenWeatherChange.start()



func _on_VictoryScreen_restart():
	restart()


func _on_RainDelay_timeout():
	$RainSound.play()
