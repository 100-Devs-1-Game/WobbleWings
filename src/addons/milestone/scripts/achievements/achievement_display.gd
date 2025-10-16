@tool
extends Control

@export var achievement_rare_overlay: Node
@export var achievement_icon: TextureRect
@export var achievement_name: Label
@export var achievement_description: Label
@export var achievement_action_label: Label
@export var progress_container: Node
@export var achievement_progress_label: Label
@export var achievement_progress_bar: ProgressBar

var achievement_badge

var achievement_id: String:
	get:
		return achievement_id
	set(value):
		achievement_id = value
		AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)
		AchievementManager.achievement_progressed.connect(_on_achievement_progressed)
		AchievementManager.achievements_reset.connect(_on_achievements_updated)
		AchievementManager.achievements_loaded.connect(_on_achievements_updated)
		_on_achievements_updated()

func _on_achievement_unlocked(_achievement_id: String) -> void:
	if _achievement_id == self.achievement_id:
		update_achievement_display()

func _on_achievement_progressed(_achievement_id: String, _progress_amount: int) -> void:
	if _achievement_id == self.achievement_id:
		update_achievement_display()

func _on_achievements_updated() -> void:
	update_achievement_display()

func update_achievement_display() -> void:
	var achievement_resource: Achievement = AchievementManager.get_achievement_resource(achievement_id)
	var achievement: Dictionary = AchievementManager.get_achievement(achievement_id)

	achievement_name.text = achievement_resource.name
	achievement_description.text = achievement_resource.description
	achievement_icon.texture_filter = achievement_resource.icon_filter

	if achievement_resource.hidden and not achievement.unlocked:
		achievement_icon.texture_filter = CanvasItem.TextureFilter.TEXTURE_FILTER_LINEAR
		achievement_icon.texture = achievement_resource.hidden_icon
		achievement_name.text = "???"
		achievement_description.text = "This achievement is hidden."
	elif not achievement.unlocked and achievement_resource.unachieved_icon:
		achievement_icon.texture = achievement_resource.unachieved_icon
	else:
		achievement_icon.texture = achievement_resource.icon

	var grayscale = not achievement.unlocked and not achievement_resource.unachieved_icon and not achievement_resource.hidden
	achievement_icon.material.set_shader_parameter("use_grayscale", grayscale)

	progress_container.visible = achievement_resource.progressive
	
	if achievement_resource.progressive:
		achievement_progress_bar.max_value = achievement_resource.progress_goal
		achievement_progress_bar.value = int(achievement.progress)
		achievement_progress_label.text = "%s / %s" % [int(achievement.progress), achievement_resource.progress_goal]
		achievement_progress_label.visible = true


	if achievement.unlocked:
		achievement_action_label.visible = true
		if achievement.unlocked_date is float:
			achievement.unlocked_date = get_readable_date(achievement.unlocked_date)
		
		achievement_action_label.text = "Unlocked %s" % achievement.unlocked_date
		achievement_rare_overlay.visible = achievement_resource.considered_rare
	else:
		achievement_action_label.visible = false
		achievement_rare_overlay.visible = false
		if achievement_resource.hidden:
			progress_container.visible = false


func _FormatDateToCustomFormat(date_string: String) -> String:
	# Parse the date string (format: YYYY-MM-DDTHH:MM:SS)
	var parts = date_string.split("T")
	var date_part = parts[0]  # YYYY-MM-DD
	var time_part = parts[1]  # HH:MM:SS
	
	# Parse date components
	var date_components = date_part.split("-")
	var year = date_components[0]
	var month = int(date_components[1])
	var day = int(date_components[2])
	
	# Parse time components
	var time_components = time_part.split(":")
	var hour = int(time_components[0])
	var minute = time_components[1]
	
	# Convert month number to abbreviated month name
	var month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
					   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var month_name = month_names[month - 1]
	
	# Convert to 12-hour format with AM/PM
	var am_pm = "AM"
	var display_hour = hour
	if hour == 0:
		display_hour = 12
	elif hour == 12:
		am_pm = "PM"
	elif hour > 12:
		display_hour = hour - 12
		am_pm = "PM"
	
	# Format: MMM DD, YYYY, T:TT AM/PM
	return "%s %02d, %s, %d:%s %s" % [month_name, day, year, display_hour, minute, am_pm]


func get_readable_date(unix: int) -> String:
	var date_dict = Time.get_datetime_dict_from_unix_time(unix)
	var meridian: String = "AM"

	if date_dict.hour - 12 < 0:
		meridian = "AM"
	else:
		meridian = "PM"

	var hour
	hour = abs(date_dict.hour % 12)

	if hour == 0:
		hour = 12
	
	var month = get_month_name(date_dict.month, true)
	var day = date_dict.day

	return "%s %s, %s, %d:%02d %s" % [month, date_dict.day, date_dict.year, hour, date_dict.minute, meridian]


func get_month_name(month_number: int, use_short_form: bool = false) -> String:
	var month_names = [
		"January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"
	]
	if month_number >= 1 and month_number <= 12:
		if use_short_form:
			return month_names[month_number - 1].left(3)
		else:
			return month_names[month_number - 1]
	else:
		return "Invalid month number"
