class_name MapGenerator
extends Node2D

@export var _dimensions: Vector2i = Vector2i(11, 9) 
@export var block_size: int = 256
@export var number_of_bars: int = 4

@export var chunk_scenes: Dictionary = {
	"I": null, "V": null, "H": null, 
	"CURVE": null, "T_CROSS": null, "DEAD_END": null, 
	"BREW": null, "BAR_V": null, "BAR_H": null,
	"EMPTY": null
}

signal map_ready

var city_blocks: Array
var player_spawn_position: Vector2 = Vector2.ZERO
var dead_end_positions: Array[Vector2] = []
var fallback_positions: Array[Vector2] = []

func _ready() -> void:
	randomize() 
	_initialize_city()
	_generate_city_layout()
	_place_brewery()
	_carve_organic_city() 
	_remove_disconnected_islands()
	_place_bars()
	_remove_unused_stubs()
	_calculate_all_intersections()
	_print_city_blocks()
	_build_world()
	
	map_ready.emit()

func _initialize_city() -> void:
	city_blocks.clear()
	for x in _dimensions.x:
		var column = []
		for y in _dimensions.y:
			column.append(" ")
		city_blocks.append(column)

func _generate_city_layout() -> void:
	for x in _dimensions.x:
		for y in _dimensions.y:
			var is_road_column = (x % 2 != 0)
			var is_road_row = (y % 2 != 0)
			
			if is_road_column and is_road_row: city_blocks[x][y] = "I"
			elif is_road_column: city_blocks[x][y] = "V"
			elif is_road_row: city_blocks[x][y] = "H"

func _place_brewery() -> void:
	var available_intersections: Array[Vector2i] = []
	for x in range(3, _dimensions.x - 2, 2):
		for y in range(3, _dimensions.y - 2, 2):
			if city_blocks[x][y] == "I":
				available_intersections.append(Vector2i(x, y))
				
	if available_intersections.size() > 0:
		available_intersections.shuffle()
		var bs_pos = available_intersections.pop_back()
		city_blocks[bs_pos.x][bs_pos.y] = "BREW"

func _carve_organic_city() -> void:
	for x in range(1, _dimensions.x - 1):
		for y in range(1, _dimensions.y - 1):
			if typeof(city_blocks[x][y]) == TYPE_STRING and city_blocks[x][y] in ["V", "H"]:
				var is_near_brewery = false
				if city_blocks[x][y-1] == "BREW" or city_blocks[x][y+1] == "BREW" or city_blocks[x-1][y] == "BREW" or city_blocks[x+1][y] == "BREW":
					is_near_brewery = true
				
				if not is_near_brewery and randf() < 0.35: 
					city_blocks[x][y] = " "

func _remove_disconnected_islands() -> void:
	# FLOOD FILL ALGORITHM
	var start_pos = Vector2i(-1, -1)
	
	# 1. Find Startpoint for Brewing Station
	for x in _dimensions.x:
		for y in _dimensions.y:
			if typeof(city_blocks[x][y]) == TYPE_STRING and city_blocks[x][y] == "BREW":
				start_pos = Vector2i(x, y)
				break
		if start_pos.x != -1: break
		
	if start_pos.x == -1: return
	
	var visited = []
	var queue = [start_pos]
	visited.append(start_pos)
	
	# 2. Create Streets
	while queue.size() > 0:
		var current = queue.pop_front()
		var neighbors = [Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0)]
		
		for n in neighbors:
			var nx = current.x + n.x
			var ny = current.y + n.y
			if nx >= 0 and nx < _dimensions.x and ny >= 0 and ny < _dimensions.y:
				var cell = city_blocks[nx][ny]
				var n_pos = Vector2i(nx, ny)
				if typeof(cell) == TYPE_STRING and cell != " " and not visited.has(n_pos):
					visited.append(n_pos)
					queue.append(n_pos)
					
	# 3. Delete everything that can't be reached
	for x in _dimensions.x:
		for y in _dimensions.y:
			var pos = Vector2i(x, y)
			if city_blocks[x][y] != " " and not visited.has(pos):
				city_blocks[x][y] = " "

