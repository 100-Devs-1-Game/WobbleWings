class_name World extends Node2D

@onready var background = $BackgroundSpace
@onready var main = $MainSpace
@onready var foreground = $ForegroundSpace

func _ready() -> void:
	GM.world = self
	add_to_group("world")
	_InitializeWorldSpaces()


#region Private
func _InitializeWorldSpaces() -> void:
	if not has_node("BackgroundSpace"):
		background = Node2D.new()
		background.name = "BackgroundSpace"
		add_child(background)
	
	if not has_node("MainSpace"):
		main = Node2D.new()
		main.name = "MainSpace"
		add_child(main)
	
	if not has_node("ForegroundSpace"):
		foreground = Node2D.new()
		foreground.name = "ForegroundSpace"
		add_child(foreground)
#endregion
