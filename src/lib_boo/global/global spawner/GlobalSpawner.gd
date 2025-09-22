class_name GlobalSpawner extends Node2D

@export var printDebug: bool = false

# Dictionaries for SpawnCount and SpawnedInstances
var _spawnCounts: Dictionary[Node, int] = {}
var _spawnedInstances: Dictionary[Node, Array] = {}

func Spawn(scene: PackedScene, parent:Enums.ParentMode, spawnPos: Vector2, calling_node: Node2D = null) -> Node:
	if calling_node == null:
		calling_node = self

	return _SpawnInternal(scene, parent, spawnPos, calling_node, "scene", false)

func SpawnInstance(calling_node: Node2D, parent:Node, spawnPos: Vector2, scene: PackedScene) -> Node:
	# Since we already have the resolved parent, we need to handle this differently
	var instance = scene.instantiate()
	
	if printDebug:	
		print("[GlobalSpawner] Spawning scene %s with parent: %s" % [
			instance.name, 
			parent.name
		])
	
	parent.add_child(instance)
	instance.global_position = spawnPos
	
	# Set instance name using the scene filename and spawn count
	var scene_name = scene.resource_path.get_file().get_basename()
	var spawn_count = _GetNextSpawnCount(calling_node)
	instance.name = "%s_%d" % [scene_name, spawn_count]
	
	# Track the spawned instance
	_TrackSpawnedInstance(calling_node, instance)
	
	return instance

## Internal helper function for spawning instances - contains the core logic for both scenes and nodes
func _SpawnInternal(template: Variant, parent: Enums.ParentMode, spawnPos: Vector2, calling_node: Node2D, debug_prefix: String = "instance", is_clone: bool = false) -> Node:
	var parent_node = ResolveParent(parent, self)
	
	# Create the instance (either instantiate scene or duplicate node)
	var instance: Node
	if is_clone:
		instance = template.duplicate()
	else:
		instance = template.instantiate()
	
	if printDebug:
		print("[GlobalSpawner] Spawning %s %s with parent: %s (Mode: %s)" % [
			debug_prefix,
			instance.name,
			parent_node.name,
			Enums.ParentMode.keys()[parent]
		])
	
	# Add to parent and position
	parent_node.add_child(instance)
	
	# Set position if the node supports it
	if instance is Node2D:
		instance.global_position = spawnPos
	elif instance is Node3D:
		instance.global_position = Vector3(spawnPos.x, spawnPos.y, 0)
	
	# Set instance name using the template name and spawn count
	var template_name: String
	if is_clone:
		template_name = template.name
	else:
		template_name = template.resource_path.get_file().get_basename()
	
	var spawn_count = _GetNextSpawnCount(calling_node)
	var suffix = "_Clone_%d" if is_clone else "_%d"
	instance.name = "%s%s" % [template_name, suffix % spawn_count]
	
	# Track the spawned instance
	_TrackSpawnedInstance(calling_node, instance)
	
	return instance

## All fail cases will set GlobalSpawner as the parent, NOT the calling_node.
func ResolveParent(parent_mode: Enums.ParentMode, calling_node: Node, manual_node: NodePath = "", target_group: String = "") -> Node:
	match parent_mode:
		#NOTE: Requiring a "calling_node" means that I can't really call this just from code, which might be troublesome later.
		Enums.ParentMode.SELF: 
			return calling_node
		Enums.ParentMode.SCENE_ROOT: 
			return calling_node.owner
		
		Enums.ParentMode.MANUAL:
			if manual_node.is_empty():
				return self
			var target = get_node_or_null(manual_node)
			return target if target != null else self
			
		Enums.ParentMode.GROUP_FIRST:
			if target_group.is_empty():
				return self
			var grouped_node = get_tree().get_first_node_in_group(target_group)
			return grouped_node if grouped_node else self
		
		# ⚠️REQUIRES Specific World Node with Entities and Foreground children nodes
		Enums.ParentMode.WORLD_BACKGROUND:
			return _get_world_space("background")

		Enums.ParentMode.WORLD_MAIN:
			return _get_world_space("main")

		Enums.ParentMode.WORLD_FOREGROUND:
			return _get_world_space("foreground")

	return self


#region Getters
func GetSpawnCount(spawner: Node) -> int:
	if not _spawnCounts.has(spawner):
		_spawnCounts[spawner] = 0
	return _spawnCounts[spawner]

func GetSpawnedInstances(spawner: Node) -> Array:
	if not _spawnedInstances.has(spawner):
		_spawnedInstances[spawner] = []
	return _spawnedInstances[spawner]
#endregion


#region Tracking
func _TrackSpawnedInstance(spawner: Node, instance: Node) -> void:
	if not _spawnedInstances.has(spawner):
		_spawnedInstances[spawner] = []
	_spawnedInstances[spawner].append(instance)

func _GetNextSpawnCount(spawner: Node) -> int:
	if not _spawnCounts.has(spawner):
		_spawnCounts[spawner] = 0
	_spawnCounts[spawner] += 1
	return _spawnCounts[spawner]
#endregion


#region Helpers
func _get_world_space(space_name: String) -> Node:
	if get_tree() == null:
		print_debug("No tree found")
		return self
	var world_node = get_tree().get_first_node_in_group("world")

	if not world_node:
		print_debug("No world node found")
		return self

	# Map space names to actual child node names
	var space_node_names = {
		"background": "BackgroundSpace",
		"main": "MainSpace", 
		"foreground": "ForegroundSpace"
	}
	
	var target_node_name = space_node_names.get(space_name, space_name)
	
	# Try to get the space as a child node
	if world_node.has_node(target_node_name):
		var space_node = world_node.get_node(target_node_name)
		if printDebug:
			print("[GlobalSpawner] Found world space '%s' as child node '%s'" % [space_name, target_node_name])
		return space_node
	
	# Fallback: try to get as a property
	if world_node.has(space_name):
		var space_node = world_node.get(space_name)
		if printDebug:
			print("[GlobalSpawner] Found world space '%s' as property" % space_name)
		return space_node
	
	if printDebug:
		print("[GlobalSpawner] Could not find world space '%s', falling back to GlobalSpawner" % space_name)
	return self
#endregion	

	
## Spawn Clone Node: Takes any node, spawns a clone of it. This allows us to have nodes within scenes (for visualization) but then spawn them without needing to create a separate packedscene file on disk.
func SpawnCloneNode(node: Node, parent: Enums.ParentMode, spawnPos: Vector2, calling_node: Node2D = null) -> Node:
	if calling_node == null:
		calling_node = self
	
	var clone  = _SpawnCloneInternal(node, parent, spawnPos, calling_node, "node")

	if clone is GPUParticles2D:
		clone.emitting = true

	return clone

## Internal helper function for cloning nodes - contains the core logic
func _SpawnCloneInternal(node: Node, parent: Enums.ParentMode, spawnPos: Vector2, calling_node: Node2D, debug_prefix: String = "node") -> Node:
	return _SpawnInternal(node, parent, spawnPos, calling_node, debug_prefix, true)
	
