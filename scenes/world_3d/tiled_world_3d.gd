@tool
extends Node3D
class_name TiledWorld3D

#@onready var world_tilemap:WorldTilemap2D = %tilemaps
#@onready var subviewport:SubViewport = %SubViewport
#@onready var ground_mesh:MeshInstance3D = %MeshInstance3D
@onready var features:Node3D = %features

@export var map:WorldMap:
	set(v):
		if map == v:
			return
		map = v
		
		#if world_tilemap:
			#world_tilemap.map = map
			
		update_from_map()

@export var map_seed:int:
	set(v):
		if map_seed == v:
			return
		map_seed = v
		
		#if world_tilemap:
			#world_tilemap.map_seed = map_seed

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
@export var world_tile_scene:PackedScene = preload("res://scenes/world_3d/props/world_tile.tscn")


func is_blocked(coord:Vector2i, 
	test_terrain:WorldMapCell.Terrain,
	boundary_terrain:WorldMapCell.Terrain = WorldMapCell.Terrain.OCEAN)->bool:
	
	var cell:WorldMapCell = map.get_cell_v(coord)
	var terrain:WorldMapCell.Terrain = cell.terrain if cell else boundary_terrain
	return terrain >= test_terrain
	
func terrain_adjacency(terrain_type:WorldMapCell.Terrain, coord:Vector2i)->WorldTile.TileType:
	
	var t_w:bool
	var t_n:bool
	var t_e:bool
	var t_s:bool
	
	if coord.y % 2 == 0:
		t_w = is_blocked(coord + Vector2i(-1, 0), terrain_type)
		t_n = is_blocked(coord + Vector2i(-1, -1), terrain_type)
		t_e = is_blocked(coord + Vector2i(0, 0), terrain_type)
		t_s = is_blocked(coord + Vector2i(-1, 1), terrain_type)
	else:
		t_w = is_blocked(coord + Vector2i(-1, 0), terrain_type)
		t_n = is_blocked(coord + Vector2i(0, -1), terrain_type)
		t_e = is_blocked(coord + Vector2i(0, 0), terrain_type)
		t_s = is_blocked(coord + Vector2i(0, 1), terrain_type)
	
	var mask:int = (0b1000 if t_w else 0) \
		| (0b100 if t_n else 0) \
		| (0b10 if t_e else 0) \
		| (0b1 if t_s else 0)
	
	#var tile_coord:Vector2i
	match mask:
		0b0000:
			return WorldTile.TileType.EMPTY
			#tile_coord = Vector2i(1, 0)
		0b1000:
			return WorldTile.TileType.W
			#tile_coord = Vector2i(2, 2)
		0b0100:
			return WorldTile.TileType.N
#			tile_coord = Vector2i(3, 2)
		0b1100:
			return WorldTile.TileType.NW
#			tile_coord = Vector2i(3, 1)
		0b0010:
			return WorldTile.TileType.E
#			tile_coord = Vector2i(1, 2)
		0b1010:
			return WorldTile.TileType.WE
#			tile_coord = Vector2i(3, 0)
		0b0110:
			return WorldTile.TileType.NE
#			tile_coord = Vector2i(2, 1)
		0b1110:
			return WorldTile.TileType.WNE
#			tile_coord = Vector2i(3, 3)
		0b0001:
			return WorldTile.TileType.S
#			tile_coord = Vector2i(0, 2)
		0b1001:
			return WorldTile.TileType.SW
#			tile_coord = Vector2i(1, 1)
		0b0101:
			return WorldTile.TileType.NS
#			tile_coord = Vector2i(2, 0)
		0b1101:
			return WorldTile.TileType.NWS
#			tile_coord = Vector2i(2, 3)
		0b0011:
			return WorldTile.TileType.SE
#			tile_coord = Vector2i(0, 1)
		0b1011:
			return WorldTile.TileType.WSE
#			tile_coord = Vector2i(0, 3)
		0b0111:
			return WorldTile.TileType.NES
#			tile_coord = Vector2i(1, 3)
		0b1111:
			return WorldTile.TileType.FULL
#			tile_coord = Vector2i(0, 0)
	
#	layer.set_cell(Vector2i(i, j), 0, tile_coord)
	return WorldTile.TileType.EMPTY
			
func update_from_map():
	if !is_node_ready():
		return
	
	for child in features.get_children():
		child.queue_free()
	
	if !map:
		return
	
	#Height divided by 2 since rows are staggered
	#var map_pixel_size:Vector2i = Vector2(map.get_width() * tile_size.x, map.get_height() * tile_size.y / 2.0)
	#subviewport.size = map_pixel_size
	#
	#ground_mesh.scale = Vector3(map.get_width(), 1, map.get_height() / 2.0) / 2.0
	
	#Create map features
	var feature_offset:Vector3 = -Vector3(map.get_width(), 0, map.get_height() / 2.0) / 2.0# + Vector3(1, 0, .5)
	
	for j in map.get_height():
		for i in map.get_width():
			var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))

			var local_pos:Vector3 = Vector3(float(i), 0, float(j) / 2.0) + feature_offset
			if (j & 0b1) == 1:
				local_pos.x += .5

			var tile_body:WorldTile = world_tile_scene.instantiate()
			tile_body.tile_continent = terrain_adjacency(WorldMapCell.Terrain.DIRT, Vector2i(i, j))
			tile_body.tile_grass = terrain_adjacency(WorldMapCell.Terrain.GRASSLAND, Vector2i(i, j))
			tile_body.tile_desert= terrain_adjacency(WorldMapCell.Terrain.DESERT, Vector2i(i, j))
			
			features.add_child(tile_body)
			#Extra offset since terrain adjacency measures points at corners rather than centers of cells
			tile_body.position = local_pos - Vector3(.5, 0, .25)
			
		 	
			#Add features
			
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
				feature.position = local_pos

func _ready() -> void:
	#world_tilemap.map = map
	#world_tilemap.map_seed = map_seed
	update_from_map()

func build_layout_from_map(new_map:WorldMap):
	#world_tilemap.map = new_map
	#world_tilemap.map_seed = map_seed
	#world_tilemap.rebuild_map()
	return
	
func _on_file_dialog_load_file_selected(path: String) -> void:
	var loaded_map = ResourceLoader.load(path)
	if loaded_map is WorldMap:
		map = loaded_map
		build_layout_from_map(map)
