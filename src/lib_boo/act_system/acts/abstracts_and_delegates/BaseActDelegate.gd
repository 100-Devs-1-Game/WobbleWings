class_name BaseActDelegate extends RefCounted

signal act_started
signal act_finished

var owner: Node
var isRunning := false
var canOverlap := true ##If true, the act can be cued multiple times while running
var autoStart := false
var canAct := true
var lastResult: Variant = null

func _init(_owner: Node):
	owner = _owner
	act_started.connect(func(): owner.act_started.emit())
	act_finished.connect(func(): owner.act_finished.emit())

## Virtual method that all Act nodes should implement
## Parameters can be passed as any type - specific Acts will handle type checking
func CueAct(parameters: Variant = null) -> Variant:
	if !canAct:
		return
	
	if !canOverlap and isRunning:
		return
		
	isRunning = true
	act_started.emit()
	
	lastResult = await owner.Execute(parameters)
	
	isRunning = false
	act_finished.emit()
	
	return lastResult