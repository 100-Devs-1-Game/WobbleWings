## Generic save/load system for the game
## Provides centralized methods for saving and loading data to/from persistent storage
##NOTE: For each project, create a SaveKeys.gd file that extends BooSaveKeys and add the keys to the class
class_name BooSaveLoad extends Node

@export var saveKeys: SaveKeys

var _registered_keys: Array[String] = [] ##Currently only used for signaling out name of deleted keys.

func _ready() -> void:
	if saveKeys and saveKeys.has_method("GetAllKeys"):
		for key_string in SaveKeys.GetAllKeys():
			_RegisterKey(key_string)

func SaveInt(key, value: int) -> void:
	var key_string = _GetKeyString(key)
	_RegisterKey(key_string)
	_WriteToFile(key_string, value, FileAccess.WRITE)
	_EmitSaveSignal(value)

func LoadInt(key, default_value: int = 0) -> int:
	var key_string = _GetKeyString(key)
	var value = _ReadFromFile(key_string, default_value, FileAccess.READ)
	_EmitLoadSignal(value)
	return value

func SaveString(key, value: String) -> void:
	var key_string = _GetKeyString(key)
	_RegisterKey(key_string)
	_WriteToFile(key_string, value, FileAccess.WRITE)
	_EmitSaveSignal(value)

func LoadString(key, default_value: String = "") -> String:
	var key_string = _GetKeyString(key)
	var value = _ReadFromFile(key_string, default_value, FileAccess.READ)
	_EmitLoadSignal(value)
	return value

func SaveFloat(key, value: float) -> void:
	var key_string = _GetKeyString(key)
	_RegisterKey(key_string)
	_WriteToFile(key_string, value, FileAccess.WRITE)
	_EmitSaveSignal(value)

func LoadFloat(key, default_value: float = 0.0) -> float:
	var key_string = _GetKeyString(key)
	var value = _ReadFromFile(key_string, default_value, FileAccess.READ)
	_EmitLoadSignal(value)
	return value

func SaveJSON(key, value) -> void:
	var key_string = _GetKeyString(key)
	_RegisterKey(key_string)
	_WriteToFile(key_string, JSON.stringify(value), FileAccess.WRITE)
	_EmitSaveSignal(value)

func LoadJSON(key, default_value = null):
	var key_string = _GetKeyString(key)
	var json_string = _ReadFromFile(key_string, "{}", FileAccess.READ)
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		var value = json.data
		_EmitLoadSignal(value)
		return value
	else:
		_EmitLoadSignal(default_value)
		return default_value

func SaveConfig(key, section: String, property: String, value) -> void:
	var key_string = _GetKeyString(key)
	_RegisterKey(key_string)
	_WriteToConfigFile(key_string, section, property, value)
	_EmitSaveSignal(value)

func LoadConfig(key, section: String, property: String, default_value = null):
	var key_string = _GetKeyString(key)
	var value = _ReadFromConfigFile(key_string, section, property, default_value)
	_EmitLoadSignal(value)
	return value


#region File Operations
func FileExists(key) -> bool:
	var key_string = _GetKeyString(key)
	return FileAccess.file_exists("user://" + key_string + ".save")

func DeleteFile(key) -> bool:
	var key_string = _GetKeyString(key)
	var file_path = "user://" + key_string + ".save"
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		_EmitDeleteSignal(key_string)
		return true
	return false

func DeleteFiles(keys: Array[String]) -> void:
	for key in keys:
		DeleteFile(key)
	_EmitDeleteSignal(keys)


func ResetAllGameData() -> void:
	print("DEBUG: Resetting all game data...")
	
	for key in _registered_keys:
		if DeleteFile(key):
			print("Deleted: ", key)
	

	if AchievementManager:
		AchievementManager.reset_achievements()
		
	_EmitDeleteSignal(_registered_keys)
	print("All save data has been reset.")
#endregion

#region Private Methods
func _RegisterKey(key: String) -> void:
	if not key in _registered_keys:
		_registered_keys.append(key)

func _GetKeyString(key) -> String:
	if key is String:
		return key
	else:
		push_error("Invalid key type. Expected String, got: " + str(typeof(key)))
		return ""


func _WriteToFile(key: String, value, mode: FileAccess.ModeFlags) -> void:
	var file_path = "user://" + key + ".save"
	var save_file = FileAccess.open(file_path, mode)
	if save_file:
		if value is int:
			save_file.store_32(value)
		elif value is String:
			save_file.store_string(value)
		elif value is float:
			save_file.store_float(value)
		save_file.close()

func _ReadFromFile(key: String, default_value, mode: FileAccess.ModeFlags):
	var file_path = "user://" + key + ".save"
	if FileAccess.file_exists(file_path):
		var save_file = FileAccess.open(file_path, mode)
		if save_file:
			var value
			if default_value is int:
				value = save_file.get_32()
			elif default_value is String:
				value = save_file.get_as_text()
			elif default_value is float:
				value = save_file.get_float()
			save_file.close()
			return value
	return default_value

func _EmitSaveSignal(value) -> void:
	GM.events.game_saved.emit(value)

func _EmitLoadSignal(value) -> void:
	GM.events.game_loaded.emit(value)

func _EmitDeleteSignal(data) -> void:
	GM.events.game_data_deleted.emit(data)

func _WriteToConfigFile(key: String, section: String, property: String, value) -> void:
	var file_path = "user://" + key + ".cfg"
	var config = ConfigFile.new()
	
	# Load existing config if it exists
	if FileAccess.file_exists(file_path):
		var err = config.load(file_path)
		if err != OK:
			print("❌Could not load existing config file: ", file_path)
	
	# Set the value
	config.set_value(section, property, value)
	
	# Save the config
	var err = config.save(file_path)
	if err != OK:
		push_error("Failed to save config file: " + file_path)
	else:
		print("Config file saved: ", file_path)

func _ReadFromConfigFile(key: String, section: String, property: String, default_value):
	var file_path = "user://" + key + ".cfg"
	
	if not FileAccess.file_exists(file_path):
		print("❌Config file does not exist: ", file_path)
		return default_value
	
	var config = ConfigFile.new()
	var err = config.load(file_path)
	if err != OK:
		print("❌Could not load config file: ", file_path, " Error: ", err)
		return default_value
	
	if config.has_section_key(section, property):
		var value = config.get_value(section, property)
		print("✅Loaded: ", section, ".", property, " = ", value)
		return value
	else:
		print("Config section/property not found: ", section, ".", property)
		return default_value
#endregion
