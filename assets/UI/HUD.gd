extends Control

onready var player: Node2D = get_viewport().get_node("Game/ViewportContainer/Viewport/Map/Player")
onready var sound_button = $always_on/sound_button
onready var cannon_charging_bar = $stats/CannonChargingBar
onready var health_bar = $stats/health_bar

onready var stats = $stats
onready var title = $title_screen/Title
onready var subtitle = $title_screen/Subtitle
onready var credit = $title_screen/Credit
onready var intro = $title_screen/Intro
onready var hint = $title_screen/Hint
onready var win_counter = $stats/WinCounter

func _ready():
	player.connect("start_charging_cannon", self, "start")
	player.connect("stop_charging_cannon", self, "stop")
	player.connect("health_changes", self, "update_health")
	sound_button.pressed = Settings.get_is_sound_active()
	health_bar.set_max(Globals.PLAYER_MAX_HEALTH)
	update_health(player.health)
	start_intro_animation()

func start_intro_animation():
	title.modulate.a = 0
	subtitle.modulate.a = 0
	credit.modulate.a = 0
	intro.modulate.a = 0
	hint.modulate.a = 0
	stats.modulate.a = 0
	
	Utils.fade_node_in(title, 1, 2)
	Utils.fade_node_out(title, 1, 11)
	Utils.fade_node_in(subtitle, 1, 3)
	Utils.fade_node_out(subtitle, 1, 10)
	Utils.fade_node_in(credit, 1, 4)
	Utils.fade_node_out(credit, 1, 10)
	Utils.fade_node_in(intro, 1, 12)
	Utils.fade_node_out(intro, 1, 18)
	Utils.fade_node_in(hint, 1, 19)
	Utils.fade_node_in(hint, 1, 19)

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
	
func update_win_counter(new_counter, init_win_counter):
	win_counter.text = str(new_counter) + "/" + str(init_win_counter)

func update_health(value):
	health_bar.value = value

func hide_hint():
	Utils.fade_node_out($title_screen, 1)
	Utils.fade_node_in($stats, 1, 1)

func hide_stats():
	Utils.fade_node_out(stats, 1)


func _on_sound_button_toggled(button_pressed):
	# pressed means active sound
	Settings.set_is_sound_active(button_pressed)
