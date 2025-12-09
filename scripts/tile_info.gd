@tool
extends Resource
class_name TileInfo

@export var terrain:WorldMapCell.Terrain
@export var feature:WorldMapCell.Feature
@export var vegetation:WorldMapCell.Vegetation

@export var blending:TileBlendInfo

#var is_nw:bool

#var is_border:bool
#var terrain_kernel:Array[WorldMapCell.Terrain]
#var kernel_size:Vector2i

var period:Vector2i = Vector2i.ONE
var phase_shift:Vector2i = Vector2i.ZERO
#var neighbor_terrain_type
