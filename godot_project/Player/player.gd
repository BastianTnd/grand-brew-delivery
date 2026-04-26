extends CharacterBody2D

# --- Signals ---
signal beer_level_changed(new_value)

# --- Physics & Driving Behavior ---
@export var engine_power = 1200.0
@export var max_speed = 800.0
@export var friction = 0.96
@export var steering_angle = 30.0
@export var normal_traction = 0.10

# --- Beer Mechanics ---
@export var max_beer = 100.0
@export var unload_speed = 40.0
var beer_level = 0.0
var is_refilling = false 
var is_unloading = false
var crash_cooldown = 0.0 
var has_filled_this_round = false

# --- UI Reference ---
var beer_visual: AnimatedSprite2D

# --- Arrow Display ---
@export var arrow_max_distance = 150.0  # Pfeil weit weg (Standard)
@export var arrow_min_distance = 30.0   # Pfeil ganz nah am Auto
@export var arrow_size = 18.0      
var current_arrow_color = Color.WHITE

func _ready():
	await get_tree().process_frame
	
	var hud_node = get_tree().get_first_node_in_group("hud")
	if hud_node:
		beer_visual = hud_node.find_child("BeerVisual", true) as AnimatedSprite2D
	else:
		print("WARNING: 'hud' group not found!")

	beer_level_changed.connect(_on_beer_level_changed)
	_on_beer_level_changed(beer_level)

func _draw():
	var targets = _get_target_positions()
	
	if is_refilling or is_unloading:
		return

	for target_pos in targets:
		if target_pos != Vector2.ZERO:
			var dist = global_position.distance_to(target_pos)
			var direction = global_position.direction_to(target_pos)
			var angle = direction.angle() - global_rotation
			
			var d_clamped = clamp(dist, 0, 500)
			
			var dynamic_dist = remap(d_clamped, 0, 500, arrow_min_distance, arrow_max_distance)
			
			var dynamic_size = remap(d_clamped, 0, 500, arrow_size * 0.33, arrow_size)
			
			var alpha = remap(d_clamped, 0, 500, 0.3, 1.0)
			var draw_color = current_arrow_color
			draw_color.a = alpha

			var arrow_center = Vector2(dynamic_dist, 0).rotated(angle)
			
			var p1 = arrow_center + Vector2(dynamic_size, 0).rotated(angle)
			var p2 = arrow_center + Vector2(-dynamic_size, -dynamic_size/1.5).rotated(angle)
			var p3 = arrow_center + Vector2(-dynamic_size, dynamic_size/1.5).rotated(angle)
			
			draw_polygon(PackedVector2Array([p1, p2, p3]), PackedColorArray([draw_color]))

func _physics_process(delta):
	if crash_cooldown > 0: 
		crash_cooldown -= delta

	if is_unloading:
		process_unloading(delta)

	var move_input = Input.get_axis("ui_down", "ui_up")
	var turn = Input.get_axis("ui_left", "ui_right")
	
	if is_refilling or is_unloading:
		velocity = velocity.move_toward(Vector2.ZERO, 600 * delta)
		move_input = 0
		turn = 0
	
	var current_power = engine_power
	if move_input < 0:
		current_power = engine_power * 0.3 
	
	if move_input != 0:
		var target_vel = transform.x * move_input * current_power
		velocity = velocity.move_toward(target_vel, current_power * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)

	velocity *= friction
	var speed = velocity.length()
	var is_forward = velocity.dot(transform.x) > 0
	
	if speed > 20:
		var side_factor = 1 if is_forward else -1
		var target_steering = velocity.rotated(turn * deg_to_rad(steering_angle) * side_factor)
		velocity = velocity.lerp(target_steering, normal_traction)
		rotation = lerp_angle(rotation, velocity.angle() if is_forward else (velocity * -1).angle(), 10.0 * delta)

	if speed > max_speed:
		velocity = velocity.limit_length(max_speed)

	var collided = move_and_slide()
	if collided and speed > 180: 
		apply_crash_penalty()

	queue_redraw()

func apply_crash_penalty():
	if crash_cooldown <= 0 and beer_level > 1.0:
		var penalty = 10.0 
		beer_level = clamp(beer_level - penalty, 1.0, max_beer)
		beer_level_changed.emit(beer_level)
		crash_cooldown = 1.2
		
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _get_target_positions() -> Array:
	var targets = []
	
	if ScoreManager.items_collected < 3:
		current_arrow_color = Color.YELLOW
		var items = get_tree().get_nodes_in_group("collectibles")
		for item in items:
			targets.append(item.global_position)
			
	elif not has_filled_this_round:
		current_arrow_color = Color.ORANGE
		var station = get_tree().get_first_node_in_group("brewing_station")
		if station: 
			targets.append(station.global_position)
		
	else:
		current_arrow_color = Color.GREEN
		var bar = get_tree().get_first_node_in_group("bar")
		if bar: 
			targets.append(bar.global_position)
		
	return targets

func add_beer(amount):
	is_refilling = true
	beer_level = clamp(beer_level + amount, 0, max_beer)
	beer_level_changed.emit(beer_level)
	if beer_level >= max_beer: 
		is_refilling = false
		has_filled_this_round = true

func start_unloading():
	if beer_level > 0 and has_filled_this_round:
		is_unloading = true

func process_unloading(delta):
	var unload_amount = unload_speed * delta
	
	if beer_level > unload_amount:
		beer_level -= unload_amount
		ScoreManager.add_points(unload_amount)
	else:
		var final_points = beer_level
		if final_points > 0:
			ScoreManager.add_points(final_points)
		
		beer_level = 0.0
		is_unloading = false
		has_filled_this_round = false
		ScoreManager.complete_delivery()
	
	beer_level_changed.emit(beer_level)

func unload_beer(_amount = 0):
	start_unloading()

func _on_beer_level_changed(new_value):
	if beer_visual:
		var frame_idx = clampi(floor(new_value / 20.0), 0, 4)
		beer_visual.frame = frame_idx
