class_name GameManager extends Node

signal gm_ready

var main:MAIN
var world:World

@onready var textSpawner:SpawnerAct = $TextPopupSpawner
@onready var timeGM:TimeManager = $TimeManager
@onready var globalSpawner:GlobalSpawner = $GlobalSpawner
@onready var globalAudio:GlobalAudioPlayer = $GlobalAudioPlayer
@onready var saveLoad: BooSaveLoad = $BooSaveLoad

@onready var events:GlobalEvents = $GlobalEvents
@onready var config: GameConfig = $GameConfig
@onready var sceneTransition: CanvasLayer = $SceneTransition
@onready var achieve: CanvasLayer = $GlobalEvents/AchievementInterface

func _ready() -> void:
	pass
	gm_ready.emit()

func ShowTextPopup(text:String, parent:Node2D = world, start_pos:Vector2 = Vector2.ZERO, color:Color = Color.WHITE) -> TextPopup:
	var popup = textSpawner.Execute({"parent":parent})[0] as TextPopup
	popup.Play(text, start_pos, color)
	return popup

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
