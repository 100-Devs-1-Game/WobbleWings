extends HSlider

enum VolumeType {
	MASTER,
	MUSIC,
	SFX
}


@export var volumeType: VolumeType

func _ready() -> void:
	value_changed.connect(_onValueChanged)
	match volumeType:
		VolumeType.MASTER:
			value = GM.config.MasterVolume
		VolumeType.MUSIC:
			value = GM.config.MusicVolume
		VolumeType.SFX:
			value = GM.config.SFXVolume

func _onValueChanged(val:float) -> void:
	match volumeType:
		VolumeType.MASTER:
			GM.config.MasterVolume = val
		VolumeType.MUSIC:
			GM.config.MusicVolume = val
		VolumeType.SFX:
			GM.config.SFXVolume = val
