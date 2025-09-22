@abstract
class_name NodeCue extends Node

@warning_ignore("unused_signal")
signal cued #connected in CueDelegate



@export_group("Optionals")
@export var cue: CueDelegate

###


func _ready():
	cue = CueDelegate.Setup(self, cue)

## Methods that CueActs
#region Cues
func CueActs(object = null):
	cue.CueActs(object)
#endregion
