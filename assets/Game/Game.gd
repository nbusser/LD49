extends Node

onready var time_slider = $HudLayer/time_slider
onready var weather_slider = $HudLayer/weather_slider
onready var bg_shader = $Background/bg.material
onready var rain = $Weather/rain
onready var clouds = $Background/clouds
onready var viewport_shader = $ViewportContainer.material
onready var player = $ViewportContainer/Viewport/Map/Player

var cutscene_mode = false

onready var sail_shader = preload("res://assets/Shaders/sail_shader.tres")
onready var flag_shader = preload("res://assets/Shaders/flag_shader.tres")

func _ready():
	WorldEnv.connect("update_time", self, "_on_update_time")
	WorldEnv.connect("update_weather", self, "_on_update_weather")
	WorldEnv.set_time(time_slider.value)
	WorldEnv.set_weather(weather_slider.value)
	# self.activate_cutscene()


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


func _input(event):
	if cutscene_mode and event.is_action_pressed("FlagUp"):
		player.flag_up()
		cutscene_mode = false
		$HudLayer/HUD.hide_hint()


func _on_time_value_changed(value):
	WorldEnv.set_time(value)

func _on_weather_value_changed(value):
	WorldEnv.set_weather(value)

func _on_CutsceneHint_timeout():
	$HudLayer/HUD.show_hint()
