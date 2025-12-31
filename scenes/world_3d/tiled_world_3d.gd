@tool
extends Node3D
class_name TiledWorld3D

@onready var world_tilemap:WorldTilemap2D = %tilemaps

@export var map:WorldMap:
	set(v):
		if map == v:
			return
		map = v
		
		if world_tilemap:
			world_tilemap.map = map

@export var map_seed:int:
	set(v):
		if map_seed == v:
			return
		map_seed = v
		
		if world_tilemap:
			world_tilemap.map_seed = map_seed
	

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
