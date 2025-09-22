class_name Area2DCue extends Area2D

signal triggeringBody(body)
signal triggeringArea(area)
signal clicked(clicked_area_position: Vector2, viewport_position: Vector2)
@warning_ignore("unused_signal")
signal cued #connected in CueDelegate

@export var cueOnBodyEntered: bool = false
@export var cueOnAreaEntered: bool = false
@export var cueOnClicked: bool = false
@export var cue:CueDelegate = null ##Leave blank for basic Delegate, otherwise use it to provide behaviors to the cue.

@export_group("Colliders")
@export var startDisabled: bool = false
@export var delayToMonitor: float = 0 ## On ready wait X time before starting to monitor collisions.

var _colliders: Array[Node] = []

#region Setup
func _ready():
	cue = CueDelegate.Setup(self, cue)
	_SetupColliders()
	_SetupMonitoring()

	body_entered.connect(_onBodyEntered)
	area_entered.connect(_onAreaEntered)


func _SetupColliders() -> void:
	for child in get_children():
		if child is CollisionPolygon2D or child is CollisionShape2D:
			_colliders.append(child)
	
	if startDisabled:
		DisableColliders()

func _SetupMonitoring() -> void:
	if delayToMonitor > 0:
		monitoring = false
		await get_tree().create_timer(delayToMonitor).timeout
		monitoring = true
#endregion

func EnableColliders() -> void:
	for collider in _colliders:
		collider.disabled = false

func DisableColliders() -> void:
	for collider in _colliders:
		collider.disabled = true

#region Cues
func CueActs(object = null):
	cue.CueActs(object)
	_SignalOutTriggerers(object)

func _SignalOutTriggerers(object = null):
	if object is PhysicsBody2D:
		triggeringBody.emit(object)
	elif object is Area2D: 
		triggeringArea.emit(object)

func _onBodyEntered(body: Node2D):
	if not cueOnBodyEntered:
		return
	CueActs(body)

func _onAreaEntered(area: Area2D):
	if not cueOnAreaEntered:
		return
	CueActs(area)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not cue.canCue or not cueOnClicked:
		return
	if event is not InputEventMouseButton or not event.pressed:
		return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		CueActs()
		clicked.emit(global_position, get_viewport().get_mouse_position())
#endregion
