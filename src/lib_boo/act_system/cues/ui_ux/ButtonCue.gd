class_name ButtonCue extends Button

@warning_ignore("unused_signal")
signal cued

@export var pressCanCue := true
@export var buttonUpCanCue := false
@export var buttonDownCanCue := false
@export var toggledCanCue := false

@export_group("Optionals")
@export var cue: CueDelegate

func _ready():
	cue = CueDelegate.Setup(self, cue)
	
	pressed.connect(func(): HandleSignal("press"))
	button_down.connect(func(): HandleSignal("button_down"))
	button_up.connect(func(): HandleSignal("button_up"))
	toggled.connect(func(toggled_on: bool): HandleSignal("toggled", toggled_on))	

func CueActs(param = null) -> void:
	cue.CueActs(param)

func HandleSignal(type_of_input: String, param: Variant = null) -> void:
	if type_of_input == "press" && pressCanCue:
		CueActs()
	elif type_of_input == "button_down" && buttonDownCanCue:
		CueActs()
	elif type_of_input == "button_up" && buttonUpCanCue:
		CueActs()
	elif type_of_input == "toggled" && toggledCanCue:
		CueActs(param)
