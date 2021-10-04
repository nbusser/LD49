extends Control

signal restart

onready var message = $Message
onready var restart_button = $CenterContainer/restart_button

func show():
	visible = true
	message.modulate.a = 0
	restart_button.modulate.a = 0
	Utils.fade_node_in(message, 1)
	Utils.fade_node_in(restart_button, 1, 1)

func _on_restart_button_button_down():
	emit_signal("restart")
