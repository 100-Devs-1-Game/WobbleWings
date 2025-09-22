class_name SubgameLoader extends Node

@export var games: Array[GamePak] = []

var activeGamePak:GamePak = null

var _subgameInstance:SubgameManager = null

var ActiveSubgame:Dictionary:
	get: return {"data": _subgameInstance.subgameData, 
				"instance":_subgameInstance}


func InstantiateSubgame(new_subgame:GamePak) -> SubgameManager:
	activeGamePak = new_subgame

	UnloadSubgame()
	_subgameInstance = new_subgame.scene.instantiate()
	
	return _subgameInstance

func UnloadSubgame():
	if _subgameInstance == null:
		return
	_subgameInstance.queue_free()
	_subgameInstance = null

func ReloadSubgame():
	InstantiateSubgame(activeGamePak)
