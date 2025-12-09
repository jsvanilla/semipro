@tool
extends Resource
class_name WorldMap

#var tiles:Array[WorldMapCell]
#var width:int
#var height:int
@export var grid:Grid2D
	
enum Quadrant { NW, NE, SW, SE }

func _init(_width:int = 0, _height:int = 0):
	grid = Grid2D.new(_width, _height)
	
	for j in _height:
		for i in _width:
			grid.set_cell(i, j, WorldMapCell.new())

static func create(width:int = 0, height:int = 0)->WorldMap:
	return WorldMap.new(width, height)

func get_width()->int:
	return grid.width

func get_height()->int:
	return grid.height

func get_cell_v(coord:Vector2i)->WorldMapCell:
	return grid.get_cell_v(coord)
	
	#var ts = tile_set.terrain_sets[0]

func get_terrain_at_pos(pos:Vector2i, default:WorldMapCell.Terrain)->WorldMapCell.Terrain:
	var cell:WorldMapCell = grid.get_cell_v(pos)
	if !cell:
		return default
	return cell.terrain
	
#var ocean_land_lookup:Dictionary = {
	#0b1: 0
	#}

func get_terrain_id(tile_set:TileSet, name:String)->int:
	for i in tile_set.get_terrain_sets_count():
		for j in tile_set.get_terrains_count(i):
			var ter_name = tile_set.get_terrain_name(i, j)
			if ter_name == name:
				return j
				
			pass
			
	return -1


## coord - cell to calculate border cell for
## quad - quadrant of cell to calculate
## ref_type - cell terrain type that is having a border added.  Border will be built where neighbor cell has differnt type
## return - type of border
func get_border_type(coord:Vector2i, quad:Quadrant, ref_type:WorldMapCell.Terrain):
	var quad_offset:Vector2i
	match quad:
		Quadrant.NW:
			quad_offset = Vector2i(-1, -1)
		Quadrant.NE:
			quad_offset = Vector2i(0, -1)
		Quadrant.SW:
			quad_offset = Vector2i(-1, 0)
		Quadrant.SE:
			quad_offset = Vector2i(0, 0)
	
	var cell_nw:WorldMapCell = grid.get_cell_v(coord + quad_offset)
	var cell_ne:WorldMapCell = grid.get_cell_v(coord + Vector2i(1, 0) + quad_offset)
	var cell_sw:WorldMapCell = grid.get_cell_v(coord + Vector2i(0, 1) + quad_offset)
	var cell_se:WorldMapCell = grid.get_cell_v(coord + Vector2i(1, 1) + quad_offset)
	
	var mask:int = (0b1 if cell_nw && cell_nw.terrain == ref_type else 0) \
		| (0b10 if cell_ne && cell_ne.terrain == ref_type else 0) \
		| (0b100 if cell_sw && cell_sw.terrain == ref_type else 0) \
		| (0b1000 if cell_se && cell_se.terrain == ref_type else 0)
	
	return mask
	
func get_corner_tiles(coord:Vector2i, quad:Quadrant)->Array:
	var quad_offset:Vector2i
	match quad:
		Quadrant.NW:
			quad_offset = Vector2i(-1, -1)
		Quadrant.NE:
			quad_offset = Vector2i(0, -1)
		Quadrant.SW:
			quad_offset = Vector2i(-1, 0)
		Quadrant.SE:
			quad_offset = Vector2i(0, 0)
	
	var cell_nw:WorldMapCell = grid.get_cell_v(coord + quad_offset)
	var cell_ne:WorldMapCell = grid.get_cell_v(coord + Vector2i(1, 0) + quad_offset)
	var cell_sw:WorldMapCell = grid.get_cell_v(coord + Vector2i(0, 1) + quad_offset)
	var cell_se:WorldMapCell = grid.get_cell_v(coord + Vector2i(1, 1) + quad_offset)
	
	return [cell_nw.terrain, cell_ne.terrain, cell_sw.terrain, cell_se.terrain]

