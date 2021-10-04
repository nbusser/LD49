extends Control

onready var player: Node2D = get_viewport().get_node("Game/ViewportContainer/Viewport/Map/Player")

func _ready():
	player.connect("start_charging_cannon", self, "start")
	player.connect("stop_charging_cannon", self, "stop")
	$CenterContainer/Hint.modulate = Color(1, 1, 1, 0)

func start():
	$Tween.stop_all()
	$Tween.interpolate_property($CannonChargingBar, "value",
	$CannonChargingBar.value, $CannonChargingBar.max_value,
	Globals.MAX_CANNON_CHARGING_TIME,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func stop():
	$Tween.stop_all()
	$Tween.interpolate_property($CannonChargingBar, "value",
	$CannonChargingBar.value, 0,
	0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func show_hint():
	$Tween.interpolate_property($CenterContainer/Hint, "modulate",
	$CenterContainer/Hint.modulate, Color(1, 1, 1, 1), 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
func hide_hint():
	$Tween.stop($CenterContainer/Hint, "modulate")
	$Tween.interpolate_property($CenterContainer/Hint, "modulate",
	$CenterContainer/Hint.modulate, Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func _on_time_slider_value_changed(value):
	WorldEnv.set_time(value)

func _on_weather_slider_value_changed(value):
	WorldEnv.set_weather(value)
