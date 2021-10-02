extends Node2D

const MAX_UNZOOM = 1.1
onready var buffer_size = 1.1 * Vector2(
	get_viewport_rect().size.x * MAX_UNZOOM, get_viewport_rect().size.y
)
