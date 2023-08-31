extends MarginContainer

func take_damage():
	var lifes = $MarginContainer/LifesContainer.get_children()
	var last_life = lifes.pop_back()
	last_life.queue_free ()

#func _unhandled_input(event):
#	if (event.is_action_pressed("jump")):
#		take_damage()
