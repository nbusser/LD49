extends Node

signal update_weather

onready var time = $HudLayer/time
onready var weather = $HudLayer/weather
onready var bg_shader = $Background/bg.material
onready var rain = $Weather/rain
onready var clouds = $Background/clouds
onready var viewport_shader = $ViewportContainer.material

var cutscene_mode = false


func _ready():
	update_time(time.value)
	update_weather(weather.value)
	# self.activate_cutscene()


func update_time(value):
	bg_shader.set_shader_param("time", value)
	viewport_shader.set_shader_param("time", value)
	clouds.modulate.a = 1 - 0.5 * value

func update_weather(value):
	Globals.current_weather = value
	bg_shader.set_shader_param("weather", value)
	viewport_shader.set_shader_param("weather", value)
	rain.lifetime = 1 + (1 - value) * 10
	rain.emitting = value > 0.0
	var lightness = 1 - 0.8 * value
	clouds.modulate = Color(lightness, lightness, lightness)
	emit_signal("update_weather", value)

func activate_cutscene():
	cutscene_mode = true
	$Map/Player.go_cutscene_mode()
	$CutsceneHint.start()


func _input(event):
	if cutscene_mode and event.is_action_pressed("FlagUp"):
		$Map/Player.flag_up()
		cutscene_mode = false
		$HudLayer/HUD.hide_hint()


func _on_time_value_changed(value):
	update_time(value)

func _on_weather_value_changed(value):
	update_weather(value)

func _on_CutsceneHint_timeout():
	$HudLayer/HUD.show_hint()
