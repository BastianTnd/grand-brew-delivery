extends Control


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/game.tscn")


func _on_back_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/MainMenu/main_menu.tscn")
