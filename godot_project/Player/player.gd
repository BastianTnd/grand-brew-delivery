extends CharacterBody2D

# --- PRELOADS ---
# Icons used for the dynamic navigation arrows (Original Assets)
var icon_malt = preload("res://Collectible/Sprites/Malt.png")
var icon_hops = preload("res://Collectible/Sprites/Hops.png")
var icon_yeast = preload("res://Collectible/Sprites/Yeast.png")

# --- VISUAL FEEDBACK REFERENCES ---
@onready var impact_particles = $ImpactParticles
@onready var grass_particles = $GrassParticles
@onready var grass_layer = get_tree().get_first_node_in_group("level_map")

signal beer_level_changed(new_value)

# --- PHYSICS CONFIGURATION ---
@export var engine_power = 150.0 
@export var max_speed = 320.0
@export var max_speed_reverse = 110.0
@export var steering_angle_limit = 42.0
@export var friction = 0.993
@export var braking_force = 2.5
@export var drift_braking = 0.985
@export var crash_threshold = 180.0
@export var traction_slow_speed = 110.0

# --- GAMEPLAY STATE ---
var speed_modifier = 1.0  # Dynamic scaling for surface penalties (Grass)
var crash_cooldown = 0.0 
var crash_counter = 0    # Hit-buffer: Damage occurs only on every 3rd major impact
var beer_level = 0.0
var has_filled_this_round = false
var is_refilling = false 
var is_unloading = false

@export var max_beer = 100.0
@export var unload_speed = 40.0
var beer_visual: AnimatedSprite2D # HUD reference for visual cargo tracking

# --- NAVIGATION CONFIGURATION ---
@export var arrow_max_distance = 150.0
@export var arrow_min_distance = 40.0
@export var arrow_size = 22.0      
var current_arrow_color = Color.WHITE
var target_bar: Node2D = null

# --- AUDIO ---
var engine_audio_player: AudioStreamPlayer

func _ready():
	# Deferred initialization to ensure HUD nodes are available
	await get_tree().process_frame
	var hud_node = get_tree().get_first_node_in_group("hud")
	if hud_node:
		beer_visual = hud_node.find_child("BeerVisual", true) as AnimatedSprite2D
	
	# Initial signal connection and UI sync
	beer_level_changed.connect(_on_beer_level_changed)
	_on_beer_level_changed(beer_level)
	
	if impact_particles: impact_particles.emitting = false
	if grass_particles: grass_particles.emitting = false
	
	# Initialize continuous engine sound
	engine_audio_player = AudioStreamPlayer.new()
	add_child(engine_audio_player)
	
	# Fetch the audio file from your SoundManager
	if SoundManager.engine_sound != null:
		engine_audio_player.stream = SoundManager.engine_sound
		engine_audio_player.volume_db = -15.0 # Mache ihn etwas leiser
		engine_audio_player.play()

