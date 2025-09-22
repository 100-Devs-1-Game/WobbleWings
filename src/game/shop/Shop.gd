extends PanelContainer

var shopItems:Array[ShopItem] = []
var multiLevelShopItems:Array[MultiLevelShopItem] = []
@onready var item_description: Label = $VBoxContainer/ItemDescription
@onready var items_costumes: GridContainer = %ItemsCostumes
@onready var items_levels: GridContainer = %ItemsLevels
@onready var items_upgrades: GridContainer = %ItemsUpgrades

func _ready() -> void:
	_SetupShopItems(items_costumes, shopItems, true)
	_SetupShopItems(items_levels, shopItems, true)
	_SetupShopItems(items_upgrades, multiLevelShopItems, false)

	LoadPurchasedItems()
	LoadMultiLevelUpgrades()

## Setup shop items with common signal connections
func _SetupShopItems(container: GridContainer, target_array: Array, is_regular_shop_item: bool) -> void:
	for item in container.get_children():
		target_array.append(item)
		if is_regular_shop_item:
			item.item_pressed.connect(_OnItemClicked)
		else:
			item.upgrade_pressed.connect(_OnMultiLevelUpgradeClicked)
		item.mouse_entered_item.connect(_OnItemHovered)
		item.mouse_exited_item.connect(_OnItemUnhovered)
		item.update_display()

## Handle item click - purchase if not owned, equip if owned
func _OnItemClicked(item:ShopItem) -> void:
	if item.isPurchased:
		GM.events.ShopItemEquipped(item.data)
	else:
		if GM.main.gems >= item.data.price:
			GM.events.ShopItemPurchased(item.data)
			item.isPurchased = true
			GM.main.gems -= item.data.price
			GM.globalAudio.PlaySound("item_purchased")
			SavePurchasedItems()
		else:
			print("not enough score")


## Handle multi-level upgrade click
func _OnMultiLevelUpgradeClicked(item:MultiLevelShopItem) -> void:
	if not item.data:
		return
		
	var currentLevel = GameUpgrades.GetUpgradeLevel(item.data.upgradeId)
	
	# Check if upgrade is already at maximum level
	if currentLevel >= item.data.maxLevel:
		print("Upgrade ", item.data.upgradeName, " is already at maximum level")
		return
	
	# Check if the level can be purchased
	if not item.data.CanPurchaseLevel(currentLevel):
		print("Cannot purchase level for ", item.data.upgradeName)
		return
	
	var nextPrice = item.data.GetNextLevelPrice(currentLevel)
	
	if GM.main.gems >= nextPrice:
		# Purchase the upgrade
		GameUpgrades.SetUpgradeLevel(item.data.upgradeId, currentLevel + 1)
		GM.main.gems -= nextPrice
		item.update_display()
		print("Purchased ", item.data.upgradeName, " level ", currentLevel + 1)
		
		GM.globalAudio.PlaySound("item_purchased")
	else:
		print("Not enough score for ", item.data.upgradeName)

	#Updated level	
	item_description.text = item.get_description()

## Load multi-level upgrade states
func LoadMultiLevelUpgrades() -> void:
	for item in multiLevelShopItems:
		if item.data:
			item.update_display()

## Handle item hover - update description
func _OnItemHovered(item:BaseShopItem) -> void:
	if item_description and item:
		item_description.text = item.get_description()

## Handle item unhover - clear description
func _OnItemUnhovered(_item:BaseShopItem) -> void:
	if item_description:
		item_description.text = ""


#region Save/Load
## Save purchased items to persistent storage
func SavePurchasedItems() -> void:
	var purchased_ids = []
	for item in shopItems:
		if item.isPurchased:
			purchased_ids.append(item.data.itemId)
	GM.saveLoad.SaveJSON(SaveKeys.PURCHASED_ITEMS, purchased_ids)

## Load purchased items from persistent storage
func LoadPurchasedItems() -> void:
	var purchased_ids = GM.saveLoad.LoadJSON(SaveKeys.PURCHASED_ITEMS, [])
	
	for item in shopItems:
		if item.data.itemId in purchased_ids:
			item.isPurchased = true

#endregion
