class_name CB2DBehavior extends Node2D
## Base class for all CharacterBody2D behaviors
## Provides common functionality and interface for modular CB2D components

signal behavior_enabled
signal behavior_disabled

@export var enabled: bool = true:
	set(value):
		enabled = value
		if enabled:
			_on_enabled()
			behavior_enabled.emit()
		else:
			_on_disabled()
			behavior_disabled.emit()

var _character_body: CharacterBody2D
var _is_ready: bool = false

func _ready():
	_is_ready = true
	_on_ready()
	
	if enabled:
		_on_enabled()

func _process(delta):
	if not enabled or not _is_ready:
		return
	_process_behavior(delta)

func _physics_process(delta):
	if not enabled or not _is_ready:
		return
	_physics_process_behavior(delta)

func _input(event):
	if not enabled or not _is_ready:
		return
	_input_behavior(event)

## Internal method for manager to set character body reference
func SetCharacterBody(character_body: CharacterBody2D):
	_character_body = character_body

## Override these methods in derived classes
func _on_ready():
	pass

func _on_enabled():
	pass

func _on_disabled():
	pass

func _process_behavior(_delta):
	pass

func _physics_process_behavior(_delta):
	pass

func _input_behavior(_event):
	pass

## Optional input hooks called by the manager
func OnActionPressed(_action_name: String):
	pass

func OnActionReleased(_action_name: String):
	pass

func OnMovementInput(_direction: Vector2):
	pass

# ## Helper methods
func get_character_body() -> CharacterBody2D:
	return _character_body

func is_on_ground() -> bool:
	if _character_body:
		return _character_body.is_on_floor()
	return false

func is_on_wall() -> bool:
	if _character_body:
		return _character_body.is_on_wall()
	return false

func is_on_ceiling() -> bool:
	if _character_body:
		return _character_body.is_on_ceiling()
	return false
