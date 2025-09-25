class_name GlobalAudioPlayer extends Node2D

signal sound_play_started(player: AudioStreamPlayer)
signal sound_play_finished(player: AudioStreamPlayer)


@export var audioDictionary:Dictionary[String, AudioStream]

@onready var players2D:Array[AudioStreamPlayer2D]
@onready var playersNon2D:Array[AudioStreamPlayer]

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is AudioStreamPlayer2D:
			players2D.append(child)
		elif child is AudioStreamPlayer:
			playersNon2D.append(child)

func PlaySound(soundName: String, the_position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> AudioStreamPlayer:
	return _PlayGeneric(audioDictionary[soundName], the_position, volume_db)

func PlayStream(stream: AudioStream, the_position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> AudioStreamPlayer:
	return _PlayGeneric(stream, the_position, volume_db)

#region Internal
func _PlayGeneric(stream: AudioStream, the_position: Vector2, volume_db: float) -> AudioStreamPlayer:
	if the_position != Vector2.ZERO:
		var au_player_2d = _FindOrCreateAudioPlayer2D()
		au_player_2d.global_position = the_position
		au_player_2d.stream = stream
		au_player_2d.volume_db = volume_db
		au_player_2d.play()
		_SignalOutAudio(au_player_2d)
		return au_player_2d
	else:
		var au_player = _FindOrCreateAudioPlayer()
		au_player.stream = stream
		au_player.volume_db = volume_db
		au_player.play()
		_SignalOutAudio(au_player)
		return au_player

func _SignalOutAudio(player: AudioStreamPlayer) -> void:
	sound_play_started.emit(player)
	await player.finished
	sound_play_finished.emit(player)

func _FindOrCreateAudioPlayer2D() -> AudioStreamPlayer2D:
	for player in players2D:
		if player.playing == false:
			return player
	
	var new_player = AudioStreamPlayer2D.new()
	add_child(new_player)
	players2D.append(new_player)
	return new_player

func _FindOrCreateAudioPlayer() -> AudioStreamPlayer:
	for player in playersNon2D:
		if player.playing == false:
			return player
	
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	playersNon2D.append(new_player)
	return new_player
#endregion
