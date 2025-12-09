extends Resource
class_name ContinentBuilder

@export var noise:FastNoiseLite
@export var low_freq_noise:FastNoiseLite
#@export var vegetation_noise:FastNoiseLite
@export var temperature_noise:FastNoiseLite
@export var moisture_noise:FastNoiseLite
@export var width:int = 40
@export var height:int = 80
@export var scale:Vector2 = Vector2(1, 1)
@export var terrain_height_scalar:float = 1
@export var warmth:float = .1
@export var wetness:float = 0
@export var land_fraction:float = .3
@export var distortion_amount:float = 1
@export var mountain_height:float = .55
@export var hill_height:float = .35
@export var rand_seed:int = 0

@export var biome_table:Texture2D

@export var num_plates:int = 10
@export var plate_pressure_radius:int = 3

@export var use_circle_mask:bool = true
@export var circle_mask_radius_inner:float = .6
@export var circle_mask_radius_outer:float = 1
@export var circle_mask_value_min:float = -1
@export var circle_mask_value_max:float = 0


var rng:RandomNumberGenerator
var plate_centers:Array[Vector2]
var plate_velocities:Array[Vector2]

enum Biome { SNOW, TUNDRA, PLAINS, GRASSLAND, DESERT, GRASS_FOREST, PLAINS_FOREST, TUNDRA_FOREST }

var biome_map:Dictionary = {
	Color.html("ffffff"): Biome.SNOW,
	Color.html("555555"): Biome.TUNDRA,
	Color.html("aa0000"): Biome.PLAINS,
	Color.html("00aa00"): Biome.GRASSLAND,
	Color.html("ffff55"): Biome.DESERT,
	Color.html("55ff55"): Biome.GRASS_FOREST,
	Color.html("ff5555"): Biome.PLAINS_FOREST,
	Color.html("aaaaaa"): Biome.TUNDRA_FOREST,
	}


func create_plate_boundaries():
	#Just a Voronoi tessellation
	#Globals.rng
	for i in num_plates:
		plate_centers.append(Vector2(rng.randf() * width, rng.randf() * height))
		plate_velocities.append(Vector2(rng.randf(), rng.randf()).normalized())
		
	pass

func get_plate_id(cell_pos:Vector2):
	var best_id:int = -1
	var best_dist:float = INF
	
	for i in range(plate_centers.size()):
		var dist:float = cell_pos.distance_to(plate_centers[i])
		if dist < best_dist:
			best_dist = dist
			best_id = i
	
	return best_id
		
func get_plate_pressure(map:WorldMap, cell_pos:Vector2i, radius:int)->float:
	var cur_cell:WorldMapCell = map.get_cell_v(cell_pos)
	var vel_0:Vector2 = plate_velocities[cur_cell.plate_id]
	
	var count:int = 0
	var pressure:float = 0
	for j in range(-radius, radius + 1):
		for i in range(-radius, radius + 1):
			var offset:Vector2i = Vector2i(i, j)
			var cell:WorldMapCell = map.get_cell_v(offset + cell_pos)
			if !cell:
				continue
			
			if cell.plate_id != cur_cell.plate_id:
				pass
			var vel_1:Vector2 = plate_velocities[cell.plate_id]
			var relative_vel:Vector2 = vel_1 - vel_0
			var normal:Vector2 = Vector2(offset).normalized()
			pressure += normal.dot(relative_vel)
			count += 1
	
	return pressure / count

func get_circle_mask_value(i:float, j:float):
	var pos:Vector2 = Vector2(i, j) * 2 - Vector2.ONE
	
	var margin:float = (pos.length() - circle_mask_radius_inner) / (circle_mask_radius_outer - circle_mask_radius_inner)
	return 1 - clamp(margin, 0, 1)

