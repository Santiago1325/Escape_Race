extends Control


var game_path = "res://Levels/TestD.tscn"
var menu_path = "res://UI/Menu.tscn"

func _ready():
	$Label.text = GameVariables.game_over_cause
	$Label2.text = "SCORE  : "+ str(GameVariables.player_score)


func _on_PlayAgain_pressed():
	get_tree().change_scene(game_path)


func _on_Menu_pressed():
	get_tree().change_scene(menu_path)


func _on_ChangeColor_pressed():
	get_tree().change_scene("res://UI/ColorSelection.tscn")
