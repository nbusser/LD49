extends Node2D

const MAX_UNZOOM = 1.1
onready var buffer_size = Vector2(
	MAX_UNZOOM * 6 * get_viewport_rect().size.x, get_viewport_rect().size.y
)

const MAX_CANNON_CHARGING_TIME = 1.0

const PLAYER_MAX_HEALTH = 1

const PLAYER_DEFAULT_SPEED = 150
const PLAYER_MAXIMUM_SPEED = PLAYER_DEFAULT_SPEED*2.5
const PLAYER_MINIMUM_SPEED = PLAYER_DEFAULT_SPEED/2

var current_weather = 0.0;
