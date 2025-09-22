class_name Helpers extends RefCounted

static func RandomBool() -> bool:
	return randi() % 2 == 0

static func GetRandomColor() -> Color:
	return Color(randf(), randf(), randf())

static func GetRandomValues(array:Array, count:int, can_repeat:bool = false) -> Array:
	var result:Array = []
	var available_values:Array = array.duplicate()
	
	# Ensure we don't try to get more values than available
	count = mini(count, array.size())
	
	for i in range(count):
		if available_values.is_empty():
			break
			
		var random_index:int = randi() % available_values.size()
		result.append(available_values[random_index])
		
		if not can_repeat:
			available_values.remove_at(random_index)
	
	return result
