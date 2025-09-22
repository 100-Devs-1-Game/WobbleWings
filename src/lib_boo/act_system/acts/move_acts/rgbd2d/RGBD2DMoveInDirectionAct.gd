class_name RGBD2DMoveInDirectionAct extends Node2DAct

@export var body: RigidBody2D
@export var direction: Vector2 = Vector2.ZERO
@export var moveForce: float = 1

@export var isLinearVelocity:bool = false
@export var steeringForce: float = 20

var _forceUnit: float = 0.0


# Getter for the current velocity
var Velocity: Vector2:
	get: return body.linear_velocity

func _ready() -> void:
	super()
	canAct = autoStart
	if _forceUnit == 0.0:
		_GetForceUnit()

func _physics_process(delta: float) -> void:
	if !canAct:
		return
	
	Execute({"delta": delta})
	

func Execute(_parameters: Variant = null) -> Variant:
	if direction == Vector2.ZERO:
		return
	# Normalize the direction vector
	var normalized_direction: Vector2 = direction.normalized()
	
	if isLinearVelocity:
		# Set velocity directly for immediate movement
		var target_velocity: Vector2 = normalized_direction * (moveForce * _forceUnit)
		body.linear_velocity = target_velocity
	else:
		# Apply force in the specified direction for organic movement
		var desired_velocity: Vector2 = normalized_direction * (moveForce * _forceUnit)
		var steering: Vector2 = (desired_velocity - body.linear_velocity) * steeringForce
		
		if _parameters is Dictionary and _parameters["delta"]:
			body.apply_central_force(steering * _parameters.delta * _forceUnit)
		else:
			body.apply_central_force(steering * _forceUnit)
	return null 

func _GetForceUnit() -> void:
	var forceU = ProjectSettings.get_setting("global/force_unit")
	if forceU == null:
		pass
		#push_warning("RGBD2DMoveInDirectionAct: 'global/force_unit' not found in ProjectSettings")
	else:
		_forceUnit = forceU
		return
	_forceUnit = 1.0

func Stop(should_stop_immediately:bool = false) -> Tween:
	canAct = false
	if should_stop_immediately:
		body.linear_velocity = Vector2.ZERO
		return null
	else:
		var tween = create_tween()
		tween.tween_property(body, "linear_velocity", Vector2.ZERO, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		return tween
