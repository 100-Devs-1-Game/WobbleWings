extends CanvasLayer

const SCREEN_WIDTH:int = 640
const MIN_OBSTACLE_SEPARATION:float = 280

#region settings

@export var levelSongs:Array[LevelSong] = []
@onready var introTimer: Timer = Timer.new()


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
@export var minPipeSeparation = 370
@export var maxPipeSeparation = 382


@export_group("Spawn rate settings")
@export var minSpawnRate:float = .5
@export var maxSpawnRate:float = 1.5

@export_group("Lives opacity settings")
@export var livesFadeDuration: float = 5.0  # Total duration: 20% hold at full opacity, 80% fade to transparent
@export var minLivesOpacity: float = 0.0  # Minimum opacity for lives display
@export var livesShakeIntensity: float = 10.0  # How much the lives shake when damage is taken
@export var livesShakeDuration: float = 0.3  # How long the shake lasts

@export_group("Firefly spawn settings")
@export var fireflySpawnRate: float = 3.0 
@export var fireflySpawnChance: float = 0.7 
@export var fireflyPoolSize: int = 10 ## Maximum number of fireflies in the pool
#endregion

var lifeIconScn:PackedScene = preload("res://game/LifeIcon.tscn")
var currentLevel:int = 0

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

@onready var frog_cheerleader: AnimatedSprite2D = $CanvasLayer/FrogCheerleader

var currentRunGems:int = 0
var currentSeparation:float = maxPipeSeparation
var obstacleDodgeCount:int = 0:
	set(val):
		obstacleDodgeCount = val
		score_label.text = str(obstacleDodgeCount)
		if obstacleDodgeCount == 1:
			frog_cheerleader.Cheer1(obstacleDodgeCount)
		_CheckForCheer()
			

var _lastObstacleX:float = 0.0

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

@export var firefly:PackedScene
@onready var foreground_space: Node2D = $World/ForegroundSpace
@onready var firefly_timer: Timer

@onready var streamIntro: BooStreamPlayer = $BgStreamPlayer
@onready var streamLoop: BooStreamPlayer = $BgStreamIntro

var livesTween: Tween = null

# Firefly pooling system
var _fireflyPool: Array[Node2D] = []
var _activeFireflies: Array[Node2D] = []


func _ready() -> void:
	add_child(introTimer)

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
	
	# Setup firefly timer and pool
	_SetupFireflyTimer()
	_SetupFireflyPool()
	_SetLevelSong(0)



func _OnMenuEntered() -> void:
	print("Final Upgrade: ", GameUpgrades.finalUpgrade)
	score.hide()

func _OnShopItemSelected(item:ShopItemData) -> void:
	if item.type == ShopItemData.Type.LEVEL and item.levelScn:
		for child in background_space.get_children():
			child.queue_free()
		var level_scn = item.levelScn.instantiate()

		currentLevel = int(item.itemId) - 4 #Gives 0, 1 or 2
		background_space.add_child(level_scn)
		_SetLevelSong(currentLevel)


#region Song
func _SetLevelSong(level:int) -> void:
	if not introTimer.is_stopped():
		introTimer.stop()
	var level_song = levelSongs[level]
	streamIntro.stop()
	streamLoop.stop()
	streamIntro.stream = level_song.intro
	streamLoop.stream = level_song.loop
	
	# Calculate intro duration based on BPM and beat count
	if level_song.introDuration > 0:
		introTimer.wait_time = level_song.introDuration
	else:
		introTimer.wait_time = _CalculateIntroDuration(level_song.bpm, level_song.intro_beats)
	introTimer.start()
	
	# Start intro
	streamIntro.play()
	
	await introTimer.timeout
	streamLoop.play()

func _CalculateIntroDuration(bpm: float, intro_beats: float) -> float:
	# Calculate duration in seconds: (beats / bpm) * 60 seconds per minute
	return (intro_beats / bpm) * 60.0

#endregion

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

func _OnGameOver(_score:int) -> void:
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
	obstacle.SetupScalingAmount(minPipeSeparation, maxPipeSeparation)
	
	# Calculate base position
	var base_x = player.global_position.x + SCREEN_WIDTH + 40
	
	# Ensure minimum separation from last obstacle
	var min_x = _lastObstacleX + MIN_OBSTACLE_SEPARATION
	obstacle.global_position.x = maxf(base_x, min_x)
	
	# Update last obstacle position for next spawn
	_lastObstacleX = obstacle.global_position.x
	
	#Oscillation check first to determine separation
	var oscillation_chance = _CalculateOscillationChance()
	var is_oscillating = randf() < oscillation_chance
	
	#Closing behavior check
	var closing_chance = _CalculateClosingChance()
	var is_closing = randf() < closing_chance
	
	var separation_amount = currentSeparation
	if is_oscillating:
		separation_amount = minf(currentSeparation, maxPipeSeparation)
	obstacle.SetSeparation(separation_amount)
	
	#Set oscillation speed if oscillating
	if is_oscillating:
		obstacle.oscillationSpeed = _CalculateOscillationSpeed()
		obstacle.randomize_time()
	
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


