extends Node3D

var index_texture_width:int
var index_texture_height:int
var index_texture:ImageTexture

@export var tile_set:TileSet
@export var continent_builder:ContinentBuilder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	index_texture_width = 4
	index_texture_height = 4
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_cell(pos:Vector2i, value:Vector2i, data:PackedFloat32Array):
	var cell_idx = ((pos.x * index_texture_width) + pos.y) * 2
	data[cell_idx] = value.x
	data[cell_idx + 1] = value.y
	

func create_map_data()->PackedFloat32Array:
	var data:PackedFloat32Array
	data.resize(index_texture_width * index_texture_height * 2)
	
	for j in index_texture_height:
		for i in index_texture_width:
			set_cell(Vector2i(i, j), Vector2i(4, 2), data)

	set_cell(Vector2i(1, 2), Vector2i(0, 1), data)
	set_cell(Vector2i(2, 2), Vector2i(3, 0), data)
	return data

func _on_button_pressed() -> void:
	var map:WorldMap = continent_builder.build_world_map()
	var data:PackedFloat32Array = map.generate_tile_map_indices(tile_set)
	var img = Image.create_from_data(map.width, map.height, false, Image.FORMAT_RGF, data.to_byte_array())

	var index_texture = ImageTexture.create_from_image(img)
	
	var mat:ShaderMaterial = %world_plane.material_override
	mat.set_shader_parameter("index_map", index_texture)
	mat.set_shader_parameter("index_map_width", map.width)
	mat.set_shader_parameter("index_map_height", map.height)
	
	############################
	
	#Using floats because unsigned bytes do not work in Godot in version 4.3
	#https://github.com/godotengine/godot/issues/57841
	
	#var data:PackedFloat32Array = create_map_data()
	
	#Image.FORMAT_RG
#	var img = Image.create_from_data(index_texture_width, index_texture_height, false, Image.FORMAT_RGF, data.to_byte_array())
	
	#index_texture = ImageTexture.create_from_image(img)
	#
	#
	#var mat:ShaderMaterial = %world_plane.material_override
	#mat.set_shader_parameter("index_map", index_texture)
	#mat.set_shader_parameter("index_map_width", index_texture_height)
	#mat.set_shader_parameter("index_map_height", index_texture_width)
	
	pass # Replace with function body.
