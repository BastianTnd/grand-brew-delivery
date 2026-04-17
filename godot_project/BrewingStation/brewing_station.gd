extends Node2D

@export var refill_speed = 25.0 
var player_in_range = null

func _ready():
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_range:
		# Filling starts if the player is stopped
		if player_in_range.velocity.length() < 20.0 or player_in_range.is_refilling:
			if player_in_range.beer_level < player_in_range.max_beer:
				player_in_range.add_beer(refill_speed * delta)

func _on_body_entered(body):
	if body.has_method("add_beer"):
		player_in_range = body

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null
