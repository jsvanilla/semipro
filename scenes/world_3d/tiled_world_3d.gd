extends Node3D
class_name TiledWorld3D

@onready var world_tilemap:WorldTilemap2D = %tilemaps

@export var map:WorldMap
@export var map_seed:int


func build_layout_from_map(map:WorldMap):
	world_tilemap.map = map
	world_tilemap.map_seed = map_seed
	world_tilemap.rebuild_map()
	
func _on_file_dialog_load_file_selected(path: String) -> void:
	var loaded_map = ResourceLoader.load(path)
	if loaded_map is WorldMap:
		map = loaded_map
		build_layout_from_map(map)
