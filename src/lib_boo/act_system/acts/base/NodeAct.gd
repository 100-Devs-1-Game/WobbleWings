@abstract
class_name NodeAct extends Node

@abstract
func Execute(_parameters: Variant = null) -> Variant

#region Delegate BOILERPLATE
# Forward signals
@warning_ignore("unused_signal")
signal act_started
@warning_ignore("unused_signal")
signal act_finished

var _act: BaseActDelegate

# Expose properties through getters/setters
@export var CanOverlap: bool:
	get: return _act.canOverlap
	set(value): _act.canOverlap = value

@export var AutoStart: bool:
	get: return _act.autoStart
	set(value): _act.autoStart = value

var IsRunning: bool:
	get: return _act.isRunning

func _ready() -> void:
	_act = BaseActDelegate.new(self)
	if AutoStart:
		CueAct(null)

## Needed, do not override. Override Execute instead.
func CueAct(param = null):
	_act.CueAct(param)
#endregion
