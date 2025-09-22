class_name CB2DBehaviorManager extends Node2D
## Manager for CB2D behaviors - central hub that manages all behaviors

signal behavior_added(behavior)
signal behavior_removed(behavior)
signal movement_changed(direction: Vector2)

@export var characterBody: CharacterBody2D
@export var shouldCallMoveAndSlide := false
@export var jumpAction: StringName = "jump"
@export var leftAction: StringName = "move_left"
@export var rightAction: StringName = "move_right"
@export var upAction: StringName = "move_up"
@export var downAction: StringName = "move_down"

var _behaviors: Array = []

func _ready():
	characterBody = get_parent() as CharacterBody2D
	if not characterBody:
		push_error("CB2DBehaviorManager must be a child of CharacterBody2D")
		return
	
	# Collect all existing behaviors
	_collect_behaviors()

func _process(_delta: float) -> void:
	if shouldCallMoveAndSlide:
		characterBody.move_and_slide()

func _input(event):
	# Dispatch action press/release
	if event is InputEventAction:
		var action_event := event as InputEventAction
		if action_event.pressed:
			if action_event.action == jumpAction:
				_dispatch_action_pressed("jump")
			if action_event.action == leftAction:
				_left_down = true
				_update_movement()
			if action_event.action == rightAction:
				_right_down = true
				_update_movement()
			if action_event.action == upAction:
				_up_down = true
				_update_movement()
			if action_event.action == downAction:
				_down_down = true
				_update_movement()
		else:
			# released
			if action_event.action == jumpAction:
				_dispatch_action_released("jump")
			if action_event.action == leftAction:
				_left_down = false
				_update_movement()
			if action_event.action == rightAction:
				_right_down = false
				_update_movement()
			if action_event.action == upAction:
				_up_down = false
				_update_movement()
			if action_event.action == downAction:
				_down_down = false
				_update_movement()

func _collect_behaviors():
	_behaviors.clear()
	for child in get_children():
		if child is CB2DBehavior:
			_behaviors.append(child)
			# Set the character body reference for each behavior
			child.SetCharacterBody(characterBody)
			behavior_added.emit(child)

## Public methods
func add_behavior(behavior: CB2DBehavior):
	if behavior and not _behaviors.has(behavior):
		add_child(behavior)
		_behaviors.append(behavior)
		# Set the character body reference
		behavior.SetCharacterBody(characterBody)
		behavior_added.emit(behavior)

func remove_behavior(behavior: CB2DBehavior):
	if behavior and _behaviors.has(behavior):
		_behaviors.erase(behavior)
		behavior_removed.emit(behavior)
		behavior.queue_free()

func get_behavior(behavior_type: GDScript) -> CB2DBehavior:
	for behavior in _behaviors:
		if behavior.get_script() == behavior_type:
			return behavior
	return null

func get_behaviors() -> Array[CB2DBehavior]:
	return _behaviors.duplicate()

func enable_all_behaviors(enabled: bool):
	for behavior in _behaviors:
		behavior.enabled = enabled

func enable_behavior_type(behavior_type: GDScript, enabled: bool):
	var behavior = get_behavior(behavior_type)
	if behavior:
		if behavior.has_variable("enabled"):
			behavior.enabled = enabled

## Convenience methods for specific behaviors
func GetGravityBehavior() -> CB2DGravity:
	return get_behavior(CB2DGravity) as CB2DGravity

func GetJumpBehavior() -> CB2DJump:
	return get_behavior(CB2DJump) as CB2DJump

#func GetInputBehavior() -> CB2DInput:
	#return get_behavior(CB2DInput) as CB2DInput
#
#func GetMovementBehavior() -> CB2DSideMovement:
	#return get_behavior(CB2DSideMovement) as CB2DSideMovement

# --- Internal input state and dispatch ---
var _movement_direction: Vector2 = Vector2.ZERO
var _left_down: bool = false
var _right_down: bool = false
var _up_down: bool = false
var _down_down: bool = false

func _update_movement():
	var new_dir := Vector2.ZERO
	new_dir.x = (1 if _right_down else 0) - (1 if _left_down else 0)
	new_dir.y = (1 if _down_down else 0) - (1 if _up_down else 0)
	if new_dir != _movement_direction:
		_movement_direction = new_dir
		movement_changed.emit(_movement_direction)
		for behavior in _behaviors:
			behavior.OnMovementInput(_movement_direction)

func _dispatch_action_pressed(canonical_action: String):
	for behavior in _behaviors:
		behavior.OnActionPressed(canonical_action)

func _dispatch_action_released(canonical_action: String):
	for behavior in _behaviors:
		behavior.OnActionReleased(canonical_action)
