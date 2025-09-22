@icon("res://lib_boo_internal/assets/class_icons_custom/TimerTrigger.svg")
class_name TimerCue extends Timer

@warning_ignore("unused_signal")
signal cued ##Signal connected in DELEGATE _init
signal second_passed(remaining_time: float)


@export var initialNonChildNodes: Array[Node]
@export var canCue := true

#CURRENTLY BUGGY, TODO: Reimplement
var isRandom := false
var minWaitTime := 0.0

@export var showDebugLogs := false
## 0 = disabled, >0 = interval in seconds
@export_range(0.0, 60.0, 1.0) var extraCueInterval := 0.0
@export var cue: CueDelegate

var _intervalTracker := 0.0
var _timeLeft := 0.0

func _ready() -> void:
	cue = CueDelegate.Setup(self, cue)
	# Setup timer functionality
	timeout.connect(_on_timeout)
	if autostart:
		UpdateWaitTime()
		super.start()

func CueActs(param = null) -> void:
	cue.CueActs(param)
	if !one_shot:
		UpdateWaitTime()

func UpdateWaitTime() -> void:
	if isRandom:
		wait_time = randf_range(minWaitTime, wait_time)
		if showDebugLogs:
			print("[TimerCue] Random wait time set: ", wait_time, " (range: ", minWaitTime, " - ", wait_time, ")")
	else:
		if showDebugLogs:
			print("[TimerCue] Exact wait time set: ", wait_time)
	_timeLeft = wait_time

func Activate() -> void:
	if !canCue:
		canCue = true
		UpdateWaitTime()

func DeactivateTrigger(duration: float = 0) -> void:
	canCue = false
	stop()
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		canCue = true
		start()

func _on_timeout() -> void:
	if !canCue:
		return
	
	if showDebugLogs:
		print("[TimerCue] Timer triggered after ", wait_time, " seconds")
	
	CueActs()
	
	if !one_shot:
		UpdateWaitTime()
		start()

func _process(delta: float) -> void:
	if extraCueInterval <= 0 or is_stopped() or time_left <= 0:
		return
		
	_intervalTracker += delta
	
	if _intervalTracker >= extraCueInterval:
		_intervalTracker -= extraCueInterval
		_timeLeft = time_left
		second_passed.emit(_timeLeft)
		CueActs()
		if showDebugLogs:
			print("[TimerCue] Time left: ", _timeLeft)
