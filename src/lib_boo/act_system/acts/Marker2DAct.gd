class_name Marker2DAct extends Marker2D

## 🎗️OVERRIDE in Inheritors. This is "What" actually "happens"
func Execute(_parameters: Variant = null) -> Variant:
	return null 

#region Delegate BOILERPLATE
# Forward signals
@warning_ignore("unused_signal")
signal act_started
@warning_ignore("unused_signal") 
signal act_finished

var _act: BaseActDelegate
# Expose properties through getters/setters
@export var canOverlap: bool:
	get: return _act.canOverlap
	set(value): _act.canOverlap = value

@export var autoStart: bool:
	get: return _act.autoStart
	set(value): _act.autoStart = value

@export var canAct: bool:
	get: return _act.canAct
	set(value): _act.canAct = value

var isRunning: bool:
	get: return _act.isRunning

func _init():
	_act = BaseActDelegate.new(self)

func _ready() -> void:
	if _act.autoStart:
		_act.CueAct()

func ActivateAct():
	canAct = true
	if autoStart:
		CueAct()

## Needed, do not override. Override Execute instead.
func CueAct(param = null):
	_act.CueAct(param)
#endregion

