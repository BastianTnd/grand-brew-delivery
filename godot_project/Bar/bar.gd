extends Node2D

@export var unload_speed = 35.0 
var player_in_range = null

func _ready():
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_range:
		# Delivery starts if the player is stopped
		if player_in_range.velocity.length() < 30.0 or player_in_range.is_refilling:
			if player_in_range.beer_level > 0:
				player_in_range.unload_beer(unload_speed * delta)

func _on_body_entered(body):
	if body.has_method("unload_beer"):
		player_in_range = body
		print("At the Bar. Please stop to deliver!")

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		print("Left the Bar.")
