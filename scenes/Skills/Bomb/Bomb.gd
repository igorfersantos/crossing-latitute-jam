tool
extends Node2D

signal exploded
signal explosion_ended

var explosion_ray_scene = preload("res://scenes/Skills/Bomb/ExplosionRay.tscn")
export(int, LAYERS_2D_PHYSICS) var bomb_mask
export var bomb_strength = 1
export var bomb_radius = 40
export var bomb_ray_casts = 200
var bomb_location = Vector2()

var tilemap:TileMap = null
var affected_tilemap_cell_by_ray:Dictionary = {}

#debug
#var debug_hits = false
var sucessful_rays_cast_to = []

func _ready():
	tilemap = $"/root/Helpers".get_tilemap()

func _draw():
	if !Engine.editor_hint:
		return

	for ray in sucessful_rays_cast_to:
		draw_line(bomb_location, bomb_location + ray, Color.red)

	draw_circle(position, bomb_radius, Color(1, 1, 1, 0.5))

func _process(delta):
	if !Engine.editor_hint:
		return
	
	update()

func init(mask, strength, radius, raycasts, location):
	bomb_mask = mask
	bomb_strength = strength
	bomb_radius = radius
	bomb_ray_casts = raycasts
	bomb_location = location

func damage_cell(cell, tile_id):
	if tile_id == -1:
		return
	
	if tile_id == 0:
		tilemap.set_cellv(cell, 1)
	elif tile_id == 1:
		tilemap.set_cellv(cell, 2)
	elif tile_id == 2:
		tilemap.set_cellv(cell, -1)
	else:
		if (tile_id < tilemap.tile_set.get_last_unused_tile_id()):
			tilemap.set_cellv(cell, tile_id+1)
		else:
			tilemap.set_cellv(cell, -1)
	

func spawn_rays():
	var i = 0
	var rotation = 0.0
	var ray_instance = null
	while i < bomb_ray_casts:
		rotation = float(i) * 360.0 / float(bomb_ray_casts)
		rotation = deg2rad(rotation)
		ray_instance = explosion_ray_scene.instance()
		ray_instance.init(bomb_mask, Vector2(
			cos(rotation), sin(rotation)) * bomb_radius, bomb_location, bomb_strength
		)
		ray_instance.connect("ray_explosion_hit_cell", self, "on_ray_explosion_hit_cell")
		add_child(ray_instance)
		i += 1
	
	ray_instance.connect("ray_explosion_ended", self, "on_last_ray_explosion_ended")
	
func explode():
	spawn_rays()
	emit_signal("exploded")

func on_ray_explosion_hit_cell(cell, tile_id, ray, collider):
	#print("cell: %s tile_id: %s, ray: %s, collider: %s" % [cell, tile_id, ray, collider])
	if tile_id == -1:
		return
	
	sucessful_rays_cast_to.append(ray[0].cast_to)

	if affected_tilemap_cell_by_ray.has(cell):
		#Same cell but different raycast
		if affected_tilemap_cell_by_ray[cell]!= ray[0]:
			return

		#print("cell %s with id %s will damaged by the same ray %s" % [cell, tile_id, ray])
		damage_cell(cell, tile_id)

		affected_tilemap_cell_by_ray[cell].weaken_strengh()
		return

	#print("affected cell %s with id %s by ray %s" % [cell, tile_id, ray])

	damage_cell(cell, tile_id)
	affected_tilemap_cell_by_ray[cell] = (ray[0])
	affected_tilemap_cell_by_ray[cell].weaken_strengh()

func on_last_ray_explosion_ended():
	emit_signal("explosion_ended")
	queue_free()
