extends RigidBody2D

signal died

enum State { IDLE, RUN, AIR, INPUT_DISABLED }

export(int, LAYERS_2D_PHYSICS) var iframe_mask
export var player_stats: Resource

onready var just_aired_timer = $JustAiredTimer

var player_death_scene = preload("res://scenes/Characters/PlayerDeath.tscn")
var footstep_particles = preload("res://scenes/FootstepParticles.tscn")

var move_vec = Vector2.ZERO
var velocity = Vector2.ZERO

var current_state = State.IDLE
var is_state_new = true
var is_dying = false

var current_iframe_mask = 0


func _ready():
	$HitboxArea.connect("area_entered", self, "on_hazard_area_entered")
	$AnimatedSprite.connect("frame_changed", self, "on_animated_sprite_frame_changed")
	current_iframe_mask = $HitboxArea.collision_mask
	

func _integrate_forces(state):
	var is_on_ground = get_is_on_ground(state)

	#print(is_on_ground)
	move_vec = get_movement_vector();

	match current_state:
		State.IDLE:
			print("idle...")
			process_idle(state, is_on_ground)
		State.RUN:
			print("run...")
			process_running(state, is_on_ground)
		State.AIR:
			print("air...")
			process_air(state, is_on_ground)
			pass
		State.INPUT_DISABLED:
			print("input disabled...")
			#process_input_disabled(delta, is_on_ground)
			pass

	is_state_new = false


func get_is_on_ground(state):
	var contact_count = state.get_contact_count()
	if contact_count > 0 and contact_count < 2:
		return is_collider_below_me(state.get_contact_collider_position(0))
	
	var ground_contacts = []
	for index in contact_count:
		ground_contacts.append(is_collider_below_me(state.get_contact_collider_position(index)))

	print(ground_contacts)
	return true in ground_contacts


func is_collider_below_me(collider):
	return int(collider.y) >= int(global_position.y)


func disable_enemy_collision():
	$HitboxArea.collision_mask = current_iframe_mask


func change_state(new_state):
	current_state = new_state
	is_state_new = true


func process_idle(state, is_on_ground):
	if (is_state_new):
		$Visuals/DashParticles.emitting = false
		$HitboxArea.collision_mask = current_iframe_mask
		linear_velocity.x = 0
	
	if move_vec.x:
		change_state(State.RUN)
	elif is_on_ground and Input.is_action_just_pressed("jump"):
		jump()
		change_state(State.AIR)


func process_running(state, is_on_ground):
	if (is_state_new):
		$Visuals/DashParticles.emitting = true
		$HitboxArea.collision_mask = current_iframe_mask
	
	if not move_vec.x:
		change_state(State.IDLE)
	elif state.get_contact_count() == 0:
		change_state(State.AIR)
	elif is_on_ground and Input.is_action_just_pressed("jump"):
		jump()
		change_state(State.AIR)
	else:
		state.linear_velocity.x = move_vec.x * player_stats.max_horizontal_speed # * get_physics_process_delta_time()
		#applied_force = Vector2(move_vec.x * player_stats.max_horizontal_speed * state.get_step(), state.linear_velocity.y)

	update_animation()


func process_air(state, is_on_ground):
	if (is_state_new):
		#disable_enemy_collision()
		$DashAudioPlayer.play()
		$Visuals/DashParticles.emitting = true
		$"/root/Helpers".apply_camera_snake(.75)
		$AnimatedSprite.play("jump")
		var velocityMod = 1 if $AnimatedSprite.flip_h else -1
		just_aired_timer.start()
	
	if is_on_ground and just_aired_timer.is_stopped():
		change_state(State.IDLE)
	# if move_vec.x:
	# 	state.linear_velocity.x += move_vec.x * player_stats.maxHorizontalSpeed

	# if (abs(velocity.x) < player_stats.minDashSpeed):
	# 	call_deferred("change_state", State.NORMAL)



# func process_input_disabled(delta):
# 	if (is_state_new):
# 		$AnimatedSprite.play("idle")
# 	# velocity.x = lerp(0, velocity.x, pow(2, -25 * delta))
# 	# velocity.y += player_stats.gravity * delta
# 	# velocity = move_and_slide(velocity, Vector2.UP)


func get_movement_vector():
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return move_vector


func update_animation():
	var move_vec = get_movement_vector()

	# if (!is_on_floor()):
	# 	$AnimatedSprite.play("jump")
	if (move_vec.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
	if (move_vec.x != 0):
		$AnimatedSprite.flip_h = move_vec.x > 0

func jump():
	var angle = 45
	var direction = Vector2(move_vec.x * -1, -1).normalized()
	var impulse = Vector2(direction.x * player_stats.horizontal_jump_force, direction.y * player_stats.vertical_jump_force)
	#player_stats.vertical_jump_force

	print(impulse)
	apply_central_impulse(impulse) #maybe add a * jump_force here

func kill():
	if (is_dying):
		return

	is_dying = true
	var playerDeathInstance = player_death_scene.instance()
	playerDeathInstance.velocity = velocity
	get_parent().add_child_below_node(self, playerDeathInstance)
	playerDeathInstance.global_position = global_position
	emit_signal("died")


func spawn_footsteps(scale = 1):
	var footstep_particle_instance = footstep_particles.instance()
	get_parent().add_child(footstep_particle_instance)
	footstep_particle_instance.scale = Vector2.ONE * scale
	footstep_particle_instance.global_position = global_position
	$FootstepAudioPlayer.play()


func disable_player_input():
	change_state(State.INPUT_DISABLED)


func on_hazard_area_entered(_area2d):
	$"/root/Helpers".apply_camera_snake(1)
	call_deferred("kill")


func on_animated_sprite_frame_changed():
	if ($AnimatedSprite.animation == "run" && $AnimatedSprite.frame == 0):
		spawn_footsteps()
