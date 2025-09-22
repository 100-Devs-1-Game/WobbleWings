class_name CB2DJump extends CB2DBehavior
## Handles jumping for a CharacterBody2D with responsive jump mechanics

@export var jump_force: float = 400.0
@export var max_jump_time: float = 0.3
@export var min_jump_time: float = 0.05

@export_group("Air Control")
@export var coyoteTime: float = 0.05
@export var airJumps: int = 0 #TODO: Implement air jumps

@export_group("Input Buffering")
@export var jump_buffer_time: float = .15

var _jump_pressed: bool = false
var _jump_time: float = 0.0
var _is_jumping: bool = false
var _coyote_timer: float = 0.0
var _has_left_ground: bool = false
var _has_made_first_jump: bool = false
var _jump_buffer_timer: float = 0.0
var _has_buffered_jump: bool = false


func OnJumpPressed():
	_jump_pressed = true
	_handle_jump_input()
func OnJumpReleased():
	_jump_pressed = false


func _physics_process_behavior(delta):
	if _is_jumping:
		_jump_time += delta
		
		# Release jump early if button is released and minimum time has passed
		if not _jump_pressed and _jump_time >= min_jump_time:
			_end_jump()
		# End jump if max time reached
		elif _jump_time >= max_jump_time:
			_end_jump()
	
	# Handle coyote timer
	if is_on_ground():
		_coyote_timer = 0.0
		_has_left_ground = false
		_has_made_first_jump = false
	else:
		# Player is in the air
		if not _has_left_ground:
			_has_left_ground = true
		if _has_left_ground:
			_coyote_timer += delta
	
	# Handle jump buffer
	if _has_buffered_jump:
		_jump_buffer_timer -= delta
		
		# Try to use buffered jump if we can now jump
		if _try_jump():
			_has_buffered_jump = false
			_jump_buffer_timer = 0.0
		# Clear buffer if time expired
		elif _jump_buffer_timer <= 0.0:
			_has_buffered_jump = false

func _handle_jump_input():
	# Try to jump immediately if possible
	if _try_jump():
		return
	
	# If we can't jump, buffer the input
	_jump_buffer_timer = jump_buffer_time
	_has_buffered_jump = true

func _try_jump():
	# Check if we can jump (on ground or within coyote time and haven't made first jump)
	var can_jump = (is_on_ground() or (_coyote_timer <= coyoteTime and not _has_made_first_jump)) and not _is_jumping
	
	if can_jump:
		_start_jump()
		return true
	return false

func _start_jump():
	_is_jumping = true
	_jump_time = 0.0
	_has_made_first_jump = true
	_coyote_timer = 0.0  # Reset coyote timer when jumping
	
	var velocity = _character_body.velocity
	velocity.y = -jump_force
	_character_body.velocity = velocity

func _end_jump():
	_is_jumping = false
	# Reduce upward velocity when jump is released early
	if _character_body.velocity.y < 0:
		_character_body.velocity.y *= 0.5

## Public methods for external control
func ForceJump():
	_try_jump()

func IsJumping() -> bool:
	return _is_jumping

func GetCoyoteTimeRemaining() -> float:
	return max(0.0, coyoteTime - _coyote_timer)
