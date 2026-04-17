extends Node2D

var collectible_blueprint = preload("res://Collectible/collectible.tscn")


func _ready() -> void:
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
	
	# Set initial spawn position
	collectible_instance_malt.position = Vector2(100, 100)
	collectible_instance_hops.position = Vector2(100, 400)
	collectible_instance_yeast.position = Vector2(500, 500)
