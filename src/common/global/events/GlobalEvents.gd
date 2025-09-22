class_name GlobalEvents extends BooEvents

enum EventName {
	GAME_START,
	GAME_END,

	SUBGAME_CHOSEN,
	SUBGAME_LOADED,
	SUBGAME_PAUSED,
	SUBGAME_RESUMED,
	SUBGAME_STARTED,
	SUBGAME_OVER,

	PLAYER_SCORED,
	PLAYER_SCORE_ADDED,
	PLAYER_TURN_TIMEOUT,
	PLAYER_UI_CLICKED,
	SHOP_ITEM_PURCHASED,
	SHOP_ITEM_EQUIPPED,
	MENU_ENTERED,
	PLAY_AGAIN_CALLED,
	GAME_OVER,
	PLAY_STARTED,
}

signal game_start_signal
func GameStart() -> void:
	game_start_signal.emit()

signal game_end_signal
func GameEnd() -> void:
	game_end_signal.emit()

signal play_started
func PlayStarted() -> void:
	play_started.emit()

signal subgame_chosen
func SubgameChosen() -> void:
	subgame_chosen.emit()

signal subgame_loaded
func SubgameLoaded() -> void:
	subgame_loaded.emit()

signal subgame_paused
func SubgamePaused() -> void:
	subgame_paused.emit()

signal subgame_resumed
func SubgameResumed() -> void:
	subgame_resumed.emit()

signal subgame_started
func SubgameStarted() -> void:
	subgame_started.emit()

signal subgame_over
func SubgameOver() -> void:
	subgame_over.emit()

signal player_scored(score_amount:int)
func PlayerScored(score_amount:int) -> void:
	player_scored.emit(score_amount)

signal player_score_added(score_amount:int, was_bonus:bool)
func PlayerScoreAdded(score_amount:int, was_bonus:bool) -> void:
	player_score_added.emit(score_amount, was_bonus)

signal obstacle_dodge
func ObstacleDodge() -> void:
	obstacle_dodge.emit()

signal player_turn_timeout()
func PlayerTurnTimeout() -> void:
	player_turn_timeout.emit()

signal player_ui_clicked(index:int)
func PlayerUiClicked(index:int) -> void:
	player_ui_clicked.emit(index)

signal shop_item_purchased(data:ShopItemData)
func ShopItemPurchased(data:ShopItemData) -> void:
	shop_item_purchased.emit(data)

signal shop_item_equipped(data:ShopItemData)
func ShopItemEquipped(data:ShopItemData) -> void:
	shop_item_equipped.emit(data)
	GM.globalAudio.PlaySound("item_equip")

#region Calls
signal menu_entered()
func MenuEntered() -> void:
	menu_entered.emit()

signal play_again_called()
func PlayAgainCalled() -> void:
	play_again_called.emit()

signal game_over()
func GameOver() -> void:
	game_over.emit()

## Converts enum value to signal name string
func GetSignalNameFromEnum(event_enum: EventName) -> String:
	return EventName.keys()[event_enum].to_snake_case()

## Connects a callable to the signal corresponding to the given event enum
func ConnectEventSignal(event_enum: EventName, callable: Callable) -> bool:
	match event_enum:
		EventName.GAME_START:
			game_start_signal.connect(callable)
		EventName.GAME_END:
			game_end_signal.connect(callable)
		EventName.SUBGAME_CHOSEN:
			subgame_chosen.connect(callable)
		EventName.SUBGAME_LOADED:
			subgame_loaded.connect(callable)
		EventName.SUBGAME_PAUSED:
			subgame_paused.connect(callable)
		EventName.SUBGAME_RESUMED:
			subgame_resumed.connect(callable)
		EventName.SUBGAME_STARTED:
			subgame_started.connect(callable)
		EventName.SUBGAME_OVER:
			subgame_over.connect(callable)
		EventName.PLAYER_SCORED:
			player_scored.connect(callable)
		EventName.PLAYER_SCORE_ADDED:
			player_score_added.connect(callable)
		EventName.PLAYER_TURN_TIMEOUT:
			player_turn_timeout.connect(callable)
		EventName.PLAYER_UI_CLICKED:
			player_ui_clicked.connect(callable)

		EventName.SHOP_ITEM_PURCHASED:
			shop_item_purchased.connect(callable)
		EventName.SHOP_ITEM_EQUIPPED:
			shop_item_equipped.connect(callable)
		EventName.MENU_ENTERED:
			menu_entered.connect(callable)
		EventName.PLAY_AGAIN_CALLED:
			play_again_called.connect(callable)
		EventName.GAME_OVER:
			game_over.connect(callable)
		EventName.PLAY_STARTED:
			play_started.connect(callable)
		_:
			push_warning("No signal connection implemented for event: " + str(event_enum))
			return false
	return true

## Disconnects a callable from the signal corresponding to the given event enum
func DisconnectEventSignal(event_enum: EventName, callable: Callable) -> bool:
	match event_enum:
		EventName.GAME_START:
			game_start_signal.disconnect(callable)
		EventName.GAME_END:
			game_end_signal.disconnect(callable)
		EventName.SUBGAME_CHOSEN:
			subgame_chosen.disconnect(callable)
		EventName.SUBGAME_LOADED:
			subgame_loaded.disconnect(callable)
		EventName.SUBGAME_PAUSED:
			subgame_paused.disconnect(callable)
		EventName.SUBGAME_RESUMED:
			subgame_resumed.disconnect(callable)
		EventName.SUBGAME_STARTED:
			subgame_started.disconnect(callable)
		EventName.SUBGAME_OVER:
			subgame_over.disconnect(callable)
		EventName.PLAYER_SCORED:
			player_scored.disconnect(callable)
		EventName.PLAYER_SCORE_ADDED:
			player_score_added.disconnect(callable)
		EventName.PLAYER_TURN_TIMEOUT:
			player_turn_timeout.disconnect(callable)
		EventName.PLAYER_UI_CLICKED:
			player_ui_clicked.disconnect(callable)
		EventName.SHOP_ITEM_PURCHASED:
			shop_item_purchased.disconnect(callable)
		EventName.SHOP_ITEM_EQUIPPED:
			shop_item_equipped.disconnect(callable)
		EventName.MENU_ENTERED:
			menu_entered.disconnect(callable)
		EventName.PLAY_AGAIN_CALLED:
			play_again_called.disconnect(callable)
		EventName.GAME_OVER:
			game_over.disconnect(callable)
		EventName.PLAY_STARTED:
			play_started.disconnect(callable)
		_:
			push_warning("No signal disconnection implemented for event: " + str(event_enum))
			return false
	return true
