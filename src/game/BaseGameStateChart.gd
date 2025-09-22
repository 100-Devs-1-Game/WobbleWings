@tool
class_name BaseGameStateChart extends StateChart

@onready var menuSt:AtomicState = $CompoundState/Menu
@onready var startingPlaySt:AtomicState = $CompoundState/Playing/StartingPlay
@onready var activeSt:AtomicState = $CompoundState/Playing/Active
@onready var pauseSt:AtomicState = $CompoundState/Playing/Pause
@onready var gameOverSt:AtomicState = $CompoundState/GameOver

func _ready() -> void:
	super()

#region States
func _on_loading_state_entered() -> void:
	send_event("loading_done")


func _on_menu_state_entered() -> void:
	send_event("play_triggered")


func _on_starting_play_state_entered() -> void:
	send_event("play_started")

func _on_starting_play_state_exited() -> void:
	pass # Replace with function body.


func _on_active_state_entered() -> void:
	pass # Replace with function body.


func _on_pause_state_entered() -> void:
	#ownerGame.PauseGame()
	pass

func _on_pause_state_exited() -> void:
	#ownerGame.ResumeGame()
	pass


func _on_game_over_state_entered() -> void:
	pass # Replace with function body.

func _on_game_over_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_menu_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_menu_state_unhandled_input(_event: InputEvent) -> void:
	pass # Replace with function body.
