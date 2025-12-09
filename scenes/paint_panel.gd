extends VBoxContainer

signal edit_mode_changed(mode:TileMapGenerator.EditTool)

@export var paintbrush_info:PaintBrushInfo

func update_from_brush():
	%option_terrain.clear()
	for key in WorldMapCell.Terrain.keys():
		%option_terrain.add_item(key)
		
	%option_vegetation.clear()
	for key in WorldMapCell.Vegetation.keys():
		%option_vegetation.add_item(key)
		
	%option_feature.clear()
	for key in WorldMapCell.Feature.keys():
		%option_feature.add_item(key)
		
	if paintbrush_info:
		%option_terrain.select(paintbrush_info.terrain)
		%option_vegetation.select(paintbrush_info.vegetation)
		%option_feature.select(paintbrush_info.feature)
		%spin_height.value = paintbrush_info.height

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	paintbrush_info = PaintBrushInfo.new()
	update_from_brush()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bn_move_pressed() -> void:
	edit_mode_changed.emit(TileMapGenerator.EditTool.MOVE)
	pass # Replace with function body.


func _on_bn_paint_pressed() -> void:
	edit_mode_changed.emit(TileMapGenerator.EditTool.PAINT)
	pass # Replace with function body.


func _on_option_terrain_item_selected(index: int) -> void:
	paintbrush_info.terrain = index
	pass # Replace with function body.


func _on_option_vegetation_item_selected(index: int) -> void:
	paintbrush_info.vegetation = index
	pass # Replace with function body.


func _on_option_feature_item_selected(index: int) -> void:
	paintbrush_info.feature = index
	pass # Replace with function body.


func _on_spin_height_value_changed(value: float) -> void:
	paintbrush_info.height = value
	pass # Replace with function body.
