## Use it to interface with AchievementManager instead of
## calling its API from all over the place.
extends CanvasLayer

func _ready() -> void:
	if GM.events == null:
		await GM.ready
	_ConnectGlobalEvents()

func _ConnectGlobalEvents():
	GM.events.player_scored.connect(func(amount:int):
		AchievementManager.progress_group("collect_gems", amount)
	)

func _input(event: InputEvent) -> void:
	if not AchievementManager.is_unlocked("press_space"):
		return
	if event.is_action_pressed("confirm"):
		AchievementManager.unlock_achievement("press_space")
