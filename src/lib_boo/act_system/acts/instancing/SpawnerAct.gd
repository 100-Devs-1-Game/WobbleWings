@icon("res://lib_boo/assets/class_icons_custom/SpawnerAct.svg")
@tool
class_name SpawnerAct extends BaseSpawnerAct

@export var sceneToSpawn: PackedScene 

## Override of Execute from Marker2DAct
## Parameters can be a Dictionary with optional keys: spawn_pos, parent, scene
## Or can be null to use default values
func _GetTemplate() -> Variant:
	return sceneToSpawn

func _HandleParameterOverrides(parameters: Dictionary, template: Variant) -> Variant:
	if parameters.has("scene"):
		return parameters.scene
	return template

func _SpawnInstance(spawnPos: Vector2, parent: Node, template: Variant) -> Node:
	var scene: PackedScene = template
	var instance = GM.globalSpawner.SpawnInstance(self, parent, spawnPos, scene)
	return instance
