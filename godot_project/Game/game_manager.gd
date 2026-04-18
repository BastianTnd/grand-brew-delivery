extends Node2D

var collectible_blueprint = preload("res://Collectible/collectible.tscn")

func _ready():
	spawn_items()
	if ScoreManager:
		ScoreManager.delivery_completed.connect(spawn_items)
		
func _input(_event: InputEvent) -> void:
	# Open Pause Menu using esc
	if Input.is_action_just_pressed("ui_text_clear_carets_and_selection"):
		get_tree().change_scene_to_file("res://Game/PauseMenu/pause_menu.tscn")

func spawn_items():
	var types = [Collectible.collectible_type.MALT, Collectible.collectible_type.HOPS, Collectible.collectible_type.YEAST]
	for t in types:
		var item = collectible_blueprint.instantiate()
		item.collectible = t
		add_child(item)
		item.position = Vector2(randf_range(200, 1600), randf_range(200, 1000))
