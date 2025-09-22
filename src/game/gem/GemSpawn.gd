extends RigidBody2D

@export var gemScn:PackedScene
@onready var possible_gem_positions: Node2D = $PossibleGemPositions

func _ready() -> void:
	_SpawnGems()

func _SpawnGems():
	# Get all possible gem positions from the PossibleGemPositions node
	var available_positions = []
	for child in possible_gem_positions.get_children():
		if child is Marker2D:
			available_positions.append(child.position)
	
	# If no positions available, return early
	if available_positions.is_empty():
		print("Warning: No gem positions found in PossibleGemPositions")
		return
	
	# Determine how many gems to spawn based on GameUpgrades.appearingGems
	var gems_to_spawn = min(GameUpgrades.appearingGems, available_positions.size())
	
	# Randomly select positions without repeating
	var selected_positions = []
	var positions_to_choose_from = available_positions.duplicate()
	
	for i in range(gems_to_spawn):
		if positions_to_choose_from.is_empty():
			break
		
		var random_index = randi() % positions_to_choose_from.size()
		var selected_pos = positions_to_choose_from[random_index]
		selected_positions.append(selected_pos)
		positions_to_choose_from.remove_at(random_index)
	
	# Instantiate gems at the selected positions
	for pos in selected_positions:
		var gem_instance = gemScn.instantiate()
		gem_instance.position = pos
		add_child(gem_instance)
