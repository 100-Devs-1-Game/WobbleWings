class_name LeaderboardPanel
extends PanelContainer

signal fetch_ended(page: LeaderboardsAPI.EntriesPage)

const LEADERBOARD_TABLE_NAME: String = "score"
const LEADERBOARD_ITEM_SCENE: PackedScene = preload("res://game/leaderboard/TaloLeaderboardDisplay.tscn")

@onready var container: VBoxContainer = $Container

func _ready() -> void:
	await identify_async("username")
	var page := await fetch_async()
	update_leaderboard(page.entries)

func identify_async(username: String) -> TaloPlayer:
	const SERVICE_NAME := "game"
	var talo_player := await Talo.players.identify(SERVICE_NAME, username)
	
	if talo_player:
		await make_entry_async(0)
	
	return talo_player

func make_entry_async(score: float) -> void:
	await Talo.leaderboards.add_entry(LEADERBOARD_TABLE_NAME, score)

func fetch_async() -> LeaderboardsAPI.EntriesPage:
	var options := Talo.leaderboards.GetEntriesOptions.new()
	options.page = 0
	var page := await Talo.leaderboards.get_entries(LEADERBOARD_TABLE_NAME)
	fetch_ended.emit(page)
	return page

func update_leaderboard(entries: Array[TaloLeaderboardEntry]) -> void:
	for child in container.get_children():
		child.queue_free()
	
	for entry in entries:
		var display := LEADERBOARD_ITEM_SCENE.instantiate() as TaloLeaderboardDisplay
		container.add_child(display)
		display.update(entry)
