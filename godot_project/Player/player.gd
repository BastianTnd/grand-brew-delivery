extends CharacterBody2D

signal beer_level_changed(new_value)

# --- PHYSICS ---
@export var engine_power = 150.0        
@export var max_speed = 320.0          
@export var max_speed_reverse = 110.0 
@export var steering_angle_limit = 42.0 
@export var friction = 0.993            
@export var braking_force = 2.5
@export var drift_braking = 0.985       

var crash_cooldown = 0.0 
var crash_counter = 0 
var beer_level = 0.0
var has_filled_this_round = false
var is_refilling = false 
var is_unloading = false

@export var max_beer = 100.0
@export var unload_speed = 40.0
var beer_visual: AnimatedSprite2D

# --- Arrow Display Config ---
@export var arrow_max_distance = 150.0
@export var arrow_min_distance = 40.0
@export var arrow_size = 18.0      
var current_arrow_color = Color.WHITE

func _ready():
	await get_tree().process_frame
	var hud_node = get_tree().get_first_node_in_group("hud")
	if hud_node:
		beer_visual = hud_node.find_child("BeerVisual", true) as AnimatedSprite2D
	beer_level_changed.connect(_on_beer_level_changed)
	_on_beer_level_changed(beer_level)

func _physics_process(delta):
	if crash_cooldown > 0: crash_cooldown -= delta
	if is_unloading: process_unloading(delta)

	var move_input = Input.get_axis("ui_down", "ui_up")
	var steer_input = Input.get_axis("ui_left", "ui_right")
	
	if is_refilling or is_unloading:
		velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
		move_and_slide()
		return

	# Dynamisches Gewicht: Je mehr Bier, desto träger (0.8 bis 1.2 Multiplikator)
	var weight_factor = remap(beer_level, 0, max_beer, 1.0, 1.3)

	var speed = velocity.length()
	if speed > 5 or move_input != 0:
		var dir = -1.0 if velocity.dot(transform.x) < -5 else 1.0
		# Lenkung wird schwerfälliger, wenn der Wagen voll beladen ist
		var steer_speed_modifier = clamp(speed / max_speed, 0.5, 0.9) / weight_factor
		rotation += steer_input * deg_to_rad(steering_angle_limit * 4.0) * delta * dir * steer_speed_modifier

	if move_input > 0:
		velocity += transform.x * (engine_power / weight_factor) * delta
	elif move_input < 0:
		if velocity.dot(transform.x) > 5:
			# Bremsweg verlängert sich bei Beladung
			velocity += transform.x * -engine_power * (braking_force / weight_factor) * delta 
		else:
			velocity += transform.x * -engine_power * 0.7 * delta 

	velocity *= friction 

	var forward_vel = transform.x * velocity.dot(transform.x)
	var steering_intensity = abs(steer_input)
	var speed_percentage = speed / max_speed
	
	var current_traction = 0.35 
	
	if speed_percentage > 0.7 and steering_intensity > 0.8:
		# Schlittern wird durch Gewicht verstärkt (weniger Traction)
		current_traction = 0.03 / weight_factor
		velocity *= drift_braking
	
	if speed < 110: 
		current_traction = 0.8 
		
	velocity = lerp(velocity, forward_vel, current_traction)

	if velocity.length() > max_speed:
		velocity = velocity.limit_length(max_speed)

	var speed_before = velocity.length()
	var collided = move_and_slide()
	
	if collided and speed_before > 180:
		if has_filled_this_round and beer_level > 0:
			apply_crash_logic()
	
	queue_redraw()

func _draw():
	var targets = _get_target_positions()
	if is_refilling or is_unloading: return
	
	for target_pos in targets:
		if target_pos != Vector2.ZERO:
			var direction = global_position.direction_to(target_pos)
			var angle = direction.angle() - global_rotation
			var dist = global_position.distance_to(target_pos)
			
			if dist < 15.0:
				continue
				
			var d_clamped = clamp(dist, 15, 500)
			
			var s = remap(d_clamped, 0, 500, 0.3, 1.0)
			var d = remap(d_clamped, 0, 500, arrow_min_distance, arrow_max_distance)
			
			var draw_color = current_arrow_color
			draw_color.a = remap(d_clamped, 0, 500, 0.4, 1.0)
			
			var arrow_center = Vector2(d, 0).rotated(angle)
			
			var p1 = arrow_center + Vector2(arrow_size * s, 0).rotated(angle)
			var p2 = arrow_center + Vector2(-arrow_size * s, -arrow_size * s / 1.5).rotated(angle)
			var p3 = arrow_center + Vector2(-arrow_size * s, arrow_size * s / 1.5).rotated(angle)
			
			draw_polygon(PackedVector2Array([p1, p2, p3]), PackedColorArray([draw_color]))

func apply_crash_logic():
	if crash_cooldown <= 0:
		crash_counter += 1
		crash_cooldown = 1.0
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.ORANGE, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		if crash_counter >= 3:
			crash_counter = 0
			beer_level = clamp(beer_level - (max_beer * 0.20), 0.0, max_beer)
			beer_level_changed.emit(beer_level)
			var loss_tween = create_tween()
			loss_tween.tween_property(self, "modulate", Color.RED, 0.1)
			loss_tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _on_beer_level_changed(new_value):
	if beer_visual:
		beer_visual.frame = clampi(int(round(new_value / 25.0)), 0, 4)

func _get_target_positions() -> Array:
	var targets = []
	if ScoreManager.items_collected < 3:
		current_arrow_color = Color.YELLOW
		for item in get_tree().get_nodes_in_group("collectibles"): targets.append(item.global_position)
	elif not has_filled_this_round:
		current_arrow_color = Color.ORANGE
		var station = get_tree().get_first_node_in_group("brewing_station")
		if station: targets.append(station.global_position)
	else:
		current_arrow_color = Color.GREEN
		var bar = get_tree().get_first_node_in_group("bar")
		if bar: targets.append(bar.global_position)
	return targets

func add_beer(amount):
	is_refilling = true
	beer_level = clamp(beer_level + amount, 0, max_beer)
	beer_level_changed.emit(beer_level)
	if beer_level >= max_beer: 
		is_refilling = false
		has_filled_this_round = true
		crash_counter = 0

func start_unloading():
	if beer_level > 0 and has_filled_this_round: is_unloading = true

func process_unloading(delta):
	var unload_amount = unload_speed * delta
	if beer_level > unload_amount:
		beer_level -= unload_amount
		ScoreManager.add_points(unload_amount)
	else:
		ScoreManager.add_points(beer_level)
		beer_level = 0.0
		is_unloading = false
		has_filled_this_round = false
		ScoreManager.complete_delivery()
	beer_level_changed.emit(beer_level)

func unload_beer(_amount = 0):
	start_unloading()
