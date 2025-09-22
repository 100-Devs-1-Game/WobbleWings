extends CharacterBody2D

signal got_hit(area:Area2D)

@onready var jump:CB2DJumpSimple = $CB2DBehaviorManager/CB2DJumpSimple
@onready var grav:CB2DGravity = $CB2DBehaviorManager/CB2DGravity
@onready var picker:Area2D = $PickupsCollector/Picker
@onready var body_spr: AnimatedSprite2D = $BodySpr
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var invul_timer: Timer = $InvulTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var maxMoveSpd:float = 448.0
var moveSpd:float = 224.0:
	get: return moveSpd
	set(val):
		moveSpd = val
		velocity.x = moveSpd


func _ready() -> void:
	GM.events.shop_item_purchased.connect(_OnShopItemSelected)
	GM.events.shop_item_equipped.connect(_OnShopItemSelected)
	jump.jumped.connect(_onJumped)
	GM.events.obstacle_dodge.connect(_OnObstacleDodge)
	
	GM.events.menu_entered.connect(_onMenuEntered)
	GM.events.play_started.connect(_onPlayStarted)

func _OnObstacleDodge() -> void:
	IncreaseSpeed(0.1)

func _OnShopItemSelected(item:ShopItemData) -> void:
	if item.type == ShopItemData.Type.COSTUME:
		modulate = item.color

func _onMenuEntered():
	body_spr.sprite_frames.set_animation_loop("default", true)
	body_spr.sprite_frames.set_animation_speed("default", 8.0)
	body_spr.play("default")

func _onPlayStarted():
	body_spr.sprite_frames.set_animation_loop("default", false)
	body_spr.sprite_frames.set_animation_speed("default", 16.0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm") or event.is_action_pressed("left_click"):
		jump.OnJumpPressed()
		animation_player.play("flap")

func Start():
	grav.enabled = true
	jump.enabled = true
	jump.OnJumpPressed()
	velocity.x = moveSpd

func Stop():
	grav.Stop()
	jump.enabled = false
	velocity.x = 0

func IncreaseSpeed(percentage:float) -> void:
	if moveSpd >= maxMoveSpd:
		return

	moveSpd = minf(maxMoveSpd, moveSpd + moveSpd * percentage)

func _on_score_check_area_entered(area: Area2D) -> void:
	# Create tween animation for gem collection
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Get the gem's current position and the player's position
	var gem_start_pos = area.global_position
	var player_pos = global_position
	
	# First phase: move gem away from collider (slightly away from player)
	var away_direction = (gem_start_pos - player_pos).normalized()
	var away_pos = gem_start_pos + away_direction * 50
	
	# Second phase: move gem towards screen center
	var final_pos = global_position
	
	# Disable collision during animation
	area.set_collision_layer_value(2, false)
	area.set_collision_mask_value(0, false)
	
	# Create the animation sequence
	tween.tween_property(area, "global_position", away_pos, 0.2)
	tween.tween_property(area, "global_position", final_pos, 0.3).set_delay(0.2)
	tween.tween_property(area, "scale", Vector2.ZERO, 0.3).set_delay(0.2)
	
	# Wait for animation to complete, then run original code
	await tween.finished
	
	# Run the original gem collection code

func _on_magnet_area_entered(area: Area2D) -> void:
	_HandlePickupMagnetEntered.call_deferred(area)

func _HandlePickupMagnetEntered(area: Area2D) -> void:
	if area.is_in_group("pickups") and not area.isBeingCollected:
		area.PickUp(picker)


func _on_picker_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickups"):
		GM.events.PlayerScored(1)
		
		audio_stream_player.play()
		area.queue_free()

func _onJumped() -> void:
	if body_spr.is_playing():
		body_spr.stop()
	
	body_spr.play("default")


func _on_body_spr_frame_changed() -> void:
	if body_spr.frame == 1:
		GM.globalAudio.PlaySound("flap")


func _on_lose_check_area_entered(area: Area2D) -> void:
	if not invul_timer.is_stopped() and not area.is_in_group("floor"):
		return
	#Get hit
	got_hit.emit(area)
	invul_timer.start()
	modulate.a = 0.5
	
func _on_invul_timer_timeout() -> void:
	modulate.a = 1.0
