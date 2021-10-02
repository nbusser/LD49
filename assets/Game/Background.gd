extends CanvasLayer

onready var slider = $HSlider
onready var shader = $ColorRect.material

func _on_HSlider_value_changed(value):
	shader.set_shader_param("time", value)
