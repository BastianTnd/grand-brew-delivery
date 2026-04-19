extends Node2D

var collectible_blueprint = preload("res://Collectible/collectible.tscn")
var spawn_points = {
	1: [Vector2(350, 195), Vector2(730, 245), Vector2(-880, 1275)],
	2: [Vector2(760, 1320), Vector2(-540, 880), Vector2(950, -70)],
	3: [Vector2(-850, 480), Vector2(200, 1030), Vector2(820, 950)],
	4: [Vector2(950, 1350), Vector2(-680, 600), Vector2(350, 340)],
	5: [Vector2(603, 580), Vector2(-535, 1360), Vector2(-5, 690)],
}

func _ready():
	spawn_items()
	if ScoreManager:
		ScoreManager.delivery_completed.connect(spawn_items)
		
func _input(_event: InputEvent) -> void:
	# Open Pause Menu using esc
	if Input.is_action_just_pressed("ui_text_clear_carets_and_selection"):
		get_tree().change_scene_to_file("res://Game/PauseMenu/pause_menu.tscn")

func spawn_items():
	var random_number_spawn_points = randi_range(1, 5)
	var collectible_spawn_points = spawn_points[random_number_spawn_points]
	print("Spawn Punkte: ", collectible_spawn_points)
	
	var types = [Collectible.collectible_type.MALT, Collectible.collectible_type.HOPS, Collectible.collectible_type.YEAST]
	
	for index in range(types.size()):
		var item = collectible_blueprint.instantiate()
		item.collectible = types[index]
		add_child(item)
		item.position = collectible_spawn_points[index]
