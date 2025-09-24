extends Control

@onready var toggle_sound_btn: TextureButton = $SoundToggleContainer/ToggleSoundBtn
@onready var sound_settings_menu_btn: ButtonCue = %SoundSettingsMenuBtn
@onready var sound_options: PanelContainer = $SoundOptions
@onready var delete_data_button: Button = %DeleteDataButton

var deleteCalls:int = 0

func _ready() -> void:
	sound_options.hide()
	# Button pressed = sound ON = not muted
	toggle_sound_btn.button_pressed = not GM.config.IsMuted

	GM.events.play_started.connect(_onPlayStarted)

func _on_sound_settings_menu_btn_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_ResetDeleteDataButton()
		GM.config.SaveConfig()

func _on_toggle_sound_btn_toggled(toggled_on: bool) -> void:
	# Button pressed = sound ON = not muted
	GM.config.IsMuted = not toggled_on

func SetAudioBusVolume(bus_name: String, volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

func _onPlayStarted() -> void:
	sound_settings_menu_btn.button_pressed = false
	_ResetDeleteDataButton()

func _ResetDeleteDataButton() -> void:
	deleteCalls = 0
	delete_data_button.text = "Clear Data"


func _on_delete_data_button_pressed() -> void:
	deleteCalls += 1
	if deleteCalls == 1:
		delete_data_button.text = "Are You Sure you want to delete?"
	if deleteCalls == 2:
		delete_data_button.text = "Final Call. Reset ALL data?"
	if deleteCalls == 3:
		GM.events.GameDataDeleteRequested()
		_ResetDeleteDataButton()
