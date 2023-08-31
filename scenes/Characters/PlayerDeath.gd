extends KinematicBody2D

export var gravity = 1000
var velocity = Vector2.ZERO

func _ready():
	if (velocity.x > 0):
		$Visuals.scale.x = -1
	
	$DeathSoundPlayer1.play()
	$DeathSoundPlayer2.play()
	$DeathSoundPlayer3.play()

func _process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

	if (is_on_floor()):
		velocity.x = lerp(0, velocity.x, pow(2, -1 * delta))