func build_world_map()->WorldMap:
	rng = RandomNumberGenerator.new()
	rng.seed = rand_seed
	
	noise.seed = rng.randi()
	low_freq_noise.seed = rng.randi()
	temperature_noise.seed = rng.randi()
	moisture_noise.seed = rng.randi()
	
	var distort_x_noise:FastNoiseLite = low_freq_noise.duplicate()
	distort_x_noise.seed = rng.randi()
	var distort_y_noise:FastNoiseLite = low_freq_noise.duplicate()
	distort_y_noise.seed = rng.randi()
	
	var biome_img:Image = biome_table.get_image()
	
	var map:WorldMap = WorldMap.create(width, height)

	for j in height:
		for i in width:
			var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			
			var sample_pos:Vector2 = Vector2(i, j) * scale
			sample_pos += distortion_amount * Vector2(distort_x_noise.get_noise_2dv(sample_pos), distort_y_noise.get_noise_2dv(sample_pos))
			var lo_freq:float = low_freq_noise.get_noise_2dv(sample_pos)
			#var distortion = low_freq_noise.get_noise_3d(
			
			var land_height:float = lo_freq * terrain_height_scalar

			if use_circle_mask:
				var weight:float = get_circle_mask_value(i / float(width - 1), j / float(height - 1))
				#var mask_height = lerp(circle_mask_value_min, circle_mask_value_max, weight)
				#land_height += mask_height
#				land_height *= weight
				land_height = (land_height + 1) / 2
				land_height *= weight
				land_height = (land_height * 2) - 1
				
			cell.height = land_height

	#Get histogram of height values
