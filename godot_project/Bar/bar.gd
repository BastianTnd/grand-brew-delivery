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
		
		# Check if the player has a specific target bar assigned
		if "target_bar" in player_in_range and player_in_range.target_bar != null:
			
			var dist = player_in_range.target_bar.global_position.distance_to(global_position)
			
			# Block size is 256: Anything under 300 pixels distance is the same building
			if dist > 300.0:
				# Wrong bar: Unloading stops if player is not at the target bar
				return 
				
		# Requires the player to be nearly stationary (velocity < 50) or already unloading
		if player_in_range.velocity.length() < 50 or player_in_range.is_unloading:
			player_in_range.unload_beer(unload_speed * delta)

func _on_body_entered(body):
	# Identify player to start delivery process
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = body

func _on_body_exited(body):
	# Reset states on exit
	if body == player_in_range:
		player_in_range.is_unloading = false
		player_in_range = null
