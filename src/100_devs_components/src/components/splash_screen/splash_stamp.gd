class_name SplashScreen
extends Node2D

signal finished

@onready var animation_player: AnimationPlayer = $HandStamp/AnimationPlayer


func _ready() -> void:
	animation_player.play("hand_stamp")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	finished.emit()
	queue_free()
