extends Control

onready var player: Node2D = get_viewport().get_node("Game/ViewportContainer/Viewport/Map/Player")
onready var sound_button = $VBoxContainer/HBoxContainer/sound_button
onready var cannon_charging_bar = $VBoxContainer/HBoxContainer/VBoxContainer/CannonChargingBar
onready var health_label = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/HealthLabel

func _ready():
	player.connect("start_charging_cannon", self, "start")
	player.connect("stop_charging_cannon", self, "stop")
	player.connect("health_changes", self, "update_health")
	$CenterContainer/Hint.modulate = Color(1, 1, 1, 0)
	sound_button.pressed = Settings.get_is_sound_active()
	update_health()

func start():
	$Tween.stop_all()
	$Tween.interpolate_property(cannon_charging_bar, "value",
	cannon_charging_bar.value, cannon_charging_bar.max_value,
	Globals.MAX_CANNON_CHARGING_TIME,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func stop():
	$Tween.stop_all()
	$Tween.interpolate_property(cannon_charging_bar, "value",
	cannon_charging_bar.value, 0,
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
	
func update_health():
	health_label.text = str(player.health)


func _on_sound_button_toggled(button_pressed):
	# pressed means active sound
	Settings.set_is_sound_active(button_pressed)
