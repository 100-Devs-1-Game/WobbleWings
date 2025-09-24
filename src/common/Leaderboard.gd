extends Control

const ENTRY_SCN = preload("res://addons/talo/samples/leaderboards/entry.tscn")

@export var leaderboardInternalName: String = "test_board"
@export var includeArchived: bool = false

@onready var boardName: Label = %LeaderboardName
@onready var entriesContainer: VBoxContainer = %Entries
@onready var infoLabel: Label = %InfoLabel
@onready var username: TextEdit = %UsernameEntry
@onready var filterBtn: Button = %Filter

var _entriesErr: bool

func _ready() -> void:
	boardName.text = boardName.text.replace("{leaderboard}", leaderboardInternalName)

	await _LoadEntries()
	_SetEntryCount()

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
	# if _filter != "All":
	# 	entries = entries.filter(func (entry: TaloLeaderboardEntry): return entry.get_prop("team", "") == _filter)

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
	await Talo.players.identify("username", username.text)
	var score := RandomNumberGenerator.new().randi_range(0, 100)

	var user_type := "tester" if OS.is_debug_build() else "player"



	var res := await Talo.leaderboards.add_entry(leaderboardInternalName, score, {user_type = user_type})
	assert(is_instance_valid(res))
	infoLabel.text = "You scored %s points for the %s team!%s" % [score, user_type, " Your highscore was updated!" if res.updated else ""]

	_BuildEntries()
