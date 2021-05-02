extends Node2D

signal EMP

func _on_Area2D_body_entered(body):
	if body is PlayerCar:
		emit_signal("EMP")
		queue_free()