#	var height_values:Array[float]
	var cells_flat:Array = map.grid.tiles.duplicate()
	cells_flat.sort_custom(func(a, b): return a.height < b.height )
	
	var cutoff_index:int = clamp((1 - land_fraction) * cells_flat.size(), 0, cells_flat.size() - 1)
	for i in range(0, cutoff_index):
		cells_flat[i].terrain = WorldMapCell.Terrain.OCEAN
		cells_flat[i].land = false
		
	for i in range(cutoff_index + 1, cells_flat.size()):
		cells_flat[i].terrain = WorldMapCell.Terrain.GRASSLAND
		cells_flat[i].land = true
		

	for j in height:
		for i in width:
			var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			if !cell.land:
				continue

			var hi_freq:float = noise.get_noise_2dv(Vector2(i, j) * scale)
			var moisture_freq:float = moisture_noise.get_noise_2dv(Vector2(i, j) * scale)
			var temp_freq:float = temperature_noise.get_noise_2dv(Vector2(i, j) * scale)

			if hi_freq > mountain_height:
				cell.feature = WorldMapCell.Feature.MOUNTAIN
			elif hi_freq > hill_height:
				cell.feature = WorldMapCell.Feature.HILL

			var biome_lookup:Vector2i = Vector2i(
				clamp(((temp_freq + 1) / 2 + warmth) * biome_table.get_width(), 0, biome_table.get_width() - 1),
				clamp(((temp_freq + 1) / 2 - wetness) * biome_table.get_height(), 0, biome_table.get_height() - 1)
			)

			var biome_pix:Color = biome_img.get_pixelv(biome_lookup)
			if biome_pix in biome_map:
				var biome:Biome = biome_map[biome_pix]
				
				match biome:
					Biome.DESERT:
						cell.terrain = WorldMapCell.Terrain.DESERT
					Biome.GRASSLAND:
						cell.terrain = WorldMapCell.Terrain.GRASSLAND
					Biome.GRASS_FOREST:
						cell.terrain = WorldMapCell.Terrain.GRASSLAND
						cell.vegetation = WorldMapCell.Vegetation.FOREST
					Biome.PLAINS:
						cell.terrain = WorldMapCell.Terrain.DIRT
					Biome.PLAINS_FOREST:
						cell.terrain = WorldMapCell.Terrain.DIRT
						cell.vegetation = WorldMapCell.Vegetation.FOREST
					Biome.TUNDRA:
						cell.terrain = WorldMapCell.Terrain.DIRT
					Biome.TUNDRA_FOREST:
						cell.terrain = WorldMapCell.Terrain.DIRT
						cell.vegetation = WorldMapCell.Vegetation.FOREST
					Biome.SNOW:
						cell.terrain = WorldMapCell.Terrain.DIRT
	
	"""
	for j in height:
		for i in width:
			var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			
			var hi_freq:float = noise.get_noise_2dv(Vector2(i, j) * scale)
			var lo_freq:float = low_freq_noise.get_noise_2dv(Vector2(i, j) * scale)
#			var veg_freq:float = vegetation_noise.get_noise_2dv(Vector2(i, j) * scale)
			var moisture_freq:float = moisture_noise.get_noise_2dv(Vector2(i, j) * scale)
			var temp_freq:float = temperature_noise.get_noise_2dv(Vector2(i, j) * scale)
			var land_height:float = lo_freq + hi_freq

			if use_circle_mask:
				var weight:float = get_circle_mask_value(i / float(width - 1), j / float(height - 1))
				var mask_height = lerp(circle_mask_value_min, circle_mask_value_max, weight)
				land_height += mask_height
			
			cell.height = land_height
			cell.temperature = temp_freq
			cell.moisture = moisture_freq
			
			if land_height > -.0:
				cell.terrain = WorldMapCell.Terrain.GRASSLAND
			else:
				cell.terrain = WorldMapCell.Terrain.OCEAN
				
			if hi_freq > .55:
				cell.feature = WorldMapCell.Feature.MOUNTAIN
			elif hi_freq > .35:
				cell.feature = WorldMapCell.Feature.HILL
			
			var biome_lookup:Vector2i = Vector2i(
				((temp_freq + 1) / 2 + warmth) * biome_table.get_width(),
				((temp_freq + 1) / 2 - wetness) * biome_table.get_height()
			)
			
			
			if cell.terrain == WorldMapCell.Terrain.GRASSLAND:
				var biome_pix:Color = biome_img.get_pixelv(biome_lookup)
				if biome_pix in biome_map:
					var biome:Biome = biome_map[biome_pix]
					
					match biome:
						Biome.DESERT:
							cell.terrain = WorldMapCell.Terrain.DESERT
						Biome.GRASSLAND:
							cell.terrain = WorldMapCell.Terrain.GRASSLAND
						Biome.GRASS_FOREST:
							cell.terrain = WorldMapCell.Terrain.GRASSLAND
							cell.vegetation = WorldMapCell.Vegetation.FOREST
						Biome.PLAINS:
							cell.terrain = WorldMapCell.Terrain.DIRT
						Biome.PLAINS_FOREST:
							cell.terrain = WorldMapCell.Terrain.DIRT
							cell.vegetation = WorldMapCell.Vegetation.FOREST
						Biome.TUNDRA:
							cell.terrain = WorldMapCell.Terrain.DIRT
						Biome.TUNDRA_FOREST:
							cell.terrain = WorldMapCell.Terrain.DIRT
							cell.vegetation = WorldMapCell.Vegetation.FOREST
						Biome.SNOW:
							cell.terrain = WorldMapCell.Terrain.DIRT
						
"""						
					
	
	
	create_plate_boundaries()
	
	for j in height:
		for i in width:
			var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			
			cell.plate_id = get_plate_id(Vector2(i, j))

	var pressure_max:float = INF
	var pressure_min:float = INF
	
	for j in height:
		for i in width:
			var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			cell.plate_pressure = get_plate_pressure(map, Vector2i(i, j), plate_pressure_radius)
			
			if pressure_max == INF || cell.plate_pressure > pressure_max:
				pressure_max = cell.plate_pressure
			if pressure_min == INF || cell.plate_pressure < pressure_min:
				pressure_min = cell.plate_pressure
	
	##Normalize pressure
	#for j in height:
		#for i in width:
			#var cell:WorldMapCell = map.get_cell_v(Vector2i(i, j))
			#cell.plate_pressure = (cell.plate_pressure - pressure_min) / (pressure_max - pressure_min)
	
	return map
