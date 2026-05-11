extends Control

# --- PRELOAD TEXTURES ---
var tex_default = preload("res://Game/TitleScreenPictures/TitlescreenNew3Buttons.png")
var tex_play_hover = preload("res://Game/TitleScreenPictures/TitlescreenNew3ButtonsPlay2.png")
var tex_play_click = preload("res://Game/TitleScreenPictures/TitlescreenNew3ButtonsPlay.png")
var tex_how_hover = preload("res://Game/TitleScreenPictures/TitlescreenNew3ButtonsHowToPlay2.png")
var tex_how_click = preload("res://Game/TitleScreenPictures/TitlescreenNew3ButtonsHowToPlay.png")
var tex_credits_hover = preload("res://Game/TitleScreenPictures/TitlescreenNew3ButtonsCredits2.png")
var tex_credits_click = preload("res://Game/TitleScreenPictures/TitlescreenNew3ButtonsCredits.png")

# --- UI REFERENCES ---
@onready var background_rect = $TextureRect
@onready var play_button = find_child("Play")
@onready var how_to_play_button = find_child("HowToPlay")
@onready var credits_button = find_child("Credits")

func _ready():
	# START MENU MUSIC
	SoundManager.play_menu_music()
	
	if background_rect:
		background_rect.texture = tex_default
	
	_setup_signals()

func _setup_signals():
	if play_button:
		play_button.mouse_entered.connect(_on_play_hover)
		play_button.mouse_exited.connect(_on_ui_exit)
		play_button.button_down.connect(_on_play_down)
	if how_to_play_button:
		how_to_play_button.mouse_entered.connect(_on_how_hover)
		how_to_play_button.mouse_exited.connect(_on_ui_exit)
		how_to_play_button.button_down.connect(_on_how_down)
	if credits_button:
		credits_button.mouse_entered.connect(_on_credits_hover)
		credits_button.mouse_exited.connect(_on_ui_exit)
		credits_button.button_down.connect(_on_credits_down)

# --- VISUAL FEEDBACK LOGIC ---
func _on_play_hover(): background_rect.texture = tex_play_hover
func _on_play_down(): background_rect.texture = tex_play_click
func _on_how_hover(): background_rect.texture = tex_how_hover
func _on_how_down(): background_rect.texture = tex_how_click
func _on_credits_hover(): background_rect.texture = tex_credits_hover
func _on_credits_down(): background_rect.texture = tex_credits_click
func _on_ui_exit(): background_rect.texture = tex_default

# --- BUTTON FUNCTIONALITY ---
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/CarSelection/car_selection.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/HowToPlayMenu/how_to_play.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/CreditsMenu/credits.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
