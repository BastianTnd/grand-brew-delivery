extends Node2D

const collectible_blueprint = preload("res://Collectible/collectible.tscn")
const spawn_points = {
	1: [Vector2(100,100), Vector2(100, 400), Vector2(500, 500)],
	2: [],
	3: [],
	4: [],
	5: [],
	6: [],
	7: [],
	8: [],
	9: [],
	10: []
}

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	# Spawn all Collectibles when starting Game
	spawn()
	
func spawn() -> void:
	# Instantiate one Collectible for every collectible type
	var collectible_instance_malt: Area2D = collectible_blueprint.instantiate()
	var collectible_instance_hops: Area2D = collectible_blueprint.instantiate()
	var collectible_instance_yeast: Area2D = collectible_blueprint.instantiate()
	
	# Set the collectible type for each Collectible
	collectible_instance_malt.collectible = Collectible.collectible_type.MALT
	collectible_instance_hops.collectible = Collectible.collectible_type.HOPS
	collectible_instance_yeast.collectible = Collectible.collectible_type.YEAST
	
	# Add Collectibles to the Game Scene
	add_child(collectible_instance_malt)
	add_child(collectible_instance_hops)
	add_child(collectible_instance_yeast)
	
	# Get the Spawn Points
	var random_number = rng.randi_range(1, 10)
	print(random_number)
	
	# Set spawn position
	collectible_instance_malt.position = Vector2(100, 100)
	collectible_instance_hops.position = Vector2(100, 400)
	collectible_instance_yeast.position = Vector2(500, 500)
