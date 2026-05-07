extends Node

signal delivery_completed
signal game_over

@export var game_time : float = 240.0 
var total_points : float = 0.0
var items_collected : int = 0 
var time_left : float

var has_malt : bool = false
var has_hops : bool = false
var has_yeast : bool = false

var is_game_active : bool = false

var highscore_file_path = "user://highscores.json"
var highscores = []

func _ready():
	time_left = game_time
	load_highscores()

func _process(delta):
	if is_game_active and time_left > 0:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			is_game_active = false
			game_over.emit()
			_trigger_end()

func start_game():
	reset_game()
	is_game_active = true

func collect_item(type: int):
	items_collected += 1
	if type == 0: has_malt = true
	elif type == 1: has_hops = true
	elif type == 2: has_yeast = true

func add_points(amount: float):
	total_points += amount

func complete_delivery():
	items_collected = 0 
	has_malt = false
	has_hops = false
	has_yeast = false
	delivery_completed.emit() 

func _trigger_end():
	is_game_active = false
	save_new_score(int(round(total_points)))
	get_tree().change_scene_to_file("res://Game/GameOverScreen/GameOverScreen.tscn")

func reset_game():
	total_points = 0.0
	items_collected = 0
	has_malt = false
	has_hops = false
	has_yeast = false
	time_left = game_time
	is_game_active = false


func save_new_score(score_value: int):
	var new_entry = {"score": score_value, "date": Time.get_date_string_from_system()}
	highscores.append(new_entry)
	
	highscores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	if highscores.size() > 5:
		highscores.resize(5)
	
	var file = FileAccess.open(highscore_file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(highscores)
		file.store_string(json_string)
		file.close()
		print("Score lokal gespeichert!")

func load_highscores():
	if not FileAccess.file_exists(highscore_file_path):
		highscores = []
		return

	var file = FileAccess.open(highscore_file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			highscores = json.data
			print("Highscores geladen: ", highscores)
		else:
			print("JSON Fehler beim Laden")