#region FireFly
func _SetupFireflyTimer() -> void:
	firefly_timer = Timer.new()
	firefly_timer.wait_time = fireflySpawnRate
	firefly_timer.autostart = true
	firefly_timer.timeout.connect(_OnFireflyTimerTimeout)
	add_child(firefly_timer)

func _SetupFireflyPool() -> void:
	if not firefly:
		return
	
	# Create all fireflies upfront and add them to the pool
	for i in range(fireflyPoolSize):
		var firefly_instance = firefly.instantiate()
		foreground_space.add_child(firefly_instance)
		
		# Disable the firefly initially
		firefly_instance.visible = false
		firefly_instance.process_mode = Node.PROCESS_MODE_DISABLED
		
		# Connect to animation finished signal to return to pool
		if firefly_instance.has_signal("animation_finished"):
			firefly_instance.animation_finished.connect(_OnFireflyAnimationFinished.bind(firefly_instance))
		
		_fireflyPool.append(firefly_instance)

func _OnFireflyTimerTimeout() -> void:
	if randf() < fireflySpawnChance:
		_SpawnFirefly()

func _SpawnFirefly() -> void:
	if currentLevel != 0:
		return

	# Get a firefly from the pool
	var firefly_instance = _GetFireflyFromPool()
	if not firefly_instance:
		return # Pool is empty
	
	# Position firefly in world space relative to player's current position
	var screen_size = get_viewport().get_visible_rect().size
	var player_pos = player.global_position + Vector2.RIGHT * 200
	
	# Spawn firefly within screen bounds relative to player position
	var spawn_x = player_pos.x + randf_range(-screen_size.x * 0.5, screen_size.x * 0.5)
	var spawn_y = player_pos.y + randf_range(-screen_size.y * 0.5, screen_size.y * 0.5)
	
	# Activate the firefly
	firefly_instance.global_position = Vector2(spawn_x, spawn_y)
	firefly_instance.visible = true
	firefly_instance.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Reset animation to start from beginning
	if firefly_instance.has_method("play"):
		firefly_instance.play("default")
	
	# Move from pool to active list
	_activeFireflies.append(firefly_instance)

func _GetFireflyFromPool() -> Node2D:
	if _fireflyPool.is_empty():
		return null
	
	return _fireflyPool.pop_back()

func _ReturnFireflyToPool(firefly_instance: Node2D) -> void:
	# Remove from active list
	_activeFireflies.erase(firefly_instance)
	
	# Disable the firefly
	firefly_instance.visible = false
	firefly_instance.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Return to pool
	_fireflyPool.append(firefly_instance)

func _OnFireflyAnimationFinished(firefly_instance: Node2D) -> void:
	# Return the firefly to the pool when animation finishes
	_ReturnFireflyToPool(firefly_instance)

func _ResetFireflyPool() -> void:
	# Return all active fireflies to the pool
	for firefly_instance in _activeFireflies.duplicate():
		_ReturnFireflyToPool(firefly_instance)
#endregion

#region helpers
func _Reset() -> void:
	currentRunGems = 0
	_ResetDifficulty()
	_ResetFireflyPool()
	_lastObstacleX = 0.0

func _ResetLivesOpacity() -> void:
	# Stop any existing tween
	if livesTween:
		livesTween.kill()
	# Create new tween with shake, then hold, then fade
	livesTween = get_tree().create_tween()
	
	# Add shake effect
	_AddShakeEffect(livesTween)
	
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

func _CheckForCheer() -> void:
	# Only check every 10 gates (10, 20, 30, etc.)
	if obstacleDodgeCount % 10 != 0:
		return
	
	# Calculate cheer chance based on current score
	var cheer_chance = _CalculateCheerChance()
	
	# Roll for cheer
	if randf() < cheer_chance:
		frog_cheerleader.Cheer1(obstacleDodgeCount)

func _CalculateCheerChance() -> float:
	# Chance increases linearly from 0% at 10 gates to 50% at 100 gates
	# Formula: (current_gates - 10) / (100 - 10) * 0.5
	# This gives us 0% at 10 gates, 50% at 100 gates, and caps at 50% beyond 100 gates
	
	if obstacleDodgeCount < 10:
		return 0.0
	
	var progress = float(obstacleDodgeCount - 10) / 90.0  # 90 is the range from 10 to 100
	var cheer_chance = progress * 0.5  # 0.5 = 50% maximum chance
	
	return minf(0.5, cheer_chance)  # Cap at 50%


#endregion

#region wip
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		pass
#endregion
