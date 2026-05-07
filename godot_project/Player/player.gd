extends CharacterBody2D

# --- LOAD COLLECTIBLES ---
var icon_malt = preload("res://Collectible/Sprites/malt.png")
var icon_hops = preload("res://Collectible/Sprites/hops.png")
var icon_yeast = preload("res://Collectible/Sprites/yeast.png")

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
@export var arrow_size = 22.0      
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

	var weight_factor = remap(beer_level, 0, max_beer, 1.0, 1.3)
	var speed = velocity.length()

	if speed > 5 or move_input != 0:
		var dir = -1.0 if velocity.dot(transform.x) < -5 else 1.0
		var steer_speed_modifier = clamp(speed / max_speed, 0.5, 0.9) / weight_factor
		rotation += steer_input * deg_to_rad(steering_angle_limit * 4.0) * delta * dir * steer_speed_modifier

	if move_input > 0:
		velocity += transform.x * (engine_power / weight_factor) * delta
	elif move_input < 0:
		if velocity.dot(transform.x) > 5:
			velocity += transform.x * -engine_power * (braking_force / weight_factor) * delta 
		else:
			velocity += transform.x * -engine_power * 0.7 * delta 

	velocity *= friction 

	var forward_vel = transform.x * velocity.dot(transform.x)
	var steering_intensity = abs(steer_input)
	var speed_percentage = speed / max_speed
	var current_traction = 0.35 
	
	if speed_percentage > 0.7 and steering_intensity > 0.8:
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
	
	var correction = Color.WHITE
	if modulate != Color.WHITE:
		correction = Color.WHITE / modulate 

	for target_pos in targets:
		if target_pos != Vector2.ZERO:
			var direction = global_position.direction_to(target_pos)
			var angle = direction.angle() - global_rotation
			var dist = global_position.distance_to(target_pos)
			
			if dist < 20.0: continue
				
			var d_clamped = clamp(dist, 20, 600)
			var s = remap(d_clamped, 20, 600, 0.4, 1.2)
			var d = remap(d_clamped, 20, 600, arrow_min_distance, arrow_max_distance)
			
			var arrow_final_color = current_arrow_color
			arrow_final_color.a = remap(d_clamped, 20, 600, 0.5, 1.0)
			arrow_final_color *= correction
			
			var arrow_center = Vector2(d, 0).rotated(angle)
			
			# --- 1. DRAW ARROW ---
			var p1 = arrow_center + Vector2(arrow_size * s * 1.2, 0).rotated(angle)
			var p2 = arrow_center + Vector2(-arrow_size * s * 0.8, -arrow_size * s * 0.5).rotated(angle)
			var p3 = arrow_center + Vector2(-arrow_size * s * 0.8, arrow_size * s * 0.5).rotated(angle)
			draw_polygon(PackedVector2Array([p1, p2, p3]), PackedColorArray([arrow_final_color]))

			# --- 2. FIND COLLECTIBLES ---
			var current_icon = null
			for item in get_tree().get_nodes_in_group("collectibles"):
				if item.global_position.distance_to(target_pos) < 10:
					if item.collectible == 0: current_icon = icon_malt
					elif item.collectible == 1: current_icon = icon_hops
					elif item.collectible == 2: current_icon = icon_yeast
			
			# --- 3. DRAW COLLECTIBLES ---
			if current_icon:
				var icon_size = Vector2(12, 12) * s 
				var offset_dist = (arrow_size * s * 0.2)
				var shifted_center = arrow_center + Vector2(offset_dist, 0).rotated(angle + PI)
				
				draw_set_transform(shifted_center, -global_rotation, Vector2.ONE)
				
				draw_texture_rect(current_icon, Rect2(-icon_size / 2, icon_size), false, correction)
				
				draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

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
		current_arrow_color = Color(0.9, 0.1, 0.15, 1.0) 
		for item in get_tree().get_nodes_in_group("collectibles"): 
			targets.append(item.global_position)
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
