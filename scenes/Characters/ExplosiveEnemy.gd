extends KinematicBody2D

signal dead

var explosiveEnemyDeathScene = preload("res://scenes/Characters/ExplosiveEnemyDeath.tscn")

export var stats: Resource
export var is_spawning = true
export var is_dying = false

var bomb_instance = preload("res://scenes/Skills/Bomb/Bomb.tscn").instance()
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var deg = deg2rad(75)

func _ready():
	# Note that this will be overwritten in EnemySpawners!
	direction = stats.start_direction

	$ExplosionTimer.wait_time = stats.countdown_time
	$ExplosionTimer.start()

	$GoalDetector.connect("area_entered", self, "on_goal_entered")
	$HitboxArea.connect("area_entered", self, "on_hitbox_entered")

	$ExplosionTimer.connect("timeout", self, "on_explosion_timer_timeout")

func _process(delta):
	$Visuals/AnimatedSprite.flip_h = velocity.x > 0 || direction.x > 0
	
	if (is_spawning):
		return
	
	velocity.x = (direction * stats.speed).x
	velocity.y += stats.gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, deg)

	if (is_on_wall() && is_on_floor()):
		call_deferred("set", "direction", direction * -1)


func kill():
	if(is_dying):
		return
	
	is_dying = true

	var deathInstance = explosiveEnemyDeathScene.instance()
	deathInstance.connect("enemy_death_exploded", self, "on_enemy_death_exploded")
	deathInstance.global_position = global_position
	get_parent().add_child(deathInstance)
	if (velocity.x > 0 || direction.x > 0):
		deathInstance.scale = Vector2(-1, 1)
	
	
	set_process(false)
	set_physics_process(false)
	$Visuals.visible = false
	$BodyCollision.disabled = true
	$GoalDetector.monitorable = false
	$HazardArea.monitorable = false
	$HitboxArea.monitorable = false
	
	emit_signal("dead")

func on_enemy_death_exploded(position):
	get_parent().add_child(bomb_instance)
	bomb_instance.init(
		stats.bomb_mask, 
		stats.bomb_strength,
		stats.bomb_radius,
		stats.bomb_raycasts, 
		position
	)
	bomb_instance.explode()
	yield(bomb_instance, "explosion_ended")
	queue_free()

func on_goal_entered(_area2d):
	direction *= -1;

func on_hitbox_entered(_area2d):
	$"/root/Helpers".apply_camera_snake(1)
	call_deferred("kill")
	
func on_explosion_timer_timeout():
	kill()
