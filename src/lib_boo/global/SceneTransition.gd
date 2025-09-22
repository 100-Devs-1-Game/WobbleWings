class_name SceneTransition extends CanvasLayer

@export var transitionTime: float = 1.5
@onready var color_rect: ColorRect = $ColorRect

func GoToScene(scene: PackedScene) -> void:
	# Set initial shader progress to 1.0 (full cover) and show the color rect
	color_rect.material.set_shader_parameter("progress", 1.0)
	# color_rect.material.set_shader_parameter("invert", false)
	color_rect.show()
	
	# Animate the shader progress from 1.0 to 0.0 (cover to reveal)
	var t = get_tree().create_tween()
	t.tween_method(_set_shader_progress, 2.7, 0.0, transitionTime)
	
	await t.finished
	get_tree().change_scene_to_packed(scene)
	
	# Animate the shader progress from 0.0 to 1.0 (reveal to cover)
	var t2 = get_tree().create_tween()
	t2.tween_method(_set_shader_progress, 0.0, 2.7, transitionTime)
	await t2.finished
	color_rect.hide()

func _set_shader_progress(value: float) -> void:
	color_rect.material.set_shader_parameter("progress", value)
