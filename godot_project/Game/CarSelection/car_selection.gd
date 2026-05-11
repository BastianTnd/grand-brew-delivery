extends Control

## Car Selection Menu: Handles vehicle picking and navigation back to the main menu.

# --- BUTTON SIGNALS ---

## Triggered when the Van is selected
func _on_van_button_pressed() -> void:
	# Store path for dynamic instantiation and proceed to map selection
	Global.selected_car_path = "res://Player/van.tscn"
	go_to_map_selection()

## Triggered when the Sports Car is selected
func _on_sportscar_button_pressed() -> void:
	# Select agile vehicle class and proceed
	Global.selected_car_path = "res://Player/sportscar.tscn"
	go_to_map_selection()

## Navigation back to main menu
## Connect the "pressed()" signal of your GoBack button to this function
func _on_back_button_pressed() -> void:
	# Returns to the main title screen
	get_tree().change_scene_to_file("res://Game/MainMenu/main_menu.tscn")

# --- NAVIGATION HELPERS ---

## Switches to the map selection scene
func go_to_map_selection() -> void:
	get_tree().change_scene_to_file("res://Game/MapSelection/map_selection.tscn")
