extends "res://Entities/Car.gd"
class_name PlayerCar

var cam_shake = 0
var fuel = 1500
var has_turbo = false
var playing = true
var health = 2000
var score = 0
var fuel_loss_mult = 1
var low_fuel = false
var low_health = false

func Get_Input():
	var Turn = 0
	if Input.is_action_pressed("turn_left"):
		Turn -= 1
	if Input.is_action_pressed("turn_right"):
		Turn += 1
	if Input.is_action_pressed("accelerate"):
		Acceleration = transform.x * EnginePower
	if Input.is_action_pressed("brake"):
		Acceleration = transform.x * Braking
	if Input.is_action_pressed("hand_brake"):
		is_Drifting = true
	if Input.is_action_just_released("hand_brake"):
		is_Drifting = false
	if Input.is_action_pressed("Turbo") and has_turbo:
		has_turbo = false
		EnginePower *= 2
		cam_shake = 2
		fuel_loss_mult = 0.5
		$Flames.emitting = true
		$Flames2.emitting = true
		$ShakeTimer.start()
		$TurboTimer.start()
		
	Steering = Turn * deg2rad(SteeringAngle)

func camera_shake(shake_amount):
	$Camera2D.set_offset(Vector2( rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount))

func get_damage():
	if get_slide_count() > 0:
		health -= 5

func _physics_process(delta):
	Acceleration = Vector2.ZERO
	if playing:
		Get_Input()
	Calculate_Steering(delta)
	Apply_Friction()
	Velocity += Acceleration * delta
	Velocity = move_and_slide(Velocity)
	engines_sound()
	if get_slide_count() > 0:
		if not $Impact.is_playing():
			$Impact.play(0.01)
		cam_shake = 1.5
		$ShakeTimer.start()
	camera_shake(cam_shake)
	get_damage()
	if fuel <= 350:
		low_fuel = true
		if not $Alarm.playing:
			$Alarm.play()
	else:
		low_fuel = false
		if $Alarm.playing and not low_fuel and not low_health:
			$Alarm.stop()
	if health <= 500:
		low_health = true
		if not $Alarm.playing:
			$Alarm.play()
	else:
		low_health = false
		if $Alarm.playing and not low_fuel and not low_health:
			$Alarm.stop()
	spawn_particles()

func _on_TurboTimer_timeout():
	EnginePower /= 2
	fuel_loss_mult = 1
	$Flames.emitting = false
	$Flames2.emitting = false

func _on_ShakeTimer_timeout():
	cam_shake = 0

func _on_FuelTimer_timeout():
	fuel -= (Velocity.length()/float(200) + 0.5) * fuel_loss_mult
