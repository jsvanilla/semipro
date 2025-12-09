@tool
extends Resource
class_name IsoTileLayoutBuilder

var continent_layer:TileMapLayer
var desert_layer:TileMapLayer
var grass_layer:TileMapLayer
var feature_layer:TileMapLayer
var map:WorldMap
var rng:RandomNumberGenerator

func is_blocked(coord:Vector2i, 
	test_terrain:WorldMapCell.Terrain,
	boundary_terrain:WorldMapCell.Terrain = WorldMapCell.Terrain.OCEAN)->bool:
	
	var cell:WorldMapCell = map.get_cell_v(coord)
	var terrain:WorldMapCell.Terrain = cell.terrain if cell else boundary_terrain
	return terrain >= test_terrain

func write_terrain_layer(layer:TileMapLayer, terrain_type:WorldMapCell.Terrain):
	layer.clear()
	
	for j in range(-1, map.grid.height + 1):
		for i in map.grid.width + 1:
			var coord:Vector2i = Vector2i(i, j)
			
			var t_w:bool
			var t_n:bool
			var t_e:bool
			var t_s:bool
			
			if j % 2 == 0:
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
			
			var tile_coord:Vector2i
			match mask:
				0b0000:
					tile_coord = Vector2i(1, 0)
				0b1000:
					tile_coord = Vector2i(2, 2)
				0b0100:
					tile_coord = Vector2i(3, 2)
				0b1100:
					tile_coord = Vector2i(3, 1)
				0b0010:
					tile_coord = Vector2i(1, 2)
				0b1010:
					tile_coord = Vector2i(3, 0)
				0b0110:
					tile_coord = Vector2i(2, 1)
				0b1110:
					tile_coord = Vector2i(3, 3)
				0b0001:
					tile_coord = Vector2i(0, 2)
				0b1001:
					tile_coord = Vector2i(1, 1)
				0b0101:
					tile_coord = Vector2i(2, 0)
				0b1101:
					tile_coord = Vector2i(2, 3)
				0b0011:
					tile_coord = Vector2i(0, 1)
				0b1011:
					tile_coord = Vector2i(0, 3)
				0b0111:
					tile_coord = Vector2i(1, 3)
				0b1111:
					tile_coord = Vector2i(0, 0)
			
			layer.set_cell(Vector2i(i, j), 0, tile_coord)
	pass

var feature_tile_lookup = {
	{"terrain": WorldMapCell.Terrain.GRASSLAND,
	"vegetation": WorldMapCell.Vegetation.FOREST} : [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	
	{"terrain": WorldMapCell.Terrain.DIRT,
	"vegetation": WorldMapCell.Vegetation.FOREST} : [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	
	{"terrain": WorldMapCell.Terrain.GRASSLAND,
	"feature": WorldMapCell.Feature.HILL} :[Vector2i(0, 1)],
	
	{"terrain": WorldMapCell.Terrain.DIRT,
	"feature": WorldMapCell.Feature.HILL} :[Vector2i(0, 1)],
	
	{"terrain": WorldMapCell.Terrain.GRASSLAND,
	"feature": WorldMapCell.Feature.MOUNTAIN} :[Vector2i(0, 2)],
	
	{"terrain": WorldMapCell.Terrain.DIRT,
	"feature": WorldMapCell.Feature.MOUNTAIN} :[Vector2i(0, 2)],
}

func get_matching_featutres(tile_set:TileSet, cell:WorldMapCell)->Array:
	for key in feature_tile_lookup.keys():
		var b0:bool = !("terrain" in key) || key["terrain"] == cell.terrain
		var b1:bool = !("feature" in key) || key["feature"] == cell.feature
		var b2:bool = !("vegetation" in key) || key["vegetation"] == cell.vegetation
		
		if b0 && b1 && b2:
			return feature_tile_lookup[key]
		
	return []

func build():
	write_terrain_layer(continent_layer, WorldMapCell.Terrain.DIRT)
	
	write_terrain_layer(desert_layer, WorldMapCell.Terrain.DESERT)
	write_terrain_layer(grass_layer, WorldMapCell.Terrain.GRASSLAND)

	feature_layer.clear()
	for j in range(-1, map.grid.height + 1):
		for i in map.grid.width + 1:
			var coord:Vector2i = Vector2i(i, j)
			var cell:WorldMapCell = map.get_cell_v(coord)
			
			if cell:
				var tile_coords:Array = get_matching_featutres(feature_layer.tile_set, cell)
				if tile_coords:
					var idx:int = rng.randi_range(0, tile_coords.size() - 1)
					#print("tile_coords[idx] ", Vector2i(i, j), " -> ", tile_coords[idx])
					feature_layer.set_cell(Vector2i(i, j), 0, tile_coords[idx])

	
