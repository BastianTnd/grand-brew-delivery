extends Node

## SoundManager: Manages global audio. 
## As an Autoload, it persists across scene changes.

@export_group("Sound Effects")
@export var collect_sound: AudioStream
@export var crash_sound: AudioStream
@export var grass_sound: AudioStream

@export_group("Music")
@export var menu_music: AudioStream
@export var race_music: AudioStream
@export var end_screen_music: AudioStream

# Reference to the persistent music player node
@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer 

func _ready() -> void:
	# Keep playing even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Set default music volume (leiser)
	music_player.volume_db = -15.0 

# --- MUSIC CONTROL ---

func play_menu_music(): _switch_music_track(menu_music)
func play_race_music(): _switch_music_track(race_music)
func play_end_screen_music(): _switch_music_track(end_screen_music)

## Switches tracks only if the new stream is different to prevent restarts
func _switch_music_track(new_stream: AudioStream):
	if new_stream == null or music_player == null: return
	if music_player.stream == new_stream and music_player.playing: return
	
	music_player.stop()
	music_player.stream = new_stream
	music_player.play()

func stop_music():
	if music_player: music_player.stop()

# --- SFX LOGIC ---

## Creates a temporary AudioStreamPlayer for one-shot sound effects
func play_sfx(stream: AudioStream, pitch_variation: float = 0.0, volume_db: float = -30.0):
	if stream == null: return
	
	var sfx = AudioStreamPlayer.new()
	add_child(sfx)
	
	sfx.stream = stream
	# Adds slight pitch randomization for variety
	if pitch_variation > 0:
		sfx.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	
	sfx.volume_db = volume_db
	sfx.play()
	
	# Clean up the node automatically after the sound finishes
	sfx.finished.connect(sfx.queue_free)

# --- SFX HELPERS ---

func play_collect_sound(): play_sfx(collect_sound, 0.1, -12.0)
func play_crash_sound(): play_sfx(crash_sound, 0.1, -18.0)
func play_grass_sound(): play_sfx(grass_sound, 0.1, -30.0)
