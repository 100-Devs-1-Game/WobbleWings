class_name MultiLevelUpgradeData extends Resource

## Data structure for multi-level upgrades
## Defines the upgrade ID, name, description, and pricing for each level

@export var upgradeId: String = ""
@export var upgradeName: String = ""
@export var description: String = ""
@export var color: Color = Color.WHITE
@export var icon:Texture2D = null

# Array of prices for each level (index 0 = level 1, index 1 = level 2, etc.)
@export var levelPrices: Array[int] = []

# Maximum level for this upgrade
@export var maxLevel: int = 1

## Get the price for a specific level (1-based)
func GetPriceForLevel(level: int) -> int:
	if level <= 0 or level > levelPrices.size():
		return 0
	return levelPrices[level - 1]

## Get the next level price (for current level + 1)
func GetNextLevelPrice(currentLevel: int) -> int:
	return GetPriceForLevel(currentLevel + 1)

## Check if a level can be purchased
func CanPurchaseLevel(currentLevel: int) -> bool:
	return currentLevel < maxLevel and currentLevel < levelPrices.size()

## Get the display text for the current level
func GetLevelDisplayText(currentLevel: int) -> String:
	if currentLevel >= maxLevel:
		return "MAX"
	elif currentLevel == 0:
		return "Level 1"
	else:
		return "Level " + str(currentLevel + 1)
