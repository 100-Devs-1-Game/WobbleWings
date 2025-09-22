extends CanvasLayer

const SCREEN_WIDTH:int = 640

#region settings

@export var increaseDifficultyThreshold:int = 3 ## After how many points does the difficulty start increasing
@export var minPlayerSpd:float = 224.0

@export_group("Oscillation settings")
@export var maxOscillationChance: float = 1.0 
@export var oscillationChanceIncrease: float = .05  # How much chance increases per score point
@export var minOscillationSpeed: float = 0.5
@export var maxOscillationSpeed: float = 2.0
@export var oscillationSpeedIncrease: float = 0.1  # How much speed increases per score point

@export_group("Closing behavior settings")
@export var maxClosingChance: float = 0.6  # Maximum chance (60%) for closing behavior
@export var closingChanceIncrease: float = 0.04  # How much chance increases per score point
@export var minClosingSpeed: float = 0.3
@export var maxClosingSpeed: float = 1.5
@export var closingSpeedIncrease: float = 0.08  # How much speed increases per score point


@export_group("Pipe settings")
@export var minPipeSeparation = 372
@export var maxPipeSeparation = 412

@export_group("Pipe speed settings")
@export var minPipeSpeed:float = 200
@export var maxPipeSpeed:float = 600
@export var speedIncreaseRate:float = 20
var currentPipeSpeed:float = minPipeSpeed


@export_group("Spawn rate settings")
@export var minSpawnRate:float = .5
@export var maxSpawnRate:float = 1.5

@export_group("Lives opacity settings")
@export var livesFadeDuration: float = 5.0  # Total duration: 20% hold at full opacity, 80% fade to transparent
@export var minLivesOpacity: float = 0.0  # Minimum opacity for lives display
@export var livesShakeIntensity: float = 10.0  # How much the lives shake when damage is taken
@export var livesShakeDuration: float = 0.3  # How long the shake lasts
#endregion

var lifeIconScn:PackedScene = preload("res://game/LifeIcon.tscn")

var _currentLives = GameUpgrades.startingLives:
	set(val):
		_currentLives = val
		if _currentLives <= 0:
			lives.hide()
			game_state_chart.send_event("game_over")
		else:
			lives.show()
	get:
		return _currentLives


var currentRunGems:int = 0
var currentSeparation:float = maxPipeSeparation
var obstacleDodgeCount:int = 0:
	set(val):
		obstacleDodgeCount = val
		score_label.text = str(obstacleDodgeCount)

var _livesOriginalPosition: Vector2


@onready var game_state_chart: Node = $GameStateChart
@onready var obstacle_timer: Timer = %ObstacleTimer
@onready var controls_label: Label = %ControlsLabel
@onready var lives: HBoxContainer = %Lives
@onready var player: CharacterBody2D = $World/MainSpace/Player
@onready var background_space: Node2D = $World/BackgroundSpace
@onready var score_label: Label = %ScoreLabel
@onready var score: HBoxContainer = $CanvasLayer/Score
@onready var final_score_label: Label = $CanvasLayer/PlayAgainBtn/FinalScoreLabel

var livesTween: Tween = null


func _ready() -> void:
	GM.events.play_started.connect(_onPlayStarted)
	GM.events.player_scored.connect(_OnPlayerScored)
	GM.events.game_over.connect(_OnGameOver)
	_SetupLives()
	GM.events.menu_entered.connect(_OnMenuEntered)
	GM.events.obstacle_dodge.connect(_OnObstacleDodge)
	GM.events.shop_item_purchased.connect(_OnShopItemSelected)
	GM.events.shop_item_equipped.connect(_OnShopItemSelected)
	
	# Store original position for shake effect
	_livesOriginalPosition = lives.position


func _OnMenuEntered() -> void:
	score.hide()

func _OnShopItemSelected(item:ShopItemData) -> void:
	if item.type == ShopItemData.Type.LEVEL and item.levelScn:
		for child in background_space.get_children():
			child.queue_free()
		var level_scn = item.levelScn.instantiate()
		background_space.add_child(level_scn)


func _SetupLives() -> void:
	_currentLives = GameUpgrades.startingLives

	for child in lives.get_children():
		child.queue_free()
	
	for i in range(GameUpgrades.startingLives):
		var life_node = lifeIconScn.instantiate()
		lives.add_child(life_node)
		life_node.visible = i < _currentLives


func _onPlayStarted() -> void:
	controls_label.hide()
	player.moveSpd = minPlayerSpd
	score.show()
	_SetupLives()
	_ResetLivesOpacity()

func _OnObstacleDodge() -> void:
	obstacleDodgeCount += 1
	obstacle_timer.wait_time = maxf(minSpawnRate, maxSpawnRate - (obstacleDodgeCount * 0.05))

func _OnGameOver() -> void:
	print("currentRunGems: ", currentRunGems, "\n currentSeparation: ", currentSeparation, "\n currentPipeSpeed: ", currentPipeSpeed, "\n obstacle_timer.wait_time: ", obstacle_timer.wait_time, "\n obstacleDodgeCount: ", obstacleDodgeCount, "\n highScore: ", GM.main.highScore)
	
	print("🏁🏁🏁Game Over")


	# Check if current obstacle dodge count is a new high score
	if obstacleDodgeCount > GM.main.highScore:
		GM.main.highScore = obstacleDodgeCount
		GM.main.SaveHighScore()
		print("🎉 New high score! Obstacles dodged: ", GM.main.highScore)

	
	final_score_label.text = "Level Score: " + str(obstacleDodgeCount) +"\n"+ "High Score: " + str(GM.main.highScore)
	_Reset()
	_ResetDifficulty()
	
