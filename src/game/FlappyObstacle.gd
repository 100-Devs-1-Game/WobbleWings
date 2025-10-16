extends RigidBody2D

@export var pipeOffsetRange:float = 104

@export var pipes:Array[CollisionShape2D]

@export var gemScn:PackedScene

# Movement control variables
@export var oscillationSpeed: float = 0.0
@export var oscillationType: OscillationType = OscillationType.SINE
@export var movementDirection: MovementDirection = MovementDirection.VERTICAL

# Closing behavior variables
@export var closingSpeed: float = 0.0
@export var closingRange: float = 12

enum OscillationType {
	SINE,
	COSINE,
	LINEAR
}

enum MovementDirection {
	VERTICAL,
	HORIZONTAL,
	BOTH
}

@onready var body: Node2D = $Body
@onready var gate_sprite: Node2D = %"Gate Sprite"

var _initialPosition: Vector2
var _time: float = 0.0

# Closing behavior variables
var _initialSeparation: float = 0.0
var _closingTime: float = 0.0

# Scaling behaviour variables
var _max_amount_scaling := 472
var _min_amount_scaling := 380

func _ready() -> void:
	_SpawnGems()
	
	if oscillationSpeed > 0:
		_initialPosition = body.position

func _process(delta: float) -> void:
	if oscillationSpeed > 0:
		_time += delta * oscillationSpeed
		_UpdateOscillation()
	
	if closingSpeed > 0:
		_closingTime += delta * closingSpeed
		_UpdateClosing()

func randomize_time() -> void:
	_time = randf_range(0, PI)

func _UpdateOscillation() -> void:
	var offset: float = 0.0
	
	match oscillationType:
		OscillationType.SINE:
			offset = sin(_time) * pipeOffsetRange
		OscillationType.COSINE:
			offset = cos(_time) * pipeOffsetRange
		OscillationType.LINEAR:
			# Linear oscillation using sawtooth wave
			var normalized_time = fmod(_time, 2.0 * PI)
			if normalized_time < PI:
				offset = lerp(-pipeOffsetRange, pipeOffsetRange, normalized_time / PI)
			else:
				offset = lerp(pipeOffsetRange, -pipeOffsetRange, (normalized_time - PI) / PI)
	
	var new_position = _initialPosition
	
	match movementDirection:
		MovementDirection.VERTICAL:
			new_position.y = _initialPosition.y + offset
		MovementDirection.HORIZONTAL:
			new_position.x = _initialPosition.x + offset
		MovementDirection.BOTH:
			new_position.y = _initialPosition.y + offset
			new_position.x = _initialPosition.x + offset * 0.5  # Slightly different amplitude for variety
	
	body.position = new_position

func _UpdateClosing() -> void:
	# Use sine wave to create smooth closing and opening motion
	var closing_offset = sin(_closingTime) * closingRange
	
	# Apply the closing effect to both pipes
	var amount = _initialSeparation + closing_offset
	UpdateGateSpriteScale(amount)
	pipes[0].position.y = -amount
	pipes[1].position.y = amount

func SetupScalingAmount(min: float, max: float) -> void:
	_min_amount_scaling = min
	_max_amount_scaling = max

func SetSeparation(amount:float):
	if oscillationSpeed == 0:
		SetRandomYPosition()
	else:

		SetRandomYPosition()
		# Update the initial position for oscillation
		if body:
			_initialPosition = body.position
	
	# Store initial separation for closing behavior
	_initialSeparation = amount
	UpdateGateSpriteScale(amount)

	pipes[0].position.y = -amount
	pipes[1].position.y = amount

func UpdateGateSpriteScale(amount: float):
	const MIN_SCALE := 0.75
	const SCALING := 1.0 - MIN_SCALE
	gate_sprite.scale.y = 1.0 - (_max_amount_scaling - amount) / (_max_amount_scaling - _min_amount_scaling) * SCALING

func SetRandomYPosition() -> void:
	position.y = randf_range(-pipeOffsetRange, pipeOffsetRange)

func _SpawnGems():
	# Define valid positions: X can be -160, 0, 160; Y can be -160, 0, 160
	# But if X is 0, then Y must also be 0
	var valid_positions = [
		Vector2(-120, -160),
		Vector2(-160, 0),
		Vector2(-120, 160),
		Vector2(0, 0),
		Vector2(120, -160),
		Vector2(160, 0),
		Vector2(120, 160)
	]
	
	# Randomly select 3 different positions
	var selected_positions = []
	for i in range(GameUpgrades.appearingGems):
		var random_index = randi() % valid_positions.size()
		var selected_pos = valid_positions[random_index]
		selected_positions.append(selected_pos)
		valid_positions.remove_at(random_index)
	
	# Instantiate gems at the selected positions
	for pos in selected_positions:
		var gem_instance = gemScn.instantiate()
		gem_instance.position = pos
		add_child(gem_instance)


func _on_scoring_body_entered(_body: Node2D) -> void:
	GM.events.ObstacleDodge()
	$AudioStreamPlayer2D.play()
	var t = get_tree().create_tween()
	t.tween_property(self, "modulate:a", 0.0, 2.5)
	await t.finished
	queue_free()


func _on_scoring_area_entered(area: Area2D) -> void:
	if area.is_in_group("cleaner"):
		queue_free()
		return
