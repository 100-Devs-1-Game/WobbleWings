class_name MultiLevelShopItem extends BaseShopItem

signal upgrade_pressed(MultiLevelShopItem)

@export var data: MultiLevelUpgradeData = null
@export var is_floating: bool

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var name_label: Label = $VBox/NameLabel
@onready var cost: Button = %Btn
@onready var view_control: Control = %"View Control"

var currentLevel: int = 0

func get_button_node() -> Button:
	return %Btn

func get_data() -> Resource:
	return data

func get_data_color() -> Color:
	if data and data.color:
		return data.color
	return Color.WHITE

func _physics_process(delta: float) -> void:
	if not is_floating:
		return
	
	var offset := sin(Time.get_ticks_usec() / 100_000 + position.x)
	view_control.position.y = offset

func update_display() -> void:
	if not data:
		return
		
	currentLevel = GameUpgrades.GetUpgradeLevel(data.upgradeId)
	
	# Update name label
	if name_label:
		name_label.text = data.upgradeName
	
	# Update cost label
	if cost:
		if currentLevel >= data.maxLevel:
			cost.text = "MAX"
		else:
			var price = data.GetNextLevelPrice(currentLevel)
			cost.text = str(price)
	
	if animated_sprite_2d.sprite_frames.has_animation(data.upgradeId):
		animated_sprite_2d.show()
		animated_sprite_2d.play(data.upgradeId)
		texture_rect.hide()
	else:
		animated_sprite_2d.hide()
		texture_rect.show()
		texture_rect.texture = data.icon
	
	# Update button state
	update_button_state()
	

func update_button_state() -> void:
	pass

func get_button_text() -> String:
	if not data:
		return "LOCKED"
		
	if currentLevel >= data.maxLevel:
		%Btn.hide()
		return "MAX"
	elif data.CanPurchaseLevel(currentLevel):
		var nextPrice = data.GetNextLevelPrice(currentLevel)
		return str(nextPrice)
	else:
		return "LOCKED"

func is_button_disabled() -> bool:
	if not data:
		return true
	return currentLevel >= data.maxLevel

## Set the current level (called by shop system)
func SetCurrentLevel(level: int) -> void:
	currentLevel = level
	update_display()

func on_item_pressed() -> void:
	upgrade_pressed.emit(self)

func get_description() -> String:
	if not data:
		return ""
	
	var current_level = GameUpgrades.GetUpgradeLevel(data.upgradeId)
	var level_text = "Lv." + str(current_level)
	
	if data.description:
		return data.description + " " + level_text
	else:
		return level_text
