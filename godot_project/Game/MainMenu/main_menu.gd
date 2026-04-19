extends Control

func _on_play_pressed() -> void:
	ScoreManager.start_game()
	get_tree().change_scene_to_file("res://Game/game.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/HowToPlayMenu/how_to_play.tscn")
	
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/CreditsMenu/credits.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
