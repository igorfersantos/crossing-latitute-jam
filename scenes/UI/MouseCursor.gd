extends CanvasLayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta):
	$Sprite.global_position = $Sprite.get_global_mouse_position()
	if (Input.is_action_pressed("click")):
		$AnimationPlayer.play("click")
