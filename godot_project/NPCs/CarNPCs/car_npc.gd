extends CharacterBody2D


func _physics_process(_delta: float) -> void:
	var collided = move_and_slide()
	
	if collided:
		print("Crashed")