func find_tile(tile_set:TileSet, mask:int, terrain_id_0:int, terrain_id_1:int)->Vector2i:
	var target_nw:int = terrain_id_1 if mask & 0b1 else terrain_id_0
	var target_ne:int = terrain_id_1 if mask & 0b10 else terrain_id_0
	var target_sw:int = terrain_id_1 if mask & 0b100 else terrain_id_0
	var target_se:int = terrain_id_1 if mask & 0b1000 else terrain_id_0
	
	for source_id in tile_set.get_source_count(): 
		if not tile_set.get_source(source_id) is TileSetAtlasSource: 
			continue 
			
		var source:TileSetAtlasSource = tile_set.get_source(source_id) 
		for tile_index in source.get_tiles_count(): 
			var coords:Vector2i = source.get_tile_id(tile_index) 
			var tile_data:TileData = source.get_tile_data(coords, 0)
			#tile_data.get_custom_data("")
			var t_nw:int = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER)
			var t_ne:int = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER)
			var t_sw:int = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER)
			var t_se:int = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)
			
			if target_nw == t_nw && target_ne == t_ne && target_sw == t_sw && target_se == t_se:
				return coords
				pass
			
			pass
			
	return Vector2i.MAX


func parse_quadrants(out_of_bounds_type:WorldMapCell.Terrain, tile_lookup:Callable)->Grid2D:
	var result:Grid2D = Grid2D.create(grid.width * 2, grid.height * 2)
	
	for src_j in grid.height:
		for src_i in grid.width:
			var src_coord = Vector2i(src_i, src_j)

			var c00:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(-1, -1), out_of_bounds_type)
			var c10:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(0, -1), out_of_bounds_type)
			var c20:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(1, -1), out_of_bounds_type)
			var c01:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(-1, 0), out_of_bounds_type)
			var c11:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(0, 0), out_of_bounds_type)
			var c21:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(1, 0), out_of_bounds_type)
			var c02:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(-1, 1), out_of_bounds_type)
			var c12:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(0, 1), out_of_bounds_type)
			var c22:WorldMapCell.Terrain = get_terrain_at_pos(src_coord + Vector2(1, 1), out_of_bounds_type)
			
			result.set_cell(src_i * 2, src_j * 2, tile_lookup.call(Quadrant.NW, c00, c10, c01, c11))
			result.set_cell(src_i * 2 + 1, src_j * 2, tile_lookup.call(Quadrant.NE, c10, c20, c11, c21))
			result.set_cell(src_i * 2, src_j * 2 + 1, tile_lookup.call(Quadrant.SW, c01, c11, c02, c12))
			result.set_cell(src_i * 2 + 1, src_j * 2 + 1, tile_lookup.call(Quadrant.SE, c11, c21, c12, c22))
				
	return result
	
func print_terrain_types():
	for src_j in grid.height:
		var s:String = ""
		for src_i in grid.width:
			var terrain = grid.get_cell(src_i, src_j).terrain
			s += ("." if terrain == 0 else str(terrain)) + " "
		print(s)

func print_plates():
	for src_j in grid.height:
		var s:String = ""
		for src_i in grid.width:
			var plate_id = grid.get_cell(src_i, src_j).plate_id
			s += str(plate_id) + " "
		print(s)

func print_plate_pressure():
	for src_j in grid.height:
		var s:String = ""
		for src_i in grid.width:
			var pressure = grid.get_cell(src_i, src_j).plate_pressure
			s += " %.01f" % [pressure]
		print(s)

func is_open_ocean(pos:Vector2i)->bool:
	for j in range(-1, 2):
		for i in range(-1, 2):
			var cell:WorldMapCell = get_cell_v(pos + Vector2i(i, j))
			if !cell:
				continue
			
			if cell.terrain != WorldMapCell.Terrain.OCEAN:
				return false
	return true

func overlay_map(map:WorldMap, offset:Vector2i):
	var mask:PackedByteArray
	mask.resize(get_width() * get_height())
	mask.fill(true)
	
	for j in get_height():
		for i in get_width():
			if !is_open_ocean(Vector2i(i, j)):
				mask[i + j * get_width()] = false
	
	
	for j in map.get_height():
		for i in map.get_width():
			var src_coord:Vector2i = Vector2i(i, j)
			var dst_coord = src_coord + offset
			
			if !mask[dst_coord.x + dst_coord.y * get_width()]:
				continue
			
			var src_cell:WorldMapCell = map.get_cell_v(src_coord)
			if src_cell.terrain == WorldMapCell.Terrain.OCEAN:
				continue
			
			
			var dest_cell:WorldMapCell = get_cell_v(src_coord + offset)
			if  dest_cell:
				dest_cell.terrain = src_cell.terrain
				dest_cell.vegetation = src_cell.vegetation
				dest_cell.feature = src_cell.feature
				dest_cell.height = src_cell.height
				dest_cell.land = src_cell.land
			
			
	pass
	
