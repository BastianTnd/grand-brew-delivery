extends Control

## Map Selection: Choose between the classic map or the procedural generator.

# --- BUTTON SIGNALS ---

## Loads the handcrafted legacy map
func _on_legacy_map_pressed() -> void:
	Global.selected_map_path = "res://Map/map.tscn"
	start_game()

## Loads the procedurally generated map
func _on_generated_map_pressed() -> void:
	Global.selected_map_path = "res://MapGenerated/map_new.tscn"
	start_game()

## Navigation back to Car Selection (The "X" button)
func _on_back_button_pressed() -> void:
	# Goes back one step so the player can pick a different vehicle
	get_tree().change_scene_to_file("res://Game/CarSelection/car_selection.tscn")

# --- GAME LOGIC ---

func start_game() -> void:
	ScoreManager.start_game()
	# SoundManager.play_race_music() # Optional, falls noch nicht im Game-Level-Ready
	get_tree().change_scene_to_file("res://Game/game.tscn")


func _on_go_back_pressed() -> void:
	pass # Replace with function body.
