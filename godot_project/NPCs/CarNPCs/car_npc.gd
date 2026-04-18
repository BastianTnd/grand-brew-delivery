extends CharacterBody2D

var crash_cooldown = 0.0
@export var cooldown_time = 0.8

func _physics_process(delta: float) -> void:
	if crash_cooldown > 0:
		crash_cooldown -= delta

	# Take position from PathFollow2D
	var path_follow = get_parent() # PathFollow2D
	global_position = path_follow.global_position
	#rotation = path_follow.rotation

	# move_and_slide für Collision Detection aufrufen
	var collided = move_and_slide()

	if collided and crash_cooldown <= 0:
		crash_cooldown = cooldown_time
		print("NPC Crashed!")
