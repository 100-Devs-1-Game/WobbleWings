extends Control

@onready var toggle_sound_btn: TextureButton = $SoundToggleContainer/ToggleSoundBtn

@onready var sound_options: PanelContainer = $SoundOptions

func _ready() -> void:
	sound_options.hide()
	# Button pressed = sound ON = not muted
	toggle_sound_btn.button_pressed = not GM.config.IsMuted

func _on_sound_settings_menu_btn_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		GM.config.SaveConfig()

func _on_toggle_sound_btn_toggled(toggled_on: bool) -> void:
	# Button pressed = sound ON = not muted
	GM.config.IsMuted = not toggled_on

func SetAudioBusVolume(bus_name: String, volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))
