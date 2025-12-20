extends Node3D
class_name TiledWorld3D


var map:WorldMap


func build_layout_from_map(map:WorldMap):
	var isoBuilder:IsoTileLayoutBuilder = IsoTileLayoutBuilder.new()
	isoBuilder.map = map
	isoBuilder.continent_layer = %continent
	isoBuilder.desert_layer = %desert
	isoBuilder.grass_layer = %grass
	isoBuilder.feature_layer = %features
	
	isoBuilder.rng = RandomNumberGenerator.new()
	isoBuilder.rng.seed = %spin_seed.value
	#isoBuilder.dump_tileset()
	isoBuilder.build()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_file_dialog_load_file_selected(path: String) -> void:
	var loaded_map = ResourceLoader.load(path)
	if loaded_map is WorldMap:
		map = loaded_map
		build_layout_from_map(map)
