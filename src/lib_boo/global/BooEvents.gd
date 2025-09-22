class_name BooEvents extends Node

signal game_start()
func GameStart() -> void:
	game_start.emit()

signal game_end()
func GameEnd() -> void:
	game_end.emit()

signal game_saved(data_saved: Variant)
func GameSaved(data_saved: Variant) -> void:
	game_saved.emit(data_saved)

signal game_loaded(data_loaded: Variant)
func GameLoaded(data_loaded: Variant) -> void:
	game_loaded.emit(data_loaded)

signal game_data_deleted(data_deleted: Variant)
func GameDataDeleted(data_deleted: Variant) -> void:
	game_data_deleted.emit(data_deleted)
