extends Node2D

var p_id = 0
var last_known_pos
var car_id = 0
var it
var game_state = "Normal"
var last_game_state = game_state
var ai_states
var can_finish = false
var pursuit_song = preload("res://Assets/PursuitSong.ogg")
var emp_sound = preload("res://Assets/EMP_Sound.ogg")
var reapir_sound = preload("res://Assets/CarRepair.ogg")
var paused = false
var busting = false
var game_lost = false
var won = false

var safezone_locations = [Vector2(2440,130), Vector2(-1406,2177), Vector2(-2985,-1922)]
var player_spawns = [Vector2(1153,-127), Vector2(-3197,1665), Vector2(1660,384)]


func _ready():
	randomize()
	$Player.position = player_spawns[randi() % 3]
	$SafeZone.position = safezone_locations[randi() % 3]
	$Player.fuel /= 2
	print($SafeZone.position)
	$Player/Body.modulate = GameVariables.car_color
	$Player/Arrow.modulate = GameVariables.car_color
	it = 1
	var ai_car_array = [$AICar, $AICar2, $AICar3]
	for car in ai_car_array:
		car.connect("searching", self, "on_ai_searching" + str(it))
		car.connect("chasing", self, "on_ai_following")
		car.connect("player_hit",self, "on_player_hit")
		it += 1
	for emp in $EMP.get_children():
		emp.connect("EMP", self, "on_EMP_picked")
	for fuel in $Fuel.get_children():
		fuel.connect("Fuel",self, "on_Fuel_picked")
	for turbo in $Turbo.get_children():
		turbo.connect("Turbo",self, "on_Turbo_picked")
	for repair in $Repair.get_children():
		repair.connect("Repair",self, "on_Repair_picked")
	Song1.stream_paused = true

func on_ai_following():
	ai_states = [$AICar.state, $AICar2.state, $AICar3.state]
	last_game_state = game_state
	game_state = "Following"
	update_map_color(last_game_state,game_state)

func on_player_hit():
	$Player.health -= 75
	$Player.cam_shake = 2.5
	$Player/ShakeTimer.start()

func on_ai_searching1():
	on_ai_searching($AICar)

func on_ai_searching2():
	on_ai_searching($AICar2)

func on_ai_searching3():
	on_ai_searching($AICar3)

func on_EMP_picked():
	$SoundFX.stream = emp_sound
	$SoundFX.volume_db = 10
	$SoundFX.play()
	var ai_car_array = [$AICar, $AICar2, $AICar3]
	for car in ai_car_array:
		if car.state != null:
			car.state = "Off"
	game_state = "Off"
	update_map_color(last_game_state,game_state)
	$CanvasLayer/HUD/HBoxContainer/EMP.visible = true
	$EMPTimer.start()

func on_Fuel_picked():
	$Player.fuel = min(1500, $Player.fuel + 500)
	$Player.score += 45

func on_Turbo_picked():
	$Player.has_turbo = true
	$CanvasLayer/HUD/HBoxContainer/Turbo.visible = true

func on_Repair_picked():
	$SoundFX.stream = reapir_sound
	$SoundFX.volume_db = 1
	$SoundFX.play()
	$Player.health = min(2000, $Player.health + 1000)


func on_ai_searching(ai_car):
	$Player.score += 35
	ai_states = [$AICar.state, $AICar2.state, $AICar3.state]
	if not "Following" in ai_states:
		game_state = "Searching"
		update_map_color(last_game_state,game_state)
	ai_car.pth_id = 0
	ai_car.passed = false
	ai_car.pointing = false
	ai_car.path_finished = false
	last_known_pos = $Player.global_position
	ai_car.pth = $Navigation2D.get_simple_path(ai_car.global_position, last_known_pos, false)

func ai_car_state(ai_car):
	if ai_car.state == "Following":
		ai_car.p = $Player.position
	if ai_car.state == "Searching":
		if ai_car.path_finished or ai_car.times_reverse % 5 == 0:
			on_ai_searching(ai_car)

func find_closest_fuel():
	var fuel_array = $Fuel.get_children()
	if not fuel_array.empty():
		var closest_fuel = fuel_array[0]
		for f in fuel_array:
			if f.position.distance_to($Player.position) < closest_fuel.position.distance_to($Player.position):
				closest_fuel = f
		$Player/Arrow.global_rotation_degrees = rad2deg($Player.position.direction_to(closest_fuel.position).angle()) - 90
	else:
		$Player/Arrow.hide()

func update_busted_bar():
	if busting:
		$CanvasLayer/Busted/TextureProgress.value = 100 - $BustTimer.time_left * 20
	else:
		$CanvasLayer/Busted/TextureProgress.value = 0


func update_map_color(last_state, current_state):
	if last_state == "Searching":
		if current_state == "Following":
			$Navigation2D/Road2/AnimationTree/AnimationPlayer.play("Search2Follow")
		if current_state == "Off":
			$Navigation2D/Road2/AnimationTree/AnimationPlayer.play("Search2Off")
	elif last_state == "Following":
		if current_state == "Searching":
			$Navigation2D/Road2/AnimationTree/AnimationPlayer.play("Follow2Search")
		if current_state == "Off":
			$Navigation2D/Road2/AnimationTree/AnimationPlayer.play("Following2Off")
	elif last_state == "Normal":
		if current_state == "Following":
			$Navigation2D/Road2/AnimationTree/AnimationPlayer.play("Normal2Follow")
			$Audio.stream = pursuit_song
			$Audio.play()
	elif last_state == "Off":
		if current_state == "Searching":
			$Navigation2D/Road2/AnimationTree/AnimationPlayer.play("Off2Search")

