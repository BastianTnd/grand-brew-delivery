extends CharacterBody2D

# --- Physics Settings ---
@export var engine_power = 1800.0      
@export var max_speed = 950.0          
@export var max_speed_reverse = 300.0  # Limit for reverse driving
@export var reverse_power_factor = 0.4 # Power reduction for reverse
@export var steering_angle = 25.0      
@export var friction = 0.97            

# --- Drift Mechanics ---
@export var drift_threshold = 400.0
@export var drift_intensity = 0.05      
@export var normal_traction = 0.12      

# --- Beer System ---
@export var max_beer = 100.0
var beer_level = 0.0
var last_announced_step = 0 
var is_refilling = false # Locks movement during unloading

# --- Crash Protection ---
var crash_cooldown = 0.0
@export var cooldown_time = 0.8        
@export var min_crash_speed = 300.0     

func _physics_process(delta):
	# Handle crash cooldown timer
	if crash_cooldown > 0:
		crash_cooldown -= delta

	# 1. INPUT HANDLING
	var move_input = 0.0
	var turn = 0.0
	
	# Only allow input if not currently refilling or unloading
	if not is_refilling:
		move_input = Input.get_axis("ui_down", "ui_up")
		turn = Input.get_axis("ui_left", "ui_right")
	else:
		# Auto-brake when at a station
		velocity = velocity.move_toward(Vector2.ZERO, 600 * delta)
	
	# 2. ACCELERATION (Forward vs. Reverse Power)
	if move_input != 0:
		var current_accel = engine_power
		if move_input < 0: 
			current_accel *= reverse_power_factor
		velocity += transform.x * move_input * current_accel * delta
	else:
		# Slow down when no input is given
		velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)

	# 3. SPEED LIMITS
	velocity *= friction 
	var speed = velocity.length()
	var is_forward = velocity.dot(transform.x) > 0
	
	if is_forward:
		if speed > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		if speed > max_speed_reverse:
			velocity = velocity.normalized() * max_speed_reverse

	# 4. STEERING AND (DRIFTING NOT WORKING LOL)
	if speed > 20:
		var current_traction = normal_traction
		
		# Apply drift logic if above speed threshold
		if speed > drift_threshold:
			var drift_factor = (speed - drift_threshold) / (max_speed - drift_threshold)
			current_traction = lerp(normal_traction, drift_intensity, clamp(drift_factor, 0.0, 1.0))
		
		# Reverse steering direction if driving backwards
		var side_factor = 1 if is_forward else -1
		var target_vel = velocity.rotated(turn * deg_to_rad(steering_angle) * side_factor * (1.0 if move_input != 0 else 0.5))
		velocity = velocity.lerp(target_vel, current_traction)
		
		# Rotate the sprite towards movement direction
		var target_rotation = velocity.angle() if is_forward else (velocity * -1).angle()
		rotation = lerp_angle(rotation, target_rotation, 12.0 * delta)

	# 5. COLLISION AND DAMAGE
	var pre_collision_speed = speed
	var collided = move_and_slide()
	
	if collided and not is_refilling and crash_cooldown <= 0:
		if pre_collision_speed > min_crash_speed:
			beer_level = clamp(beer_level - (max_beer * 0.10), 0, max_beer)
			crash_cooldown = cooldown_time
			last_announced_step = int(beer_level / 10) * 10 
			print("CRASH! Beer lost!")

# --- STATION METHODS ---

func add_beer(amount):
	is_refilling = true
	beer_level = clamp(beer_level + amount, 0, max_beer)
	_check_announcement("Refilling")
	if beer_level >= max_beer:
		is_refilling = false
		print("REFILLED!")

func unload_beer(amount):
	if beer_level > 0:
		is_refilling = true
		
		# calculation to ensure exact score transmission
		var actual_unload = amount
		if beer_level < amount:
			actual_unload = beer_level 
		
		if ScoreManager:
			ScoreManager.add_points(actual_unload)
		
		beer_level -= actual_unload
		_check_announcement("Unloading")
		
		# Unlock movement once the tank is empty
		if beer_level <= 0:
			beer_level = 0
			is_refilling = false
			last_announced_step = 0
			print("DELIVERY FINISHED! Score: ", round(ScoreManager.total_points))

# Helper to print progress every 10%
func _check_announcement(type):
	var current_step = int(beer_level / 10) * 10
	if current_step != last_announced_step:
		last_announced_step = current_step
		print(type, ": ", current_step, "%")
