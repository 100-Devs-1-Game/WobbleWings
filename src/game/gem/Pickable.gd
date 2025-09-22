class_name Pickable extends Area2D

@export var push_away_duration: float = 0.15
@export var push_away_distance: float = 8.0

var isBeingCollected := false
var _target : Node2D = null
var _fly_speed := 984.0
var _tween: Tween
var _tweenFinished := false

func _physics_process(delta: float) -> void:
	if isBeingCollected and _tweenFinished:
		var direction = (_target.global_position - global_position).normalized()
		global_position += direction * _fly_speed * delta


func PickUp(pickup_target: Node2D) -> void:
	isBeingCollected = true
	_target = pickup_target
	var away_direction = (global_position - _target.global_position).normalized()
	var away_position = global_position + away_direction * push_away_distance
	
	if _tween:
		_tween.kill()
	_tween = create_tween()
	
	# Simple linear push away
	_tween.tween_property(self, "global_position", away_position, push_away_duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

	await _tween.finished 
	_tweenFinished = true

func GetCollected() -> void:
	if _tween:
		_tween.kill()

	queue_free()


#func Appear(_initial_pos: Vector2) -> void:
	#
	## Random offset within a circle
	#var random_angle = randf() * TAU
	#var random_radius = randf_range(0, 12.0)  # Adjust radius as needed
	#var random_offset = Vector2.from_angle(random_angle) * random_radius
	#
	## Set initial spawn state
	#scale = Vector2.ZERO
	#position += random_offset
	#
	## Create spawn animation
	#var spawn_tween = create_tween()
	#spawn_tween.set_parallel(true)
	#
	## Scale pop animation
	#spawn_tween.tween_property(self, "scale", Vector2.ONE, 0.3)\
		#.set_trans(Tween.TRANS_ELASTIC)\
		#.set_ease(Tween.EASE_OUT)
	#
	## Small bounce in position
	#spawn_tween.tween_property(self, "global_position", global_position - Vector2(0, 4), 0.15)\
		#.set_trans(Tween.TRANS_CUBIC)\
		#.set_ease(Tween.EASE_OUT)
	#spawn_tween.chain().tween_property(self, "global_position", global_position, 0.15)\
		#.set_trans(Tween.TRANS_CUBIC)\
		#.set_ease(Tween.EASE_IN)
