extends Control

signal restart

func _on_Button_button_down():
	emit_signal("restart")
