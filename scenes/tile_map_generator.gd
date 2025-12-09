extends Control
class_name TileMapGenerator

@export var continent_builder:ContinentBuilder = ContinentBuilder.new()
var map:WorldMap

@export var world_assembler:WorldAssemblerManifest = WorldAssemblerManifest.new()

enum EditTool { MOVE, PAINT }
@export var edit_tool:EditTool

@export var paintbrush_info:PaintBrushInfo


var start_drag_pos:Vector2
var mouse_down_pos:Vector2
var dragging:bool = false
var zoom_base:float = 1.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_from_continent_builder()
	
	var pmenu_file_popup:PopupMenu = %MenuButton_file.get_popup()
	pmenu_file_popup.id_pressed.connect(_on_file_id_pressed)
	
	paintbrush_info = PaintBrushInfo.new()
	%Paint.paintbrush_info = paintbrush_info
	
	%WorldAssembler.world_assembler = world_assembler
	pass # Replace with function body.

func update_from_continent_builder():
	%spin_width.value = continent_builder.width
	%spin_height.value = continent_builder.height
	%spin_scale_x.value = continent_builder.scale.x
	%spin_scale_y.value = continent_builder.scale.y
	%spin_warmth.value = continent_builder.warmth
	%spin_wetness.value = continent_builder.wetness
	%spin_land_fraction.value = continent_builder.land_fraction
	%spin_mountain_height.value = continent_builder.mountain_height
	%spin_hill_height.value = continent_builder.hill_height
	%spin_seed.value = continent_builder.rand_seed
	
	#Build continent
	_on_bn_generate_pressed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bn_generate_pressed() -> void:
	map = continent_builder.build_world_map()
	#map.print_terrain_types()
	build_layout_from_map(map)

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
	
	
	pass # Replace with function body.


func _on_spin_seed_value_changed(value: float) -> void:
	continent_builder.rand_seed = value

func _on_spin_width_value_changed(value: float) -> void:
	continent_builder.width = value


func _on_spin_height_value_changed(value: float) -> void:
	continent_builder.height = value

func dab_brush(coord:Vector2i):
	if !map:
		return
	
	var cell:WorldMapCell = map.get_cell_v(coord)
	cell.terrain = paintbrush_info.terrain
	cell.vegetation = paintbrush_info.vegetation
	cell.feature = paintbrush_info.feature
	cell.height = paintbrush_info.height
	
	build_layout_from_map(map)
	pass

func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if edit_tool == EditTool.MOVE:
		tool_move(event)
		return
	elif edit_tool == EditTool.PAINT:
		tool_paint(event)
		return
		pass
	
