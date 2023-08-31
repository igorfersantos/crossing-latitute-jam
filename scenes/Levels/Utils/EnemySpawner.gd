extends Position2D

signal enemy_spawned(enemy)

enum Direction { RIGHT, LEFT }

export var enabled = true
export(Direction) var start_direction
export(PackedScene) var enemy_scene
export(Resource) var enemy_stats;

var current_enemy_node = null
var spawn_on_next_tick = false

func _ready():
	$SpawnTimer.connect("timeout", self, "on_check_enemy_spawn", [], CONNECT_REFERENCE_COUNTED)
	call_deferred("spawn_enemy")

func get_start_direction():
	return Vector2.RIGHT if start_direction == Direction.RIGHT else Vector2.LEFT

func spawn_enemy():
	if !enabled:
		return
		
	current_enemy_node = enemy_scene.instance()
	if enemy_stats:
		current_enemy_node.stats = enemy_stats
	current_enemy_node.stats.start_direction = get_start_direction()
	current_enemy_node.global_position = global_position

	get_parent().add_child(current_enemy_node)
	emit_signal("enemy_spawned", current_enemy_node)

func check_enemy_spawn():
	if is_instance_valid(current_enemy_node): 
		return
		
	if (spawn_on_next_tick):
		spawn_enemy()
		spawn_on_next_tick = false
	else: 
		spawn_on_next_tick = true

func on_check_enemy_spawn():
	check_enemy_spawn()
