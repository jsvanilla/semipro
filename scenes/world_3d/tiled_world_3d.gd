@tool
extends Node3D
class_name TiledWorld3D

@onready var world_tilemap:WorldTilemap2D = %tilemaps
@onready var subviewport:SubViewport = %SubViewport
@onready var ground_mesh:MeshInstance3D = %MeshInstance3D
@onready var features:Node3D = %features

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

@export var mountain_scene:PackedScene = preload("res://scenes/world_3d/props/mountain.tscn")
@export var hill_scene:PackedScene = preload("res://scenes/world_3d/props/hill.tscn")
@export var trees_scene:PackedScene = preload("res://scenes/world_3d/props/trees.tscn")
@export var ocean_scene:PackedScene = preload("res://scenes/world_3d/props/ocean.tscn")


func update_from_map():
	if !is_node_ready():
		return
	
	for child in features.get_children():
		child.queue_free()
	
	if !map:
		return
	
	#Height divided by 2 since rows are staggered
	var map_pixel_size:Vector2i = Vector2(map.get_width() * tile_size.x, map.get_height() * tile_size.y / 2.0)
	subviewport.size = map_pixel_size
	
	ground_mesh.scale = Vector3(map.get_width(), 1, map.get_height() / 2.0) / 2.0
	
	#Create map features
	var feature_offset:Vector3 = -Vector3(map.get_width(), 0, map.get_height() / 2.0) / 2.0 + Vector3(1, 0, .5)
	
	for j in map.get_height():
		for i in map.get_width():
			var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))

				
			#
			#if !cell.land:
				#continue
		 		
			var feature:Node3D
			
			if cell.terrain == WorldMapCell.Terrain.OCEAN:
				feature = ocean_scene.instantiate()
			
			elif cell.terrain == WorldMapCell.Terrain.DIRT || cell.terrain == WorldMapCell.Terrain.GRASSLAND:
			
				if cell.vegetation == WorldMapCell.Vegetation.FOREST:
					feature = trees_scene.instantiate()
					#print("trees ", Vector2i(i, j))
				elif cell.feature == WorldMapCell.Feature.MOUNTAIN:
					feature = mountain_scene.instantiate()
				elif cell.feature == WorldMapCell.Feature.HILL:
					feature = hill_scene.instantiate()
			
			if feature:
				features.add_child(feature)
				
				var pos:Vector3 = Vector3(float(i), 0, float(j) / 2.0) + feature_offset
				feature.position = pos
				if (j & 0b1) == 1:
					#feature.position.y += .5
					feature.position.x += .5
			

func _ready() -> void:
	world_tilemap.map = map
	world_tilemap.map_seed = map_seed
	update_from_map()

func build_layout_from_map(new_map:WorldMap):
	world_tilemap.map = new_map
	world_tilemap.map_seed = map_seed
	world_tilemap.rebuild_map()
	
func _on_file_dialog_load_file_selected(path: String) -> void:
	var loaded_map = ResourceLoader.load(path)
	if loaded_map is WorldMap:
		map = loaded_map
		build_layout_from_map(map)
