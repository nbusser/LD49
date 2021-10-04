extends Node

var _is_sound_active: bool = true

func _ready():
	set_is_sound_active(Globals.IS_SOUND_ACTIVE_INITIAL)

func set_is_sound_active(value: bool):
	_is_sound_active = value
	var master_sound = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_sound, not _is_sound_active)

func get_is_sound_active():
	return _is_sound_active
