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
	spawn_player_car()
	
	spawn_items()
	if ScoreManager:
		ScoreManager.delivery_completed.connect(spawn_items)

func spawn_player_car():
	var car_to_spawn = Global.selected_car_path
	var car_scene = load(car_to_spawn)
	var car_instance = car_scene.instantiate()
	
	if has_node("SpawnPoint"):
		car_instance.global_position = $SpawnPoint.global_position
	else:
		car_instance.global_position = Vector2(0, 0) 
		
	add_child(car_instance)

func spawn_items():
	var random_number_spawn_points = randi_range(1, 5)
	var collectible_spawn_points = spawn_points[random_number_spawn_points]
	
	var types = [Collectible.collectible_type.MALT, Collectible.collectible_type.HOPS, Collectible.collectible_type.YEAST]
	
	for index in range(types.size()):
		var item = collectible_blueprint.instantiate()
		item.collectible = types[index]
		add_child(item)
		item.position = collectible_spawn_points[index]
