extends MAIN

@onready var stateChartDebug = %StateChartDebugger
@onready var shop:PanelContainer = $GlobalUI/MainUI/Shop
@onready var sound_main: Control = $GlobalUI/MainUI/SoundMain
@onready var gems_label: Label = %GemsLabel

@onready var credits: Control = $GlobalUI/MainUI/Credits
@onready var credits_crawl: PanelContainer = $GlobalUI/MainUI/Credits/CreditsCrawl
@onready var achievement_button: TextureButton = $GlobalUI/MainUI/AchievementButton
@onready var achievements: PanelContainer = $GlobalUI/MainUI/Achievements
@onready var thanks_for_playing: Label = $GlobalUI/MainUI/ThanksForPlaying

var gems:int = 0:
	set(val):
		gems = val
		if gems_label:
			gems_label.text = "x " + str(gems)
		SaveGemScore()

var highScore:int = 0

func _ready() -> void:
	super()
	GM.events.player_scored.connect(_OnPlayerScored)
	GM.events.play_started.connect(_OnPlayStarted)
	GM.events.menu_entered.connect(_onMenuEntered)
	GM.events.game_data_delete_requested.connect(_OnGameDataDeleteRequested)
	GM.events.upgrade_purchased.connect(_onUpgradePurchased)
	# Load saved gem gems
	LoadGemScore()
	
	
func _onMenuEntered() -> void:
	shop.show()
	sound_main.show()
	credits.show()
	achievement_button.show()
	thanks_for_playing.visible = GameUpgrades.finalUpgrade
	

	LoadHighScore()
	%Highscore.text = "Highscore: " + str(highScore)

func _OnPlayerScored(amount:int) -> void:
	gems += amount

func SetStateChartDebug(chart:BaseGameStateChart):
	stateChartDebug.debug_node(chart)

func _OnPlayStarted() -> void:
	shop.hide()
	sound_main.hide()
	credits.hide()
	achievement_button.hide()
	achievements.hide()
	thanks_for_playing.hide()

func _onUpgradePurchased(item:MultiLevelUpgradeData):
	if item.upgradeId == "final":
		thanks_for_playing.show()

## Saves the current gem gems to persistent storage
func SaveGemScore() -> void:
	GM.saveLoad.SaveInt(SaveKeys.GEM_SCORE, gems)

## Loads the saved gem gems from persistent storage
func LoadGemScore() -> void:
	gems = GM.saveLoad.LoadInt(SaveKeys.GEM_SCORE, 0)

func _OnGameDataDeleteRequested() -> void:
	ResetAllGameData()

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("delete_all"):
		GM.events.GameDataDeleteRequested()
	elif event.is_action_pressed("motherload"):
		gems = 999999

## DEBUG: Resets all game data and reloads the game
func ResetAllGameData() -> void:
	# Reset all save data through BooSaveLoad
	GM.saveLoad.ResetAllGameData()
	
	# Reset current gems
	gems = 0
	# Reset upgrade levels
	GameUpgrades.ResetUpgradeLevels()
	# Reload the current scene
	get_tree().reload_current_scene()

#region Credits
func _on_credits_btn_pressed() -> void:
	credits_crawl.show()

func _on_credits_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		credits_crawl.hide()
#endregion


## Saves the high gems to persistent storage
func SaveHighScore() -> void:
	GM.saveLoad.SaveInt(SaveKeys.OBSTACLE_HIGH_SCORE, highScore)

## Loads the saved high gems from persistent storage
func LoadHighScore() -> void:
	highScore = GM.saveLoad.LoadInt(SaveKeys.OBSTACLE_HIGH_SCORE, 0)
