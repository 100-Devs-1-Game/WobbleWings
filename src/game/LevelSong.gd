class_name LevelSong extends Resource

@export var intro:AudioStream
@export var loop:AudioStream
@export var bpm:float = 120.0 ## Beats per minute for timing calculations
@export var intro_beats:float = 8.0 ## Number of beats in the intro before loop should start
@export var introDuration:float = -1.0 ## Duration of the intro in seconds
