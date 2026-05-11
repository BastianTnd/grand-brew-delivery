extends Node2D

@export var refill_speed = 30.0 
var player_in_range = null

func _ready():
	# Detection setup for player proximity
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _process(delta):
	# Refill logic: requires all items collected and stationary vehicle
	if player_in_range and ScoreManager.items_collected >= 3:
		if not player_in_range.has_filled_this_round:
			if player_in_range.velocity.length() < 50 or player_in_range.is_refilling:
				player_in_range.add_beer(refill_speed * delta)

func _on_body_entered(body):
	# Identify player to enable brewing process
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = body

func _on_body_exited(body):
	# Reset player states upon leaving the station
	if body == player_in_range:
		player_in_range.is_refilling = false
		player_in_range = null
