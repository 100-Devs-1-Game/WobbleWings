extends Node

## Centralized upgrade manager for all game upgrades
## Provides a single source of truth for all upgrade values

# Upgrade values - these will be set by the upgrade system
var startingLives: int = 1
var maxLives: int = 5  # Maximum possible lives 

var appearingGems:int = 2
var maxGems: int = 7  # Maximum possible gems upgrade level


var finalUpgrade := false

# Upgrade level tracking
var upgradeLevels: Dictionary = {}

# Signals for when upgrades change
signal upgrade_changed(upgrade_id: String, new_level: int)

func _ready() -> void:
	# Load saved upgrade levels
	LoadUpgradeLevels()
	
	# Apply loaded upgrades
	ApplyUpgradeLevels()

## Get the current level of an upgrade
func GetUpgradeLevel(upgrade_id: String) -> int:
	return upgradeLevels.get(upgrade_id, 0)

## Set the level of an upgrade
func SetUpgradeLevel(upgrade_id: String, level: int) -> void:
	upgradeLevels[upgrade_id] = level
	upgrade_changed.emit(upgrade_id, level)
	ApplyUpgradeLevels()
	SaveUpgradeLevels()

## Apply all upgrade levels to game values
func ApplyUpgradeLevels() -> void:
	# Apply lives upgrade
	startingLives = 1 + GetUpgradeLevel("lives")
	
	# Ensure we don't exceed max lives
	if startingLives > maxLives:
		startingLives = maxLives

	# Apply gems upgrade
	appearingGems = 2 + GetUpgradeLevel("gems")
	
	# Ensure we don't exceed max gems
	if appearingGems > maxGems:
		appearingGems = maxGems
	
	# Apply final upgrade
	finalUpgrade = GetUpgradeLevel("final") > 0

## Save upgrade levels to persistent storage
func SaveUpgradeLevels() -> void:
	GM.saveLoad.SaveJSON(SaveKeys.UPGRADE_LEVELS, upgradeLevels)

## Load upgrade levels from persistent storage
func LoadUpgradeLevels() -> void:
	upgradeLevels = GM.saveLoad.LoadJSON(SaveKeys.UPGRADE_LEVELS, {})

func ResetUpgradeLevels() -> void:
	GM.saveLoad.DeleteFile(SaveKeys.UPGRADE_LEVELS)
	upgradeLevels = {}
	ApplyUpgradeLevels()
