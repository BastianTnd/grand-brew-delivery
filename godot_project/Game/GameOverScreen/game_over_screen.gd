extends CanvasLayer

@onready var result_label = find_child("ResultLabel")
@onready var name_input = find_child("NameInput") 

func _ready():
	# Show final score on screen
	if result_label:
		result_label.text = "Final Score: " + str(int(round(ScoreManager.total_points)))
	
	# Configure the input field if it exists
	if name_input:
		name_input.max_length = 3
		name_input.placeholder_text = "ABC"
		name_input.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		# Focus the field so player can type immediately
		name_input.grab_focus() 
	else:
		print("WARNING: NameInput node not found! Check your Scene Tree.")
	
	# Make mouse visible for UI interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _save_and_finalize():
	var player_name = "???"
	if name_input:
		var text = name_input.text.strip_edges()
		if text != "":
			player_name = text
	
	ScoreManager.save_new_score(int(round(ScoreManager.total_points)), player_name)

func _on_restart_button_pressed():
	_save_and_finalize()
	ScoreManager.start_game()
	get_tree().change_scene_to_file("res://Game/game.tscn")

func _on_main_menu_button_pressed():
	_save_and_finalize()
	ScoreManager.reset_game()
	get_tree().change_scene_to_file("res://Game/MainMenu/main_menu.tscn")
