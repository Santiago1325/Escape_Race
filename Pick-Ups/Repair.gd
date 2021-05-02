extends Node2D

signal Repair


func _on_Area2D_body_entered(body):
	if body is PlayerCar:
		emit_signal("Repair")
		queue_free()