func _physics_process(delta):
	if crash_cooldown > 0: crash_cooldown -= delta
	if is_unloading: process_unloading(delta)

	var move_input = Input.get_axis("ui_down", "ui_up")
	var steer_input = Input.get_axis("ui_left", "ui_right")
	
	# Immobilize vehicle during loading/unloading sequences
	if is_refilling or is_unloading:
		velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
		move_and_slide()
		return

	# Check for off-road physics (speed reduction)
	_handle_grass_logic(velocity.length())

	# Calculate dynamic mass: Cargo weight influences handling and inertia
	var weight_factor = remap(beer_level, 0, max_beer, 1.0, 1.3)
	var speed = velocity.length()
	var forward_dir = Vector2.RIGHT.rotated(rotation)
	
	# --- ENGINE SOUND DYNAMICS ---
	if engine_audio_player and engine_audio_player.playing:
		# Calculate pitch based on speed ratio (0.0 to 1.0)
		var current_max = max_speed * speed_modifier
		var speed_ratio = clamp(speed / current_max, 0.0, 1.0)
		
		# Base pitch is 0.8 (idle), max pitch is 2.0 (top speed)
		var target_pitch = 0.8 + (speed_ratio * 1.2)
		
		# Smoothly transition to the new pitch
		engine_audio_player.pitch_scale = lerp(engine_audio_player.pitch_scale, target_pitch, 10.0 * delta)

	# --- STEERING LOGIC ---
	if speed > 5 or move_input != 0:
		var dir = -1.0 if velocity.dot(forward_dir) < -5 else 1.0
		var steer_speed_mod = clamp(speed / max_speed, 0.5, 0.9) / weight_factor
		rotation += steer_input * deg_to_rad(steering_angle_limit * 4.0) * delta * dir * steer_speed_mod

	# --- ACCELERATION & BRAKING ---
	if move_input > 0:
		velocity += forward_dir * (engine_power * speed_modifier / weight_factor) * delta
	elif move_input < 0:
		if velocity.dot(forward_dir) > 5:
			velocity += forward_dir * -engine_power * (braking_force / weight_factor) * delta 
		else:
			velocity += forward_dir * -engine_power * 0.7 * speed_modifier * delta 

	velocity *= friction 

	# --- TRACTION & DRIFT ---
	var forward_vel = forward_dir * velocity.dot(forward_dir)
	var steering_intensity = abs(steer_input)
	var current_traction = 0.35 
	
	if (speed / max_speed) > 0.7 and steering_intensity > 0.8:
		current_traction = 0.03 / weight_factor
		velocity *= drift_braking
	
	if speed < traction_slow_speed: current_traction = 0.8
	velocity = lerp(velocity, forward_vel, current_traction)

	# --- COLLISION LOGIC ---
	var current_max = max_speed * speed_modifier
	if velocity.length() > current_max:
		velocity = velocity.limit_length(current_max)

	var speed_before = velocity.length()
	var collided = move_and_slide()
	
	if collided:
		_handle_collision_effects(speed_before)

	queue_redraw()

func _handle_grass_logic(speed):
	# Detect surface type via TileMap custom data
	if not grass_layer:
		grass_layer = get_tree().get_first_node_in_group("level_map")
	
	var on_grass = false
	if grass_layer:
		var tile_pos = grass_layer.local_to_map(grass_layer.to_local(global_position))
		var data = grass_layer.get_cell_tile_data(tile_pos)
		if data and data.get_custom_data("type") == "grass":
			on_grass = true
	
	if on_grass:
		SoundManager.play_grass_sound()
		speed_modifier = 0.4 # 60% speed penalty
		if grass_particles: grass_particles.emitting = speed > 40
	else:
		speed_modifier = 1.0
		if grass_particles: grass_particles.emitting = false

func _draw():
	# Render navigation system for objectives
	var targets = _get_target_positions()
	if is_refilling or is_unloading: return
	
	var correction = Color.WHITE / modulate if modulate != Color.WHITE else Color.WHITE

	for target_pos in targets:
		if target_pos != Vector2.ZERO:
			_draw_nav_arrow(target_pos, correction)

