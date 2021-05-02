extends "res://Entities/Car.gd"

var passed = false
var pointing = false
var path_finished = false

var p
var angle
var state
var pth
var stuck = false
var has_moved = false

var times_reverse = 0
var movement_mult = 1
var turning_mult = 1
var pth_id = 0

signal chasing
signal searching
signal player_hit

# Called when the node enters the scene tree for the first time.
func _ready():
	Steering = 0

func find_direction_to_point(point):
	if not passed:
		var Turn = 0
		angle = transform.x.angle_to(global_position.direction_to(point))
		if angle < -0.1:
			Turn -= 1 * turning_mult
		elif angle > 0.1:
			Turn += 1 * turning_mult
		Acceleration = transform.x * EnginePower * movement_mult
		Steering = Turn * deg2rad(SteeringAngle)
		if angle >= -0.1 and angle <= 0.1:
			pointing = true
			Steering = 0

func go_to_point(point):
	if point != null:
		if not pointing and not passed:
			find_direction_to_point(point)
		if position.distance_to(point) > 100 and not passed and pointing:
			Acceleration = transform.x * EnginePower * movement_mult
		if position.distance_to(point) < 100:
			passed = true
			pointing = false

func follow_path(path):
	if path != null:
		if not path_finished:
			p = path[pth_id]
			if passed:
				passed = false
				pointing = false
				pth_id = min(pth_id + 1, path.size()-1)
				if pth_id == path.size()-1:
					path_finished = true

func follow_objective():
	passed = false
	pointing = false

func unstuck():
	if stuck:
		Steering = 0
		Acceleration = transform.x * Braking
		going_backwards = true


func _physics_process(delta):
	Acceleration = Vector2.ZERO
	if state == "Following":
		follow_objective()
	elif state == "Searching" or state == "Patrolling":
		follow_path(pth)
	go_to_point(p)
	unstuck()
	Calculate_Steering(delta)
	Apply_Friction()
	if state == "Off":
		Acceleration = Vector2.ZERO
	Velocity += Acceleration * delta
	Velocity = move_and_slide(Velocity)
	engines_sound()
	if get_slide_count() > 0:
		$Impact.play()
	if Acceleration != Vector2.ZERO and Velocity.length() <= 50 and not going_backwards and get_slide_count() > 0 and state != "Following":
		stuck = true
		times_reverse += 1
		$Timer2.start()
	spawn_particles()

func _on_Area2D_body_entered(body):
	if body is PlayerCar and state != "Off":
		if not has_moved:
			has_moved = true
			$Sirens.play()
			$AnimationTree/AnimationPlayer.play("Police Sirens")
		emit_signal("chasing")
		state = "Following"
		movement_mult = 1
		turning_mult = 1.5

func _on_Area2D_body_exited(body):
	if body is PlayerCar and state != "Off":
		pth_id = 0
		path_finished = false
		emit_signal("searching")
		state = "Searching"
		movement_mult = 1
		turning_mult = 1.5


func _on_Timer2_timeout():
	stuck = false
	Acceleration = transform.x * EnginePower
	going_backwards = false


func _on_HitZone_body_entered(body):
	if body is PlayerCar:
		$Impact.play()
		emit_signal("player_hit")
