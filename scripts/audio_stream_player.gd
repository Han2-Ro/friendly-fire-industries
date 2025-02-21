extends AudioStreamPlayer


const level_music = preload("res://assets/music/Future-Industry-1.mp3")

func _play_music(music: AudioStream, volume = -10.0):
	if stream == music:
		print("playing")
		return
		
	stream = music
	volume_db = volume
	play()

func play_music_level():
	_play_music(level_music)
	print("playing")
	
