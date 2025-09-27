extends Control

signal loaded_entries(user:String)
signal username_saved(user:String)

const ENTRY_SCN = preload("res://addons/talo/samples/leaderboards/entry.tscn")

@export var activateOnStart := true
@export var leaderboardInternalName: String = "score"
@export var includeArchived: bool = false

@onready var boardName: Label = %LeaderboardName
@onready var entriesContainer: VBoxContainer = %Entries
@onready var infoLabel: Label = %InfoLabel
@onready var usernameEntry: TextEdit = %UsernameEntry
@onready var user_h_box: HBoxContainer = $MarginContainer/VBoxContainer/Username/User_HBox
@onready var username_info: Label = $MarginContainer/VBoxContainer/Username/UsernameInfo
@onready var filterBtn: Button = %Filter

var _entriesErr: bool
var savedUsername: String = ""

func _ready() -> void:
	GM.events.game_data_delete_requested.connect(_onGameDataDeleteRequested)
	boardName.text = boardName.text.replace("{leaderboard}", leaderboardInternalName)

	# Check if we have a saved username
	savedUsername = GM.saveLoad.LoadString(SaveKeys.USERNAME)
	if savedUsername != "":
		user_h_box.visible = false
		username_info.text = "Playing as " + savedUsername
		username_info.visible = true

	if not activateOnStart and OS.is_debug_build():
		return

	if savedUsername != "":
		await Talo.players.identify("usernameEntry", savedUsername)

	await _LoadEntries()
	_SetEntryCount()
	loaded_entries.emit(savedUsername)

func Show():
	show()
	usernameEntry.grab_focus()
	

func SubmitScore(score: int) -> void:
	if not activateOnStart and OS.is_debug_build():
		return
	var user_type := "tester" if OS.is_debug_build() else "player"

	var res := await Talo.leaderboards.add_entry(leaderboardInternalName, score, {user_type = user_type})
	assert(is_instance_valid(res))
	print("Submitted score: ", score, " for user: ", user_type, " Updated: ", res.updated)

	_BuildEntries()

func _onGameDataDeleteRequested() -> void:
	if savedUsername == "":
		return
	
	Talo.players.clear_identity()


func _LoadEntries() -> void:
	var page := 0
	var done := false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		options.include_archived = includeArchived

		var res := await Talo.leaderboards.get_entries(leaderboardInternalName, options)

		if not is_instance_valid(res):
			_entriesErr = true
			return

		# var entries := res.entries
		var is_last_page := res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

	_BuildEntries()

func _BuildEntries() -> void:
	for child in entriesContainer.get_children():
		child.queue_free()

	var entries = Talo.leaderboards.get_cached_entries(leaderboardInternalName)

	for entry in entries:
		entry.position = entries.find(entry)
		_CreateEntry(entry)

func _CreateEntry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance = ENTRY_SCN.instantiate()
	entry_instance.set_data(entry)
	entriesContainer.add_child(entry_instance)

func _SetEntryCount():
	if entriesContainer.get_child_count() == 0:
		infoLabel.text = "No entries yet!" if not _entriesErr else "Failed loading leaderboard %s. Does it exist?" % leaderboardInternalName
	else:
		infoLabel.text = "%s entries" % entriesContainer.get_child_count()
		# if _filter != "All":
		# 	infoLabel.text += " (%s team)" % _filter

func _on_submit_pressed() -> void:
	user_h_box.visible = false
	username_info.text = "Adding User..."


	await Talo.players.identify("usernameEntry", usernameEntry.text)
	# var user_type := "tester" if OS.is_debug_build() else "player"
	GM.saveLoad.SaveString(SaveKeys.USERNAME, usernameEntry.text)

	# var res := await Talo.leaderboards.add_entry(leaderboardInternalName, score, {user_type = user_type})
	# assert(is_instance_valid(res))
	# infoLabel.text = "You scored %s points for the %s team!%s" % [score, user_type, " Your highscore was updated!" if res.updated else ""]

	# Hide the input box and show the username info
	user_h_box.visible = false
	username_info.text = "Playing as " + usernameEntry.text
	username_info.visible = true

	username_saved.emit(usernameEntry.text)

	_BuildEntries()

func _input(event: InputEvent) -> void:
	if usernameEntry.text == "":
		return
	if not usernameEntry.has_focus():
		return

	if event.is_action_pressed("ui_accept"):
		_on_submit_pressed()
