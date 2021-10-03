extends Node

signal update_weather

onready var time = $Background/time
onready var weather = $Background/weather
onready var shader = $Background/ColorRect.material
onready var rain = $Weather/rain

var cutscene_mode = false


func _ready():
	update_time(time.value)
	update_weather(weather.value)
	# self.activate_cutscene()


func update_time(value):
	shader.set_shader_param("time", value)

func update_weather(value):
	shader.set_shader_param("weather", value)
	rain.lifetime = 1 + (1 - value) * 10
	rain.emitting = value > 0.0
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
