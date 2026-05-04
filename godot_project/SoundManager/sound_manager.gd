extends Node

@export_group("Sound Effects")
@export var collect_sound: AudioStream


func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> void:
	if stream == null: 
		return
		
	var new_audio_player = AudioStreamPlayer.new()
	add_child(new_audio_player)
	
	new_audio_player.stream = stream
	
	if pitch_variation > 0:
		new_audio_player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	
	new_audio_player.play()
	new_audio_player.finished.connect(new_audio_player.queue_free)


func play_collect_sound() -> void:
	play_sfx(collect_sound, 0.1)
