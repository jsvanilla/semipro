@tool
extends Node3D
class_name TiledWorld3D

@onready var world_tilemap:WorldTilemap2D = %tilemaps
@onready var subviewport:SubViewport = %SubViewport

@export var map:WorldMap:
	set(v):
		if map == v:
			return
		map = v
		
		if world_tilemap:
			world_tilemap.map = map
			
		update_from_map()

@export var map_seed:int:
	set(v):
		if map_seed == v:
			return
		map_seed = v
		
		if world_tilemap:
			world_tilemap.map_seed = map_seed

@export var tile_size:Vector2i = Vector2i(32, 32):
	set(v):
		if tile_size == v:
			return
			
		tile_size = v
		update_from_map()

func update_from_map():
	if !is_node_ready():
		return
		
	if !map:
		return
	
	#Height divided by 2 since rows are staggered
	subviewport.size = Vector2i(map.get_width() * tile_size.x, map.get_height() * tile_size.y / 2)
	
	
	pass

func _ready() -> void:
	world_tilemap.map = map
	world_tilemap.map_seed = map_seed

func build_layout_from_map(map:WorldMap):
	world_tilemap.map = map
	world_tilemap.map_seed = map_seed
	world_tilemap.rebuild_map()
	
func _on_file_dialog_load_file_selected(path: String) -> void:
	var loaded_map = ResourceLoader.load(path)
	if loaded_map is WorldMap:
		map = loaded_map
		build_layout_from_map(map)
