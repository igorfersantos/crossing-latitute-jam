extends RigidBody2D

signal enemy_death_exploded


func _ready():
	$DeathSoundPlayer1.play()
# 	$DeathSoundPlayer2.play()


func drop_bomb():
	emit_signal("enemy_death_exploded", global_position)
