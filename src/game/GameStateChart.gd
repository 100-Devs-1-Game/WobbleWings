@tool
extends BaseGameStateChart

signal took_damage(amount:int)

@export var player:CharacterBody2D = null
@export var level:CanvasLayer = null
@onready var title_screen: CanvasLayer = $"../Title/"

var startPos:Vector2 = Vector2(115, 162)

@onready var playAgainBtn:Button = %PlayAgainBtn

func _ready() -> void:
	super()
	
	# Connect the button's input event to handle custom input
	playAgainBtn.gui_input.connect(_on_play_again_btn_gui_input)
	
	await get_tree().process_frame
	GM.main.SetStateChartDebug(self)

func _on_menu_state_entered() -> void:
	playAgainBtn.hide()

	if player != null:
		player.position = startPos
	
	for obstacle in get_tree().get_nodes_in_group("hazard"):
		obstacle.queue_free()
	
	GM.events.MenuEntered()


func _on_menu_state_input(_event: InputEvent) -> void:
	pass

func _on_menu_state_unhandled_input(event: InputEvent) -> void:
	if title_screen.visible:
		return
	if event.is_action_pressed("confirm") or event.is_action_pressed("left_click"):
		send_event("play_triggered")

func _on_starting_play_state_entered() -> void:

	GM.events.PlayStarted()
	send_event("play_started")

func _on_active_state_entered() -> void:
	player.Start()
	%ObstacleTimer.start()


func _on_game_over_state_entered() -> void:
	player.Stop()

	%ObstacleTimer.stop()
	for obstacle in get_tree().get_nodes_in_group("hazard"):
		obstacle.linear_velocity = Vector2.ZERO
	
	
	playAgainBtn.show()
	playAgainBtn.grab_focus()
	GM.main.SaveGemScore()
	GM.events.GameOver(level.obstacleDodgeCount)

func _on_game_over_state_input(_event: InputEvent) -> void:
	pass

func _on_player_ui_clicked(_index:int) -> void:
	send_event("reset_game")

#region Calls
func _on_play_again_called() -> void:
	send_event("reset_game")


func _on_play_again_btn_pressed() -> void:
	send_event("reset_game")

func _on_play_again_btn_gui_input(event: InputEvent) -> void:
	# Only respond to ENTER key, ignore SPACE and other keys
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			# Accept the input and trigger the button
			get_viewport().set_input_as_handled()
			playAgainBtn.emit_signal("pressed")
		elif event.keycode == KEY_SPACE:
			# Consume SPACE input to prevent default button behavior
			get_viewport().set_input_as_handled()


func _on_player_got_hit(area: Area2D) -> void:
	GM.globalAudio.PlaySound("hit")
	# player.jump.OnJumpPressed()
	if area.is_in_group("floor"):
		took_damage.emit(9999)
		return

	took_damage.emit(1)
