extends Node


func update_bus_volume(busName, volumePercent):
	var busIdx = AudioServer.get_bus_index(busName)
	var volumeDb = linear2db(volumePercent)
	AudioServer.set_bus_volume_db(busIdx, volumeDb)

func _ready():

	if OS.has_feature("editor"):
		OS.window_fullscreen = false
		update_bus_volume("Master", 0)