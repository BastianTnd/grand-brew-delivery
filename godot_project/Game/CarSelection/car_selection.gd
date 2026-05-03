extends Control

func _on_van_button_pressed() -> void:
	Global.selected_car_path = "res://Player/van.tscn"
	start_game()

func _on_sportscar_button_pressed() -> void:
	Global.selected_car_path = "res://Player/sportscar.tscn"
	start_game()

func start_game() -> void:
	ScoreManager.start_game()
	get_tree().change_scene_to_file("res://Game/game.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
