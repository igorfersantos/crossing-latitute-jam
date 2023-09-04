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
var max_life


func _ready():
	randomize()
	spawnPosition = $PlayerSpawnPoint.global_position
	var player_instance = register_player(playerScene)
	spawn_player(player_instance)
	max_life = player_instance.player_stats.lifes
	print(max_life)
	
	coin_total_changed(get_tree().get_nodes_in_group("coin").size())
	$LevelUI.init(max_life)


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


func player_won():
	current_player_node.disable_player_input()
	current_player_node.disable_enemy_collision()
	var level_complete_scene_instance = level_complete_scene.instance()
	add_child(level_complete_scene_instance)


func register_player(player_scene):
	current_player_node = player_scene.instance()
	current_player_node.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)
	current_player_node.connect("took_damage", $LevelUI, "on_player_took_damage")
	return current_player_node


func spawn_player(player_instance):
	$PlayerSpawnPoint.add_child(player_instance)
	player_instance.global_position = $PlayerSpawnPoint.global_position


func on_player_died():
	current_player_node.queue_free()
	var level_failed_scene_instance = level_failed_scene.instance()
	add_child(level_failed_scene_instance)
