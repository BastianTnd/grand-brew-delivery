extends Node2D

@export var _dimensions: Vector2i = Vector2i(7, 5)
@export var block_size: int = 256


@export var chunk_scenes: Dictionary = {
	"I": null,
	"V": null,
	"H": null  
}

var city_blocks: Array

func _ready() -> void:
	_initialize_city()
	_generate_city_layout()
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

func _build_world() -> void:
	for x in _dimensions.x:
		for y in _dimensions.y:
			var symbol = city_blocks[x][y]
			var scene_to_instance: PackedScene = chunk_scenes.get(symbol)
			
			if scene_to_instance != null:
				var chunk = scene_to_instance.instantiate()
				add_child(chunk)

				chunk.position = Vector2(x * block_size, y * block_size)

func _print_city_blocks():
	print("City Block Map:")
	var map_string = ""

	for y in _dimensions.y:

		for x in _dimensions.x:
			map_string += "[" + str(city_blocks[x][y]) + "]"
		map_string += "\n"
	print(map_string)
