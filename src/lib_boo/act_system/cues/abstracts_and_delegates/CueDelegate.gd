##Holds Cue shared behavior.
class_name CueDelegate extends Resource

signal delegate_cued

var owner: Node
var cueableNodes: Array[Node]
var initialNonChildNodesToCue: Array[Node]##Use with care. Only applied at initialization. Allows to pass in a list of nodes to cue that are not children of the owner for cueing.

@export_group("CanCue")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "feature") 
var canCue:bool = true

@export_subgroup("Basic Behaviors")
@export var oneShot: bool = false

 
func Init(_owner: Node, _initialNonChildNodesToCue: Array[Node] = []) -> void:
	owner = _owner
	initialNonChildNodesToCue = _initialNonChildNodesToCue
	
	if owner.is_inside_tree():
		_SetupDelegate()
	else:
		owner.ready.connect(_SetupDelegate, CONNECT_ONE_SHOT)

#region Setup
##Gets initial nodes and connects to child_entered_tree for new nodes in the future.
func _SetupDelegate() -> void:
	owner.child_entered_tree.connect(AddValidNodeForCue)
	_SetupListeningNodes(owner.get_children() + initialNonChildNodesToCue)

func _SetupListeningNodes(nodes: Array[Node]) -> void:
	for node in nodes:
		AddValidNodeForCue(node)
#endregion


#region Public
func CueActs(param: Variant = null) -> void:
	if not canCue:
		return

	for node in cueableNodes:
		node.CueAct(param)
	delegate_cued.emit()
	
	if oneShot and canCue:
		canCue = false

func AddValidNodeForCue(the_node: Node) -> void:
	if the_node.has_method("CueAct") and not cueableNodes.has(the_node):
		cueableNodes.append(the_node)
		the_node.tree_exiting.connect(func(): cueableNodes.erase(the_node))

## Connect a signal to be emitted when the delegate is cued
func ConnectCuedSignal(callback: Callable) -> void:
	delegate_cued.connect(callback)
#endregion

## Simple setup method that handles everything
static func Setup(_owner: Node, _cue: CueDelegate = null, _initialNonChildNodesToCue: Array[Node] = []) -> CueDelegate:
	if _cue == null:
		_cue = CueDelegate.new()
	_cue.Init(_owner, _initialNonChildNodesToCue)
	if _owner.has_signal("cued"):
		_cue.delegate_cued.connect(func(): _owner.cued.emit())
	return _cue
