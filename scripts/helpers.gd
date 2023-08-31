extends Node

func apply_camera_snake(percetage):
	var cameras = get_tree().get_nodes_in_group("camera")

	if (cameras.size() > 0):
		cameras[0].apply_shake(percetage)

func get_tilemap():
	return get_tree().get_nodes_in_group("base_level")[0].get_node("TileMap")
