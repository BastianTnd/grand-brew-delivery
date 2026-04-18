extends CanvasLayer

@onready var time_label = $TimeLabel
@onready var score_label = $ScoreLabel

func _process(_delta):
	if ScoreManager:
		var total_secs = int(ScoreManager.time_left)
		var mins = total_secs / 60
		var secs = total_secs % 60
		time_label.text = "TIME: %02d:%02d" % [mins, secs]
		score_label.text = "SCORE: " + str(round(ScoreManager.total_points))
