class_name SaveKeys extends BooSaveKeys

const GEM_SCORE := "gem_score"
const OBSTACLE_HIGH_SCORE := "obstacle_high_score"
const PURCHASED_ITEMS := "purchased_items"
const UPGRADE_LEVELS := "upgrade_levels"
const USERNAME := "username"


## Gets all key strings as an array
static func GetAllKeys() -> Array[String]:
	var arr = super()
	arr.append_array([GEM_SCORE, OBSTACLE_HIGH_SCORE, PURCHASED_ITEMS, UPGRADE_LEVELS, USERNAME])
	return arr
