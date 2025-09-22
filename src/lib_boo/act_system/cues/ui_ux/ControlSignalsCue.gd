##Use when you don't want to create a whole Cue for each control node.
##Automatically connects to the signals of a Control node and cues the act when the signals are emitted.
##NOTE: Some control nodes have their own cues, such as ButtonCue 
class_name ControlSignalsCue extends NodeCue

@export var cueOnClick: bool = false
#TODO: Add more of the bools and connect the signals as I need them.

@export var parent: Control

func _ready():
	super()

	if not parent:
		parent = get_parent()
		if not parent is Control:
			print_debug("ControlSignalsCue: No control parent found or given")
			return
	
	_ConnectSignals()


func _ConnectSignals():
	parent.gui_input.connect(_onGuiInput)

#region Cues
func _onGuiInput(event: InputEvent) -> void:
	if not cueOnClick:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		CueActs(event)

#endregion
