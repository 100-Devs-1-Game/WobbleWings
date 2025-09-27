class_name ShopItem extends BaseShopItem

@export var data: ShopItemData = null
var _needs_display_update: bool = false
@export var isPurchased: bool = false:
	set(value):
		isPurchased = value
		_needs_display_update = true
		if is_inside_tree():
			call_deferred("_update_display_if_needed")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func get_data() -> Resource:
	return data

func get_data_color() -> Color:
	if data and data.color:
		return data.color
	return Color.WHITE

func MarkSelected(itemId:String) -> void:
	if data.itemId == itemId:
		animated_sprite_2d.play(str(data.itemId))
	else:
		animated_sprite_2d.stop()

func update_display() -> void:
	super()
	
	if data.levelScn != null:
		texture_rect.show()
		animated_sprite_2d.hide()
	else:
		_UpdateCostumeItem()
	
	update_button_state()

func _UpdateCostumeItem() -> void:
	animated_sprite_2d.play(str(data.itemId))
	animated_sprite_2d.stop()
	# animated_sprite_2d.show()
	# texture_rect.hide()


func get_button_text() -> String:
	if not data:
		return ""
	if data.price <= 0 or isPurchased:
		return ""
	return str(data.price)

func is_button_disabled() -> bool:
	return false

func get_description() -> String:
	if data and data.description:
		return data.description
	return ""

func _ready() -> void:
	super._ready()
	_update_display_if_needed()

func _update_display_if_needed() -> void:
	if _needs_display_update:
		_needs_display_update = false
		update_display()
