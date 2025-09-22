@icon("res://lib_boo/assets/class_icons_custom/SpawnerAct.svg")
@tool
class_name BaseSpawnerAct extends Marker2DAct

signal done(spawnedInstances)

@export var positionOverride: Node2D = null ##Necessary when child of Non-Node2D, Use to spawn at Global Position of a different Node2D.

func _ready():
	pass

##OPTIONALS
@export var parentMode:Enums.ParentMode = Enums.ParentMode.SELF:
	set(value):
		parentMode = value
		notify_property_list_changed()

var _manualNode: NodePath = ""
var _target_group: String = ""

## Override of Execute from Marker2DAct
## Parameters can be a Dictionary with optional keys: spawn_pos, parent, and other specific keys
## Or can be null to use default values
func Execute(parameters: Variant = null) -> Array:
	var spawn_pos := global_position
	var parent = GM.globalSpawner.ResolveParent(parentMode, self, _manualNode, _target_group)
	
	# Get the template object (scene or node) to spawn/clone
	var template = _GetTemplate()
	
	# Handle parameter OVERRIDES
	if parameters is Dictionary:
		if parameters.has("spawn_pos"):
			spawn_pos = parameters.spawn_pos
		if parameters.has("parent"):
			parent = parameters.parent
		# Let subclasses handle their specific parameter overrides
		template = _HandleParameterOverrides(parameters, template)
	
	if positionOverride != null:
		spawn_pos = positionOverride.global_position
	
	var newInstance = _SpawnInstance(spawn_pos, parent, template)

	var arr:Array = [newInstance]
	done.emit(arr)
	return arr

## Virtual methods that subclasses must implement
func _GetTemplate() -> Variant:
	push_error("_GetTemplate() must be implemented by subclass")
	return null

func _HandleParameterOverrides(parameters: Dictionary, template: Variant) -> Variant:
	# Override in subclasses to handle specific parameter overrides
	return template

func _SpawnInstance(spawnPos: Vector2, parent: Node, template: Variant) -> Node:
	push_error("_SpawnInstance() must be implemented by subclass")
	return null

# EDITOR ONLY
func _get_property_list() -> Array:
	var properties: Array[Dictionary] = []
	
	# Show manual_parent_path only when mode is MANUAL
	if parentMode == Enums.ParentMode.MANUAL:
		properties.append({
			"name": "_manualNode",
			"type": TYPE_NODE_PATH,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	# Show target_group for modes that need it
	if parentMode == Enums.ParentMode.GROUP_FIRST:
		properties.append({
			"name": "_target_group",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
			"hint_string": "Group name..."
		})
	
	return properties
