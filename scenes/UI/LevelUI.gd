extends CanvasLayer

onready var life_image: TextureRect = $Life

var life_size = 39
var lifes = 10


func init(lifes):
	life_image.rect_size.x = life_size * lifes

func on_player_took_damage(damage):
	lifes -= damage
	if lifes <= 0:
		visible = false
		return
	life_image.rect_size.x -= life_size * damage
