tool
extends KinematicBody2D

signal died

enum State { NORMAL, DASHING, INPUT_DISABLED }

export(int, LAYERS_2D_PHYSICS) var dashHazardMask
export var focus_max_time = 60 
export var focus_image_max_scale = 1.7
export var focus_image_min_scale = 0.6
export var player_stats: Resource

var playerDeathScene = preload("res://scenes/Characters/PlayerDeath.tscn")
var footstepParticles = preload("res://scenes/FootstepParticles.tscn")

onready var focus_texture_rect = $Visuals/Position2D/Focus
onready var focus_timer = $FocusTimer
var focus_time_left setget set_focus_time_left

var velocity = Vector2.ZERO
var hasDoubleJump = false
var hasDash = false
var currentState = State.NORMAL
var isStateNew = true
var isDying = false

var defaultHazardMask = 0


func _ready():
	if Engine.editor_hint:
		return

	$HitboxArea.connect("area_entered", self, "on_hazard_area_entered")
	$AnimatedSprite.connect("frame_changed", self, "on_animated_sprite_frame_changed")
	defaultHazardMask = $HitboxArea.collision_mask

	$FocusTimer.call_deferred("start", focus_max_time)
	focus_time_left = focus_max_time
	

func _process(delta):
	if Engine.editor_hint:
		return
	focus_texture_rect.rect_rotation += 1
	focus_time_left = focus_timer.time_left

	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
		State.INPUT_DISABLED:
			process_input_disabled(delta)
	isStateNew = false

func disable_enemy_collision():
	$HitboxArea.collision_mask = dashHazardMask

func set_focus_time_left(value):
	focus_time_left = value
	#lerp(rect_scale, focus_image_rect_scale, focus/focus_time_left)
	$Visuals/Position2D/Focus.rect_scale = Vector2()

func change_state(newState):
	currentState = newState
	isStateNew = true


func process_normal(delta):
	if (isStateNew):
		$Visuals/DashParticles.emitting = false
		$DashArea/CollisionShape2D.disabled = true
		$HitboxArea.collision_mask = defaultHazardMask

	var moveVector = get_movement_vector()

	velocity.x += moveVector.x * player_stats.horizontalAcceleration * delta
	if (moveVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -25 * delta))
	
	velocity.x = clamp(velocity.x, -player_stats.maxHorizontalSpeed, player_stats.maxHorizontalSpeed)

	if (moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || hasDoubleJump)):
		velocity.y = moveVector.y * player_stats.jumpSpeed
		if (!is_on_floor() && $CoyoteTimer.is_stopped()):
			$"/root/Helpers".apply_camera_snake(.75)
			hasDoubleJump = false
		$CoyoteTimer.stop()
		

	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += player_stats.gravity * player_stats.jumpFallGravityMultiplier * delta
	else:
		velocity.y += player_stats.gravity * delta

	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if (wasOnFloor && !is_on_floor()):
		$CoyoteTimer.start()
	if (!wasOnFloor && is_on_floor() && !isStateNew):
		spawn_footsteps(1.5)
	
	if (is_on_floor()):
		if(player_stats.canDoubleJump):
			hasDoubleJump = true
		if(player_stats.canDash):
			hasDash = true
	
	if (hasDash && Input.is_action_just_pressed("dash")):
		call_deferred("change_state", State.DASHING)
		hasDash = false
	
	update_animation()


func process_dash(delta):
	if (isStateNew):
		disable_enemy_collision()
		$DashAudioPlayer.play()
		$Visuals/DashParticles.emitting = true
		$"/root/Helpers".apply_camera_snake(.75)
		$DashArea/CollisionShape2D.disabled = false
		$AnimatedSprite.play("jump")
		var velocityMod = 1 if $AnimatedSprite.flip_h else -1

		velocity = Vector2(player_stats.maxDashSpeed * velocityMod, 0)

	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -8 * delta))

	if (abs(velocity.x) < player_stats.minDashSpeed):
		call_deferred("change_state", State.NORMAL)


func process_input_disabled(delta):
	if (isStateNew):
		$AnimatedSprite.play("idle")
	velocity.x = lerp(0, velocity.x, pow(2, -25 * delta))
	velocity.y += player_stats.gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return moveVector

func update_animation():
	var moveVec = get_movement_vector()

	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (moveVec.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
	if (moveVec.x != 0):
		$AnimatedSprite.flip_h = moveVec.x > 0

func kill():
	if (isDying):
		return

	isDying = true
	var playerDeathInstance = playerDeathScene.instance()
	playerDeathInstance.velocity = velocity
	get_parent().add_child_below_node(self, playerDeathInstance)
	playerDeathInstance.global_position = global_position
	emit_signal("died")

func spawn_footsteps(scale = 1):
	var footstepParticlesInstance = footstepParticles.instance()
	get_parent().add_child(footstepParticlesInstance)
	footstepParticlesInstance.scale = Vector2.ONE * scale
	footstepParticlesInstance.global_position = global_position
	$FootstepAudioPlayer.play()

func disable_player_input():
	change_state(State.INPUT_DISABLED)

func on_hazard_area_entered(_area2d):
	$"/root/Helpers".apply_camera_snake(1)
	call_deferred("kill")

func on_animated_sprite_frame_changed():
	if ($AnimatedSprite.animation == "run" && $AnimatedSprite.frame == 0):
		spawn_footsteps()
