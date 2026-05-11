extends Control

func _on_van_button_pressed() -> void:
	Global.selected_car_path = "res://Player/van.tscn"
	go_to_map_selection()

func _on_sportscar_button_pressed() -> void:
	Global.selected_car_path = "res://Player/sportscar.tscn"
	go_to_map_selection()

func go_to_map_selection() -> void:
	get_tree().change_scene_to_file("res://Game/MapSelection/map_selection.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