func update_hud():
	$CanvasLayer/HUD/HBoxContainer/HBoxContainer/Time.text = "Time : " + str(int($GameTimer.time_left)) + "     "
	
	$CanvasLayer/HUD/HBoxContainer/HBoxContainer2/Health.text = "Health : " + str(max($Player.health,0)) + "      "
	
	$CanvasLayer/HUD/HBoxContainer/HBoxContainer3/Fuel.text = "Fuel : " + str(max(int($Player.fuel),0)) + "     "
	
	if not $Player.has_turbo:
		$CanvasLayer/HUD/HBoxContainer/Turbo.visible = false
	if can_finish:
		$CanvasLayer/HUD/HBoxContainer/HBoxContainer/Time.text = "Time : " + str(int($EndTimer.time_left)) + "   "

func path_to_safe_zone():
	if not $Player/Arrow.visible:
		$Player/Arrow.show()
	$Player/Arrow.global_rotation_degrees = rad2deg($Player.position.direction_to($SafeZone.position).angle()) - 90


func _process(_delta):
	last_game_state = game_state
	ai_car_state($AICar)
	ai_car_state($AICar2)
	ai_car_state($AICar3)
	update_hud()
	if not can_finish:
		find_closest_fuel()
	else:
		path_to_safe_zone()
	if $Player.Velocity.length() <= 50:
		bust_player()
		update_busted_bar()
	else:
		$BustTimer.stop()
		busting = false
		$CanvasLayer/Busted/TextureProgress.value = 0
	if $Player.Drifting:
		$Player.score += 25
	if $Player.fuel < 0 and not game_lost and not won:
		GameVariables.game_over_cause = "You ran out of fuel"
		game_lost = true
		$CanvasLayer/PreGameOver/Label.text = "NO FUEL"
		$CanvasLayer/PreGameOver/Label.align = HALIGN_CENTER
		$CanvasLayer/PreGameOver.show()
		$Player.playing = false
		$GameOverTimer.start()
	if $Player.health < 0 and not game_lost and not won:
		GameVariables.game_over_cause = "Your car got destroyed"
		game_lost = true
		$CanvasLayer/PreGameOver/Label.text = "DESTROYED"
		$CanvasLayer/PreGameOver.show()
		$Player.playing = false
		$GameOverTimer.start()
	if $Player.low_fuel:
		$CanvasLayer/HUD/AnimationTreeFuel/AnimationPlayerFuel.play("DangerFuel")
	else:
		$CanvasLayer/HUD/AnimationTreeFuel/AnimationPlayerFuel.stop()
		$CanvasLayer/HUD/HBoxContainer/HBoxContainer3.modulate = Color.white
	if $Player.low_health:
		$CanvasLayer/HUD/AnimationTreeHealth/AnimationPlayerHealth.play("DangerHealth")
	else:
		$CanvasLayer/HUD/AnimationTreeHealth/AnimationPlayerHealth.stop()
		$CanvasLayer/HUD/HBoxContainer/HBoxContainer2.modulate = Color.white

func bust_player():
	var ai_car_array = [$AICar, $AICar2, $AICar3]
	for car in ai_car_array:
			if car.state == "Following" and car.global_position.distance_to($Player.global_position) <= 125 and not busting:
				$BustTimer.start()
				busting = true


func _on_EMPTimer_timeout():
	var ai_car_array = [$AICar, $AICar2, $AICar3]
	for car in ai_car_array:
		if car.state != null:
			car.state = "Searching"
			on_ai_searching(car)
	$CanvasLayer/HUD/HBoxContainer/EMP.visible = false


func _on_GameTimer_timeout():
	$EndTimer.start()
	$CanvasLayer/HUD/HBoxContainer/HBoxContainer/TextureRect.modulate = Color.green
	$CanvasLayer/HUD/HBoxContainer/HBoxContainer/Time.modulate = Color.green
	$SafeZone.show()
	can_finish = true


func _on_SafeZone_body_entered(body):
	if body is PlayerCar and can_finish:
		$Player.score += 1000000
		won = true
		GameVariables.game_over_cause = "You escaped"
		$CanvasLayer/PreGameOver/Label.text = "ESCAPED"
		$CanvasLayer/PreGameOver/Label.align = HALIGN_CENTER
		$CanvasLayer/PreGameOver.show()
		$Player.playing = false
		on_EMP_picked()
		$GameOverTimer.start()

func game_over():
	GameVariables.player_score = $Player.score
	Song1.stream_paused = false
	get_tree().change_scene("res://UI/GameOver.tscn")


func _on_EndTimer_timeout():
	GameVariables.game_over_cause = "You couldn't escape in time"
	$CanvasLayer/PreGameOver/Label.text = "NO TIME"
	$CanvasLayer/PreGameOver.show()
	$CanvasLayer/PreGameOver/Label.align = HALIGN_CENTER
	$Player.playing = false
	$GameOverTimer.start()

func _on_BustTimer_timeout():
	GameVariables.game_over_cause = "You got arrested"
	$CanvasLayer/PreGameOver/Label.text = "BUSTED"
	$CanvasLayer/PreGameOver/Label.align = HALIGN_CENTER
	$CanvasLayer/PreGameOver.show()
	$Player.playing = false
	$GameOverTimer.start()


func _on_GameOverTimer_timeout():
	game_over()
