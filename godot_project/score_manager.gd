extends Node

# Using float for internal calculations to prevent losing decimal precision
var total_points : float = 0.0

func add_points(amount: float):
	total_points += amount
	
	# Use round() for the output so that 99.99 displays as 100
	if Engine.get_frames_drawn() % 30 == 0:
		print("--- CURRENT SCORE: ", round(total_points), " ---")

func reset_score():
	total_points = 0.0
