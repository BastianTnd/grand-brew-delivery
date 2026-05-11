extends Control


func _on_legacy_map_pressed() -> void:
	Global.selected_map_path = "res://Map/map.tscn"
	start_game()
	

func _on_generated_map_pressed() -> void:
	Global.selected_map_path = "res://MapGenerated/map_new.tscn"
	start_game()
	
func start_game() -> void:
	ScoreManager.start_game()
	get_tree().change_scene_to_file("res://Game/game.tscn")
