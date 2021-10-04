extends Node

signal update_weather
signal update_time

var _current_weather: float = 0.0;
var _current_time: float = 0.0;

func set_weather(value: float):
	_current_weather = clamp(value, 0.0, 1.0)
	emit_signal("update_weather", _current_weather)

func get_weather():
	return _current_weather

func set_time(value: float):
	_current_time = clamp(value, 0.0, 1.0)
	emit_signal("update_time", _current_time)

func get_time():
	return _current_time
