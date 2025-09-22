## Base class for save key definitions
## Create a SaveKeys.gd file in each project that extends this class
## string constants for that game
@abstract
class_name BooSaveKeys extends Resource

const TOTAL_PLAYTIME := "total_playtime"
const MUSIC_VOLUME := "music_volume"
const SFX_VOLUME := "sfx_volume"

static func GetAllKeys() -> Array[String]:
	return [TOTAL_PLAYTIME, MUSIC_VOLUME, SFX_VOLUME]
