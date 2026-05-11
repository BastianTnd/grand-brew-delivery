extends Node2D

var collectible_blueprint = preload("res://Collectible/collectible.tscn")
var current_map_generator = null

var spawn_points = {
	1: [Vector2(350, 195), Vector2(730, 245), Vector2(-880, 1275)],
	2: [Vector2(760, 1320), Vector2(-540, 880), Vector2(950, -70)],
	3: [Vector2(-850, 480), Vector2(200, 1030), Vector2(820, 950)],
	4: [Vector2(950, 1350), Vector2(-680, 600), Vector2(350, 340)],
	5: [Vector2(603, 580), Vector2(-535, 1360), Vector2(-5, 690)],
}

func _ready():
	# SWITCH TO RACE MUSIC
	SoundManager.play_race_music()
	
	_load_selected_map() 
	
	# Find Map Generator and save it
	current_map_generator = _find_map_generator(self)
	
	if current_map_generator != null:
		spawn_player_car(current_map_generator)
	else:
		spawn_player_car(null)
	
	spawn_items()
	if ScoreManager:
		ScoreManager.delivery_completed.connect(spawn_items)
		
func _load_selected_map() -> void:
	if Global.selected_map_path != "":
		var map_scene = load(Global.selected_map_path)
		var map_instance = map_scene.instantiate()
		add_child(map_instance) 
		move_child(map_instance, 0) 

func _find_map_generator(node: Node) -> Node:
	if node is MapGenerator:
		return node
	for child in node.get_children():
		var result = _find_map_generator(child)
		if result != null:
			return result
	return null

func spawn_player_car(map_generator = null):
	var car_to_spawn = Global.selected_car_path
	var car_scene = load(car_to_spawn)
	var car_instance = car_scene.instantiate()
	
	if map_generator != null:
		car_instance.global_position = map_generator.player_spawn_position
		car_instance.adapt_to_map_scale(0.5) 
		
		var camera = car_instance.get_node_or_null("Camera2D")
		if camera:
			camera.zoom = Vector2(2.5, 2.5) 
			camera.limit_left = 0
			camera.limit_top = 0
			camera.limit_right = map_generator._dimensions.x * map_generator.block_size
			camera.limit_bottom = map_generator._dimensions.y * map_generator.block_size
			
	elif has_node("SpawnPoint"):
		car_instance.global_position = $SpawnPoint.global_position
		var camera = car_instance.get_node_or_null("Camera2D")
		if camera:
			camera.limit_left = -1007
			camera.limit_top = -119
			camera.limit_right = 993
			camera.limit_bottom = 1401
	else:
		car_instance.global_position = Vector2.ZERO 
		
	add_child(car_instance)

func spawn_items():
	var types = [Collectible.collectible_type.MALT, Collectible.collectible_type.HOPS, Collectible.collectible_type.YEAST]
	var selected_spawn_coords = []
	
	if current_map_generator != null:
		var all_possible_spawns = current_map_generator.dead_end_positions.duplicate()
		all_possible_spawns.append_array(current_map_generator.fallback_positions.duplicate())
		all_possible_spawns.shuffle()
		
		for i in range(3):
			var found_spot = false
			for pos in all_possible_spawns:
				if pos.distance_to(current_map_generator.player_spawn_position) > 100 and not selected_spawn_coords.has(pos):
					selected_spawn_coords.append(pos)
					all_possible_spawns.erase(pos)
					found_spot = true
					break
			if not found_spot:
				selected_spawn_coords.append(Vector2(0,0))
	else:
		var random_number_spawn_points = randi_range(1, 5)
		selected_spawn_coords = spawn_points[random_number_spawn_points]
	
	for index in range(types.size()):
		var item = collectible_blueprint.instantiate()
		item.collectible = types[index]
		add_child(item)
		item.position = selected_spawn_coords[index]
		if current_map_generator != null:
			item.scale = Vector2(0.5, 0.5)
