extends Node2D

signal spawn_cannonball(projectile, shoot_origin, shoot_velocity)

onready var sight_loss_distance = 1.2*get_viewport_rect().size.x*Globals.MAX_UNZOOM

onready var Malfrat = preload("res://assets/Enemies/Malfrat/Malfrat.tscn")

onready var primary_wave = $Wave0
onready var secondary_wave = $Wave1
var secondary_generated = true

var next_buffer_offset
var x_in_buffer

var elapsed_time = 0.0

var transition_time = 5.0
var amp_y = 300

func get_peaks_to_player(enemy: Node2D):
	var bakeds # quelque chose à redire ?
	var waves
	if primary_wave.position.x < secondary_wave.position.x:
		bakeds = [primary_wave.get_baked_points(), secondary_wave.get_baked_points()]
		waves = [primary_wave, secondary_wave]
	else:
		bakeds = [secondary_wave.get_baked_points(), primary_wave.get_baked_points()]
		waves = [secondary_wave, primary_wave]

	var baked = bakeds[0]
	var a_global = min($Player.position.x, enemy.position.x)
	var b_global = max($Player.position.x, enemy.position.x)
	var a = a_global - waves[0].global_position.x
	var b = b_global - waves[0].global_position.x
	
	var i = 0
	var baked_i =  0
	while baked_i < 2 and baked[i].x < a:
		while i < len(baked) and baked[i].x < a:
			i += 1
		if i >= len(baked):
			baked_i += 1
			baked = bakeds[baked_i]
			i = 0
			a = a_global - waves[baked_i].global_position.x
			b = b_global - waves[baked_i].global_position.x

	var peaks = []
	var prev_d = (baked[max(1, i)].y - baked[max(1, i) - 1].y) < 0
	var leave = false

	while baked_i < 2 and !leave:
		baked = bakeds[baked_i]
		a = a_global - waves[baked_i].global_position.x
		b = b_global - waves[baked_i].global_position.x
		while i + 1 < len(baked) and baked[i].x < b:
			var d = (baked[i + 1].y - baked[i].y) < 0
			if prev_d and !d:
				peaks.append(baked[i] + waves[baked_i].global_position)
			prev_d = d
			i += 1
		leave = baked[i].x >= b
		i = 0
		baked_i += 1

	return peaks

var Mouette = preload("res://assets/Powerup/Mouette.tscn")

func _ready():
	primary_wave.init($WaveGenerator.generate_buffer())
	secondary_wave.init($WaveGenerator.generate_buffer())
	secondary_wave.position.x = Globals.buffer_size.x
	secondary_generated = true
	x_in_buffer = 4000
	next_buffer_offset = 1

func spawn_mouette():
	var dir = 1 if randi()%2 else -1
	var offset = randi()%300+300
	
	var mouette = Mouette.instance()
	mouette.init($Player, offset, dir)
	add_child(mouette)

func spawn_enemy():
	var malfrat = Malfrat.instance()
	malfrat.get_node("ship/hull").material.set_shader_param("color", Vector3(randf(), randf(), randf()));
	var scale = max(randf() * 2, .5)
	malfrat.get_node("ship").scale = Vector2(scale, scale)
	malfrat.health = ceil(scale * 2)
	malfrat.speed *= 3 - scale
	
	malfrat.set_player($Player)
	
	malfrat.position = Vector2($Player.position.x + sight_loss_distance * 2 + 450, 416)

	if malfrat.position.x - primary_wave.position.x < Globals.buffer_size.x:
		malfrat.current_wave = primary_wave
	else:
		malfrat.current_wave = secondary_wave
		
	malfrat.x_in_buffer = malfrat.current_wave.curve.get_closest_point(malfrat.position - malfrat.current_wave.global_position).x

	malfrat.connect("dead", self, "remove_enemy")

	$Malfrats.add_child(malfrat)

func remove_enemy(malfrat):
	$Malfrats.remove_child(malfrat)
	malfrat.queue_free()

