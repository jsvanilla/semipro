extends Node2D


@export var tile_set:TileSet
@export var continent_builder:ContinentBuilder

@export var seed:int = 0
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func set_cell(pos:Vector2i, value:Vector2i, data:PackedFloat32Array):
	var index_texture_width = continent_builder.width
	
	var cell_idx = ((pos.x * index_texture_width) + pos.y) * 2
	data[cell_idx] = value.x
	data[cell_idx + 1] = value.y
	

func create_map_data()->PackedFloat32Array:
	var index_texture_width = continent_builder.width
	var index_texture_height = continent_builder.height
	
	var data:PackedFloat32Array
	data.resize(index_texture_width * index_texture_height * 2)
	
	for j in index_texture_height:
		for i in index_texture_width:
			set_cell(Vector2i(i, j), Vector2i(4, 2), data)

	set_cell(Vector2i(1, 2), Vector2i(0, 1), data)
	set_cell(Vector2i(2, 2), Vector2i(3, 0), data)
	return data

func map_quadrant(q:WorldMap.Quadrant, c00:WorldMapCell.Terrain, c10:WorldMapCell.Terrain, c01:WorldMapCell.Terrain, c11:WorldMapCell.Terrain):
	var c_home:WorldMapCell.Terrain
	if q == WorldMap.Quadrant.NW:
		c_home = c00
	elif q == WorldMap.Quadrant.NE:
		c_home = c10
	elif q == WorldMap.Quadrant.SW:
		c_home = c01
	elif q == WorldMap.Quadrant.SE:
		c_home = c11
		
	#if c_home == WorldMapCell.Terrain.LAND:
		#return Vector2i(1, 1)
	
	
	
	return Vector2i()
	pass

var border_tile_lookup = {
	BorderBuilder.BorderCellType.NONE: Vector2i(4, 2),
	BorderBuilder.BorderCellType.FILL: Vector2i(1, 1),
	BorderBuilder.BorderCellType.EDGE_N: Vector2i(1, 3),
	BorderBuilder.BorderCellType.EDGE_N_TURN_W: Vector2i(1, 3),
	BorderBuilder.BorderCellType.EDGE_N_TURN_E: Vector2i(1, 3),
	BorderBuilder.BorderCellType.EDGE_E: Vector2i(0, 1),
	BorderBuilder.BorderCellType.EDGE_E_TURN_N: Vector2i(0, 1),
	BorderBuilder.BorderCellType.EDGE_E_TURN_S: Vector2i(0, 1),
	BorderBuilder.BorderCellType.EDGE_W: Vector2i(3, 1),
	BorderBuilder.BorderCellType.EDGE_W_TURN_N: Vector2i(3, 1),
	BorderBuilder.BorderCellType.EDGE_W_TURN_S: Vector2i(3, 1),
	BorderBuilder.BorderCellType.EDGE_S: Vector2i(1, 0),
	BorderBuilder.BorderCellType.EDGE_S_TURN_W: Vector2i(1, 0),
	BorderBuilder.BorderCellType.EDGE_S_TURN_E: Vector2i(1, 0),
	
	BorderBuilder.BorderCellType.CONVEX_NW: Vector2i(3, 3),
	BorderBuilder.BorderCellType.CONVEX_NE: Vector2i(0, 3),
	BorderBuilder.BorderCellType.CONVEX_SW: Vector2i(3, 0),
	BorderBuilder.BorderCellType.CONVEX_SE: Vector2i(0, 0),
	BorderBuilder.BorderCellType.CONCAVE_NW: Vector2i(4, 0),
	BorderBuilder.BorderCellType.CONCAVE_NE: Vector2i(5, 0),
	BorderBuilder.BorderCellType.CONCAVE_SW: Vector2i(4, 1),
	BorderBuilder.BorderCellType.CONCAVE_SE: Vector2i(5, 1),
	}

var features_lookup:Dictionary = {
	#WorldMapCell.Terrain.HILL: [Vector2i(0, 1), Vector2i(1, 1)],
	#WorldMapCell.Terrain.MOUNTAIN: [Vector2i(0, 2)],
	}

var forest_coord = [Vector2i(0, 0)]

func build_base_layer(border_grid:Grid2D, layer:TileMapLayer):
	layer.clear()
	
	for j in border_grid.height:
		for i in border_grid.width:
			var tile:BorderBuilder.BorderCellType = border_grid.get_cell(i, j)
			var atlas_co:Vector2i
			if tile == BorderBuilder.BorderCellType.FILL:
				atlas_co = Vector2i(1, 1) + Vector2i(i % 2, j % 2)
			elif tile == BorderBuilder.BorderCellType.NONE:
				atlas_co = Vector2i(4, 2) + Vector2i(i % 2, j % 2)
			elif tile == BorderBuilder.BorderCellType.EDGE_N \
				|| tile == BorderBuilder.BorderCellType.EDGE_N_TURN_W \
				|| tile == BorderBuilder.BorderCellType.EDGE_N_TURN_E:
				atlas_co = Vector2i(1, 3) + Vector2i(i % 2, 0)
			elif tile == BorderBuilder.BorderCellType.EDGE_S \
				|| tile == BorderBuilder.BorderCellType.EDGE_S_TURN_W \
				|| tile == BorderBuilder.BorderCellType.EDGE_S_TURN_E:
				atlas_co = Vector2i(1, 0) + Vector2i(i % 2, 0)
			elif tile == BorderBuilder.BorderCellType.EDGE_W \
				|| tile == BorderBuilder.BorderCellType.EDGE_W_TURN_N \
				|| tile == BorderBuilder.BorderCellType.EDGE_W_TURN_S:
				atlas_co = Vector2i(3, 1) + Vector2i(0, j % 2)
			elif tile == BorderBuilder.BorderCellType.EDGE_E \
				|| tile == BorderBuilder.BorderCellType.EDGE_E_TURN_N \
				|| tile == BorderBuilder.BorderCellType.EDGE_E_TURN_S:
				atlas_co = Vector2i(0, 1) + Vector2i(0, j % 2)
			else:
				atlas_co = border_tile_lookup[tile]
			layer.set_cell(Vector2i(i, j), 0, atlas_co)
			

