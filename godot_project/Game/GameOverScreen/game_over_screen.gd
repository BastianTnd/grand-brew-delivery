extends CanvasLayer

# --- PRELOAD TEXTURES ---
var tex_default = preload("res://Game/EndScreensPictures/EndScreen.png")
var tex_restart_hover = preload("res://Game/EndScreensPictures/EndScreenTryAgain2.png")
var tex_restart_click = preload("res://Game/EndScreensPictures/EndScreenTryAgain.png")
var tex_menu_hover = preload("res://Game/EndScreensPictures/EndScreenMainMenu2.png")
var tex_menu_click = preload("res://Game/EndScreensPictures/EndScreenMainMenu.png")

# --- UI REFERENCES ---
@onready var background_rect = $Background 
@onready var result_label = find_child("ResultLabel")
@onready var name_input = find_child("NameInput") 
@onready var restart_button = find_child("RestartButton")
@onready var main_menu_button = find_child("MainMenuButton")

func _ready():
	if background_rect:
		background_rect.texture = tex_default
	
	if restart_button:
		restart_button.mouse_entered.connect(_on_restart_hover)
		restart_button.mouse_exited.connect(_on_ui_exit)
		restart_button.button_down.connect(_on_restart_down)
	
	if main_menu_button:
		main_menu_button.mouse_entered.connect(_on_main_menu_hover)
		main_menu_button.mouse_exited.connect(_on_ui_exit)
		main_menu_button.button_down.connect(_on_main_menu_down)

	if result_label:
		result_label.text = "Final Score: " + str(int(round(ScoreManager.total_points)))
	
	if name_input:
		name_input.max_length = 3
		name_input.placeholder_text = "ABC"
		name_input.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		name_input.grab_focus() 
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# --- VISUAL FEEDBACK LOGIC ---

func _on_restart_hover():
	background_rect.texture = tex_restart_hover

func _on_restart_down():
	background_rect.texture = tex_restart_click

func _on_main_menu_hover():
	background_rect.texture = tex_menu_hover

func _on_main_menu_down():
	background_rect.texture = tex_menu_click

func _on_ui_exit():
	background_rect.texture = tex_default

# --- BUTTON FUNCTIONALITY ---

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
