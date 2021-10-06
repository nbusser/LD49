extends Control

var value = 0 setget set_value

func _ready():
	pass

func set_max(value):
	_set_sprite_size($health_bar_bg, value)

func set_value(value):
	value = value
	_set_sprite_size($health_bar, value)

func _set_sprite_size(sprite, value):
	if value == 0:
		sprite.hide()
	else:
		sprite.rect_size.x = max(0, value * 87)
		sprite.show()
	sprite.rect_size.x = max(0, value * 87)
