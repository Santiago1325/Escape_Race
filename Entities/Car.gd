extends KinematicBody2D

var WheelBase = 45
var SteeringAngle = 15
var Steering
var Friction = -0.9
var Drag = -0.001
var Traction = 0.1
export var MinTraction = 0.1
export var MaxTraction = 1
export var EnginePower = 800
export var Braking = -450
var MaxSpeedReverse = 250
export var SlipSpeed = 250
var Acceleration = Vector2.ZERO
var Velocity = Vector2.ZERO
var MinDriftAngle = 0.7
var DriftAngle = 0
var Drifting = false
var is_Drifting = false
var going_backwards = false

const collision_particles = preload("res://Effects/Collision.tscn")

func spawn_particles():
	if get_slide_count() > 0 and Velocity.length() > 10:
		var coll_pos = get_slide_collision(0).position
		var particle_instance = collision_particles.instance()
		particle_instance.position = coll_pos
		particle_instance.rotation = rotation
		var parent = get_parent()
		parent.add_child(particle_instance)

func Calculate_Steering(delta):
	var RearWheel = position - transform.x * WheelBase/2.0
	var FrontWheel = position + transform.x * WheelBase/2.0
	RearWheel += Velocity * delta
	FrontWheel += Velocity.rotated(Steering) * delta
	var NewDirection = (FrontWheel - RearWheel).normalized()
	var d = NewDirection.dot(Velocity.normalized())
	if Velocity.length() > SlipSpeed:
		if Traction > MinTraction:
			Traction -= 0.01
			Traction = max(MinTraction, Traction)
	elif Velocity.length() == 0:
		Traction = 1
	else:
		if Traction < MaxTraction:
			Traction += 0.001
			Traction = min(MaxTraction, Traction)
	if is_Drifting:
		Traction = 0
	if not is_Drifting:
		Traction = MinTraction
	if d > 0:
		Velocity = Velocity.linear_interpolate(NewDirection * Velocity.length(), Traction)
		DriftAngle = abs(Velocity.angle_to(NewDirection))
		if DriftAngle > MinDriftAngle and is_Drifting:
			Drifting = true
		else:
			Drifting = false
	if d < 0:
		Velocity = -NewDirection * min(MaxSpeedReverse, Velocity.length())
	rotation = NewDirection.angle()

func Apply_Friction():
	if Velocity.length() < 5:
		Velocity = Vector2.ZERO
	var FrictionForce = Velocity * Friction
	var DragForce = Velocity * Velocity.length() * Drag
	Acceleration += DragForce + FrictionForce

func engines_sound():
	$Engine.pitch_scale = max(float(1)/800 * Velocity.length(),0.01)





