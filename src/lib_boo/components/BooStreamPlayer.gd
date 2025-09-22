class_name BooStreamPlayer extends AudioStreamPlayer

var lastPlaybackPosition:float = 0.0

func Pause()-> float:
	lastPlaybackPosition = get_playback_position()
	stop()
	return lastPlaybackPosition
	
func Resume():
	play(lastPlaybackPosition)
	
