extends CanvasLayer

var score_label: Label
var time_label: Label

func _ready():
	score_label = find_child("ScoreLabel", true, false) as Label
	time_label = find_child("TimeLabel", true, false) as Label
	
	if score_label == null:
		print("WARNING: ScoreLabel not found!")
	if time_label == null:
		print("WARNING: TimeLabel not found!")

func _process(_delta):
	update_display()

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
