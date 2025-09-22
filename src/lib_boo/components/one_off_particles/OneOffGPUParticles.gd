class_name OneOffGPUParticles extends GPUParticles2D

@export var emitOnReady := true

func _ready() -> void:
	if emitOnReady:
		emitting = true
