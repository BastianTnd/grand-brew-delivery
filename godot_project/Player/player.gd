extends CharacterBody2D

# Einstellungen für das Fahrverhalten
@export var wheel_base = 70      # Abstand zwischen Achsen (beeinflusst Wendekreis)
@export var steering_angle = 15   # Wie stark das Auto einschlägt
@export var engine_power = 800   # Beschleunigung
@export var friction = -0.9      # Reibung (bremst das Auto langsam ab)
@export var drag = -0.0015       # Luftwiderstand (bremst bei hohem Tempo)
@export var braking = -450       # Bremskraft
@export var max_speed_reverse = 250

# Variablen für die Berechnung
var steer_direction
var acceleration = Vector2.ZERO

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()

func get_input():
	# Gas geben und Bremsen
	var turn = Input.get_axis("ui_left", "ui_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += friction_force + drag_force

func calculate_steering(delta):
	# Berechnet die Drehung basierend auf der Geschwindigkeit
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	var dot = new_heading.dot(velocity.normalized())
	if dot > 0:
		velocity = new_heading * velocity.length()
	if dot < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
