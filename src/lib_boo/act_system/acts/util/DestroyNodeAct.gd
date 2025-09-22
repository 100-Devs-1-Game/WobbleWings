@icon("res://lib_boo/assets/class_icons_custom/DestroyNodeAct.svg")
class_name DestroyNodeAct extends Node2DAct

signal nodeQueuedForDestruction(theNode)

@export var actor:Node = null
@export var beforeDestroyTrigger:CueNode = null
@export var delay := 0.0

func Execute(_parameters: Variant = null) -> Variant:
	if !actor:
		printerr("Missing actor to destroy, from DestroyNodeAct in ", owner.name)
		return 
	
	if beforeDestroyTrigger:
		beforeDestroyTrigger.CueActs(null)
	
	nodeQueuedForDestruction.emit(actor) #Doing this before queue_free() in case it's freeing itself.
	
	if delay > 0:
		await get_tree().create_timer(delay).timeout
		actor.queue_free.call_deferred()
	else:
		actor.queue_free.call_deferred()
	
	return null
