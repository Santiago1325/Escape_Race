extends Control

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		$".".show()
		get_tree().paused = true
	if Input.is_action_pressed("ui_accept"):
		$".".hide()
		get_tree().paused = false
		Song1.stream_paused = true

