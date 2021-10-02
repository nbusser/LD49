extends Node2D

const MAX_UNZOOM = 1.1
onready var buffer_size = Vector2(
	MAX_UNZOOM * 3 * get_viewport_rect().size.x, get_viewport_rect().size.y
)
