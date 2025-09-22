##NOTE:⚠️ (WIP/Evaluating) Use ButtonCue instead of this 
class_name ButtonSignalsCue extends ControlSignalsCue

@export var cueOnToggled: bool = false

func _ConnectSignals():
	super()
	if not parent is Button:
		print_debug("ButtonSignalsCue: No button parent found or given")
		return
	parent.toggled.connect(_onToggled)

func _onToggled(toggled_on: bool) -> void:
	if cueOnToggled:
		CueActs(toggled_on)
