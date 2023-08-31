extends Node2D

export var focus_time_gained = 10

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")

func on_area_entered(_area2d):
	$AnimationPlayer.play("pickup")
	call_deferred("disable_pickup")

	var baseLevel = get_tree().get_nodes_in_group("base_level")[0]
	baseLevel.coin_collected(self)
	$RandomAudioStreamPlayer.play()
	$RandomAudioStreamPlayer2.play()

func disable_pickup():
	$Area2D/CollisionShape2D.disabled = true
