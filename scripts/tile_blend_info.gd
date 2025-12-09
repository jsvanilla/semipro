@tool
extends Resource
class_name TileBlendInfo

enum NeighborBlendType { OTHER, SELF, ANY }

@export var blend_into_terrain:WorldMapCell.Terrain

@export var blend_W:NeighborBlendType
@export var blend_NW:NeighborBlendType
@export var blend_N:NeighborBlendType
@export var blend_NE:NeighborBlendType
@export var blend_E:NeighborBlendType
@export var blend_SE:NeighborBlendType
@export var blend_S:NeighborBlendType
@export var blend_SW:NeighborBlendType


#@export var terrain_type_nw:WorldMapCell.Terrain
#@export var terrain_type_ne:WorldMapCell.Terrain
#@export var terrain_type_sw:WorldMapCell.Terrain
#@export var terrain_type_se:WorldMapCell.Terrain
#
#@export var period:Vector2i = Vector2i.ONE
#@export var phase_shift:Vector2i = Vector2i.ZERO
