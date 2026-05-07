extends CanvasLayer

var score_label: Label
var time_label: Label

@onready var malt_icon = find_child("MaltIcon", true, false) as TextureRect
@onready var hops_icon = find_child("HopsIcon", true, false) as TextureRect
@onready var yeast_icon = find_child("YeastIcon", true, false) as TextureRect

var inactive_color = Color(1, 1, 1, 0.3)

func _ready():
	score_label = find_child("ScoreLabel", true, false) as Label
	time_label = find_child("TimeLabel", true, false) as Label
	
	if score_label == null:
		print("WARNING: ScoreLabel not found!")
	if time_label == null:
		print("WARNING: TimeLabel not found!")
	
	reset_ingredient_icons()

func _process(_delta):
	update_display()
	update_ingredients()

func update_display():
	# --- SCORE UPDATE ---
	if score_label:
		var current_score = ScoreManager.total_points
		score_label.text = "Score: " + str(int(round(current_score)))
	
	# --- TIMER UPDATE ---
	if time_label:
		var time_left = ScoreManager.time_left
		
		if time_left < 0: 
			time_left = 0
		
		var minutes = int(time_left / 60)
		var seconds = int(fmod(time_left, 60))
		
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]

func update_ingredients():
	if malt_icon:
		malt_icon.modulate = Color.WHITE if ScoreManager.has_malt else inactive_color
	if hops_icon:
		hops_icon.modulate = Color.WHITE if ScoreManager.has_hops else inactive_color
	if yeast_icon:
		yeast_icon.modulate = Color.WHITE if ScoreManager.has_yeast else inactive_color

func reset_ingredient_icons():
	if malt_icon: malt_icon.modulate = inactive_color
	if hops_icon: hops_icon.modulate = inactive_color
	if yeast_icon: yeast_icon.modulate = inactive_color
