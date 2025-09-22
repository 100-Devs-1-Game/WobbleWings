class_name CB2DJumpSimple extends CB2DBehavior
## Handles jumping for a CharacterBody2D with responsive jump mechanics

signal jumped

@export var jump_force: float = 400.0

@export_group("Air Control")
@export var coyoteTime: float = 0.05
@export var airJumps: int = -1 #-1 means unlimited

@export_group("Input Buffering")
@export var jump_buffer_time: float = .15

var _coyoteTimer: float = 0.0
var _hasLeftGround: bool = false
var _hasMadeFirstJump: bool = false
var _jumpBufferTimer: float = 0.0
var _hasBufferedJump: bool = false

func OnJumpPressed():
	_TryJump()


func _physics_process_behavior(delta):
	# Handle coyote timer
	if is_on_ground():
		_coyoteTimer = 0.0
		_hasLeftGround = false
		_hasMadeFirstJump = false
	else:
		# Player is in the air
		if not _hasLeftGround:
			_hasLeftGround = true
		if _hasLeftGround:
			_coyoteTimer += delta
	
	# Handle jump buffer
	if _hasBufferedJump:
		_jumpBufferTimer -= delta
		
		# Try to use buffered jump if we can now jump
		if _TryJump():
			_hasBufferedJump = false
			_jumpBufferTimer = 0.0
		# Clear buffer if time expired
		elif _jumpBufferTimer <= 0.0:
			_hasBufferedJump = false

func _TryJump():
	if not enabled:
		return
	_Jump()

func _Jump():
	_coyoteTimer = 0.0

	var velocity = _character_body.velocity
	velocity.y = -jump_force
	_character_body.velocity = velocity
	jumped.emit()
