## Base class for all shop items that consolidates common functionality
class_name BaseShopItem extends PanelContainer


signal item_pressed(BaseShopItem)
signal mouse_entered_item(BaseShopItem)
signal mouse_exited_item(BaseShopItem)

@onready var btn: Button = get_button_node()
@onready var texture_rect: TextureRect = %TextureRect

## Override this in subclasses to specify the button node path
func get_button_node() -> Button:
	return $Btn

## Override this in subclasses to get the data object
func get_data() -> Resource:
	return null

## Override this in subclasses to get the color from data
func get_data_color() -> Color:
	var data = get_data()
	if data and data.has_method("get") and data.get("color"):
		return data.color
	return Color.WHITE

## Override this in subclasses to update display
func update_display() -> void:
	var data = get_data()
	if data and data.icon:
		texture_rect.texture = data.icon

## Override this in subclasses to get button text
func get_button_text() -> String:
	return ""

## Override this in subclasses to check if button should be disabled
func is_button_disabled() -> bool:
	return false

func _ready() -> void:
	# Set up button connection
	if btn and not btn.pressed.is_connected(_on_btn_pressed):
		btn.pressed.connect(_on_btn_pressed)
	
	# Set up mouse enter/exit connections
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	
	# Set background color
	setup_background_color()
	
	# Update display
	update_display()

## Set up the background color from data
func setup_background_color() -> void:
	var color = get_data_color()
	if color != Color.WHITE:
		var style_box = get_theme_stylebox("panel")
		if style_box and style_box is StyleBoxFlat:
			var new_style_box = style_box.duplicate()
			new_style_box.bg_color = color
			add_theme_stylebox_override("panel", new_style_box)

## Update button state
func update_button_state() -> void:
	if btn:
		btn.text = get_button_text()
		btn.disabled = is_button_disabled()

func _on_btn_pressed() -> void:
	item_pressed.emit(self)
	# Allow subclasses to emit their own signals
	on_item_pressed()

## Override this in subclasses to emit specific signals
func on_item_pressed() -> void:
	pass

## Override this in subclasses to get the description from data
func get_description() -> String:
	var data = get_data()
	if data and data.has_method("get") and data.get("description"):
		return data.description
	return ""

func _on_mouse_entered() -> void:
	mouse_entered_item.emit(self)

func _on_mouse_exited() -> void:
	mouse_exited_item.emit(self)