func player_move_checks():
	if (!secondary_generated):
		if (($Player.position.x - (next_buffer_offset-1)*Globals.buffer_size.x) > 2*sight_loss_distance):
			secondary_generated = true
			secondary_wave.init($WaveGenerator.generate_buffer())
			secondary_wave.position.x = next_buffer_offset*Globals.buffer_size.x
	
	elif ($Player.position.x > next_buffer_offset*Globals.buffer_size.x):
		next_buffer_offset += 1
		secondary_generated = false
		x_in_buffer = 0
		
		var tmp_wave = primary_wave
		primary_wave = secondary_wave
		secondary_wave = tmp_wave
		
	for malfrat in $Malfrats.get_children():
		if malfrat.current_wave == primary_wave && malfrat.position.x > next_buffer_offset*Globals.buffer_size.x:
			malfrat.current_wave = secondary_wave
			malfrat.x_in_buffer = 0

func _process(delta):
	if $Player.can_move():
		var x_in_buffer_before = primary_wave.curve.get_closest_offset($Player.position - primary_wave.global_position)
		x_in_buffer = x_in_buffer_before + $Player.speed*delta
		var displacement = Vector2(primary_wave.interpolate_baked(x_in_buffer)) - Vector2(primary_wave.interpolate_baked(x_in_buffer_before))
		$Player.update_velocity(displacement/delta)
		$Player.position = Vector2(primary_wave.interpolate_baked(x_in_buffer))
		player_move_checks()
		
		var closest = primary_wave.curve.get_closest_point($Player.position + Vector2(35, 0) - primary_wave.global_position)
		var rot = closest.angle_to_point($Player.position - primary_wave.global_position)
		rot = clamp(rot, -1.0, 1.0)
		$Player/ship.rotation = lerp($Player/ship.rotation, rot, 3*delta)
	
		# TODO: if tempête, caméra bourrée en faisant
		# $Player.ship.rotation = lerp($Player.ship.rotation, rot, 5*delta)
	
		for malfrat in $Malfrats.get_children():
			if abs(malfrat.position.x - $Player.position.x) < malfrat.MALFRAT_DANGER_DISTANCE:
				malfrat.accelerate()
			
			if malfrat.can_move():
				closest = malfrat.current_wave.curve.get_closest_point(malfrat.position + Vector2(35, 0) - malfrat.current_wave.global_position)
				rot = closest.angle_to_point(malfrat.position - malfrat.current_wave.global_position)
				rot = clamp(rot, -1.0, 1.0)
				var malfrat_ship = malfrat.get_node("ship")
				malfrat_ship.rotation = lerp(malfrat_ship.rotation, rot, 6*delta)
				
				malfrat.position = Vector2(malfrat.current_wave.interpolate_baked(malfrat.x_in_buffer))
				
				malfrat.x_in_buffer = malfrat.current_wave.curve.get_closest_offset(malfrat.position - malfrat.current_wave.global_position) + malfrat.speed*delta
	
	elapsed_time += delta
	if elapsed_time > transition_time:
		elapsed_time -= (int(elapsed_time/transition_time))*transition_time
		var vdiff = Vector2(Globals.buffer_size.x, 0)
		if secondary_generated:
			primary_wave.update_target_curve_fst()
			secondary_wave.update_target_curve_snd(
				primary_wave.target_curve[-2] - vdiff, primary_wave.target_curve[-1] - vdiff,
				primary_wave.starting_curve[-2] - vdiff, primary_wave.starting_curve[-1] - vdiff
			)
		else:
			secondary_wave.update_target_curve_fst()
			primary_wave.update_target_curve_snd(
				secondary_wave.target_curve[-2] - vdiff, secondary_wave.target_curve[-1] - vdiff,
				secondary_wave.starting_curve[-2] - vdiff, secondary_wave.starting_curve[-1] - vdiff
			)
	
	primary_wave.timer_stage = elapsed_time/transition_time
	secondary_wave.timer_stage = elapsed_time/transition_time

func _on_Map_spawn_cannonball(projectile, shoot_origin, shoot_velocity):
	$Projectiles.add_child(projectile)
	projectile.global_transform.origin = shoot_origin
	projectile.linear_velocity = shoot_velocity
	yield(get_tree().create_timer(45), "timeout")
	projectile.queue_free()

var difficulty = 1
var first_enemy_spawned = false

func _on_SpawnMalfratTimer_timeout():
	spawn_enemy()
	$SpawnMalfratTimer.start(randf() * 35 / (WorldEnv.get_weather() + difficulty))

func _on_SpawnMouetteTimer_timeout():
	if (WorldEnv.get_weather() < Globals.LIGHTNING_THRESHOLD):
		spawn_mouette()
		$SpawnMouetteTimer.start(randf() * 35 * (1 + (WorldEnv.get_weather() + difficulty)/2))
