@tool
extends Resource
class_name WorldMapCell

enum Terrain { OCEAN, DIRT, DESERT, GRASSLAND }
enum Feature { NONE, MOUNTAIN, HILL }
enum Vegetation { NONE, FOREST }

@export var terrain:Terrain
@export var vegetation:Vegetation
@export var feature:Feature

@export var height:float
@export var temperature:float
@export var moisture:float
@export var plate_id:int
@export var plate_pressure:float

@export var bridge:bool
@export var land:bool

func copy_cell(peer:WorldMapCell):
	terrain = peer.terrain
