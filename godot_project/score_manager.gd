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

func _ready():
	time_left = game_time

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
	get_tree().change_scene_to_file("res://Game/GameOverScreen/GameOverScreen.tscn")

func reset_game():
	total_points = 0.0
	items_collected = 0
	has_malt = false
	has_hops = false
	has_yeast = false
	time_left = game_time
	is_game_active = false
