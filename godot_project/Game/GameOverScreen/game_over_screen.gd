extends CanvasLayer

@onready var result_label = find_child("ResultLabel")

func _ready():
	if result_label:
		result_label.text = "Final Score: " + str(int(round(ScoreManager.total_points)))
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed():
	ScoreManager.start_game()
	get_tree().change_scene_to_file("res://Game/game.tscn")

func _on_main_menu_button_pressed():
	ScoreManager.reset_game()
	get_tree().change_scene_to_file("res://Game/MainMenu/main_menu.tscn")
