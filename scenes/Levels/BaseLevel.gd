extends Node

signal coin_total_changed(total_coins, collectedCoins)

export(PackedScene) var playerScene
export(PackedScene) var level_failed_scene 
export(PackedScene) var level_complete_scene

var pauseScene = preload("res://scenes/UI/PauseMenu.tscn")
var enemyScene = preload("res://scenes/Characters/ExplosiveEnemy.tscn")
var spawnPosition = Vector2.ZERO
var current_player_node = null
var total_coins = 0
var collected_coins = 0
var enemy_spawnable_area = Vector2()
onready var tilemap = $TileMap

func _ready():
	randomize()
	spawnPosition = $PlayerSpawnPoint.global_position
	var player_instance = register_player(playerScene)
	spawn_player(player_instance)
	
	coin_total_changed(get_tree().get_nodes_in_group("coin").size())
	
	enemy_spawnable_area = get_valid_spawnable_header_column($TileMap)
	for enemy_spawner in $EnemySpawners.get_children():
		enemy_spawner.connect("enemy_spawned", self, "on_enemy_spawned", [enemy_spawner], CONNECT_REFERENCE_COUNTED)
		enemy_spawner.get_node("SpawnTimer").connect("timeout", self, "on_check_enemy_spawn", [enemy_spawner], CONNECT_REFERENCE_COUNTED)

func _unhandled_input(event):
	if (event.is_action_pressed("pause")):
		var pauseInstance = pauseScene.instance()
		add_child(pauseInstance)

func coin_collected(coin):
	collected_coins += 1
	print("collected coin %s" % [coin])
	if (collected_coins == total_coins):
		player_won()
	emit_signal("coin_total_changed", total_coins, collected_coins)


func coin_total_changed(newTotal):
	total_coins = newTotal
	emit_signal("coin_total_changed", total_coins, collected_coins)

func get_valid_spawnable_header_column(tile_map: TileMap):
	var most_left = Vector2(1,0)
	var most_right = Vector2(0,0)
	for used_cell in tile_map.get_used_cells():
		if (used_cell.x > most_right.x):
			most_right.x = used_cell.x
	
	return [most_left, most_right]

func player_won():
	current_player_node.disable_player_input()
	current_player_node.disable_enemy_collision()
	var level_complete_scene_instance = level_complete_scene.instance()
	add_child(level_complete_scene_instance)

func randomize_enemy_spawner_position(enemy_spawner):
	var x = randi() % int(enemy_spawnable_area[1].x) + 1
	var random_cell_position = Vector2(x,0)
	var cell_world_pos = $TileMap.to_global($TileMap.map_to_world(random_cell_position))
	# TODO: Make use of the body collision shape radius as margin safety
	#var body_collision = enemy_spawner.current_enemy_node.get_node("BodyCollision")
	enemy_spawner.global_position = Vector2(cell_world_pos.x + 10, cell_world_pos.y)
	enemy_spawner.start_direction = randi() % 2


func register_player(player_scene):
	current_player_node = player_scene.instance()
	current_player_node.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)
	return current_player_node

func spawn_player(player_instance):
	$PlayerSpawnPoint.add_child(player_instance)
	player_instance.global_position = $PlayerSpawnPoint.global_position


func on_player_died():
	current_player_node.queue_free()

	var level_failed_scene_instance = level_failed_scene.instance()

	add_child(level_failed_scene_instance)

func on_enemy_spawned(enemy_spawner, enemy_spawned):
	print("Enemy %s spawned at %s by %s" % [enemy_spawned, enemy_spawner.global_position ,enemy_spawner])

func on_check_enemy_spawn(enemy_spawner):
	if !enemy_spawner.spawn_on_next_tick:
		return

	print("[%s] Enemy %s will be spawned on the next tick" % [enemy_spawner, enemy_spawner.enemy_scene])
	
	randomize_enemy_spawner_position(enemy_spawner)

	print("[%s] Enemy %s start direction: %s" % [enemy_spawner, enemy_spawner.enemy_scene, enemy_spawner.start_direction])
