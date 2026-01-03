@tool
extends Node3D
class_name WorldTile

enum TileType { FULL, EMPTY, NS, WE, SE, SW, NE, NW, S, E, W, N, WSE, NES, NWS, WNE }

@onready var ground_material:ShaderMaterial = %MeshInstance3D.get_surface_override_material(0)

@export var tile_continent:TileType = TileType.EMPTY
@export var tile_grass:TileType = TileType.EMPTY
@export var tile_desert:TileType = TileType.EMPTY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ground_material.set_shader_parameter("cell_continent", tile_continent)
	ground_material.set_shader_parameter("cell_grass", tile_grass)
	ground_material.set_shader_parameter("cell_desert", tile_desert)
	pass