func _place_bars() -> void:
	var edges = { "top": [], "bottom": [], "left": [], "right": [] }
	
	for x in _dimensions.x:
		for y in _dimensions.y:
			var cell = city_blocks[x][y]
			if typeof(cell) == TYPE_STRING:
				if y == 0 and cell == "V": edges["top"].append({"pos": Vector2i(x, y), "type": "BAR_V_TOP"})
				elif y == _dimensions.y - 1 and cell == "V": edges["bottom"].append({"pos": Vector2i(x, y), "type": "BAR_V_BOTTOM"})
				elif x == 0 and cell == "H": edges["left"].append({"pos": Vector2i(x, y), "type": "BAR_H_LEFT"})
				elif x == _dimensions.x - 1 and cell == "H": edges["right"].append({"pos": Vector2i(x, y), "type": "BAR_H_RIGHT"})
					
	var bars_placed = 0
	var directions = ["top", "bottom", "left", "right"]
	directions.shuffle()
	
	for dir in directions:
		if bars_placed >= number_of_bars: break
		if edges[dir].size() > 0:
			edges[dir].shuffle()
			var bar_data = edges[dir].pop_back()
			city_blocks[bar_data["pos"].x][bar_data["pos"].y] = bar_data["type"]
			bars_placed += 1
			
	if bars_placed < number_of_bars:
		var remaining_spots = []
		for dir in edges: remaining_spots.append_array(edges[dir])
		remaining_spots.shuffle()
		while bars_placed < number_of_bars and remaining_spots.size() > 0:
			var bar_data = remaining_spots.pop_back()
			city_blocks[bar_data["pos"].x][bar_data["pos"].y] = bar_data["type"]
			bars_placed += 1

func _remove_unused_stubs() -> void:
	for x in _dimensions.x:
		for y in _dimensions.y:
			var cell = city_blocks[x][y]
			if typeof(cell) == TYPE_STRING:
				if (x == 0 or x == _dimensions.x - 1) and cell == "H":
					city_blocks[x][y] = " "
				elif (y == 0 or y == _dimensions.y - 1) and cell == "V":
					city_blocks[x][y] = " "

func _calculate_all_intersections() -> void:
	for x in range(1, _dimensions.x - 1, 2):
		for y in range(1, _dimensions.y - 1, 2):
			if city_blocks[x][y] == "I":
				city_blocks[x][y] = _calculate_intersection_type(x, y)

func _is_road_connection(x: int, y: int) -> bool:
	if x < 0 or x >= _dimensions.x or y < 0 or y >= _dimensions.y:
		return false
	var cell = city_blocks[x][y]
	if typeof(cell) == TYPE_STRING: return cell != " "
	elif typeof(cell) == TYPE_DICTIONARY: return cell["type"] != " "
	return false

func _calculate_intersection_type(x: int, y: int) -> Dictionary:
	var north = 1 if _is_road_connection(x, y - 1) else 0
	var east  = 2 if _is_road_connection(x + 1, y) else 0
	var south = 4 if _is_road_connection(x, y + 1) else 0
	var west  = 8 if _is_road_connection(x - 1, y) else 0
	
	var sum = north + east + south + west
	match sum:
		0: return {"type": " ", "rot": 0}
		1: return {"type": "DEAD_END", "rot": 180}
		2: return {"type": "DEAD_END", "rot": 270}
		3: return {"type": "CURVE", "rot": 270}
		4: return {"type": "DEAD_END", "rot": 0}
		5: return {"type": "V", "rot": 0}
		6: return {"type": "CURVE", "rot": 0}
		7: return {"type": "T_CROSS", "rot": 270}
		8: return {"type": "DEAD_END", "rot": 90}
		9: return {"type": "CURVE", "rot": 180}
		10: return {"type": "H", "rot": 0}
		11: return {"type": "T_CROSS", "rot": 180}
		12: return {"type": "CURVE", "rot": 90}
		13: return {"type": "T_CROSS", "rot": 90}
		14: return {"type": "T_CROSS", "rot": 0}
		15: return {"type": "I", "rot": 0}
	return {"type": "I", "rot": 0}

