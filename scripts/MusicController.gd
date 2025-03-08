extends Node

var music_player = AudioStreamPlayer.new()
var current_track = null

func _ready():
	add_child(music_player)
	music_player.bus = "Sounds" 
	
func play_music(track_path):
	if current_track == track_path and music_player.playing:
		return
	
	current_track = track_path
	var music = load(track_path)
	music_player.stream = music
	music_player.play()

func stop_music():
	music_player.stop()
	current_track = null