func tool_paint(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e:InputEventMouseButton = event

		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if e.is_pressed():
				start_drag_pos = %tilemaps.global_position
				mouse_down_pos = e.position
				dragging = true
				
				#event.position
				var xform:Transform2D = %continent.global_transform
				var local_pos = xform.affine_inverse() * event.global_position
				
#				var grid_coord:Vector2i = %continent.local_to_map(event.position)
				var grid_coord:Vector2i = %continent.local_to_map(local_pos)
				dab_brush(grid_coord)
			
			else:
				dragging = false

		
	elif event is InputEventMouseMotion:
		if dragging:
			var xform:Transform2D = %continent.global_transform
			var local_pos = xform.affine_inverse() * event.global_position
			
#				var grid_coord:Vector2i = %continent.local_to_map(event.position)
			var grid_coord:Vector2i = %continent.local_to_map(local_pos)
			dab_brush(grid_coord)

		
func tool_move(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e:InputEventMouseButton = event
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if e.is_pressed():
				start_drag_pos = %tilemaps.global_position
				mouse_down_pos = e.position
				dragging = true
			
			else:
				dragging = false

		if e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var view_size:Vector2 = %SubViewportContainer.size
			var xform:Transform2D = %tilemaps.transform
			var pos:Vector2 = e.position
			
			xform = xform.translated(-pos)
			xform = xform.scaled(Vector2.ONE / zoom_base)
			xform = xform.translated(pos)
			
			%tilemaps.transform = xform
			
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			var view_size:Vector2 = %SubViewportContainer.size
			var xform:Transform2D = %tilemaps.transform
			var pos:Vector2 = e.position
			
			xform = xform.translated(-pos)
			xform = xform.scaled(Vector2.ONE * zoom_base)
			xform = xform.translated(pos)
			
			%tilemaps.transform = xform
			
	elif event is InputEventMouseMotion:
		if dragging:
			%tilemaps.global_position = (event.position - mouse_down_pos) + start_drag_pos


func _on_spin_scale_x_value_changed(value: float) -> void:
	continent_builder.scale.x = value


func _on_spin_scale_y_value_changed(value: float) -> void:
	continent_builder.scale.y = value


func _on_spin_warmth_value_changed(value: float) -> void:
	continent_builder.warmth = value


func _on_spin_wetness_value_changed(value: float) -> void:
	continent_builder.wetness = value


func _on_spin_land_fraction_value_changed(value: float) -> void:
	continent_builder.land_fraction = value


func _on_spin_mountain_height_value_changed(value: float) -> void:
	continent_builder.mountain_height = value


func _on_spin_hill_height_value_changed(value: float) -> void:
	continent_builder.hill_height = value


func _on_bn_save_pressed() -> void:
	%FileDialog_save.show()


func _on_bn_load_pressed() -> void:
	%FileDialog_load.show()


func _on_file_dialog_save_file_selected(path: String) -> void:
	ResourceSaver.save(map, path)
	pass # Replace with function body.


func _on_file_dialog_load_file_selected(path: String) -> void:
	var loaded_map = ResourceLoader.load(path)
	if loaded_map is WorldMap:
		map = loaded_map
		build_layout_from_map(map)
	else:
		var dlg:AcceptDialog = AcceptDialog.new()
		dlg.dialog_text = "Selected file was not a WorldMap"
		dlg.dialog_autowrap = true
#		get_editor_interface().popup_dialog(dlg)
		dlg.popup_centered()
		
	pass # Replace with function body.


func _on_paint_edit_mode_changed(mode: TileMapGenerator.EditTool) -> void:
	edit_tool = mode
	pass # Replace with function body.


func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			%FileDialog_continent_save.show()
		1:
			%FileDialog_continent_load.show()
		2:
			%FileDialog_generator_save.show()
		3:
			%FileDialog_generator_load.show()
		
	pass # Replace with function body.


func _on_file_dialog_generator_save_file_selected(path: String) -> void:
	ResourceSaver.save(continent_builder, path)
	pass # Replace with function body.


func _on_file_dialog_generator_load_2_file_selected(path: String) -> void:
	var builder = ResourceLoader.load(path)
	if builder is ContinentBuilder:
		continent_builder = builder
		update_from_continent_builder()
	else:
		var dlg:AcceptDialog = AcceptDialog.new()
		dlg.dialog_text = "Selected file was not a ContinentBuilder"
		dlg.dialog_autowrap = true
#		get_editor_interface().popup_dialog(dlg)
		dlg.popup_centered()
		
	pass # Replace with function body.


func _on_world_assembler_generate_world() -> void:
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = world_assembler.seed
	
	var world_map:WorldMap = WorldMap.create(world_assembler.width, world_assembler.height)
	
	for path in world_assembler.generator_paths:
		var res:Resource = ResourceLoader.load(path)
		var sub_map:WorldMap
		
		if res is ContinentBuilder:
			#res.rng = RandomNumberGenerator.new()
			#res.rng.seed = rng.randi()
			res.rand_seed = rng.randi()
			sub_map = res.build_world_map()

		elif res is WorldMap:
			sub_map = res
	
		if sub_map.get_width() > world_map.get_width()\
			 || sub_map.get_height() > world_map.get_height():
			continue
		
		var offset:Vector2i = Vector2i(
			rng.randi_range(0, world_map.get_width() - sub_map.get_width()),
			rng.randi_range(0, world_map.get_height() - sub_map.get_height())
			)
		
		world_map.overlay_map(sub_map, offset)
		#for j in sub_map.get_height():
			#for i in sub_map.get_width():
				#pass
	
	var sub_map = continent_builder.build_world_map()
	
	build_layout_from_map(world_map)
	pass # Replace with function body.
