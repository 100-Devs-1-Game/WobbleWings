class_name SceneTransition extends CanvasLayer

@export var transitionTime: float = 1.5
@onready var color_rect: ColorRect = $ColorRect

func GoToScene(scene: PackedScene) -> void:
	color_rect.material.set_shader_parameter("progress", 1.0)
	color_rect.show()
	
	var ARBITRARY_TRANSITION_SIZE = 2.7 #NOTE: Dunno why it's not 1.0
	var t = get_tree().create_tween()
	t.tween_method(_set_shader_progress, ARBITRARY_TRANSITION_SIZE, 0.0, transitionTime)
	
	await t.finished
	get_tree().change_scene_to_packed(scene)
	
	var t2 = get_tree().create_tween()
	t2.tween_method(_set_shader_progress, 0.0, ARBITRARY_TRANSITION_SIZE, transitionTime)
	await t2.finished
	color_rect.hide()

func _set_shader_progress(value: float) -> void:
	color_rect.material.set_shader_parameter("progress", value)
