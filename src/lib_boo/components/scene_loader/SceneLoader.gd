extends Node

@export var mainScn:PackedScene = null
@onready var splash_screen: SplashScreen = $Splash_Screen


func _ready():
	if GM.config.ShouldSkipIntros and OS.is_debug_build():
		get_tree().change_scene_to_packed.call_deferred(mainScn)

func LoadGame():
	GM.sceneTransition.GoToScene(mainScn)
