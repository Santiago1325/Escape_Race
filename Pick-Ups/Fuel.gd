extends Node2D

signal Fuel

func _on_Area2D_body_entered(body):
	if body is PlayerCar:
		emit_signal("Fuel")
		queue_free()

