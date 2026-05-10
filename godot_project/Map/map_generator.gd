extends Node2D

@export var _dimensions: Vector2i = Vector2i(7, 5)
@export var block_size: int = 256
@export var number_of_bars: int = 3


@export var chunk_scenes: Dictionary = {
	"I": null,
	"V": null,
	"H": null,
	"BREW": null,
	"BAR_V": null,
	"BAR_H": null
}

var city_blocks: Array

func _ready() -> void:
	randomize() 
	_initialize_city()
	_generate_city_layout()
	_place_buildings()
	_print_city_blocks()
	_build_world()

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
			
			if is_road_column and is_road_row:
				city_blocks[x][y] = "I"
			elif is_road_column:
				city_blocks[x][y] = "V"
			elif is_road_row:
				city_blocks[x][y] = "H"

func _place_buildings() -> void:
	var available_intersections: Array[Vector2i] = []
	
	var edges = {
		"top": [],
		"bottom": [],
		"left": [],
		"right": []
	}
	
	for x in _dimensions.x:
		for y in _dimensions.y:

			if city_blocks[x][y] == "I":
				available_intersections.append(Vector2i(x, y))
				
			if y == 0 and city_blocks[x][y] == "V":
				edges["top"].append({"pos": Vector2i(x, y), "type": "BAR_V_TOP"})
			elif y == _dimensions.y - 1 and city_blocks[x][y] == "V":
				edges["bottom"].append({"pos": Vector2i(x, y), "type": "BAR_V_BOTTOM"})
			elif x == 0 and city_blocks[x][y] == "H":
				edges["left"].append({"pos": Vector2i(x, y), "type": "BAR_H_LEFT"})
			elif x == _dimensions.x - 1 and city_blocks[x][y] == "H":
				edges["right"].append({"pos": Vector2i(x, y), "type": "BAR_H_RIGHT"})
				
	available_intersections.shuffle()
	
	if available_intersections.size() > 0:
		var bs_pos = available_intersections.pop_back()
		city_blocks[bs_pos.x][bs_pos.y] = "BREW"
		
	var bars_placed = 0
	
	var directions = ["top", "bottom", "left", "right"]
	directions.shuffle()
	
	for dir in directions:
		if bars_placed >= number_of_bars:
			break
			
		var spots_in_this_direction = edges[dir]
		if spots_in_this_direction.size() > 0:
			spots_in_this_direction.shuffle()
			var bar_data = spots_in_this_direction.pop_back()
			var pos = bar_data["pos"]
			city_blocks[pos.x][pos.y] = bar_data["type"]
			bars_placed += 1
			
	if bars_placed < number_of_bars:
		var remaining_spots = []
		for dir in edges:
			remaining_spots.append_array(edges[dir])
			
		remaining_spots.shuffle()
		
		while bars_placed < number_of_bars and remaining_spots.size() > 0:
			var bar_data = remaining_spots.pop_back()
			var pos = bar_data["pos"]
			city_blocks[pos.x][pos.y] = bar_data["type"]
			bars_placed += 1

func _build_world() -> void:
	for x in _dimensions.x:
		for y in _dimensions.y:
			var symbol = city_blocks[x][y]
			if symbol == " ":
				continue
				
			var scene_key = symbol
			var rotation_degrees = 0
			var needs_position_fix = false
			
			if symbol == "BAR_V_TOP":
				scene_key = "BAR_V"
			elif symbol == "BAR_V_BOTTOM":
				scene_key = "BAR_V"
				rotation_degrees = 180
				needs_position_fix = true
			elif symbol == "BAR_H_LEFT":
				scene_key = "BAR_H"
			elif symbol == "BAR_H_RIGHT":
				scene_key = "BAR_H"
				rotation_degrees = 180
				needs_position_fix = true
				
			var scene_to_instance: PackedScene = chunk_scenes.get(scene_key)
			
			if scene_to_instance != null:
				var chunk = scene_to_instance.instantiate()
				add_child(chunk)
				
				chunk.position = Vector2(x * block_size, y * block_size)
				
				if needs_position_fix:
					chunk.rotation = deg_to_rad(180)
					chunk.position += Vector2(block_size, block_size)

func _print_city_blocks():
	print("City Block Map:")
	var map_string = ""
	for y in _dimensions.y:
		for x in _dimensions.x:
			var symbol = str(city_blocks[x][y]).left(3) 
			if symbol == " ":
				symbol = "   "
			elif symbol.length() == 1:
				symbol = " " + symbol + " "
			map_string += "[" + symbol + "]"
		map_string += "\n"
	print(map_string)
