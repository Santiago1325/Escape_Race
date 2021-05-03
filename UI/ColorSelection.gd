extends CanvasLayer



func _on_ColorPicker_color_changed(color):
	$TextureRect/Car.modulate = color
	GameVariables.car_color = color

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://Levels/TestD.tscn")


func _on_Button_pressed():
	get_tree().change_scene("res://UI/Menu.tscn")
