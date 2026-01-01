@tool
extends Node2D
class_name WorldTilemap2D

@onready var layer_continent:TileMapLayer = %continent
@onready var layer_desert:TileMapLayer = %desert
@onready var layer_grass:TileMapLayer = %grass
@onready var layer_features:TileMapLayer = %features

@export var map_seed:int
@export var map:WorldMap:
	set(v):
		if v == map:
			return
		map = v
		
		rebuild_map()

var start_drag_pos:Vector2
var mouse_down_pos:Vector2
var dragging:bool = false
var zoom_base:float = 1.2

func rebuild_map():
	if !is_node_ready():
		return
	
	var isoBuilder:IsoTileLayoutBuilder = IsoTileLayoutBuilder.new()
	isoBuilder.map = map
	isoBuilder.continent_layer = layer_continent
	isoBuilder.desert_layer = layer_desert
	isoBuilder.grass_layer = layer_grass
	isoBuilder.feature_layer = layer_features
	
	isoBuilder.rng = RandomNumberGenerator.new()
	isoBuilder.rng.seed = map_seed
	#isoBuilder.dump_tileset()
	isoBuilder.build()

func _ready() -> void:
	rebuild_map()
