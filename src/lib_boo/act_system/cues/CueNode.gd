@icon("res://lib_boo/assets/class_icons_custom/CueNode2D.svg")
class_name CueNode extends Node2D

signal cued()

@export var initialNonChildNodes:Array[Node] # Extra nodes to be cued
@export var canCue := true
@export var delayToCue:float = 0.0

var cueableNodes:Array[Node] # Stores all nodes that can be cued
var delegateOwner:Node = null 

func _init(initializationOwner:Node = null, extraActs:Array[Node] = []):
	delegateOwner = initializationOwner
	if delegateOwner:
		delegateOwner.add_child(self)
		initialNonChildNodes = extraActs
		delegateOwner.child_entered_tree.connect(AddValidNodeToTriggerables)
	else:
		child_entered_tree.connect(AddValidNodeToTriggerables)

func _ready():
	#Get children node from Parent...
	if delegateOwner:
		AddListeningNodes(delegateOwner.get_children() + initialNonChildNodes)
	else:
		# Gets child nodes within this trigger.
		AddListeningNodes(get_children() + initialNonChildNodes)

func AddListeningNodes(nodes:Array[Node]):
	if nodes.size() < 1: return
	
	for node in nodes:
		AddValidNodeToTriggerables(node)

## Call this one from inside the script and its inheritors.
## param can be any type - child Acts will handle the parameter based on their needs
func CueActs(param = null):
	if canCue:
		if delayToCue > 0.0:
			print("Delaying cue for ", delayToCue, " seconds")
			await get_tree().create_timer(delayToCue).timeout
		for node in cueableNodes:
			if param != null:
				node.CueAct(param)
			else:
				node.CueAct()
		cued.emit()

## Use this one when calling the function directly from an outside script and its inheritors.
func ManualTrigger(param = null):
	CueActs(param)

## Differentiation just to make it clearer where it is being called from.
func SignalTrigger(param = null):
	CueActs(param)

func AddValidNodeToTriggerables(theNode:Node):
	if theNode.has_method("CueAct") and not cued.is_connected(theNode.CueAct):
		if not cueableNodes.has(theNode):
			cueableNodes.append(theNode)
			theNode.tree_exiting.connect(_RemoveNode.bind(theNode))

func ActivateTrigger():
	canCue = true
	print("ACTIVATED CUE")
func DeactivateTrigger():
	canCue = false

## LOCAL
func _RemoveNode(theNode:Node):
	cueableNodes.erase(theNode)
