extends CanvasLayer



func _on_Button_pressed():
	get_tree().change_scene("res://UI/Menu.tscn")




func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
