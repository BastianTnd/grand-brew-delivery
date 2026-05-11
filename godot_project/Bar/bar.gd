extends Node2D

@export var unload_speed = 40.0 
var player_in_range = null

func _ready():
	# Connect proximity signals
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _process(delta):
	# Unload logic: requires proximity and nearly stationary vehicle
	if player_in_range and player_in_range.beer_level > 0:
		if player_in_range.velocity.length() < 50 or player_in_range.is_refilling:
			player_in_range.unload_beer(unload_speed * delta)

func _on_body_entered(body):
	# Identify player to start delivery process
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = body

func _on_body_exited(body):
	# Reset states on exit
	if body == player_in_range:
		player_in_range.is_refilling = false
		player_in_range = null
