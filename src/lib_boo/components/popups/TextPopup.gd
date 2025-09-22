class_name TextPopup extends Node2D

@onready var label: Label = $Label

func Play(msg:String, start_pos: Vector2, color: Color = Color.WHITE) -> void:
	# Set random offset for spread effect with customizable range
	global_position = start_pos
	
	# Set the damage text and color
	if label:
		label.text = msg
		modulate = color