func _build_world() -> void:
	for x in _dimensions.x:
		for y in _dimensions.y:
			var symbol = city_blocks[x][y]
			var scene_key = ""
			var rot_degrees = 0
			var needs_rotation = false
			
			if typeof(symbol) == TYPE_STRING:
				if symbol == " ": scene_key = "EMPTY"
				elif symbol == "BAR_V_TOP": scene_key = "BAR_V"
				elif symbol == "BAR_V_BOTTOM": scene_key = "BAR_V"; rot_degrees = 180; needs_rotation = true
				elif symbol == "BAR_H_LEFT": scene_key = "BAR_H"
				elif symbol == "BAR_H_RIGHT": scene_key = "BAR_H"; rot_degrees = 180; needs_rotation = true
				else: scene_key = symbol
					
			elif typeof(symbol) == TYPE_DICTIONARY:
				if symbol["type"] == " ": scene_key = "EMPTY"
				else: scene_key = symbol["type"]
				rot_degrees = symbol["rot"]
				if rot_degrees != 0: needs_rotation = true
					
			var scene_to_instance: PackedScene = chunk_scenes.get(scene_key)
			if scene_to_instance != null:
				var chunk = scene_to_instance.instantiate()
				add_child(chunk)
				chunk.position = Vector2(x * block_size, y * block_size)
				
				if needs_rotation:
					chunk.rotation = deg_to_rad(rot_degrees)
					if rot_degrees == 90: chunk.position += Vector2(block_size, 0)
					elif rot_degrees == 180: chunk.position += Vector2(block_size, block_size)
					elif rot_degrees == 270: chunk.position += Vector2(0, block_size)
						
				if scene_key == "DEAD_END":
					var center_pos = Vector2(x * block_size + (block_size / 2.0), y * block_size + (block_size / 2.0))
					dead_end_positions.append(center_pos)
						
	var valid_spawns = []
	fallback_positions.clear()
	
	for x in _dimensions.x:
		for y in _dimensions.y:
			var cell = city_blocks[x][y]
			var is_road = false
			
			if typeof(cell) == TYPE_DICTIONARY:
				var t = cell["type"]
				if t == "I" or t == "T_CROSS" or t == "CURVE":
					valid_spawns.append(Vector2i(x, y))
				if t in ["I", "V", "H", "T_CROSS", "CURVE"]:
					is_road = true
			elif typeof(cell) == TYPE_STRING:
				if cell == "I":
					valid_spawns.append(Vector2i(x, y))
				if cell in ["I", "V", "H"]:
					is_road = true
					
			if is_road:
				var pos = Vector2(x * block_size + (block_size / 2.0), y * block_size + (block_size / 2.0))
				fallback_positions.append(pos)
				
	if valid_spawns.size() > 0:
		var spawn_pos = valid_spawns.pick_random()
		player_spawn_position = Vector2(spawn_pos.x * block_size + (block_size / 2.0), spawn_pos.y * block_size + (block_size / 2.0))

func _print_city_blocks():
	print("City Block Map:")
	var map_string = ""
	for y in _dimensions.y:
		for x in _dimensions.x:
			var cell = city_blocks[x][y]
			var txt = " "
			if typeof(cell) == TYPE_STRING:
				txt = cell
				if txt.begins_with("BAR_V"): txt = "BAR_V"
				elif txt.begins_with("BAR_H"): txt = "BAR_H"
			elif typeof(cell) == TYPE_DICTIONARY:
				txt = cell["type"]
				if txt == "DEAD_END": txt = "DEA_C"
				
			txt = txt.left(5)
			while txt.length() < 5: txt += " "
			map_string += "[" + txt + "]"
		map_string += "\n"
	print(map_string)
