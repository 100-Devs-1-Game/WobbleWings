class_name GlobalConfig extends Node


#region General
@export var ShouldSkipIntros:bool = true:
	set(skip):
		ShouldSkipIntros = skip
		if GM:
			GM.saveLoad.SaveConfig("game_config", "general", "should_skip_intros", skip)
#endregion


#region Audio Settings
@export_group("Audio Settings")
@export var IsMuted: bool = false:
	set(muted):
		IsMuted = muted
		if is_node_ready():
			GM.saveLoad.SaveConfig.call_deferred("game_config", "audio", "is_muted", muted)
		_ApplyMasterVolume()

@export var MasterVolume: float = 0.5:
	set(vol):
		MasterVolume = vol
		if is_node_ready():
			GM.saveLoad.SaveConfig("game_config", "audio", "master_volume", vol)
		_ApplyMasterVolume()

@export var SFXVolume: float = 0.5:
	set(vol):
		SFXVolume = vol
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), vol)

@export var MusicVolume: float = 0.5:
	set(vol):
		MusicVolume = vol
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), vol)
#endregion

@export_group("Development")
@export var overrideInEditor:bool = false


func _ready() -> void:
	
	if overrideInEditor and OS.is_debug_build():
		return
	
	_LoadAudioVolumesFromConfig.call_deferred()

	await get_tree().process_frame
	ShouldSkipIntros = true

func _LoadAudioVolumesFromConfig() -> void:
	# Load all audio settings from config file on startup
	if GM.saveLoad:
		# Load values without triggering setters to avoid premature volume application
		var loaded_muted = GM.saveLoad.LoadConfig("game_config", "audio", "is_muted", false)
		var loaded_master = GM.saveLoad.LoadConfig("game_config", "audio", "master_volume", 0.5)
		var loaded_music = GM.saveLoad.LoadConfig("game_config", "audio", "music_volume", 0.5)
		var loaded_sfx = GM.saveLoad.LoadConfig("game_config", "audio", "sfx_volume", 0.5)
		
		print("Loaded audio settings from config file:")
		print("  Muted: ", loaded_muted)
		print("  Master Volume: ", loaded_master)
		print("  Music Volume: ", loaded_music)
		print("  SFX Volume: ", loaded_sfx)
		
		# Set values directly to avoid triggering setters during loading
		IsMuted = loaded_muted
		MasterVolume = loaded_master
		MusicVolume = loaded_music
		SFXVolume = loaded_sfx
		
		# Apply the final master volume after all values are loaded
		_ApplyMasterVolume()
	else:
		print("Warning: GM or GM.saveLoad not available when trying to load audio volumes")

func SaveConfig() -> void:
	if GM.saveLoad:
		GM.saveLoad.SaveConfig("game_config", "audio", "is_muted", IsMuted)
		GM.saveLoad.SaveConfig("game_config", "audio", "master_volume", MasterVolume)
		GM.saveLoad.SaveConfig("game_config", "audio", "music_volume", MusicVolume)
		GM.saveLoad.SaveConfig("game_config", "audio", "sfx_volume", SFXVolume)
	else:
		print("Warning: GM or GM.saveLoad not available when trying to save audio volumes")

func _ApplyMasterVolume() -> void:
	var volume = 0.0 if IsMuted else MasterVolume
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), volume)
