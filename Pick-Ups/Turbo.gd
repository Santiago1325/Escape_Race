extends Node2D

signal Turbo

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_Area2D_body_entered(body):
	if body is PlayerCar:
		emit_signal("Turbo")
		queue_free()
