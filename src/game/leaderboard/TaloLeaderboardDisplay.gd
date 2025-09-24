class_name TaloLeaderboardDisplay
extends PanelContainer

@onready var position_label: Label = %"Position Label"
@onready var player_name: Label = %"Player Name"
@onready var score: Label = %Score

func update(target: TaloLeaderboardEntry) -> void:
	position_label.text = "#%s" % target.position
	player_name.text = target.player_alias.identifier
	score.text = str(target.score)
