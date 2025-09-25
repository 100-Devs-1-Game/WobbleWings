extends PanelContainer

var shopItems:Array[ShopItem] = []
var multiLevelShopItems:Array[MultiLevelShopItem] = []
@onready var item_description: Label = %ItemDescription
@onready var items_costumes: GridContainer = %ItemsCostumes
@onready var items_levels: GridContainer = %ItemsLevels
@onready var items_upgrades: GridContainer = %ItemsUpgrades
@onready var final_upgrade: MultiLevelShopItem = $VBoxContainer/ItemsUpgrades/FinalUpgrade

var _initialPosition: Vector2

func _ready() -> void:
	_initialPosition = position
	_SetupShopItems(items_costumes, shopItems, true)
	_SetupShopItems(items_levels, shopItems, true)
	_SetupShopItems(items_upgrades, multiLevelShopItems, false)

	GM.events.menu_entered.connect(Appear)

	LoadPurchasedItems()
	LoadMultiLevelUpgrades()
	# Check if final upgrade should be revealed on initial load
	_CheckAndRevealFinalUpgrade()
	Appear()

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

## Check if all costume and level items are purchased
func _CheckAllItemsPurchased() -> bool:
	# Check all costume items
	for item in items_costumes.get_children():
		if item is ShopItem and not item.isPurchased:
			return false
	
	# Check all level items  
	for item in items_levels.get_children():
		if item is ShopItem and not item.isPurchased:
			return false
	
	return true

## Check if final upgrade should be revealed and update visibility
func _CheckAndRevealFinalUpgrade() -> void:
	if _CheckAllItemsPurchased():
		_RevealFinalUpgrade()
	else:
		final_upgrade.visible = false

func _RevealFinalUpgrade() -> void:
	final_upgrade.visible = true

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
			# Check if final upgrade should be revealed after purchase
			_CheckAndRevealFinalUpgrade()
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
		GM.events.UpgradePurchased(item.data)
		GM.globalAudio.PlaySound("item_purchased")
		# Check if final upgrade should be revealed after purchase
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

#region Fun
func Appear():
	position = Vector2(650,0)
	var t = get_tree().create_tween()
	t.tween_property(self, "position", _initialPosition, .7)
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_SINE)
	t.play()
#endregion
