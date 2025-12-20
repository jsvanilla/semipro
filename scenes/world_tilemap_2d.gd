extends Node2D
class_name WorldTilemap2D

@onready var layer_continent:TileMapLayer = %continent
@onready var layer_desert:TileMapLayer = %desert
@onready var layer_grass:TileMapLayer = %grass
@onready var layer_features:TileMapLayer = %features

@export var map_seed:int
@export var map:WorldMap

var start_drag_pos:Vector2
var mouse_down_pos:Vector2
var dragging:bool = false
var zoom_base:float = 1.2


func rebuild_map():
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


#func dab_brush(coord:Vector2i):
	#if !map:
		#return
	#
	#var cell:WorldMapCell = map.get_cell_v(coord)
	#cell.terrain = paintbrush_info.terrain
	#cell.vegetation = paintbrush_info.vegetation
	#cell.feature = paintbrush_info.feature
	#cell.height = paintbrush_info.height
	#
	#build_layout_from_map(map)
	#pass
#
#func tool_paint(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#var e:InputEventMouseButton = event
#
		#
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if e.is_pressed():
				#start_drag_pos = global_position
				#mouse_down_pos = e.position
				#dragging = true
				#
				##event.position
				#var xform:Transform2D = layer_continent.global_transform
				#var local_pos = xform.affine_inverse() * event.global_position
				#
##				var grid_coord:Vector2i = %continent.local_to_map(event.position)
				#var grid_coord:Vector2i = layer_continent.local_to_map(local_pos)
				#dab_brush(grid_coord)
			#
			#else:
				#dragging = false
#
		#
	#elif event is InputEventMouseMotion:
		#if dragging:
			#var xform:Transform2D = layer_continent.global_transform
			#var local_pos = xform.affine_inverse() * event.global_position
			#
##				var grid_coord:Vector2i = %continent.local_to_map(event.position)
			#var grid_coord:Vector2i = layer_continent.local_to_map(local_pos)
			#dab_brush(grid_coord)
#
		#
#func tool_move(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#var e:InputEventMouseButton = event
		#
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if e.is_pressed():
				#start_drag_pos = global_position
				#mouse_down_pos = e.position
				#dragging = true
			#
			#else:
				#dragging = false
#
		#if e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#var view_size:Vector2 = %SubViewportContainer.size
			#var xform:Transform2D = transform
			#var pos:Vector2 = e.position
			#
			#xform = xform.translated(-pos)
			#xform = xform.scaled(Vector2.ONE / zoom_base)
			#xform = xform.translated(pos)
			#
			#transform = xform
			#
		#if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			#var view_size:Vector2 = %SubViewportContainer.size
			#var xform:Transform2D = transform
			#var pos:Vector2 = e.position
			#
			#xform = xform.translated(-pos)
			#xform = xform.scaled(Vector2.ONE * zoom_base)
			#xform = xform.translated(pos)
			#
			#transform = xform
			#
	#elif event is InputEventMouseMotion:
		#if dragging:
			#global_position = (event.position - mouse_down_pos) + start_drag_pos