#func get_feature_coord(terrain:WorldMapCell.Terrain):
	#if terrain in features_lookup:
		#var feature_arr:Array = features_lookup[terrain]
		#var feature_co:Vector2i = feature_arr[Globals.rng.randi_range(0, feature_arr.size() - 1)]
		#return feature_co
	#return Vector2i.

func build_features_layer(map:WorldMap, layer:TileMapLayer):
	layer.clear()

	for j in map.grid.height:
		for i in map.grid.width:
			var tile:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			var tile_e:WorldMapCell = map.get_cell_v(Vector2i(i + 1, j))
			var tile_w:WorldMapCell = map.get_cell_v(Vector2i(i - 1, j))
			
			if tile_e:
				var terrain = tile.terrain
				if tile_e.height < tile.height:
					terrain = tile_e.terrain
				
	
	for j in map.grid.height:
		for i in map.grid.width:
			var tile:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			var tile_e:WorldMapCell = map.get_cell_v(Vector2i(i + 1, j))
			var tile_s:WorldMapCell = map.get_cell_v(Vector2i(i, j + 1))
			var tile_se:WorldMapCell = map.get_cell_v(Vector2i(i + 1, j + 1))
			
			var co:Vector2i = Vector2i(i + j * 2, (j * 2 - i))
			
			if tile.terrain in features_lookup:
				var feature_arr:Array = features_lookup[tile.terrain]
				var feature_co:Vector2i = feature_arr[Globals.rng.randi_range(0, feature_arr.size() - 1)]
				
				layer.set_cell(co, 0, feature_co)
				layer.set_cell(co + Vector2i(1, 1), 0, feature_co)

			if tile.forest:
				layer.set_cell(co, 0, forest_coord[0])
				layer.set_cell(co + Vector2i(1, 1), 0, forest_coord[0])
				
			if tile_e:
				var cells = [tile, tile_e]
				cells.sort_custom(func(a, b): return a.height < b.height )
				
				var terrain = cells[0].terrain
				var forest:bool = cells[0].forest
				#
				#if tile_e.height < tile.height:
					#terrain = tile_e.terrain
					#forest = tile.forest
					
				if terrain in features_lookup:
					var feature_arr:Array = features_lookup[terrain]
					var feature_co:Vector2i = feature_arr[Globals.rng.randi_range(0, feature_arr.size() - 1)]
					layer.set_cell(co + Vector2i(1, 0), 0, feature_co)

				#if forest && terrain == WorldMapCell.Terrain.LAND:
					#layer.set_cell(co + Vector2i(1, 0), 0, forest_coord[0])
				
				if tile_s && tile_se:
					cells = [tile, tile_e, tile_s, tile_se]
					cells.sort_custom(func(a, b): return a.height < b.height )
					
					terrain = cells[0].terrain
					forest = cells[0].forest
					
					if terrain in features_lookup:
						var feature_arr:Array = features_lookup[terrain]
						var feature_co:Vector2i = feature_arr[Globals.rng.randi_range(0, feature_arr.size() - 1)]
						layer.set_cell(co + Vector2i(2, 1), 0, feature_co)

					#if forest && terrain == WorldMapCell.Terrain.LAND:
						#layer.set_cell(co + Vector2i(2, 1), 0, forest_coord[0])
				
				#layer.set_cell(Vector2i(i, j * 2), 0, feature_co)
				#layer.set_cell(Vector2i(i, j * 2 + 1), 0, feature_co)
				
				
	


func _on_bn_generate_pressed() -> void:
	seed += 1
	continent_builder.noise.seed = seed
	continent_builder.low_freq_noise.seed = seed
	continent_builder.vegetation_noise.seed = seed
	
	var map:WorldMap = continent_builder.build_world_map()
	var ocean_id:int = map.get_terrain_id(%base_layer.tile_set, "Ocean")
	var land_id:int = map.get_terrain_id(%base_layer.tile_set, "Land")
	#map.find_tile(%TileMapLayer2.tile_set,
	
	map.print_terrain_types()
	map.print_plates()
	map.print_plate_pressure()
	
	
	var border_builder:BorderBuilder = BorderBuilder.new()
	border_builder.solid_test = func(cell:WorldMapCell): 
		return cell.terrain != WorldMapCell.Terrain.OCEAN if cell else false
#	border_builder.default_cell_type = WorldMapCell.Terrain.OCEAN
	border_builder.src_grid = map.grid
	
	var border:Grid2D = border_builder.build()
	build_base_layer(border, %base_layer)
	build_features_layer(map, %features_layer)
	
	pass

	