## Sets properties of spawned obstacles
func _on_spawner_act_done(spawnedInstances: Variant) -> void:
	var obstacle = spawnedInstances[0]
	
	obstacle.global_position.x = player.global_position.x + SCREEN_WIDTH + 40
	
	#Oscillation check first to determine separation
	var oscillation_chance = _CalculateOscillationChance()
	var is_oscillating = randf() < oscillation_chance
	
	#Closing behavior check
	var closing_chance = _CalculateClosingChance()
	var is_closing = randf() < closing_chance
	
	var separation_amount = currentSeparation
	if is_oscillating:
		separation_amount = currentSeparation + 24
	obstacle.SetSeparation(separation_amount)
	
	#Speed
	# obstacle.SetSpeed(currentPipeSpeed)
	currentPipeSpeed = minf(maxPipeSpeed, currentPipeSpeed + speedIncreaseRate)
	
	#Set oscillation speed if oscillating
	if is_oscillating:
		obstacle.oscillationSpeed = _CalculateOscillationSpeed()
	
	#Set closing speed if closing
	if is_closing:
		obstacle.closingSpeed = _CalculateClosingSpeed()


func _on_game_state_chart_took_damage(amount: int) -> void:
	_currentLives -= amount
	if lives.get_children().size()> 0:
		lives.get_child(0).queue_free()
	
	# Reset lives opacity and start fading
	if _currentLives > 0:
		_ResetLivesOpacity()


#region helpers
func _Reset() -> void:
	currentRunGems = 0
	_ResetDifficulty()

func _ResetLivesOpacity() -> void:
	# Stop any existing tween
	if livesTween:
		livesTween.kill()
	
	# Reset opacity to full and position to original center
	lives.modulate.a = 1.0
	lives.position = _livesOriginalPosition
	
	# Calculate timing: 20% hold, 80% fade
	var hold_duration = livesFadeDuration * 0.2  # 20% of total time
	var fade_duration = livesFadeDuration * 0.8  # 80% of total time
	
	# Create new tween with shake, then hold, then fade
	livesTween = get_tree().create_tween()
	
	# Add shake effect
	_AddShakeEffect(livesTween)
	
	# Then hold at full opacity
	livesTween.tween_interval(hold_duration)
	
	# Finally fade
	livesTween.tween_property(lives, "modulate:a", minLivesOpacity, fade_duration)

func _AddShakeEffect(tween: Tween) -> void:
	# Create a quick shake effect by moving the lives container
	var shake_steps = 8  # Number of shake movements
	var step_duration = livesShakeDuration / shake_steps
	
	# Calculate the actual center of the lives container
	var lives_center = _livesOriginalPosition + lives.size * 0.5
	
	for i in range(shake_steps):
		# Generate random offset for shake
		var random_offset = Vector2(
			randf_range(-livesShakeIntensity, livesShakeIntensity),
			randf_range(-livesShakeIntensity, livesShakeIntensity)
		)
		
		# Move to shake position, keeping the center in the same relative position
		var shake_position = lives_center + random_offset - lives.size * 0.5
		tween.tween_property(lives, "position", shake_position, step_duration)
	
	# Return to original position
	tween.tween_property(lives, "position", _livesOriginalPosition, step_duration)

func _ResetDifficulty() -> void:
	obstacleDodgeCount = 0
	currentSeparation = maxPipeSeparation
	currentPipeSpeed = minPipeSpeed
	obstacle_timer.wait_time = maxSpawnRate

func _OnPlayerScored(score_amount: int) -> void:
	currentRunGems += score_amount

	_IncreaseDifficulty()

func _IncreaseDifficulty() -> void:
	#Separation
	var separation_mod = 0 if obstacleDodgeCount < increaseDifficultyThreshold else obstacleDodgeCount * 2
	currentSeparation = maxf(minPipeSeparation, maxPipeSeparation - separation_mod)
	
	#Timers
	obstacle_timer.wait_time = maxf(minSpawnRate, maxSpawnRate - (obstacleDodgeCount * 0.02))

func _CalculateOscillationChance() -> float:
	# Only calculate oscillation if score is above threshold
	if obstacleDodgeCount < increaseDifficultyThreshold:
		return 0.0
	
	# Calculate chance based on current score
	var score_based_chance = (obstacleDodgeCount - increaseDifficultyThreshold) * oscillationChanceIncrease
	return minf(maxOscillationChance, score_based_chance)

func _CalculateOscillationSpeed() -> float:
	# Only calculate speed if score is above threshold
	if obstacleDodgeCount < increaseDifficultyThreshold:
		return minOscillationSpeed
	
	# Calculate speed based on difference from threshold
	var score_difference = obstacleDodgeCount - increaseDifficultyThreshold
	var score_based_speed = minOscillationSpeed + score_difference * oscillationSpeedIncrease
	return minf(maxOscillationSpeed, score_based_speed)

func _CalculateClosingChance() -> float:
	# Only calculate closing if score is above threshold
	if obstacleDodgeCount < increaseDifficultyThreshold:
		return 0.0
	
	# Calculate chance based on current score
	var score_difference = obstacleDodgeCount - increaseDifficultyThreshold
	var score_based_chance = score_difference * closingChanceIncrease
	return minf(maxClosingChance, score_based_chance)

func _CalculateClosingSpeed() -> float:
	# Only calculate speed if score is above threshold
	if obstacleDodgeCount < increaseDifficultyThreshold:
		return minClosingSpeed
	
	# Calculate speed based on difference from threshold
	var score_difference = obstacleDodgeCount - increaseDifficultyThreshold
	var score_based_speed = minClosingSpeed + score_difference * closingSpeedIncrease
	return minf(maxClosingSpeed, score_based_speed)


#endregion

#region wip
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		pass
#endregion
