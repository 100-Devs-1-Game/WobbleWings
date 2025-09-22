## Applies gravity to a CharacterBody2D
class_name CB2DGravity extends CB2DBehavior

signal on_ground_reached()

@export var gravity_force: float = 980.0
@export var max_fall_speed: float = 1000.0

var _airborneCounter: int = 0

var _overrideForce: float = 0.0
var _isOverriding := false

func _physics_process_behavior(delta):
	if not _character_body or _character_body.is_on_floor():
		if _airborneCounter > 0:
			_airborneCounter = 0
			on_ground_reached.emit()
		return

	_airborneCounter += 1
	
	var velocity = _character_body.velocity
	
	velocity.y += gravity_force * delta
	
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed
	
	_character_body.velocity = velocity

func Stop():
	_character_body.velocity.y = 0
	enabled = false

func GravityOverride(force:float, duration:float):
	_overrideForce = force
	_isOverriding = true
	await get_tree().create_timer(duration).timeout
	_isOverriding = false