func _draw_nav_arrow(target_pos: Vector2, correction: Color):
	var direction = global_position.direction_to(target_pos)
	var angle = direction.angle() - global_rotation
	var dist = global_position.distance_to(target_pos)
	
	if dist < 20.0: return
	
	# Scale and alpha mapping based on objective distance
	var d_clamped = clamp(dist, 20, 600)
	var s = remap(d_clamped, 20, 600, 0.4, 1.2)
	var d = remap(d_clamped, 20, 600, arrow_min_distance, arrow_max_distance)
	
	var arrow_final_color = current_arrow_color
	arrow_final_color.a = remap(d_clamped, 20, 600, 0.5, 1.0)
	arrow_final_color *= correction
	
	var arrow_center = Vector2(d, 0).rotated(angle)
	
	# Draw Polygon
	var p1 = arrow_center + Vector2(arrow_size * s * 1.2, 0).rotated(angle)
	var p2 = arrow_center + Vector2(-arrow_size * s * 0.8, -arrow_size * s * 0.5).rotated(angle)
	var p3 = arrow_center + Vector2(-arrow_size * s * 0.8, arrow_size * s * 0.5).rotated(angle)
	draw_polygon(PackedVector2Array([p1, p2, p3]), PackedColorArray([arrow_final_color]))
	
	# Icon Overlay logic
	var current_icon = null
	for item in get_tree().get_nodes_in_group("collectibles"):
		if item.global_position.distance_to(target_pos) < 10:
			if item.get("collectible") == 0: current_icon = icon_malt
			elif item.get("collectible") == 1: current_icon = icon_hops
			elif item.get("collectible") == 2: current_icon = icon_yeast
	
	if current_icon:
		var icon_size = Vector2(12, 12) * s
		var shifted_center = arrow_center + Vector2((arrow_size * s * 0.2), 0).rotated(angle + PI)
		draw_set_transform(shifted_center, -global_rotation, Vector2.ONE)
		draw_texture_rect(current_icon, Rect2(-icon_size / 2, icon_size), false, correction)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _handle_collision_effects(speed_before):
	var collision = get_last_slide_collision()
	if collision:
		if impact_particles:
			impact_particles.global_position = collision.get_position()
			impact_particles.rotation = collision.get_normal().angle()
			impact_particles.emitting = true
		
		velocity = velocity.slide(collision.get_normal()).normalized() * (speed_before * 0.8)

	if speed_before > crash_threshold:
		SoundManager.play_crash_sound()
		if has_filled_this_round and beer_level > 0:
			_apply_crash_logic()

func _apply_crash_logic():
	if crash_cooldown <= 0:
		crash_counter += 1
		crash_cooldown = 1.0
		# Visual hit flash
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.ORANGE, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		
		if crash_counter >= 3:
			crash_counter = 0
			beer_level = clamp(beer_level - (max_beer * 0.20), 0.0, max_beer)
			beer_level_changed.emit(beer_level)

func _on_beer_level_changed(new_value):
	# Sync visual cargo display in HUD
	if beer_visual:
		beer_visual.frame = clampi(int(round(new_value / 25.0)), 0, 4)

func _get_target_positions() -> Array:
	# State-based navigation objectives
	var targets = []
	if ScoreManager.items_collected < 3:
		current_arrow_color = Color(0.9, 0.1, 0.15, 1.0) # Red: Collect Ingredients
		for item in get_tree().get_nodes_in_group("collectibles"): 
			targets.append(item.global_position)
	elif not has_filled_this_round:
		current_arrow_color = Color.ORANGE # Orange: Return to Brewery
		var station = get_tree().get_first_node_in_group("brewing_station")
		if station: targets.append(station.global_position)
	else:
		current_arrow_color = Color.GREEN # Green: Deliver to Bar
		var bar = target_bar if is_instance_valid(target_bar) else get_tree().get_first_node_in_group("bar")
		if bar: targets.append(bar.global_position)
	return targets

func add_beer(amount):
	is_refilling = true
	beer_level = clamp(beer_level + amount, 0, max_beer)
	beer_level_changed.emit(beer_level)
	if beer_level >= max_beer and not has_filled_this_round:
		is_refilling = false
		has_filled_this_round = true
		crash_counter = 0
		_pick_random_bar()

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
	if beer_level > 0 and has_filled_this_round: is_unloading = true

func _pick_random_bar():
	var all_bars = get_tree().get_nodes_in_group("bar")
	if all_bars.size() > 0:
		var new_bar = all_bars.pick_random()
		while all_bars.size() > 1 and new_bar == target_bar:
			new_bar = all_bars.pick_random()
		target_bar = new_bar

func adapt_to_map_scale(scale_factor: float) -> void:
	# Scaling logic for PCG map consistency
	self.scale = Vector2(scale_factor, scale_factor)
	engine_power *= scale_factor
	max_speed *= scale_factor
	max_speed_reverse *= scale_factor
	braking_force *= scale_factor
	crash_threshold *= scale_factor
	traction_slow_speed *= scale_factor
