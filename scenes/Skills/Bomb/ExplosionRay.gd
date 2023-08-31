extends RayCast2D

signal ray_explosion_ended
signal ray_explosion_hit_player(player)
signal ray_explosion_hit_cell(cell, tile_id, ray, collider)

var strength = 1
var collider = null
var tilemap
var cell = Vector2()
var tile_id = -1
var is_destroying = false

var initialized = false


func _ready():
	tilemap = $"/root/Helpers".get_tilemap()
	$ExplosionTimer.connect("timeout", self, "on_explosion_timer_timeout")


func destroy():
	if (is_destroying):
		return
		
	is_destroying = true
	emit_signal("ray_explosion_ended")
	queue_free()


func init(mask, cast, global_pos, strength):
	collision_mask = mask
	cast_to = cast
	position = global_pos
	self.strength = strength
	initialized = true


func _physics_process(_delta):
	collider = get_collider()
	
	if (!initialized or collider == null):
		return
	
	if (collider.is_in_group("player")):
		collider.kill()
		set_collision_mask_bit(2, false)
		emit_signal("ray_explosion_hit_player", collider)
		return
	
	if (collider.is_in_group("enemy")):
		print("hit enemy %s" % [collider.name])
		set_collision_mask_bit(1, false)

	if (collider.name == "TileMap"):
		cell = tilemap.world_to_map(get_collision_point() - get_collision_normal())
		tile_id = tilemap.get_cellv(cell)
		#print("cell/id/ray: %s/%s/%s" % [cell, tile_id, self])
		
		emit_signal("ray_explosion_hit_cell", cell, tile_id, [self], collider)


func weaken_strengh():
	strength -= 1
	if strength <= 0:
		destroy()


func on_explosion_timer_timeout():
	destroy()
